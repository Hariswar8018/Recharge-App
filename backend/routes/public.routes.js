const express = require('express');
const { query } = require('../db');

const router = express.Router();

// Health Check Endpoint
router.get('/health', (req, res) => {
  res.json({ status: 'OK', message: 'API Server is healthy and running' });
});

// GET Public Landing Info & Settings
router.get('/landing-info', async (req, res) => {
  try {
    const rows = await query('SELECT * FROM system_settings');
    const data = {};
    rows.forEach(r => {
      data[r.key_name] = r.val_value;
    });
    res.json({
      marquee_text: data['marquee_text'] || 'Welcome to EarnFarm! Instant wallet loading and commissions are live.',
      marquee_images: data['marquee_images'] || '',
      whatsapp_support_link: data['whatsapp_support_link'] || 'https://wa.me/919876543210',
      whatsapp_support_enabled: data['whatsapp_support_enabled'] === 'true',
      whatsapp_group_link: data['whatsapp_group_link'] || 'https://chat.whatsapp.com/EarnFarmGlobalTeam',
      whatsapp_group_enabled: data['whatsapp_group_enabled'] === 'true',
      popup_banner_image: data['popup_banner_image'] || '',
      popup_banner_enabled: data['popup_banner_enabled'] === 'true',
      popup_banner_display_mode: data['popup_banner_display_mode'] || 'once',
      settings: data
    });
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch settings' });
  }
});

// GET Public Settings
router.get('/settings', async (req, res) => {
  try {
    const rows = await query('SELECT key_name, val_value FROM system_settings');
    const settings = {};
    rows.forEach(r => { settings[r.key_name] = r.val_value; });
    res.json(settings);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch public settings' });
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
