const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Mock Razorpay payment simulation callback
router.post('/razorpay-sandbox', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, serviceType, walletType } = req.body;
  if (!amount || !serviceType || !walletType) {
    return res.status(400).json({ error: 'Missing payment metadata parameters' });
  }

  try {
    await transaction(async (conn) => {
      const balanceField = walletType === 'FUND' ? 'fund_wallet_balance' : 'main_wallet_balance';
      
      await conn.execute(
        `UPDATE users SET ${balanceField} = ${balanceField} + ? WHERE id = ?`,
        [parseFloat(amount), req.user.id]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, ?, ?, ?, ?, "Success")',
        [req.user.id, walletType, `₹${parseFloat(amount).toFixed(2)}`, serviceType, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({ message: 'Sandbox payment registered and wallet updated.' });
  } catch (err) {
    res.status(500).json({ error: 'Transaction failed' });
  }
});

// Scriza Telecom Recharge Callback Hook
router.get('/scriza-callback', async (req, res) => {
  const { payid, client_id, operator_ref, status } = req.query;
  console.log(`Received Scriza Callback - Client ID: ${client_id}, Pay ID: ${payid}, Operator Ref: ${operator_ref}, Status: ${status}`);

  if (!client_id) {
    return res.status(200).send('Missing client_id');
  }

  try {
    const isSuccess = status === 'success' || status === 'Success';
    const finalStatus = isSuccess ? 'Success' : 'Failure';

    await query(
      'UPDATE transactions SET status = ? WHERE id = ?',
      [finalStatus, client_id]
    );

    res.status(200).send('OK');
  } catch (err) {
    console.error('Error handling Scriza callback:', err);
    res.status(200).send('OK');
  }
});

module.exports = router;
