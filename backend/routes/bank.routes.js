const express = require('express');
const { query } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Real Live Bank Verification API (Finpay Ultra Penny Drop)
router.post('/verify', verifyAppToken, verifyUserToken, async (req, res) => {
  const { bank_name, account_holder, account_no, ifsc } = req.body;
  if (!account_no || !ifsc) {
    return res.status(400).json({ error: 'Account number and IFSC code are required for Penny Drop verification.' });
  }

  try {
    const existing = await query('SELECT bank_verified FROM users WHERE id = ?', [req.user.id]);
    if (existing.length > 0 && (existing[0].bank_verified === 1 || existing[0].bank_verified === true)) {
      return res.status(400).json({ error: 'Bank details are already verified and locked. Only Admin can modify verified bank details.' });
    }

    const apiKey = process.env.BANK_API || 'bf66f8-23662d-4b6e45-ec27cc-a98eaa';
    const orderId = `BANKVER_${Date.now()}_${req.user.id}`;
    
    // Call Finpay Ultra Live Bank Verification Penny Drop API
    const verifyUrl = `https://api.finpayultra.com/api/bank-varification-live?api_key=${encodeURIComponent(apiKey)}&orderid=${encodeURIComponent(orderId)}&account_number=${encodeURIComponent(account_no.trim())}&ifsc=${encodeURIComponent(ifsc.trim().toUpperCase())}`;

    console.log(`[Bank Penny Drop] Calling Finpay Ultra API for user ${req.user.id}, orderid: ${orderId}`);

    const apiResponse = await fetch(verifyUrl, { method: 'GET' });
    const resData = await apiResponse.json();

    console.log('[Bank Penny Drop] Finpay Ultra API Response:', resData);

    const isSuccess = (resData.status === 'SUCCESS' || resData.status_code === '200' || resData.status_code === 200);

    if (!isSuccess) {
      const errMsg = resData.message || resData.data?.message || 'Bank Account Penny Drop verification failed. Please check Account Number & IFSC.';
      return res.status(400).json({ error: errMsg, details: resData });
    }

    const bankData = resData.data || {};
    const nameAtBank = bankData.nameAtBank || bankData['Account Holder Name'] || account_holder || 'Verified Account';
    const finalBankName = bank_name || 'Bank Account';
    const utr = bankData.utr || bankData.UTR || '';

    await query(
      'UPDATE users SET bank_name = ?, account_holder = ?, account_no = ?, ifsc = ?, bank_verified = 1 WHERE id = ?',
      [finalBankName, nameAtBank, account_no.trim(), ifsc.trim().toUpperCase(), req.user.id]
    );

    // Record Penny Drop verification transaction log if UTR is provided
    if (utr) {
      const dateStr = new Date().toISOString().replace('T', ' ').substring(0, 19);
      try {
        await query(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", 0.00, ?, ?, "Success")',
          [req.user.id, `Bank Penny Drop Verified (UTR: ${utr})`, dateStr]
        );
      } catch (_) {}
    }

    await invalidateCache(`user_profile_${req.user.id}`);

    return res.json({
      success: true,
      message: `₹1 Penny Drop verification successful! Name at Bank: ${nameAtBank}`,
      bank_verified: true,
      nameAtBank,
      utr,
      data: bankData
    });

  } catch (err) {
    console.error('Bank verify error:', err);
    return res.status(500).json({ error: 'Bank Penny Drop API request failed: ' + (err.message || 'Server error') });
  }
});

module.exports = router;
