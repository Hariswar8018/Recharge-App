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

    const minWithdraw = parseFloat(settings['min_withdrawal'] || settings['minimum_withdrawal'] || '500');
    const feePercent = parseFloat(settings['withdrawal_deduction_percent'] || settings['withdrawal_percentage'] || '15');
    const allowedDaysStr = settings['withdrawal_days'] || 'Monday, Wednesday, Friday';
    
    // Check allowed days
    const fullDay = new Date().toLocaleDateString('en-US', { weekday: 'long' }).toLowerCase();
    const shortDay = new Date().toLocaleDateString('en-US', { weekday: 'short' }).toLowerCase();
    const allowedLower = allowedDaysStr.toLowerCase();

    if (!allowedLower.includes(fullDay) && !allowedLower.includes(shortDay)) {
      return res.status(400).json({ error: `Withdrawals are allowed only on ${allowedDaysStr}. Today is not an allowed withdrawal day.` });
    }

    if (amt < minWithdraw) {
      return res.status(400).json({ error: `Minimum withdrawal amount is ₹${minWithdraw}` });
    }

    // Enforce strict 1 withdrawal per day per user limit (even if rejected or approved)
    const userWithdrawals = await query(
      `SELECT createdAt FROM withdrawals WHERE user_id = ? ORDER BY id DESC`,
      [req.user.id]
    );

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);

    const hasDoneWithdrawalToday = userWithdrawals.some(w => {
      if (!w.createdAt) return false;
      const d = new Date(w.createdAt);
      return d >= todayStart;
    });

    if (hasDoneWithdrawalToday) {
      return res.status(400).json({ error: 'Only 1 withdrawal request is allowed per day. You have already submitted a withdrawal request today.' });
    }

    const users = await query('SELECT status, main_wallet_balance, bank_name, account_holder, account_no, ifsc, branch, account_type FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    
    // Enforce Active Status requirement for withdrawal
    const userRow = users[0];
    const status = (userRow.status || '').toUpperCase();
    if (status !== 'ACTIVE') {
      return res.status(400).json({ error: 'Free/Inactive members cannot withdraw Main Wallet balance. Please activate your ID.' });
    }

    const balance = parseFloat(userRow.main_wallet_balance || 0);

    if (balance < amt) {
      return res.status(400).json({ error: 'Insufficient Main Wallet balance' });
    }

    const deduction = (amt * feePercent) / 100;
    const netCredit = amt - deduction;

    await transaction(async (conn) => {
      // Deduct balance upfront to lock funds while pending approval
      await conn.execute(
        'UPDATE users SET main_wallet_balance = main_wallet_balance - ? WHERE id = ?',
        [amt, req.user.id]
      );
      
      // Insert withdrawal request
      await conn.execute(
        `INSERT INTO withdrawals (user_id, amount, deduction_fee, net_amount, account_holder, account_no, ifsc, bank_name, branch, account_type, status)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'PENDING')`,
        [
          req.user.id,
          amt,
          deduction,
          netCredit,
          userRow.account_holder || '',
          userRow.account_no || '',
          userRow.ifsc || '',
          userRow.bank_name || '',
          userRow.branch || '',
          userRow.account_type || 'Savings'
        ]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Cashout Request", ?, "Pending")',
        [req.user.id, `-₹${amt.toFixed(2)}`, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({
      message: 'Withdrawal request submitted successfully. Awaiting Admin Approval.',
      requestedAmount: amt,
      deductionFee: deduction,
      netCredited: netCredit
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to process withdrawal request' });
  }
});

// GET /api/withdrawal/my-requests - Returns user's withdrawal request history
router.get('/my-requests', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const requests = await query(
      'SELECT id, user_id, amount, deduction_fee, net_amount, account_holder, account_no, ifsc, bank_name, branch, account_type, status, rejection_reason, processed_at, createdAt FROM withdrawals WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(requests);
  } catch (err) {
    console.error('Error fetching user withdrawal requests:', err);
    res.status(500).json({ error: 'Failed to fetch withdrawal requests' });
  }
});

module.exports = router;
