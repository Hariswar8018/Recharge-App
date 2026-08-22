require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const { query, transaction, initDb } = require('./db');
const { initCache, getCache, setCache, invalidateCache } = require('./cache');

const app = express();
console.log("LOADED BACKEND INDEX.JS");
console.log("FILE:", __filename);
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
  jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Forbidden: Invalid token' });
    }
    req.user = decoded;
    next();
  });
};

// --- USER AUTHENTICATION ROUTES ---

// Register User
app.post('/api/auth/register', verifyAppToken, async (req, res) => {
  const { fullName, email, mobileNumber, password } = req.body;
  if (!fullName || !email || !mobileNumber || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const existing = await query('SELECT id FROM users WHERE email = ?', [email.toLowerCase()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync(password, salt);

    await query(
      'INSERT INTO users (fullName, email, mobileNumber, passwordHash, fund_wallet_balance, main_wallet_balance) VALUES (?, ?, ?, ?, 0.00, 0.00)',
      [fullName, email.toLowerCase(), mobileNumber, passwordHash]
    );

    // Invalidate cached dashboard metrics
    await invalidateCache('admin_stats');

    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred during registration' });
  }
});

// Login User
app.post('/api/auth/login', verifyAppToken, async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const users = await query('SELECT * FROM users WHERE email = ? AND role = "user"', [email.toLowerCase()]);
    if (users.length === 0) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    const isMatch = bcrypt.compareSync(password, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

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
        fund_wallet_balance: user.fund_wallet_balance,
        main_wallet_balance: user.main_wallet_balance,
        status: user.status
      }
    });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred during login' });
  }
});

// Get User Profile (JWT authenticated)
app.get('/api/user/profile', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    // Cache profile details for 5 seconds to reduce direct db queries on high frequencies
    const cacheKey = `user_profile_${req.user.id}`;
    const cachedProfile = await getCache(cacheKey);
    if (cachedProfile) {
      return res.json(cachedProfile);
    }

    const users = await query(
      'SELECT id, fullName, email, mobileNumber, fund_wallet_balance, main_wallet_balance, status FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    await setCache(cacheKey, user, 5); // cache for 5 seconds
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// --- USER WALLET FLOW & FUND REQUEST ENDPOINTS ---

// User creates fund request
app.post('/api/fund/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount } = req.body;
  if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
    return res.status(400).json({ error: 'Invalid request amount' });
  }

  try {
    await query('INSERT INTO fund_requests (user_id, amount, status) VALUES (?, ?, "PENDING")', [
      req.user.id,
      parseFloat(amount)
    ]);
    res.status(201).json({ message: 'Fund deposit request submitted successfully for approval' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to record fund request' });
  }
});

// User lists their own fund request history
app.get('/api/fund/requests', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const requests = await query(
      'SELECT id, amount, status, createdAt FROM fund_requests WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load request history' });
  }
});

// User lists their own transactions
app.get('/api/user/transactions', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const txns = await query(
      'SELECT id, wallet_type, amount, type, date, status FROM transactions WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(txns);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load transactions list' });
  }
});

// Mock Razorpay payment simulation callback to update wallets on successful Sandbox payments
app.post('/api/payment/razorpay-sandbox', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, serviceType, walletType } = req.body;
  if (!amount || !serviceType || !walletType) {
    return res.status(400).json({ error: 'Missing payment metadata parameters' });
  }

  try {
    // Process inside a SQL transaction
    await transaction(async (conn) => {
      const balanceField = walletType === 'FUND' ? 'fund_wallet_balance' : 'main_wallet_balance';
      
      // Update balance
      await conn.execute(
        `UPDATE users SET ${balanceField} = ${balanceField} + ? WHERE id = ?`,
        [parseFloat(amount), req.user.id]
      );

      // Record transaction
      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, ?, ?, ?, ?, "Success")',
        [req.user.id, walletType, `₹${parseFloat(amount).toFixed(2)}`, serviceType, dateStr]
      );
    });

    // Invalidate cache
    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({ message: 'Sandbox payment registered and wallet updated.' });
  } catch (err) {
    res.status(500).json({ error: 'Transaction failed' });
  }
});


// --- ADMIN SECTION ENDPOINTS ---

