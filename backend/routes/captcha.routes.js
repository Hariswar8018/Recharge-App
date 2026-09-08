const express = require('express');
const { transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

router.post('/earn', verifyAppToken, verifyUserToken, async (req, res) => {
  const earnedAmount = parseFloat(req.body.amount || '0.01');
  if (isNaN(earnedAmount) || earnedAmount <= 0) {
    return res.status(400).json({ error: 'Invalid reward amount' });
  }

  try {
    await transaction(async (conn) => {
      // Credit reward directly to Main Wallet for both active and free/inactive users
      await conn.execute(
        'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
        [earnedAmount, req.user.id]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Captcha Solve Reward", ?, "Success")',
        [req.user.id, `+₹${earnedAmount.toFixed(2)}`, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({
      message: `Reward ₹${earnedAmount.toFixed(2)} credited to Main Wallet`,
      earnedAmount: earnedAmount
    });
  } catch (err) {
    console.error('Captcha earn error:', err);
    res.status(500).json({ error: 'Failed to process captcha reward' });
  }
});

module.exports = router;
