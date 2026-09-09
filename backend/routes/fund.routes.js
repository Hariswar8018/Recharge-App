const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// User creates fund request
router.post('/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, utr } = req.body;
  const numericAmt = parseFloat(amount);
  if (!amount || isNaN(numericAmt)) {
    return res.status(400).json({ error: 'Invalid request amount' });
  }

  if (numericAmt < 1200 || numericAmt > 12000 || numericAmt % 1200 !== 0) {
    return res.status(400).json({ error: 'Deposit amount must be between ₹1,200 and ₹12,000 in multiples of ₹1,200' });
  }

  const cleanUtr = (utr || '').toString().trim();
  if (!/^\d{12}$/.test(cleanUtr)) {
    return res.status(400).json({ error: 'UTR number must be exactly 12 digits' });
  }

  try {
    const existing = await query('SELECT id FROM fund_requests WHERE utr = ?', [cleanUtr]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Duplicate UTR number submitted' });
    }

    // Insert as PENDING for admin approval
    await query(
      'INSERT INTO fund_requests (user_id, amount, utr, status) VALUES (?, ?, ?, "PENDING")',
      [req.user.id, numericAmt, cleanUtr]
    );

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.status(201).json({ message: 'Fund deposit request submitted successfully! Pending admin verification and approval.' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to submit fund request' });
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
