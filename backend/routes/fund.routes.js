const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Helper to determine fund request status & cycle state for user
async function getUserFundStatus(userId) {
  const allRequests = await query(
    'SELECT id, amount, utr, status, createdAt FROM fund_requests WHERE user_id = ? ORDER BY id DESC',
    [userId]
  );

  const pendingReq = allRequests.find(r => r.status === 'PENDING');
  if (pendingReq) {
    return {
      canSubmit: false,
      statusState: 'PENDING',
      statusMessage: 'Verification Pending. Please wait for administrator approval.',
      lastRequest: pendingReq,
      allRequests
    };
  }

  // Check active cycles
  const activeCycles = await query(
    'SELECT id, status FROM cycles WHERE user_id = ? AND status = "ACTIVE"',
    [userId]
  );

  const lastApprovedReq = allRequests.find(r => r.status === 'APPROVED');
  if (activeCycles.length > 0 || lastApprovedReq) {
    if (activeCycles.length > 0) {
      return {
        canSubmit: false,
        statusState: 'APPROVED_CYCLE_ACTIVE',
        statusMessage: 'Request Approved & Cycle In Progress. Next request available after current cycle completion.',
        lastRequest: lastApprovedReq || allRequests[0],
        allRequests
      };
    }
  }

  const lastReq = allRequests[0];
  if (lastReq && lastReq.status === 'REJECTED') {
    return {
      canSubmit: true,
      statusState: 'REJECTED',
      statusMessage: 'Previous Request Rejected. You can submit a new request with a valid 12-digit UTR.',
      lastRequest: lastReq,
      allRequests
    };
  }

  return {
    canSubmit: true,
    statusState: 'AVAILABLE',
    statusMessage: 'Next Request Available. Pay ₹1,200 via UPI and enter your 12-digit UTR.',
    lastRequest: lastReq || null,
    allRequests
  };
}

// GET user fund request status & rules state
router.get('/status', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const statusData = await getUserFundStatus(req.user.id);
    res.json(statusData);
  } catch (err) {
    console.error('Error getting fund status:', err);
    res.status(500).json({ error: 'Failed to fetch fund status' });
  }
});

// User creates fund request
router.post('/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, utr } = req.body;
  const numericAmt = parseFloat(amount);
  
  if (isNaN(numericAmt) || Math.round(numericAmt) !== 1200) {
    return res.status(400).json({ error: 'Deposit amount is fixed at exactly ₹1,200' });
  }

  const cleanUtr = (utr || '').toString().trim();
  if (!/^\d{12}$/.test(cleanUtr)) {
    return res.status(400).json({ error: 'UTR number must be exactly 12 digits' });
  }

  try {
    // 1. Enforce global UTR uniqueness across all requests (PENDING, APPROVED, REJECTED)
    const existing = await query('SELECT id FROM fund_requests WHERE utr = ?', [cleanUtr]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'UTR Number Already Used' });
    }

    // 2. Check cycle & request state rules
    const fundStatus = await getUserFundStatus(req.user.id);
    if (!fundStatus.canSubmit) {
      return res.status(400).json({ error: fundStatus.statusMessage });
    }

    // 3. Insert as PENDING for admin approval
    await query(
      'INSERT INTO fund_requests (user_id, amount, utr, status) VALUES (?, 1200.00, ?, "PENDING")',
      [req.user.id, cleanUtr]
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

// Check if UTR is already registered/used system-wide
router.get('/check-utr/:utr', verifyAppToken, async (req, res) => {
  const cleanUtr = (req.params.utr || '').toString().trim();
  try {
    const existing = await query('SELECT id FROM fund_requests WHERE utr = ?', [cleanUtr]);
    res.json({ exists: existing.length > 0, registered: existing.length > 0 });
  } catch (err) {
    res.status(500).json({ error: 'Failed to check UTR' });
  }
});

module.exports = router;
