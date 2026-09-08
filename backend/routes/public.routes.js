const express = require('express');
const { query } = require('../db');

const router = express.Router();

// Health Check Endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'API Server is healthy and running' });
});

// GET Public Landing Info
router.get('/landing-info', async (req, res) => {
  try {
    const rows = await query('SELECT * FROM system_settings WHERE key_name IN ("marquee_text", "marquee_images")');
    const data = {};
    rows.forEach(r => {
      data[r.key_name] = r.val_value;
    });
    res.json({
      marquee_text: data['marquee_text'] || 'Welcome to EarnFarm! Instant wallet loading and commissions are live.',
      marquee_images: data['marquee_images'] || ''
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch marquee settings' });
  }
});

// GET Public Notifications
router.get('/notifications', async (req, res) => {
  try {
    const list = await query('SELECT * FROM notifications ORDER BY id DESC LIMIT 50');
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: 'Database error loading notifications' });
  }
});

module.exports = router;
