const express = require('express');
const { query } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Real Live Bank Verification API (Finpay Ultra Simple API with Live Penny Drop Fallback)
router.post('/verify', verifyAppToken, verifyUserToken, async (req, res) => {
  const { bank_name, account_holder, account_no, ifsc } = req.body;
  if (!account_no || !ifsc) {
    return res.status(400).json({ error: 'Account number and IFSC code are required for Bank Verification.' });
  }

  if ((bank_name && bank_name.toLowerCase().includes('icici')) || (ifsc && ifsc.toLowerCase().startsWith('icic'))) {
    return res.status(400).json({ error: 'ICICI payout unavailable. Use another bank' });
  }

  try {
    const existing = await query('SELECT bank_verified FROM users WHERE id = ?', [req.user.id]);
    if (existing.length > 0 && (existing[0].bank_verified === 1 || existing[0].bank_verified === true)) {
      return res.status(400).json({ error: 'Bank details are already verified and locked. Only Admin can modify verified bank details.' });
    }

    const apiKey = process.env.BANK_API || 'bf66f8-23662d-4b6e45-ec27cc-a98eaa';
    const orderId = `BANKVER_${Date.now()}_${req.user.id}`;
    const cleanAccount = account_no.trim();
    const cleanIfsc = ifsc.trim().toUpperCase();
    
    // 1. Primary Live Penny Drop API
    const liveUrl = `https://api.finpayultra.com/api/bank-varification-live?api_key=${encodeURIComponent(apiKey)}&orderid=${encodeURIComponent(orderId)}&account_number=${encodeURIComponent(cleanAccount)}&ifsc=${encodeURIComponent(cleanIfsc)}`;
    // 2. Secondary Simple Bank Verification API (Fallback)
    const simpleUrl = `https://api.finpayultra.com/api/bank-varification?api_key=${encodeURIComponent(apiKey)}&orderid=${encodeURIComponent(orderId)}&account_number=${encodeURIComponent(cleanAccount)}&ifsc=${encodeURIComponent(cleanIfsc)}`;

    console.log(`[Bank Penny Drop] Calling Finpay Ultra Penny Drop API for user ${req.user.id}, orderid: ${orderId}`);

    let apiResponse = await fetch(liveUrl, { method: 'GET' });
    let resData = await apiResponse.json();

    console.log('[Bank Penny Drop] Finpay Ultra API Response:', resData);

    let isSuccess = (resData.status === 'SUCCESS' || resData.status_code === '200' || resData.status_code === 200);

    // If Penny Drop API returned 503 or failed, attempt Simple Bank Verification API fallback
    if (!isSuccess && (resData.status_code === '503' || resData.status_code === 503 || resData.status === 'FAILED')) {
      console.log('[Bank Penny Drop] Penny Drop API 503/FAILED fallback: Trying Simple Bank Verification API...');
      try {
        const simpleResponse = await fetch(simpleUrl, { method: 'GET' });
        const simpleData = await simpleResponse.json();
        console.log('[Bank Verification] Finpay Ultra Simple API Fallback Response:', simpleData);
        if (simpleData.status === 'SUCCESS' || simpleData.status_code === '200' || simpleData.status_code === 200) {
          resData = simpleData;
          isSuccess = true;
        }
      } catch (_) {}
    }

    if (!isSuccess) {
      const errMsg = resData.message || resData.data?.message || 'Bank Account verification failed. Please check Account Number & IFSC.';
      return res.status(400).json({ error: errMsg, details: resData });
    }

    const bankData = resData.data || {};
    let nameAtBank = bankData.nameAtBank || bankData['Account Holder Name'] || bankData.name || account_holder || 'Verified Account';
    if (typeof bankData.provider_response === 'object' && bankData.provider_response) {
      if (bankData.provider_response.nameAtBank) nameAtBank = bankData.provider_response.nameAtBank;
      else if (bankData.provider_response.beneficiary_name) nameAtBank = bankData.provider_response.beneficiary_name;
    }

    const finalBankName = bank_name || 'Bank Account';
    const utr = bankData.utr || bankData.UTR || bankData.rrn || '';

    await query(
      'UPDATE users SET bank_name = ?, account_holder = ?, account_no = ?, ifsc = ?, bank_verified = 1 WHERE id = ?',
      [finalBankName, nameAtBank, cleanAccount, cleanIfsc, req.user.id]
    );

    // Record verification transaction log if UTR exists
    if (utr) {
      const dateStr = new Date().toISOString().replace('T', ' ').substring(0, 19);
      try {
        await query(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", 0.00, ?, ?, "Success")',
          [req.user.id, `Bank Account Verified (UTR: ${utr})`, dateStr]
        );
      } catch (_) {}
    }

    await invalidateCache(`user_profile_${req.user.id}`);

    return res.json({
      success: true,
      message: `Bank Account verification successful! Name at Bank: ${nameAtBank}`,
      bank_verified: true,
      nameAtBank,
      utr,
      data: bankData
    });

  } catch (err) {
    console.error('Bank verify error:', err);
    return res.status(500).json({ error: 'Bank Verification API request failed: ' + (err.message || 'Server error') });
  }
});

module.exports = router;
