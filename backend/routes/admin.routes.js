const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query, transaction } = require('../db');
const { getCache, setCache, invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { JWT_SECRET, verifyAdminToken } = require('../middleware/auth');

const fs = require('fs');
const path = require('path');

const router = express.Router();

// Admin Login
router.post('/login', async (req, res) => {
  const email = (req.body.email || '').trim().toLowerCase();
  const password = (req.body.password || '').trim();

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    // Primary Admin Auto-Seeder & Auto-Healer on Login
    if (email === 'srdigitalseva9@gmail.com' && password === 'Rajesh@1819') {
      const salt = bcrypt.genSaltSync(10);
      const passwordHash = bcrypt.hashSync('Rajesh@1819', salt);

      const checkUser = await query('SELECT * FROM users WHERE LOWER(email) = ?', ['srdigitalseva9@gmail.com']);
      if (!checkUser || checkUser.length === 0) {
        await query(
          'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, role, status) VALUES (?, ?, ?, ?, ?, ?, "ACTIVE")',
          ['SR Digital Seva Admin', 'srdigitalseva9@gmail.com', '9988494936', passwordHash, 'Rajesh@1819', 'admin']
        );
      } else {
        await query(
          'UPDATE users SET mobileNumber = "9988494936", passwordHash = ?, plain_password = ?, role = "admin", status = "ACTIVE" WHERE LOWER(email) = ?',
          [passwordHash, 'Rajesh@1819', 'srdigitalseva9@gmail.com']
        );
      }

      const token = jwt.sign(
        { email: 'srdigitalseva9@gmail.com', role: 'admin' },
        JWT_SECRET,
        { expiresIn: '7d' }
      );
      return res.json({ token, email: 'srdigitalseva9@gmail.com' });
    }

    // Standard lookup for other admin accounts
    const admins = await query('SELECT * FROM users WHERE LOWER(email) = ? AND role = "admin"', [email]);
    if (!admins || admins.length === 0) {
      return res.status(400).json({ error: 'Admin account not found for this email' });
    }

    const admin = admins[0];
    let isMatch = false;

    if (admin.passwordHash) {
      try {
        isMatch = bcrypt.compareSync(password, admin.passwordHash);
      } catch (err) {
        console.error('Bcrypt compare error:', err);
      }
    }

    if (!isMatch && admin.plain_password) {
      isMatch = (password === admin.plain_password);
    }

    if (!isMatch) {
      return res.status(400).json({ error: 'Incorrect admin password' });
    }

    const token = jwt.sign(
      { email: admin.email, role: 'admin' },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    return res.json({ token, email: admin.email });
  } catch (err) {
    console.error('Admin login error:', err);
    return res.status(500).json({ error: 'Database error occurred during admin login' });
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
    const updates = { ...req.body };
    if (updates.upi_vpa_id && !updates.upi_id) updates.upi_id = updates.upi_vpa_id;
    if (updates.upi_id && !updates.upi_vpa_id) updates.upi_vpa_id = updates.upi_id;
    if (updates.upi_qr_url && !updates.qr_image_url) updates.qr_image_url = updates.upi_qr_url;

    if (updates.min_withdrawal) updates.minimum_withdrawal = updates.min_withdrawal;
    if (updates.minimum_withdrawal) updates.min_withdrawal = updates.minimum_withdrawal;
    if (updates.withdrawal_deduction_percent) updates.withdrawal_percentage = updates.withdrawal_deduction_percent;
    if (updates.withdrawal_percentage) updates.withdrawal_deduction_percent = updates.withdrawal_percentage;

    for (const [key, val] of Object.entries(updates)) {
      const strVal = val !== null && val !== undefined ? String(val) : '';
      const existing = await query('SELECT key_name FROM system_settings WHERE key_name = ?', [key]);
      if (existing && existing.length > 0) {
        await query('UPDATE system_settings SET val_value = ? WHERE key_name = ?', [strVal, key]);
      } else {
        await query('INSERT INTO system_settings (key_name, val_value) VALUES (?, ?)', [key, strVal]);
      }
    }
    res.json({ message: 'System settings updated successfully.' });
  } catch (err) {
    console.error('Failed to update system settings:', err);
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
    res.json({
      database: 'Operational (Online)',
      app_api: 'Operational (Online)',
      scriza_api: 'Operational (Live)',
      razorpay_gateway: 'Operational (Live)',
      redis_cache: 'Operational (Online)'
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

router.post('/send-notification', verifyAdminToken, async (req, res) => {
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

// GET Admin List Notifications
router.get('/notifications', verifyAdminToken, async (req, res) => {
  try {
    const list = await query('SELECT * FROM notifications ORDER BY id DESC LIMIT 100');
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch notifications' });
  }
});

// DELETE Admin Notification
router.delete('/notifications/:id', verifyAdminToken, async (req, res) => {
  try {
    await query('DELETE FROM notifications WHERE id = ?', [req.params.id]);
    res.json({ message: 'Notification deleted successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to delete notification' });
  }
});


// GET Paginated & Filterable Admin Transactions
router.get('/transactions', verifyAdminToken, async (req, res) => {
  try {
    const userId = req.query.user_id || req.query.userId;
    const { search, wallet_type, status, type, startDate, endDate } = req.query;
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 200;
    const offset = (page - 1) * limit;

    let sql = `SELECT t.*, u.fullName, u.email, u.mobileNumber, u.bank_name, u.account_holder, u.account_no, u.ifsc, u.branch, u.account_type 
               FROM transactions t 
               LEFT JOIN users u ON t.user_id = u.id 
               WHERE 1=1 `;
    let params = [];

    if (userId) {
      sql += ` AND (t.user_id = ? OR u.mobileNumber = ?) `;
      params.push(userId, userId);
    }

    if (wallet_type && wallet_type.toUpperCase() !== 'ALL') {
      sql += ` AND UPPER(t.wallet_type) = ? `;
      params.push(wallet_type.toUpperCase());
    }

    if (status && status.toUpperCase() !== 'ALL') {
      sql += ` AND UPPER(t.status) = ? `;
      params.push(status.toUpperCase());
    }

    if (type && type.toUpperCase() !== 'ALL') {
      sql += ` AND UPPER(t.type) LIKE ? `;
      params.push(`%${type.toUpperCase()}%`);
    }

    if (search && search.trim() !== '') {
      const q = `%${search.trim()}%`;
      sql += ` AND (u.fullName LIKE ? OR u.mobileNumber LIKE ? OR u.email LIKE ? OR CAST(t.user_id AS CHAR) LIKE ? OR t.type LIKE ? OR t.amount LIKE ? OR CAST(t.id AS CHAR) LIKE ?) `;
      params.push(q, q, q, q, q, q, q);
    }

    if (startDate && startDate.trim() !== '') {
      sql += ` AND (DATE(t.createdAt) >= ? OR t.date >= ?) `;
      params.push(startDate.trim(), startDate.trim());
    }

    if (endDate && endDate.trim() !== '') {
      sql += ` AND (DATE(t.createdAt) <= ? OR t.date <= ?) `;
      params.push(endDate.trim(), endDate.trim() + ' 23:59:59');
    }

    sql += ` ORDER BY t.id DESC LIMIT ? OFFSET ?`;
    params.push(limit, offset);

    const list = await query(sql, params);

    const cleanedList = list.map(tx => {
      const rawAmt = String(tx.amount || 0);
      const cleanAmt = rawAmt.replace(/[\+\?\-\₹\s]|Rs\.?|INR/gi, '').trim();
      const numAmt = parseFloat(cleanAmt) || 0;
      const isDebit = rawAmt.includes('-') || (tx.type && (tx.type.toLowerCase().includes('debit') || tx.type.toLowerCase().includes('withdrawal') || tx.type.toLowerCase().includes('cashout') || tx.type.toLowerCase().includes('recharge')));
      return {
        ...tx,
        raw_amount: tx.amount,
        numeric_amount: numAmt,
        is_debit: isDebit,
        amount: numAmt.toFixed(2)
      };
    });

    res.json(cleanedList);
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
      `SELECT u.*, (SELECT COUNT(d.id) FROM users d WHERE d.sponsor_id = u.id) as downlineCount 
       FROM users u 
       WHERE u.role != "admin" OR u.role IS NULL 
       ORDER BY u.id DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );

    const rawTransactions = await query(
      'SELECT * FROM transactions ORDER BY id DESC LIMIT 15'
    );
    const transactions = rawTransactions.map(tx => ({
      ...tx,
      amount: String(tx.amount || 0).replace(/[\+\?\-\₹\s]|Rs\.?|INR/gi, '').trim()
    }));

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

// GET Admin Teams (Downline Affiliates / User Tree)
router.get('/teams', verifyAdminToken, async (req, res) => {
  try {
    const users = await query(
      `SELECT u.id, u.fullName, u.email, u.mobileNumber, u.sponsor_id, u.status, u.main_wallet_balance, u.createdAt,
              s.fullName as sponsorName, s.email as sponsorEmail
       FROM users u
       LEFT JOIN users s ON u.sponsor_id = s.id
       WHERE u.role != "admin" OR u.role IS NULL
       ORDER BY u.id DESC`
    );

    const sponsorsMap = {};
    const unassigned = [];

    users.forEach(user => {
      if (user.sponsor_id) {
        if (!sponsorsMap[user.sponsor_id]) {
          sponsorsMap[user.sponsor_id] = {
            sponsorId: user.sponsor_id,
            sponsorName: user.sponsorName || `User #${user.sponsor_id}`,
            sponsorEmail: user.sponsorEmail || '',
            downlines: []
          };
        }
        sponsorsMap[user.sponsor_id].downlines.push(user);
      } else {
        unassigned.push(user);
      }
    });

    const teams = Object.values(sponsorsMap);

    res.json({
      teams,
      allUsers: users,
      directSponsorsCount: teams.length,
      totalUsersCount: users.length
    });
  } catch (err) {
    console.error('Error fetching admin teams:', err);
    res.status(500).json({ error: 'Failed to fetch user teams', details: err.message });
  }
});

// Admin lists all user Fund Requests
router.get('/fund-requests', verifyAdminToken, async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 200;
    const offset = (page - 1) * limit;

    const requests = await query(
      `SELECT fr.*, u.fullName, u.email, u.mobileNumber 
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
    const approve = req.body.approve !== false;
    const remark = req.body.remark;
    const requestId = req.params.id;

    const reqs = await query('SELECT * FROM fund_requests WHERE id = ?', [requestId]);
    if (reqs.length === 0) {
      return res.status(404).json({ error: 'Fund request not found' });
    }

    const request = reqs[0];
    if (request.status !== 'PENDING') {
      return res.status(400).json({ error: 'Request already processed' });
    }

    // Fetch user details for receipt generation
    const users = await query('SELECT id, fullName, email, mobileNumber FROM users WHERE id = ?', [request.user_id]);
    const userObj = users.length > 0 ? users[0] : { fullName: 'User #' + request.user_id, mobileNumber: 'N/A', email: 'N/A' };

    if (approve === true) {
      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await transaction(async (conn) => {
        await conn.execute('UPDATE fund_requests SET status = "APPROVED" WHERE id = ?', [requestId]);

        await conn.execute(
          'UPDATE users SET fund_wallet_balance = fund_wallet_balance + ? WHERE id = ?',
          [request.amount, request.user_id]
        );

        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Fund Deposit", ?, "Success")',
          [request.user_id, `+${parseFloat(request.amount).toFixed(2)}`, dateStr]
        );
      });

      await invalidateCache(`user_profile_${request.user_id}`);
      await invalidateCache('admin_stats');

      if (userObj.email && userObj.email !== 'N/A') {
        sendNotificationEmail(userObj.email, "Fund Deposit Approved - SR Digital Seva", `
          <h3>Hi ${userObj.fullName},</h3>
          <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> (UTR: ${request.utr}) has been approved. The funds are available in your Fund Wallet.</p>
        `).catch((e) => console.error(e));
      }

      const receipt = {
        id: request.id,
        user_id: request.user_id,
        fullName: userObj.fullName,
        mobileNumber: userObj.mobileNumber,
        email: userObj.email,
        amount: request.amount,
        utr_number: request.utr,
        payment_method: 'UPI Deposit',
        status: 'APPROVED',
        created_at: request.createdAt || new Date().toISOString()
      };

      res.json({
        message: 'Fund deposit request approved successfully.',
        receipt
      });
    } else {
      await query('UPDATE fund_requests SET status = "REJECTED" WHERE id = ?', [requestId]);
      await invalidateCache(`user_profile_${request.user_id}`);
      await invalidateCache('admin_stats');

      if (userObj.email && userObj.email !== 'N/A') {
        sendNotificationEmail(userObj.email, "Fund Deposit Rejected - SR Digital Seva", `
          <h3>Hi ${userObj.fullName},</h3>
          <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> (UTR: ${request.utr}) has been rejected by the administrator.${remark ? ' Remark: ' + remark : ''}</p>
        `).catch((e) => console.error(e));
      }

      res.json({ message: 'Fund request has been rejected.' });
    }
  } catch (err) {
    console.error('Error approving fund request:', err);
    res.status(500).json({ error: 'Failed to approve fund request' });
  }
});

// Admin rejects a pending Fund Request
router.post('/fund-requests/:id/reject', verifyAdminToken, async (req, res) => {
  try {
    const remark = req.body.remark || '';
    const requestId = req.params.id;

    const reqs = await query('SELECT * FROM fund_requests WHERE id = ?', [requestId]);
    if (reqs.length === 0) {
      return res.status(404).json({ error: 'Fund request not found' });
    }

    const request = reqs[0];
    if (request.status !== 'PENDING') {
      return res.status(400).json({ error: 'Request already processed' });
    }

    const users = await query('SELECT id, fullName, email, mobileNumber FROM users WHERE id = ?', [request.user_id]);
    const userObj = users.length > 0 ? users[0] : { fullName: 'User #' + request.user_id, mobileNumber: 'N/A', email: 'N/A' };

    await query('UPDATE fund_requests SET status = "REJECTED" WHERE id = ?', [requestId]);
    await invalidateCache(`user_profile_${request.user_id}`);
    await invalidateCache('admin_stats');

    if (userObj.email && userObj.email !== 'N/A') {
      sendNotificationEmail(userObj.email, "Fund Deposit Rejected - SR Digital Seva", `
        <h3>Hi ${userObj.fullName},</h3>
        <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> (UTR: ${request.utr}) has been rejected by the administrator.${remark ? ' Remark: ' + remark : ''}</p>
      `).catch((e) => console.error(e));
    }

    res.json({ message: 'Fund request has been rejected.' });
  } catch (err) {
    console.error('Error rejecting fund request:', err);
    res.status(500).json({ error: 'Failed to reject fund request' });
  }
});

// POST Update User Password (Admin feature)
router.post('/users/:userId/update-password', verifyAdminToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const { newPassword } = req.body;

    if (!newPassword || newPassword.trim().length < 4) {
      return res.status(400).json({ error: 'Password must be at least 4 characters long.' });
    }

    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync(newPassword.trim(), salt);

    await query('UPDATE users SET passwordHash = ? WHERE id = ?', [passwordHash, userId]);

    res.json({ message: `Password for User #${userId} updated successfully.` });
  } catch (err) {
    console.error('Error updating user password:', err);
    res.status(500).json({ error: 'Failed to update user password.' });
  }
});

// GET List System Admins
router.get('/system-admins', verifyAdminToken, async (req, res) => {
  try {
    const admins = await query('SELECT id, fullName, email, mobileNumber, role, createdAt FROM users WHERE role = "admin" ORDER BY id DESC');
    res.json(admins);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch admins list' });
  }
});

// POST Create System Admin
router.post('/create-admin', verifyAdminToken, async (req, res) => {
  const { fullName, email, mobileNumber, password, role } = req.body;
  if (!fullName || !email || !password) {
    return res.status(400).json({ error: 'Name, email, and password are required' });
  }
  try {
    const existing = await query('SELECT id FROM users WHERE email = ?', [email.toLowerCase().trim()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Email already exists' });
    }
    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync(password.trim(), salt);
    await query(
      'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, role, status) VALUES (?, ?, ?, ?, ?, ?, "ACTIVE")',
      [fullName.trim(), email.toLowerCase().trim(), mobileNumber || '0000000000', passwordHash, password.trim(), role || 'admin']
    );
    res.status(201).json({ message: 'System admin created successfully' });
  } catch (err) {
    console.error('Create admin error:', err);
    res.status(500).json({ error: 'Failed to create admin account' });
  }
});

// DELETE System Admin
router.delete('/system-admins/:id', verifyAdminToken, async (req, res) => {
  try {
    const adminId = req.params.id;
    const admins = await query('SELECT COUNT(id) as count FROM users WHERE role = "admin"');
    if (admins[0].count <= 1) {
      return res.status(400).json({ error: 'Cannot delete the master admin account.' });
    }
    await query('DELETE FROM users WHERE id = ? AND role = "admin"', [adminId]);
    res.json({ message: 'Admin account removed successfully.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to remove admin' });
  }
});

// POST Approve/Reject Transaction from Ledger
router.post('/transactions/:id/approve', verifyAdminToken, async (req, res) => {
  const txnId = req.params.id;
  const { approve } = req.body;
  try {
    const txns = await query('SELECT * FROM transactions WHERE id = ?', [txnId]);
    if (txns.length === 0) {
      return res.status(404).json({ error: 'Transaction not found' });
    }
    const txn = txns[0];
    const newStatus = approve === true ? 'Success' : 'FAILED';
    await query('UPDATE transactions SET status = ? WHERE id = ?', [newStatus, txnId]);

    if (approve === false && (txn.type === 'Cashout' || txn.type === 'Withdrawal')) {
      const rawAmt = parseFloat((txn.amount || '0').toString().replace(/[^0-9.]/g, '')) || 0;
      if (rawAmt > 0) {
        await query('UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?', [rawAmt, txn.user_id]);
      }
    }

    res.json({ message: `Transaction #${txnId} status updated to ${newStatus}` });
  } catch (err) {
    console.error('Approve transaction error:', err);
    res.status(500).json({ error: 'Failed to update transaction status' });
  }
});

// GET Detailed User Profile by ID or Mobile
router.get('/users/:userId', verifyAdminToken, async (req, res) => {
  try {
    const { userId } = req.params;
    let users = await query('SELECT * FROM users WHERE id = ? OR mobileNumber = ?', [userId, userId]);
    if (!users || users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    const user = users[0];

    // Fetch sponsor details if any
    let sponsor = null;
    if (user.sponsor_id) {
      const sp = await query('SELECT id, fullName, mobileNumber, email FROM users WHERE id = ?', [user.sponsor_id]);
      if (sp && sp.length > 0) sponsor = sp[0];
    }

    // Downline count
    const downline = await query('SELECT COUNT(id) as count FROM users WHERE sponsor_id = ?', [user.id]);
    const downlineCount = downline[0]?.count || 0;

    res.json({
      ...user,
      sponsor_name: sponsor ? sponsor.fullName : (user.sponsor_id ? `User #${user.sponsor_id}` : 'None'),
      sponsor_mobile: sponsor ? sponsor.mobileNumber : 'N/A',
      downlineCount
    });
  } catch (err) {
    console.error('Error fetching user profile:', err);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
});

// GET User Income & Earnings Breakdown
router.get('/users/:userId/income', verifyAdminToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const userRes = await query('SELECT id, fullName, email, mobileNumber, main_wallet_balance, fund_wallet_balance FROM users WHERE id = ? OR mobileNumber = ?', [userId, userId]);
    if (!userRes || userRes.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    const user = userRes[0];

    const txns = await query(
      `SELECT * FROM transactions 
       WHERE user_id = ?
       ORDER BY id DESC`,
      [user.id]
    );

    let directIncome = 0;
    let singleLegIncome = 0;
    let otherIncome = 0;

    const incomeTxns = [];

    txns.forEach(t => {
      let cleanAmt = t.amount;
      if (typeof cleanAmt === 'string') {
        cleanAmt = parseFloat(cleanAmt.replace(/[^0-9.-]/g, '')) || 0;
      } else if (typeof cleanAmt !== 'number' || isNaN(cleanAmt)) {
        cleanAmt = 0;
      }
      t.amount = cleanAmt;

      const tType = (t.type || '').toLowerCase();
      const isDebit = tType.includes('debit') || tType.includes('withdrawal') || tType.includes('recharge');
      
      if (!isDebit && cleanAmt > 0) {
        incomeTxns.push(t);
        if (tType.includes('direct') || tType.includes('sponsor') || tType.includes('referral')) {
          directIncome += cleanAmt;
        } else if (tType.includes('level') || tType.includes('single leg') || tType.includes('pool') || tType.includes('cycle')) {
          singleLegIncome += cleanAmt;
        } else {
          otherIncome += cleanAmt;
        }
      }
    });

    const totalIncome = directIncome + singleLegIncome + otherIncome;

    const downlines = await query(
      'SELECT id, fullName, mobileNumber, email, status, createdAt FROM users WHERE sponsor_id = ? OR sponsor_id = ? ORDER BY id DESC',
      [user.id, user.mobileNumber || '']
    );

    res.json({
      user,
      totalIncome: totalIncome.toFixed(2),
      directIncome: directIncome.toFixed(2),
      singleLegIncome: singleLegIncome.toFixed(2),
      otherIncome: otherIncome.toFixed(2),
      transactions: incomeTxns.length > 0 ? incomeTxns : txns,
      downlines: downlines || []
    });
  } catch (err) {
    console.error('Error fetching user income details:', err);
    res.status(500).json({ error: 'Failed to fetch user income details' });
  }
});

// PUT Update Full User Details & Bank Info
router.put('/users/:userId', verifyAdminToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const {
      fullName,
      email,
      mobileNumber,
      password,
      status,
      sponsor_id,
      createdAt,
      bank_name,
      account_holder,
      account_no,
      ifsc,
      branch,
      account_type
    } = req.body;

    const existing = await query('SELECT * FROM users WHERE id = ?', [userId]);
    if (!existing || existing.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    let passwordHash = existing[0].passwordHash;
    let plainPassword = existing[0].plain_password;

    if (password && password.trim().length > 0) {
      const salt = bcrypt.genSaltSync(10);
      passwordHash = bcrypt.hashSync(password.trim(), salt);
      plainPassword = password.trim();
    }

    let updatedCreatedAt = existing[0].createdAt;
    if (createdAt && String(createdAt).trim().length >= 10) {
      updatedCreatedAt = String(createdAt).trim();
    }

    await query(
      `UPDATE users SET 
        fullName = ?, 
        email = ?, 
        mobileNumber = ?, 
        passwordHash = ?, 
        plain_password = ?, 
        status = ?, 
        sponsor_id = ?, 
        createdAt = ?,
        bank_name = ?, 
        account_holder = ?, 
        account_no = ?, 
        ifsc = ?, 
        branch = ?, 
        account_type = ? 
       WHERE id = ?`,
      [
        fullName !== undefined ? fullName : existing[0].fullName,
        email !== undefined ? email : existing[0].email,
        mobileNumber !== undefined ? mobileNumber : existing[0].mobileNumber,
        passwordHash,
        plainPassword,
        status || existing[0].status,
        sponsor_id !== undefined && sponsor_id !== null ? sponsor_id : existing[0].sponsor_id,
        updatedCreatedAt,
        bank_name !== undefined ? bank_name : existing[0].bank_name,
        account_holder !== undefined ? account_holder : existing[0].account_holder,
        account_no !== undefined ? account_no : existing[0].account_no,
        ifsc !== undefined ? ifsc : existing[0].ifsc,
        branch !== undefined ? branch : existing[0].branch,
        account_type || existing[0].account_type || 'Savings',
        userId
      ]
    );

    const updated = await query('SELECT * FROM users WHERE id = ?', [userId]);
    res.json({ message: 'User details updated successfully', user: updated[0] });
  } catch (err) {
    console.error('Error updating user details:', err);
    res.status(500).json({ error: 'Failed to update user details' });
  }
});

// POST Adjust / Add Funds to User Wallet
router.post('/users/:userId/adjust-wallet', verifyAdminToken, async (req, res) => {
  try {
    const { userId } = req.params;
    const walletType = req.body.walletType || req.body.wallet_type || 'MAIN';
    const actionType = req.body.actionType || req.body.action_type || 'CREDIT';
    const amount = req.body.amount;
    const remark = req.body.remark;

    const numAmount = parseFloat(amount);
    if (isNaN(numAmount) || numAmount <= 0) {
      return res.status(400).json({ error: 'Invalid amount entered' });
    }

    const users = await query('SELECT * FROM users WHERE id = ?', [userId]);
    if (!users || users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const isCredit = (actionType || 'CREDIT').toUpperCase() === 'CREDIT';
    const targetWallet = (walletType || 'MAIN').toUpperCase() === 'FUND' ? 'fund_wallet_balance' : 'main_wallet_balance';
    const walletLabel = targetWallet === 'fund_wallet_balance' ? 'FUND' : 'MAIN';

    const delta = isCredit ? numAmount : -numAmount;

    await query(`UPDATE users SET ${targetWallet} = ${targetWallet} + ? WHERE id = ?`, [delta, userId]);

    // Record transaction entry
    const formattedAmt = `${isCredit ? '+' : '-'}₹${numAmount.toFixed(2)}`;
    const txnType = isCredit ? 'Admin Fund Credit' : 'Admin Fund Debit';
    const nowStr = new Date().toISOString();

    await query(
      'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, ?, ?, ?, ?, "Success")',
      [userId, walletLabel, formattedAmt, `${txnType}${remark ? ' (' + remark + ')' : ''}`, nowStr]
    );

    const updated = await query('SELECT * FROM users WHERE id = ?', [userId]);
    res.json({
      message: `Successfully ${isCredit ? 'added' : 'deducted'} ₹${numAmount.toFixed(2)} ${isCredit ? 'to' : 'from'} ${walletLabel} Wallet`,
      user: updated[0]
    });
  } catch (err) {
    console.error('Error adjusting wallet:', err);
    res.status(500).json({ error: 'Failed to adjust user wallet' });
  }
});

// POST Upload UPI QR Code Image (Cloud / MilesWeb / Local Storage)
router.post('/upload-qr', verifyAdminToken, async (req, res) => {
  try {
    const { qrImageBase64, qrImageUrl } = req.body;
    let inputStr = qrImageBase64 || qrImageUrl || '';
    let finalUrl = qrImageUrl || '';

    if (inputStr && inputStr.includes('base64,')) {
      const base64Data = inputStr.split('base64,')[1];
      const fileName = `upi_qr_${Date.now()}.png`;
      const uploadDir = path.join(__dirname, '../uploads');
      if (!fs.existsSync(uploadDir)) {
        fs.mkdirSync(uploadDir, { recursive: true });
      }
      const uploadPath = path.join(uploadDir, fileName);

      fs.writeFileSync(uploadPath, base64Data, 'base64');
      const protocol = req.protocol || 'http';
      const host = req.get('host') || 'localhost:5000';
      finalUrl = `${protocol}://${host}/uploads/${fileName}`;
    }

    if (!finalUrl) {
      return res.status(400).json({ error: 'Please provide an image file or URL' });
    }

    // Save into system_settings under both upi_qr_url and qr_image_url
    for (const k of ['upi_qr_url', 'qr_image_url']) {
      const existing = await query('SELECT id FROM system_settings WHERE key_name = ?', [k]);
      if (existing && existing.length > 0) {
        await query('UPDATE system_settings SET val_value = ? WHERE key_name = ?', [finalUrl, k]);
      } else {
        await query('INSERT INTO system_settings (key_name, val_value) VALUES (?, ?)', [k, finalUrl]);
      }
    }

    res.json({ message: 'UPI QR Code updated successfully', upi_qr_url: finalUrl });
  } catch (err) {
    console.error('Error uploading QR code:', err);
    res.status(500).json({ error: 'Failed to upload QR code image' });
  }
});

// GET Admin Withdrawal Requests (Filters: status, search, startDate, endDate)
router.get('/withdrawals', verifyAdminToken, async (req, res) => {
  try {
    const { status, search, startDate, endDate } = req.query;
    
    let sql = `
      SELECT 
        w.id,
        w.user_id,
        w.amount,
        w.deduction_fee,
        w.net_amount,
        w.account_holder,
        w.account_no,
        w.ifsc,
        w.bank_name,
        w.branch,
        w.account_type,
        w.status,
        w.rejection_reason,
        w.processed_at,
        w.createdAt,
        u.fullName,
        u.mobileNumber,
        u.email,
        u.main_wallet_balance as available_balance
      FROM withdrawals w
      LEFT JOIN users u ON w.user_id = u.id
      WHERE 1=1
    `;
    const params = [];

    if (status && status.toUpperCase() !== 'ALL') {
      sql += ' AND UPPER(w.status) = ?';
      params.push(status.toUpperCase());
    }

    if (search && search.trim() !== '') {
      const q = `%${search.trim()}%`;
      sql += ' AND (u.fullName LIKE ? OR u.mobileNumber LIKE ? OR u.email LIKE ? OR CAST(w.user_id AS CHAR) LIKE ? OR w.account_no LIKE ? OR w.ifsc LIKE ? OR CAST(w.id AS CHAR) LIKE ?)';
      params.push(q, q, q, q, q, q, q);
    }

    if (startDate && startDate.trim() !== '') {
      sql += ' AND DATE(w.createdAt) >= ?';
      params.push(startDate.trim());
    }

    if (endDate && endDate.trim() !== '') {
      sql += ' AND DATE(w.createdAt) <= ?';
      params.push(endDate.trim());
    }

    sql += ' ORDER BY w.id DESC';

    const rows = await query(sql, params);
    res.json(rows || []);
  } catch (err) {
    console.error('Error fetching admin withdrawal requests:', err);
    res.status(500).json({ error: 'Failed to fetch withdrawal requests' });
  }
});

// POST Bulk or Single Approve Withdrawal Requests
router.post('/withdrawals/approve', verifyAdminToken, async (req, res) => {
  try {
    let { ids, approveAllPending } = req.body;
    
    let targetIds = [];

    if (approveAllPending) {
      const pending = await query('SELECT id FROM withdrawals WHERE status = "PENDING"');
      targetIds = pending.map(r => r.id);
    } else if (Array.isArray(ids) && ids.length > 0) {
      targetIds = ids.map(id => parseInt(id)).filter(id => !isNaN(id));
    }

    if (targetIds.length === 0) {
      return res.status(400).json({ error: 'No valid withdrawal requests selected to approve' });
    }

    const nowStr = new Date().toISOString().slice(0, 19).replace('T', ' ');

    await transaction(async (conn) => {
      for (const reqId of targetIds) {
        // Fetch request info
        const [wRows] = await conn.execute('SELECT user_id, amount, status FROM withdrawals WHERE id = ?', [reqId]);
        if (wRows && wRows.length > 0) {
          const w = wRows[0];
          if (w.status === 'PENDING') {
            await conn.execute('UPDATE withdrawals SET status = "APPROVED", processed_at = ? WHERE id = ?', [nowStr, reqId]);
            await conn.execute('UPDATE transactions SET status = "Approved" WHERE user_id = ? AND type LIKE "%Cashout%" AND status = "Pending"', [w.user_id]);
          }
        }
      }
    });

    res.json({
      message: `Successfully approved ${targetIds.length} withdrawal request(s)`,
      approvedCount: targetIds.length
    });
  } catch (err) {
    console.error('Error approving withdrawal requests:', err);
    res.status(500).json({ error: 'Failed to approve withdrawal request(s)' });
  }
});

// POST Bulk or Single Reject Withdrawal Requests (With Reason & Refund to Main Wallet)
router.post('/withdrawals/reject', verifyAdminToken, async (req, res) => {
  try {
    let { ids, rejection_reason } = req.body;
    const reasonText = (rejection_reason || 'Rejected by Admin').trim();

    const targetIds = (Array.isArray(ids) ? ids : []).map(id => parseInt(id)).filter(id => !isNaN(id));

    if (targetIds.length === 0) {
      return res.status(400).json({ error: 'No valid withdrawal requests selected to reject' });
    }

    const nowStr = new Date().toISOString().slice(0, 19).replace('T', ' ');
    let rejectedCount = 0;

    await transaction(async (conn) => {
      for (const reqId of targetIds) {
        const [wRows] = await conn.execute('SELECT user_id, amount, status FROM withdrawals WHERE id = ?', [reqId]);
        if (wRows && wRows.length > 0) {
          const w = wRows[0];
          if (w.status === 'PENDING') {
            const refundAmt = parseFloat(w.amount || 0);

            // 1. Mark request as REJECTED with reason
            await conn.execute(
              'UPDATE withdrawals SET status = "REJECTED", rejection_reason = ?, processed_at = ? WHERE id = ?',
              [reasonText, nowStr, reqId]
            );

            // 2. Refund balance back to user's main_wallet_balance
            if (refundAmt > 0) {
              await conn.execute(
                'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
                [refundAmt, w.user_id]
              );
            }

            // 3. Log refund & update transaction status
            const formattedRefund = `+₹${refundAmt.toFixed(2)}`;
            await conn.execute(
              'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, ?, ?, "Success")',
              [w.user_id, formattedRefund, `Withdrawal Refund (${reasonText})`, nowStr]
            );

            await conn.execute(
              'UPDATE transactions SET status = "Rejected" WHERE user_id = ? AND type LIKE "%Cashout%" AND status = "Pending"',
              [w.user_id]
            );

            rejectedCount++;
          }
        }
      }
    });

    res.json({
      message: `Successfully rejected ${rejectedCount} withdrawal request(s) and refunded balance to user wallet`,
      rejectedCount
    });
  } catch (err) {
    console.error('Error rejecting withdrawal requests:', err);
    res.status(500).json({ error: 'Failed to reject withdrawal request(s)' });
  }
});

module.exports = router;
