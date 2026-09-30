require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { query, initDb } = require('./db');
const { initCache } = require('./cache');

// Import modular API route modules
const publicRoutes = require('./routes/public.routes');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const fundRoutes = require('./routes/fund.routes');
const cyclesRoutes = require('./routes/cycles.routes');
const captchaRoutes = require('./routes/captcha.routes');
const bankRoutes = require('./routes/bank.routes');
const withdrawalRoutes = require('./routes/withdrawal.routes');
const paymentRoutes = require('./routes/payment.routes');
const adminRoutes = require('./routes/admin.routes');

const path = require('path');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 5000;

// Ensure uploads directory exists
const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

// Enable CORS & JSON Body Parser (with limit for image uploads)
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'x-app-token', 'x-access-token']
}));
app.options('*', cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));
app.use('/uploads', express.static(uploadsDir));

// Android App Links Verification Endpoint
app.get('/.well-known/assetlinks.json', (req, res) => {
  res.json([{
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.srdigitalseva",
      "sha256_cert_fingerprints": [
        "FA:C6:17:45:DC:09:03:78:6F:B9:ED:E6:2A:96:2B:39:9F:73:48:F0:BB:6F:89:9B:83:32:66:75:91:03:3B:9C"
      ]
    }
  }]);
});

// Root Health & Info Endpoints
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    uptimeSeconds: Math.floor(process.uptime()),
    timestamp: new Date().toISOString(),
    message: 'API Server is healthy and operational'
  });
});

app.get('/info', async (req, res) => {
  try {
    let users = await query('SELECT id, fullName, email, mobileNumber, role, status FROM users').catch(() => []);
    if (!users || users.length === 0) {
      await initDb().catch(() => {});
      users = await query('SELECT id, fullName, email, mobileNumber, role, status FROM users').catch(() => []);
    }
    const safeUsers = users.map(u => ({
      id: u.id,
      name: u.fullName,
      email: u.email,
      role: u.role,
      status: u.status,
      mobileFirst6Digits: u.mobileNumber ? u.mobileNumber.toString().substring(0, 6) : 'N/A',
      mobileMasked: u.mobileNumber ? (u.mobileNumber.toString().substring(0, 6) + 'XXXX') : 'N/A'
    }));

    res.json({
      status: 'OK',
      server: 'SR Digital Seva Kendram API',
      version: '1.0.0',
      uptimeSeconds: Math.floor(process.uptime()),
      timestamp: new Date().toISOString(),
      environment: process.env.NODE_ENV || 'production',
      database: 'connected',
      totalUsersInDb: safeUsers.length,
      users: safeUsers
    });
  } catch (err) {
    res.json({
      status: 'OK',
      server: 'SR Digital Seva Kendram API',
      version: '1.0.0',
      uptimeSeconds: Math.floor(process.uptime()),
      timestamp: new Date().toISOString(),
      database: 'connected',
      error: err.message
    });
  }
});

app.get('/users', async (req, res) => {
  try {
    let users = await query('SELECT id, fullName, email, mobileNumber, role, status FROM users').catch(() => []);
    if (!users || users.length === 0) {
      await initDb().catch(() => {});
      users = await query('SELECT id, fullName, email, mobileNumber, role, status FROM users').catch(() => []);
    }
    const safeUsers = users.map(u => ({
      id: u.id,
      name: u.fullName,
      email: u.email,
      role: u.role,
      status: u.status,
      mobileFirst6Digits: u.mobileNumber ? u.mobileNumber.toString().substring(0, 6) : 'N/A',
      mobileMasked: u.mobileNumber ? (u.mobileNumber.toString().substring(0, 6) + 'XXXX') : 'N/A'
    }));

    res.json({
      totalUsers: safeUsers.length,
      users: safeUsers
    });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Mount Modular Router Endpoints
app.use('/api', publicRoutes);
app.use('/api/public', publicRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/fund', fundRoutes);
app.use('/api/cycles', cyclesRoutes);
app.use('/api/captcha', captchaRoutes);
app.use('/api/bank', bankRoutes);
app.use('/api/withdrawal', withdrawalRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/admin', adminRoutes);

async function startup() {
  await initDb();
  await initCache();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Production-ready modular server listening on port ${PORT}`);
  });
}

startup();
