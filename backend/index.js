require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { getDb, saveDb } = require('./db');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Health Check Route
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Recharge API is running'
  });
});

// Middleware: Verify x-app-token header
const verifyAppToken = (req, res, next) => {
  const appToken = req.headers['x-app-token'];
  if (!appToken || appToken !== process.env.APP_TOKEN) {
    return res.status(401).json({ error: 'Unauthorized: Invalid or missing App Token' });
  }
  next();
};

// Middleware: Verify JWT token
const verifyUserToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized: Token required' });
  }
  jwt.verify(token, process.env.JWT_SECRET, (err, user) => {
    if (err) {
      return res.status(403).json({ error: 'Forbidden: Invalid token' });
    }
    req.user = user;
    next();
  });
};

// --- AUTH ROUTES ---

// Register User
app.post('/api/auth/register', verifyAppToken, (req, res) => {
  const { fullName, email, mobileNumber, password } = req.body;
  if (!fullName || !email || !mobileNumber || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const db = getDb();
  const existingUser = db.users.find(u => u.email.toLowerCase() === email.toLowerCase());
  if (existingUser) {
    return res.status(400).json({ error: 'Email already registered' });
  }

  const salt = bcrypt.genSaltSync(10);
  const passwordHash = bcrypt.hashSync(password, salt);

  const newUser = {
    id: Date.now(),
    fullName,
    email: email.toLowerCase(),
    mobileNumber,
    passwordHash,
    walletBalance: 0,
    status: 'ACTIVE',
    createdAt: new Date().toISOString()
  };

  db.users.push(newUser);
  saveDb(db);

  res.status(201).json({ message: 'User registered successfully' });
});

// Login User
app.post('/api/auth/login', verifyAppToken, (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const db = getDb();
  const user = db.users.find(u => u.email.toLowerCase() === email.toLowerCase());
  if (!user) {
    return res.status(400).json({ error: 'Invalid credentials' });
  }

  const isMatch = bcrypt.compareSync(password, user.passwordHash);
  if (!isMatch) {
    return res.status(400).json({ error: 'Invalid credentials' });
  }

  // Sign JWT
  const token = jwt.sign(
    { id: user.id, email: user.email, role: 'user' },
    process.env.JWT_SECRET,
    { expiresIn: '30d' }
  );

  res.json({
    token,
    user: {
      id: user.id,
      fullName: user.fullName,
      email: user.email,
      mobileNumber: user.mobileNumber,
      walletBalance: user.walletBalance,
      status: user.status
    }
  });
});

// Get User Profile (authenticated via JWT)
app.get('/api/user/profile', verifyAppToken, verifyUserToken, (req, res) => {
  const db = getDb();
  const user = db.users.find(u => u.id === req.user.id);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  res.json({
    id: user.id,
    fullName: user.fullName,
    email: user.email,
    mobileNumber: user.mobileNumber,
    walletBalance: user.walletBalance,
    status: user.status
  });
});

// --- ADMIN ROUTES ---

// Admin Login
app.post('/api/admin/login', verifyAppToken, (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  const db = getDb();
  const admin = db.admin;
  if (admin.email.toLowerCase() !== email.toLowerCase()) {
    return res.status(400).json({ error: 'Invalid admin credentials' });
  }

  const isMatch = bcrypt.compareSync(password, admin.passwordHash);
  if (!isMatch) {
    return res.status(400).json({ error: 'Invalid admin credentials' });
  }

  // Sign Admin JWT
  const token = jwt.sign(
    { email: admin.email, role: 'admin' },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );

  res.json({ token, email: admin.email });
});

// Change Admin Password
app.post('/api/admin/change-password', verifyAppToken, (req, res) => {
  // Simple check for authorization header
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err || decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Old and new passwords are required' });
    }

    const db = getDb();
    const isMatch = bcrypt.compareSync(oldPassword, db.admin.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Incorrect old password' });
    }

    const salt = bcrypt.genSaltSync(10);
    db.admin.passwordHash = bcrypt.hashSync(newPassword, salt);
    saveDb(db);

    res.json({ message: 'Password updated successfully' });
  });
});

// Admin Dashboard stats & users list
app.get('/api/admin/dashboard', verifyAppToken, (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err || decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const db = getDb();
    // Return counts and user list (excluding hashes)
    const usersList = db.users.map(u => ({
      id: u.id,
      fullName: u.fullName,
      email: u.email,
      mobileNumber: u.mobileNumber,
      walletBalance: u.walletBalance,
      status: u.status,
      createdAt: u.createdAt
    }));

    res.json({
      stats: {
        totalUsers: db.users.length,
        totalWalletBalance: db.users.reduce((acc, u) => acc + (u.walletBalance || 0), 0),
        totalTransactions: db.transactions.length
      },
      users: usersList,
      transactions: db.transactions
    });
  });
});

// Listen on all interfaces
app.listen(PORT, '0.0.0.0', () => {
  console.log(`Server running on port ${PORT}`);
});
