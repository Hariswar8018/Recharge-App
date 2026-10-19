const express = require('express');
const bcrypt = require('bcryptjs');
const { query } = require('../db');
const { getCache, setCache, invalidateCache } = require('../cache');
const jwt = require('jsonwebtoken');
const { verifyAppToken, verifyUserToken, JWT_SECRET } = require('../middleware/auth');

const router = express.Router();

function validatePasswordStrength(password) {
  if (!password || password.length < 8) {
    return 'Password must be at least 8 characters long.';
  }
  const weakPasswords = ['123456', '12345678', '123456789', '1234567890', 'password', 'qwerty', '11111111', 'abcdef'];
  if (weakPasswords.includes(password.toLowerCase()) || /^(\d)\1+$/.test(password)) {
    return 'Simple or predictable passwords (like 123456) are not allowed.';
  }
  if (!/[A-Z]/.test(password)) {
    return 'Password must contain at least one uppercase letter (A-Z).';
  }
  if (!/[a-z]/.test(password)) {
    return 'Password must contain at least one lowercase letter (a-z).';
  }
  if (!/[0-9]/.test(password)) {
    return 'Password must contain at least one number (0-9).';
  }
  if (!/[!@#\$&*~%]/.test(password)) {
    return 'Password must contain at least one special character (!@#$&*~%).';
  }
  return null;
}

// Get User Profile
router.get('/profile', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const cacheKey = `user_profile_${req.user.id}`;
    const cachedProfile = await getCache(cacheKey);
    if (cachedProfile) {
      return res.json(cachedProfile);
    }

    const users = await query(
      `SELECT u.id, u.fullName, u.email, u.mobileNumber, u.user_code, u.fund_wallet_balance, u.main_wallet_balance, u.status, u.sponsor_id, u.createdAt,
              u.bank_name, u.account_holder, u.account_no, u.ifsc, u.bank_verified,
              s.mobileNumber AS sponsor_mobileNumber, s.user_code AS sponsor_user_code
       FROM users u
       LEFT JOIN users s ON u.sponsor_id = s.id
       WHERE u.id = ?`,
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    user.memberId = user.mobileNumber;
    user.user_code = user.user_code || user.mobileNumber;
    user.sponsor_mobileNumber = user.sponsor_mobileNumber || 'N/A';
    await setCache(cacheKey, user, 5);
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Update User Profile
router.post('/update', verifyAppToken, verifyUserToken, async (req, res) => {
  const { fullName, mobileNumber } = req.body;
  if (!fullName) {
    return res.status(400).json({ error: 'Full Name is required' });
  }
  try {
    await query(
      'UPDATE users SET fullName = ?, mobileNumber = ? WHERE id = ?',
      [fullName, mobileNumber || null, req.user.id]
    );
    await invalidateCache(`user_profile_${req.user.id}`);
    res.json({ success: true, message: 'Profile updated successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Register or update User FCM Device Token for push notifications
router.post('/fcm-token', verifyAppToken, async (req, res) => {
  const { fcm_token, mobileNumber } = req.body;
  if (!fcm_token || typeof fcm_token !== 'string') {
    return res.status(400).json({ error: 'Valid fcm_token is required' });
  }

  const cleanToken = fcm_token.trim();

  try {
    let userId = null;
    const authHeader = req.headers['authorization'];
    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.split(' ')[1];
      try {
        const decoded = jwt.verify(token, JWT_SECRET);
        userId = decoded.id;
      } catch (_) {}
    }

    if (userId) {
      await query('UPDATE users SET fcm_token = ? WHERE id = ?', [cleanToken, userId]);
    } else if (mobileNumber) {
      await query('UPDATE users SET fcm_token = ? WHERE mobileNumber = ?', [cleanToken, String(mobileNumber).trim()]);
    } else {
      await query('UPDATE users SET fcm_token = ? WHERE fcm_token IS NULL OR fcm_token = ""', [cleanToken]);
    }

    console.log(`📱 [FCM] Device token registered: ${cleanToken.substring(0, 20)}... (User ID: ${userId || 'anonymous'})`);
    res.json({ success: true, message: 'FCM device token registered successfully' });
  } catch (err) {
    console.error('Failed to update user FCM token:', err);
    res.status(500).json({ error: 'Failed to update FCM device token' });
  }
});

// Change User Password
router.post('/change-password', verifyAppToken, verifyUserToken, async (req, res) => {
  const { oldPassword, newPassword } = req.body;
  if (!oldPassword || !newPassword) {
    return res.status(400).json({ error: 'Previous password and new password are required' });
  }

  try {
    const users = await query('SELECT id, passwordHash FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    const isMatch = bcrypt.compareSync(oldPassword, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Previous password is incorrect' });
    }

    const valErr = validatePasswordStrength(newPassword);
    if (valErr) {
      return res.status(400).json({ error: valErr });
    }

    const salt = bcrypt.genSaltSync(10);
    const newHash = bcrypt.hashSync(newPassword, salt);

    await query('UPDATE users SET passwordHash = ?, plain_password = ? WHERE id = ?', [newHash, newPassword, req.user.id]);
    await invalidateCache(`user_profile_${req.user.id}`);

    res.json({ success: true, message: 'Password updated successfully' });
  } catch (err) {
    console.error('Error changing user password:', err);
    res.status(500).json({ error: 'Failed to change password' });
  }
});

// Get User Direct Team Members
router.get('/team', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const team = await query(
      `SELECT u.id, u.fullName, u.email, u.mobileNumber, u.status, u.main_wallet_balance, u.createdAt,
              (SELECT COUNT(*) FROM users WHERE sponsor_id = u.id) AS team_count,
              (SELECT COUNT(*) FROM cycles WHERE user_id = u.id) AS cycle_count
       FROM users u 
       WHERE u.sponsor_id = ? 
       ORDER BY u.id DESC`,
      [req.user.id]
    );
    const formattedTeam = (team || []).map(m => ({
      ...m,
      mobileNumber: m.mobileNumber || m.mobilenumber || m.mobile || m.phone || 'N/A',
      memberId: m.mobileNumber || m.mobilenumber || m.mobile || m.phone || m.id || 'N/A'
    }));
    res.json(formattedTeam);
  } catch (err) {
    console.error('Error fetching user team:', err);
    res.status(500).json({ error: 'Failed to load team network' });
  }
});

// Get User Transactions
router.get('/transactions', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const txns = await query(
      'SELECT id, wallet_type, amount, type, date, status, createdAt FROM transactions WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );

    const fundReqs = await query(
      'SELECT id, amount, utr, status, createdAt FROM fund_requests WHERE user_id = ? AND status IN ("PENDING", "REJECTED") ORDER BY id DESC',
      [req.user.id]
    );

    const pendingAndRejectedTxns = fundReqs.map(r => {
      const isPending = r.status === 'PENDING';
      return {
        id: `FR_${r.id}`,
        wallet_type: 'FUND',
        amount: `+${parseFloat(r.amount).toFixed(2)}`,
        type: 'Fund Deposit',
        description: `UTR: ${r.utr} • ${isPending ? 'Pending Verification' : 'Rejected by Admin'}`,
        date: r.createdAt ? r.createdAt.toISOString() : new Date().toISOString(),
        status: isPending ? 'Pending' : 'Failed',
        createdAt: r.createdAt || new Date()
      };
    });

    const cleanedTxns = txns.map(t => {
      let typeStr = t.type || 'Transaction';
      const levelMatch = typeStr.match(/Level\s*([1-6])/i);
      if (levelMatch) {
        typeStr = `Level ${levelMatch[1]} Income`;
      }
      return {
        ...t,
        type: typeStr,
        amount: String(t.amount || '').replace(/[\+\?\-\₹\s]|Rs\.?|INR/gi, '').trim()
      };
    });

    const allTxns = [...pendingAndRejectedTxns, ...cleanedTxns].sort((a, b) => {
      const timeA = new Date(a.createdAt || a.date).getTime();
      const timeB = new Date(b.createdAt || b.date).getTime();
      return timeB - timeA;
    });

    res.json(allTxns);
  } catch (err) {
    console.error('Failed to load user transactions:', err);
    res.status(500).json({ error: 'Failed to load transactions list' });
  }
});

// Lookup User by ID or Mobile Number (for sponsor confirmation or ID subscription check)
router.get('/by-id/:id', verifyAppToken, async (req, res) => {
  const raw = (req.params.id || '').toString().trim();
  if (!raw) {
    return res.status(400).json({ error: 'User ID or mobile number is required' });
  }

  const digitsOnly = raw.replace(/\D/g, '');
  const last10 = digitsOnly.length >= 10 ? digitsOnly.slice(-10) : digitsOnly;
  const numericId = parseInt(raw.replace(/^SR[MD]0*/i, ''), 10);

  try {
    let users = [];
    if (digitsOnly.length === 10) {
      users = await query(
        `SELECT id, fullName, email, mobileNumber, user_code, status, main_wallet_balance, fund_wallet_balance, createdAt 
         FROM users 
         WHERE mobileNumber = ? OR user_code = ? LIMIT 1`,
        [digitsOnly, digitsOnly]
      );
    } else if (digitsOnly.length > 10) {
      users = await query(
        `SELECT id, fullName, email, mobileNumber, user_code, status, main_wallet_balance, fund_wallet_balance, createdAt 
         FROM users 
         WHERE mobileNumber = ? OR mobileNumber = ? OR user_code = ? LIMIT 1`,
        [last10, digitsOnly, raw]
      );
    } else if (!isNaN(numericId) && numericId > 0) {
      users = await query(
        `SELECT id, fullName, email, mobileNumber, user_code, status, main_wallet_balance, fund_wallet_balance, createdAt 
         FROM users 
         WHERE id = ? OR user_code = ? LIMIT 1`,
        [numericId, raw]
      );
    } else {
      users = await query(
        `SELECT id, fullName, email, mobileNumber, user_code, status, main_wallet_balance, fund_wallet_balance, createdAt 
         FROM users 
         WHERE user_code = ? OR email = ? LIMIT 1`,
        [raw, raw.toLowerCase()]
      );
    }

    if (!users || users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    const user = users[0];
    user.memberId = user.mobileNumber;

    // Fetch cycle info to determine if user has an ongoing active cycle or is eligible for Re-entry
    const userCycles = await query(
      'SELECT id, cycle_id, status, members_count FROM cycles WHERE user_id = ? ORDER BY id DESC',
      [user.id]
    );
    const activeCycle = userCycles.find(c => c.status === 'ACTIVE');
    const latestCycle = userCycles[0];

    user.has_active_cycle = !!activeCycle && (activeCycle.members_count < 126);
    user.active_cycle_id = activeCycle ? activeCycle.cycle_id : '';
    user.cycle_count = userCycles.length;
    user.latest_cycle_status = latestCycle ? latestCycle.status : 'NONE';
    // User is eligible for Top-Up / Re-Entry if they have NO ongoing active cycle (< 126 members)
    user.is_topup_eligible = (!activeCycle && userCycles.length > 0) || (activeCycle && activeCycle.members_count >= 126);

    res.json(user);
  } catch (err) {
    console.error('Failed to lookup user:', err);
    res.status(500).json({ error: 'Failed to lookup user' });
  }
});

module.exports = router;
