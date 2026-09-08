const express = require('express');
const { query } = require('../db');
const { getCache, setCache, invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Get User Profile
router.get('/profile', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const cacheKey = `user_profile_${req.user.id}`;
    const cachedProfile = await getCache(cacheKey);
    if (cachedProfile) {
      return res.json(cachedProfile);
    }

    const users = await query(
      'SELECT id, fullName, email, mobileNumber, fund_wallet_balance, main_wallet_balance, status, sponsor_id, bank_name, account_holder, account_no, ifsc, bank_verified FROM users WHERE id = ?',
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

// Get User Direct Team Members
router.get('/team', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const team = await query(
      'SELECT id, fullName, email, mobileNumber, status, createdAt FROM users WHERE sponsor_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(team);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load team network' });
  }
});

// Get User Transactions
router.get('/transactions', verifyAppToken, verifyUserToken, async (req, res) => {
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

// Lookup User by ID (for sponsor confirmation or ID subscription check)
router.get('/by-id/:id', verifyAppToken, async (req, res) => {
  let targetId = req.params.id.toString().trim().toUpperCase();
  if (targetId.startsWith('EARNFARMX7AQ96SD')) {
    targetId = targetId.replace('EARNFARMX7AQ96SD', '');
  } else if (targetId.startsWith('EARNFARM')) {
    targetId = targetId.replace('EARNFARM', '');
  } else if (targetId.startsWith('EARNKARO97US77')) {
    targetId = targetId.replace('EARNKARO97US77', '');
  }

  try {
    const users = await query('SELECT id, fullName, mobileNumber, status FROM users WHERE id = ?', [targetId]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }
    res.json(users[0]);
  } catch (err) {
    res.status(500).json({ error: 'Failed to lookup user' });
  }
});

module.exports = router;
