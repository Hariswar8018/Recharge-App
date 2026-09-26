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

    const advanceUrl = `https://api.finpayultra.com/api/advance_bank_verification?api_key=${encodeURIComponent(apiKey)}&orderid=${encodeURIComponent(orderId)}&account_number=${encodeURIComponent(cleanAccount)}&ifsc=${encodeURIComponent(cleanIfsc)}`;
    const simpleUrl = `https://api.finpayultra.com/api/bank-varification?api_key=${encodeURIComponent(apiKey)}&orderid=${encodeURIComponent(orderId)}&account_number=${encodeURIComponent(cleanAccount)}&ifsc=${encodeURIComponent(cleanIfsc)}`;
    const pennyDropUrl = `https://api.finpayultra.com/api/bank-varification-live?api_key=${encodeURIComponent(apiKey)}&orderid=${encodeURIComponent(orderId)}&account_number=${encodeURIComponent(cleanAccount)}&ifsc=${encodeURIComponent(cleanIfsc)}`;

    let resData = null;
    let isSuccess = false;
    let verificationMethod = '';

    // 1. Primary: Advance Bank Verification API
    console.log(`[Bank Verification] Step 1: Calling Advance Bank Verification API for user ${req.user.id}...`);
    try {
      const advRes = await fetch(advanceUrl, { method: 'GET' });
      const advJson = await advRes.json();
      console.log('[Bank Verification] Advance API Response:', advJson);
      if (advJson.status === 'SUCCESS' || advJson.status_code === '200' || advJson.status_code === 200) {
        resData = advJson;
        isSuccess = true;
        verificationMethod = 'Advance Bank Verification';
      } else {
        resData = advJson;
      }
    } catch (err) {
      console.error('[Bank Verification] Advance API fetch error:', err.message);
    }

    // 2. Secondary: Simple Bank Verification API
    if (!isSuccess) {
      console.log(`[Bank Verification] Step 2: Calling Simple Bank Verification API for user ${req.user.id}...`);
      try {
        const simpleRes = await fetch(simpleUrl, { method: 'GET' });
        const simpleJson = await simpleRes.json();
        console.log('[Bank Verification] Simple API Response:', simpleJson);
        if (simpleJson.status === 'SUCCESS' || simpleJson.status_code === '200' || simpleJson.status_code === 200) {
          resData = simpleJson;
          isSuccess = true;
          verificationMethod = 'Simple Bank Verification';
        } else {
          resData = simpleJson;
        }
      } catch (err) {
        console.error('[Bank Verification] Simple API fetch error:', err.message);
      }
    }

    // 3. Fallback: Live Penny Drop API
    if (!isSuccess) {
      console.log(`[Bank Verification] Step 3: Calling Penny Drop Live API for user ${req.user.id}...`);
      try {
        const pennyRes = await fetch(pennyDropUrl, { method: 'GET' });
        const pennyJson = await pennyRes.json();
        console.log('[Bank Verification] Penny Drop API Response:', pennyJson);
        if (pennyJson.status === 'SUCCESS' || pennyJson.status_code === '200' || pennyJson.status_code === 200) {
          resData = pennyJson;
          isSuccess = true;
          verificationMethod = 'Penny Drop Live';
        } else {
          resData = pennyJson;
        }
      } catch (err) {
        console.error('[Bank Verification] Penny Drop API fetch error:', err.message);
      }
    }

    if (!isSuccess || !resData) {
      const errMsg = (resData && (resData.message || resData.data?.message)) || 'Bank Account verification failed. Please check Account Number & IFSC.';
      return res.status(400).json({ error: errMsg, details: resData });
    }

    const bankData = resData.data || {};
    let nameAtBank = bankData.nameAtBank || bankData['Account Holder Name'] || bankData.name || account_holder || 'Verified Account';
    let fetchedBankName = bankData.bankName || bankData.bank_name || bank_name || 'Bank Account';

    if (typeof bankData.provider_response === 'object' && bankData.provider_response) {
      if (bankData.provider_response.nameAtBank) nameAtBank = bankData.provider_response.nameAtBank;
      else if (bankData.provider_response.beneficiary_name) nameAtBank = bankData.provider_response.beneficiary_name;
      
      if (bankData.provider_response.bankName) fetchedBankName = bankData.provider_response.bankName;
      else if (bankData.provider_response.bank_name) fetchedBankName = bankData.provider_response.bank_name;
    } else if (typeof bankData.provider_response === 'string' && bankData.provider_response.includes('{')) {
      try {
        const parsed = JSON.parse(bankData.provider_response);
        if (parsed.nameAtBank) nameAtBank = parsed.nameAtBank;
        else if (parsed.beneficiary_name) nameAtBank = parsed.beneficiary_name;
        if (parsed.bankName) fetchedBankName = parsed.bankName;
      } catch (_) {}
    }

    const finalBankName = fetchedBankName || bank_name || 'Bank Account';
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
          [req.user.id, `Bank Account Verified via ${verificationMethod} (UTR: ${utr})`, dateStr]
        );
      } catch (_) {}
    }

    await invalidateCache(`user_profile_${req.user.id}`);

    return res.json({
      success: true,
      message: `Bank Account verification successful! (${verificationMethod})`,
      bank_verified: true,
      nameAtBank,
      bankName: finalBankName,
      utr,
      method: verificationMethod,
      data: bankData
    });

  } catch (err) {
    console.error('Bank verify error:', err);
    return res.status(500).json({ error: 'Bank Verification API request failed: ' + (err.message || 'Server error') });
  }
});

module.exports = router;
