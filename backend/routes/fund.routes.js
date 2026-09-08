const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// User creates fund request
router.post('/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, utr } = req.body;
  if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
    return res.status(400).json({ error: 'Invalid request amount' });
  }
  if (!utr || utr.trim().length === 0) {
    return res.status(400).json({ error: 'UTR number is required' });
  }

  try {
    const existing = await query('SELECT id FROM fund_requests WHERE utr = ?', [utr.trim()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Duplicate UTR number submitted' });
    }

    await transaction(async (conn) => {
      // 1. Insert approved fund request
      await conn.execute(
        'INSERT INTO fund_requests (user_id, amount, utr, status) VALUES (?, ?, ?, "APPROVED")',
        [req.user.id, parseFloat(amount), utr.trim()]
      );

      // 2. Credit user's fund wallet
      await conn.execute(
        'UPDATE users SET fund_wallet_balance = fund_wallet_balance + ? WHERE id = ?',
        [parseFloat(amount), req.user.id]
      );

      // 3. Log transaction success
      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Fund Deposit", ?, "Success")',
        [req.user.id, `₹${parseFloat(amount).toFixed(2)}`, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    query('SELECT fullName FROM users WHERE id = ?', [req.user.id]).then((users) => {
      if (users.length > 0) {
        sendNotificationEmail(req.user.email, "Fund Deposit Approved - EarnFarm", `
          <h3>Hi ${users[0].fullName},</h3>
          <p>Your deposit of <strong>₹${parseFloat(amount).toFixed(2)}</strong> has been processed successfully. The funds are now available in your Fund Wallet.</p>
        `);
      }
    }).catch(e => console.error(e));

    res.status(201).json({ message: 'Funds added directly to your Fund Wallet successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add funds directly' });
  }
});

// User lists their own fund request history
router.get('/requests', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const requests = await query(
      'SELECT id, amount, utr, status, createdAt FROM fund_requests WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load request history' });
  }
});

module.exports = router;
