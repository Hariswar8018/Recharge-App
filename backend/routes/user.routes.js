const express = require('express');
const bcrypt = require('bcryptjs');
const { query } = require('../db');
const { getCache, setCache, invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

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
      `SELECT u.id, u.fullName, u.email, u.mobileNumber, u.fund_wallet_balance, u.main_wallet_balance, u.status, u.sponsor_id, u.createdAt,
              u.bank_name, u.account_holder, u.account_no, u.ifsc, u.bank_verified,
              s.mobileNumber AS sponsor_mobileNumber
       FROM users u
       LEFT JOIN users s ON u.sponsor_id = s.id
       WHERE u.id = ?`,
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
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
    res.json(team);
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
        amount: `+₹${parseFloat(r.amount).toFixed(2)}`,
        type: 'Fund Deposit',
        description: `UTR: ${r.utr} • ${isPending ? 'Pending Verification' : 'Rejected by Admin'}`,
        date: r.createdAt ? r.createdAt.toISOString() : new Date().toISOString(),
        status: isPending ? 'Pending' : 'Failed',
        createdAt: r.createdAt || new Date()
      };
    });

    const allTxns = [...pendingAndRejectedTxns, ...txns].sort((a, b) => {
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
  let targetId = req.params.id.toString().trim().toUpperCase();
  if (targetId.startsWith('EARNFARMX7AQ96SD')) {
    targetId = targetId.replace('EARNFARMX7AQ96SD', '');
  } else if (targetId.startsWith('EARNFARM')) {
    targetId = targetId.replace('EARNFARM', '');
  } else if (targetId.startsWith('EARNKARO97US77')) {
    targetId = targetId.replace('EARNKARO97US77', '');
  } else if (targetId.startsWith('SRM')) {
    targetId = targetId.replace('SRM', '');
  } else if (targetId.startsWith('SRSPO')) {
    targetId = targetId.replace('SRSPO', '');
  }
  // Remove leading zeros for numeric ID comparison
  const numericId = parseInt(targetId, 10);

  try {
    const users = await query(
      'SELECT id, fullName, email, mobileNumber, status, main_wallet_balance, createdAt FROM users WHERE id = ? OR mobileNumber = ?',
      [isNaN(numericId) ? targetId : numericId, targetId]
    );
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(users[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to lookup user' });
  }
});

module.exports = router;