// Admin Login
app.post('/api/admin/login', verifyAppToken, async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const admins = await query('SELECT * FROM users WHERE email = ? AND role = "admin"', [email.toLowerCase()]);
    if (admins.length === 0) {
      return res.status(400).json({ error: 'Invalid admin credentials' });
    }

    const admin = admins[0];
    const isMatch = bcrypt.compareSync(password, admin.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid admin credentials' });
    }

    const token = jwt.sign(
      { email: admin.email, role: 'admin' },
      process.env.JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({ token, email: admin.email });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Change Admin Password
app.post('/api/admin/change-password', verifyAppToken, async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Old and new passwords are required' });
    }

    const admins = await query('SELECT * FROM users WHERE email = ? AND role = "admin"', [decoded.email]);
    if (admins.length === 0) {
      return res.status(404).json({ error: 'Admin not found' });
    }

    const admin = admins[0];
    const isMatch = bcrypt.compareSync(oldPassword, admin.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Incorrect old password' });
    }

    const salt = bcrypt.genSaltSync(10);
    const newHash = bcrypt.hashSync(newPassword, salt);

    await query('UPDATE users SET passwordHash = ? WHERE id = ?', [newHash, admin.id]);
    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token or unauthorized operation' });
  }
});

// Admin Dashboard stats & users list (Supports Redis caching and pagination)
app.get('/api/admin/dashboard', verifyAppToken, async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    // Try cache first
    let stats = await getCache('admin_stats');
    if (!stats) {
      const totalUsersResult = await query('SELECT COUNT(id) as count FROM users WHERE role = "user"');
      const walletsResult = await query(
        'SELECT SUM(fund_wallet_balance) as fundTotal, SUM(main_wallet_balance) as mainTotal FROM users'
      );
      const txnsCountResult = await query('SELECT COUNT(id) as count FROM transactions');

      stats = {
        totalUsers: totalUsersResult[0].count,
        totalFundWallet: parseFloat(walletsResult[0].fundTotal || 0),
        totalMainWallet: parseFloat(walletsResult[0].mainTotal || 0),
        totalTransactions: txnsCountResult[0].count
      };
      await setCache('admin_stats', stats, 30); // Cache stats for 30s
    }

    // Load users with pagination (default page 1, limit 10)
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const usersList = await query(
      'SELECT id, fullName, email, mobileNumber, fund_wallet_balance, main_wallet_balance, status, createdAt FROM users WHERE role = "user" ORDER BY id DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );

    const transactions = await query(
      'SELECT id, user_id, wallet_type, amount, type, date, status FROM transactions ORDER BY id DESC LIMIT 15'
    );

    res.json({
      stats,
      users: usersList,
      transactions,
      pagination: {
        page,
        limit
      }
    });
  } catch (err) {
    res.status(401).json({ error: 'Session expired or invalid token' });
  }
});

// Admin lists all user Fund Requests (with pagination)
app.get('/api/admin/fund-requests', verifyAppToken, async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const requests = await query(
      `SELECT fr.id, fr.amount, fr.status, fr.createdAt, u.fullName, u.email 
       FROM fund_requests fr 
       JOIN users u ON fr.user_id = u.id 
       ORDER BY fr.id DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );

    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch fund requests' });
  }
});

// Admin approves a pending Fund Request (Runs inside transactional SQL block)
app.post('/api/admin/fund-requests/:id/approve', verifyAppToken, async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { approve } = req.body; // true to approve, false to reject
    const requestId = req.params.id;

    const reqs = await query('SELECT * FROM fund_requests WHERE id = ?', [requestId]);
    if (reqs.length === 0) {
      return res.status(404).json({ error: 'Fund request not found' });
    }

    const request = reqs[0];
    if (request.status !== 'PENDING') {
      return res.status(400).json({ error: 'Request already processed' });
    }

    if (approve === true) {
      // Approve: credit user's Fund Wallet inside SQL transaction block
      await transaction(async (conn) => {
        // Update request status
        await conn.execute('UPDATE fund_requests SET status = "APPROVED" WHERE id = ?', [requestId]);

        // Credit fund wallet balance
        await conn.execute(
          'UPDATE users SET fund_wallet_balance = fund_wallet_balance + ? WHERE id = ?',
          [request.amount, request.user_id]
        );

        // Record transaction log
        const dateStr = new Date().toLocaleString('en-US', { hour12: true });
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Fund Deposit", ?, "Success")',
          [request.user_id, `₹${parseFloat(request.amount).toFixed(2)}`, dateStr]
        );
      });

      // Clear related cache
      await invalidateCache(`user_profile_${request.user_id}`);
      await invalidateCache('admin_stats');

      res.json({ message: 'Fund deposit request approved and balance credited successfully.' });
    } else {
      // Reject request
      await query('UPDATE fund_requests SET status = "REJECTED" WHERE id = ?', [requestId]);
      res.json({ message: 'Fund request has been rejected.' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Transaction failed during approval process' });
  }
});

// Start Database and Server Listen
async function startup() {
  await initDb();
  await initCache();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Production-ready server listening on port ${PORT}`);
  });
}

startup();
