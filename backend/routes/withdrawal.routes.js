const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

router.post('/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount } = req.body;
  if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
    return res.status(400).json({ error: 'Invalid withdrawal amount' });
  }

  const amt = parseFloat(amount);

  try {
    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => { settings[row.key_name] = row.val_value; });

    const minWithdraw = parseFloat(settings['minimum_withdrawal'] || '500');
    const feePercent = parseFloat(settings['withdrawal_percentage'] || '15');

    if (amt < minWithdraw) {
      return res.status(400).json({ error: `Minimum withdrawal amount is ₹${minWithdraw}` });
    }

    const users = await query('SELECT status, main_wallet_balance FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    
    // Enforce Active Status requirement for withdrawal
    const status = (users[0].status || '').toUpperCase();
    if (status !== 'ACTIVE') {
      return res.status(400).json({ error: 'Free/Inactive members cannot withdraw Main Wallet balance. Please activate your ID.' });
    }

    const balance = parseFloat(users[0].main_wallet_balance);

    if (balance < amt) {
      return res.status(400).json({ error: 'Insufficient Main Wallet balance' });
    }

    const deduction = (amt * feePercent) / 100;
    const netCredit = amt - deduction;

    await transaction(async (conn) => {
      await conn.execute(
        'UPDATE users SET main_wallet_balance = main_wallet_balance - ? WHERE id = ?',
        [amt, req.user.id]
      );
      
      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Cashout", ?, "Success")',
        [req.user.id, `-₹${amt.toFixed(2)}`, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({
      message: 'Withdrawal processed successfully',
      requestedAmount: amt,
      deductionFee: deduction,
      netCredited: netCredit
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to process withdrawal request' });
  }
});

module.exports = router;
