const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// GET /api/captcha/config - Public Captcha Work Config (ON/OFF status & per-captcha reward rate)
router.get('/config', async (req, res) => {
  try {
    const settingsRows = await query('SELECT key_name, val_value FROM system_settings');
    const settings = {};
    settingsRows.forEach(r => { settings[r.key_name] = r.val_value; });

    const isEnabled = settings['captcha_enabled'] !== 'false' && 
                      settings['captcha_enabled'] !== '0' &&
                      settings['sec_captcha_enabled_bool'] !== 'false';

    const rawVal = settings['captcha_reward_amount'] || 
                   settings['captcha_per_solve_income'] || 
                   settings['per_captcha_income'] || 
                   settings['sec_captcha_reward'] || 
                   settings['captcha_reward'] || 
                   '0.50';
    const rewardAmount = parseFloat(rawVal);
    const maintenanceMsg = settings['sec_captcha_notice'] || settings['captcha_maintenance_msg'] || 'CAPTCHA Work is currently under maintenance. Please check back later.';

    res.json({
      captcha_enabled: isEnabled,
      captcha_reward_amount: rewardAmount,
      maintenance_message: maintenanceMsg
    });
  } catch (err) {
    console.error('Error fetching captcha config:', err);
    res.status(500).json({ error: 'Failed to fetch captcha configuration' });
  }
});

// POST /api/captcha/earn - Submit successful captcha solve & credit reward
router.post('/earn', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const settingsRows = await query('SELECT key_name, val_value FROM system_settings');
    const settings = {};
    settingsRows.forEach(r => { settings[r.key_name] = r.val_value; });

    const isEnabled = settings['captcha_enabled'] !== 'false' && 
                      settings['captcha_enabled'] !== '0' &&
                      settings['sec_captcha_enabled_bool'] !== 'false';

    if (!isEnabled) {
      const msg = settings['sec_captcha_notice'] || settings['captcha_maintenance_msg'] || 'CAPTCHA Work is currently under maintenance. Please check back later.';
      return res.status(400).json({ error: msg });
    }

    const rawVal = settings['captcha_reward_amount'] || 
                   settings['captcha_per_solve_income'] || 
                   settings['per_captcha_income'] || 
                   settings['sec_captcha_reward'] || 
                   settings['captcha_reward'] || 
                   '0.50';
    const rewardAmount = parseFloat(rawVal);
    if (isNaN(rewardAmount) || rewardAmount <= 0) {
      return res.status(400).json({ error: 'Invalid captcha reward rate setting' });
    }

    await transaction(async (conn) => {
      // Credit reward directly to Main Wallet
      await conn.execute(
        'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
        [rewardAmount, req.user.id]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Captcha Solve Reward", ?, "Success")',
        [req.user.id, `+₹${rewardAmount.toFixed(2)}`, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({
      message: `Reward ₹${rewardAmount.toFixed(2)} credited to Main Wallet`,
      earnedAmount: rewardAmount
    });
  } catch (err) {
    console.error('Captcha earn error:', err);
    res.status(500).json({ error: 'Failed to process captcha reward' });
  }
});

module.exports = router;
