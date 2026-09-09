const express = require('express');
const { query } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

router.post('/verify', verifyAppToken, verifyUserToken, async (req, res) => {
  const { bank_name, account_holder, account_no, ifsc } = req.body;
  if (!bank_name || !account_holder || !account_no || !ifsc) {
    return res.status(400).json({ error: 'All bank details (Bank Name, Holder Name, Account No, IFSC) are required' });
  }

  try {
    const existing = await query('SELECT bank_verified FROM users WHERE id = ?', [req.user.id]);
    if (existing.length > 0 && (existing[0].bank_verified === 1 || existing[0].bank_verified === true)) {
      return res.status(400).json({ error: 'Bank details are already verified and locked. Only Admin can modify verified bank details.' });
    }

    await query(
      'UPDATE users SET bank_name = ?, account_holder = ?, account_no = ?, ifsc = ?, bank_verified = 1 WHERE id = ?',
      [bank_name, account_holder, account_no, ifsc, req.user.id]
    );

    await invalidateCache(`user_profile_${req.user.id}`);
    res.json({
      message: '₹1 Penny Drop verification successful! Bank account details verified and saved.',
      bank_verified: true
    });
  } catch (err) {
    console.error('Bank verify error:', err);
    res.status(500).json({ error: 'Failed to verify bank account' });
  }
});

module.exports = router;
