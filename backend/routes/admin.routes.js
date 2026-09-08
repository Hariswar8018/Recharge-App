const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query, transaction } = require('../db');
const { getCache, setCache, invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { JWT_SECRET, verifyAdminToken } = require('../middleware/auth');

const router = express.Router();

// Admin Login
router.post('/login', async (req, res) => {
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
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({ token, email: admin.email });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Change Admin Password
router.post('/change-password', verifyAdminToken, async (req, res) => {
  const { oldPassword, newPassword } = req.body;
  if (!oldPassword || !newPassword) {
    return res.status(400).json({ error: 'Old and new passwords are required' });
  }

  try {
    const admins = await query('SELECT * FROM users WHERE email = ? AND role = "admin"', [req.admin.email]);
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
    res.status(500).json({ error: 'Failed to change password' });
  }
});

// GET Admin System Settings
router.get('/settings', verifyAdminToken, async (req, res) => {
  try {
    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => {
      settings[row.key_name] = row.val_value;
    });
    res.json(settings);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

// UPDATE Admin System Settings
router.post('/settings', verifyAdminToken, async (req, res) => {
  try {
    const updates = req.body;
    for (const [key, val] of Object.entries(updates)) {
      await query(
        'INSERT INTO system_settings (key_name, val_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE val_value = ?',
        [key, String(val), String(val)]
      );
    }
    res.json({ message: 'System settings updated successfully.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update system settings' });
  }
});

// GET Admin list
router.get('/list', verifyAdminToken, async (req, res) => {
  try {
    const admins = await query('SELECT id, fullName, email, mobileNumber, status, createdAt FROM users WHERE role = "admin" ORDER BY id ASC');
    res.json(admins);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch admin list' });
  }
});

// GET Gateway & APIs Operational Status
router.get('/gateway-status', verifyAdminToken, async (req, res) => {
  try {
    let dbStatus = 'Operational';
    try {
      await query('SELECT 1');
    } catch (e) {
      dbStatus = 'Offline';
    }

    const rows = await query('SELECT * FROM system_settings');
    const settings = {};
    rows.forEach(r => { settings[r.key_name] = r.val_value; });

    const scrizaMode = settings['scriza_api_mode'] || 'simulation';
    const razorpayMode = settings['razorpay_api_mode'] || 'test';

    res.json({
      database: dbStatus,
      app_api: 'Operational',
      scriza_api: scrizaMode === 'production' ? 'Operational (Live)' : 'Simulation Active',
      razorpay_gateway: razorpayMode === 'live' ? 'Operational (Live)' : 'Test Sandbox Active',
      redis_cache: 'Operational (In-Memory Fallback)'
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to get gateway status' });
  }
});

// POST Admin Notification Broadcast
router.post('/notifications', verifyAdminToken, async (req, res) => {
  const { title, message } = req.body;
  if (!title || !message) {
    return res.status(400).json({ error: 'Title and Message are required.' });
  }

  try {
    await query('INSERT INTO notifications (title, message) VALUES (?, ?)', [title, message]);
    res.status(201).json({ message: 'Notification broadcasted successfully.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create notification' });
  }
});

// GET Paginated Admin Transactions
router.get('/transactions', verifyAdminToken, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 15;
    const offset = (page - 1) * limit;

    const list = await query(
      `SELECT t.*, u.fullName, u.email 
       FROM transactions t 
       LEFT JOIN users u ON t.user_id = u.id 
       ORDER BY t.id DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );

    res.json(list);
  } catch (err) {
    console.error('Error fetching admin transactions:', err);
    res.status(500).json({ error: 'Database error loading transactions', details: err.message });
  }
});

// Admin Dashboard stats & users list
router.get('/dashboard', verifyAdminToken, async (req, res) => {
  try {
    let stats = await getCache('admin_stats');
    if (!stats) {
      const totalUsersResult = await query('SELECT COUNT(id) as count FROM users WHERE role != "admin" OR role IS NULL');
      const walletsResult = await query(
        'SELECT COALESCE(SUM(fund_wallet_balance), 0) as fundTotal, COALESCE(SUM(main_wallet_balance), 0) as mainTotal FROM users'
      );
      const txnsCountResult = await query('SELECT COUNT(id) as count FROM transactions');

      stats = {
        totalUsers: (totalUsersResult && totalUsersResult[0] && totalUsersResult[0].count) ? parseInt(totalUsersResult[0].count) : 0,
        totalFundWallet: (walletsResult && walletsResult[0] && walletsResult[0].fundTotal) ? parseFloat(walletsResult[0].fundTotal) : 0,
        totalMainWallet: (walletsResult && walletsResult[0] && walletsResult[0].mainTotal) ? parseFloat(walletsResult[0].mainTotal) : 0,
        totalTransactions: (txnsCountResult && txnsCountResult[0] && txnsCountResult[0].count) ? parseInt(txnsCountResult[0].count) : 0
      };
      await setCache('admin_stats', stats, 15);
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const usersList = await query(
      'SELECT * FROM users WHERE role != "admin" OR role IS NULL ORDER BY id DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );

    const transactions = await query(
      'SELECT * FROM transactions ORDER BY id DESC LIMIT 15'
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
    console.error('Error fetching admin dashboard:', err);
    res.status(500).json({ error: 'Failed to load admin dashboard data', details: err.message });
  }
});

// Admin lists all user Fund Requests
router.get('/fund-requests', verifyAdminToken, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const requests = await query(
      `SELECT fr.*, u.fullName, u.email 
       FROM fund_requests fr 
       LEFT JOIN users u ON fr.user_id = u.id 
       ORDER BY fr.id DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );

    res.json(requests);
  } catch (err) {
    console.error('Error fetching fund requests:', err);
    res.status(500).json({ error: 'Failed to fetch fund requests', details: err.message });
  }
});

// Admin approves a pending Fund Request
router.post('/fund-requests/:id/approve', verifyAdminToken, async (req, res) => {
  try {
    const { approve } = req.body;
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
      await transaction(async (conn) => {
        await conn.execute('UPDATE fund_requests SET status = "APPROVED" WHERE id = ?', [requestId]);

        await conn.execute(
          'UPDATE users SET fund_wallet_balance = fund_wallet_balance + ? WHERE id = ?',
          [request.amount, request.user_id]
        );

        const dateStr = new Date().toLocaleString('en-US', { hour12: true });
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Fund Deposit", ?, "Success")',
          [request.user_id, `₹${parseFloat(request.amount).toFixed(2)}`, dateStr]
        );
      });

      await invalidateCache(`user_profile_${request.user_id}`);
      await invalidateCache('admin_stats');

      query('SELECT email, fullName FROM users WHERE id = ?', [request.user_id]).then((users) => {
        if (users.length > 0) {
          sendNotificationEmail(users[0].email, "Fund Deposit Approved - EarnFarm", `
            <h3>Hi ${users[0].fullName},</h3>
            <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> has been approved. The funds are now available in your Fund Wallet.</p>
          `);
        }
      }).catch((e) => console.error(e));

      res.json({ message: 'Fund deposit request approved successfully.' });
    } else {
      await query('UPDATE fund_requests SET status = "REJECTED" WHERE id = ?', [requestId]);

      query('SELECT email, fullName FROM users WHERE id = ?', [request.user_id]).then((users) => {
        if (users.length > 0) {
          sendNotificationEmail(users[0].email, "Fund Deposit Rejected - EarnFarm", `
            <h3>Hi ${users[0].fullName},</h3>
            <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> has been rejected by the administrator.</p>
          `);
        }
      }).catch((e) => console.error(e));

      res.json({ message: 'Fund request has been rejected.' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Transaction failed' });
  }
});

module.exports = router;
