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
      app_share_text: data['app_share_text'] || 'Download our App to Earn Money from Scratch Cards',
      playstore_link: data['playstore_link'] || 'https://play.google.com/store/apps/details?id=com.app.earnfarm',
      playstore_package_id: data['playstore_package_id'] || 'com.app.earnfarm',
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

// GET Public Element Visibility Settings (Show / Hide options for all Web & App elements)
router.get('/visibility', async (req, res) => {
  try {
    const rows = await query('SELECT key_name, val_value FROM system_settings');
    const settings = {};
    rows.forEach(r => { settings[r.key_name] = r.val_value; });

    // Standardized Show/Hide state dictionary
    const visibility = {
      // Web Landing Page Elements
      web_show_header_logo: settings['web_show_header_logo'] !== 'Hide',
      web_show_hero_graphic: settings['web_show_hero_graphic'] !== 'Hide',
      web_show_headline: settings['web_show_headline'] !== 'Hide',
      web_show_referral_banner: settings['web_show_referral_banner'] !== 'Hide',
      web_show_playstore_btn: settings['web_show_playstore_btn'] !== 'Hide',
      web_show_terms_disclaimer: settings['web_show_terms_disclaimer'] !== 'Hide',
      web_show_footer: settings['web_show_footer'] !== 'Hide',

      // App & Panel Elements
      ref_section_visibility: settings['ref_section_visibility'] || 'Show',
      ref_invite_button_visibility: settings['ref_invite_button_visibility'] || 'Show',
      sub_user_details_visibility: settings['sub_user_details_visibility'] || 'Show',
      sub_wallet_visibility: settings['sub_wallet_visibility'] || 'Show',
      sub_button_visibility: settings['sub_button_visibility'] || 'Show',
      cashout_section_visibility: settings['cashout_section_visibility'] || 'Show',
      cashout_submit_button_visibility: settings['cashout_submit_button_visibility'] || 'Show',
      add_money_section_visibility: settings['add_money_section_visibility'] || 'Show',
      captcha_section_visibility: settings['captcha_section_visibility'] || 'Show',
      notice_marquee_visibility: settings['notice_marquee_visibility'] || 'Show',

      // User Management & Section Configurations
      sec_registration_visibility: settings['sec_registration_visibility'] || 'Show',
      sec_registration_enabled: settings['registration_enabled'] !== 'false' && settings['registration_enabled_bool'] !== 'false',
      sec_registration_rule_mode: settings['sec_registration_rule_mode'] || 'Enabled (Standard)',
      sec_registration_notice: settings['sec_registration_notice'] || '',
      sec_login_visibility: settings['sec_login_visibility'] || 'Show',
      sec_login_enabled: settings['login_enabled'] !== 'false' && settings['login_enabled_bool'] !== 'false',
      sec_login_rule_mode: settings['sec_login_rule_mode'] || 'Enabled (Standard)',
      sec_login_notice: settings['sec_login_notice'] || '',
      sec_otp_visibility: settings['sec_otp_visibility'] || 'Show',
      sec_otp_enabled: settings['forgot_password_enabled'] !== 'false' && settings['forgot_password_enabled_bool'] !== 'false',
      sec_otp_rule_mode: settings['sec_otp_rule_mode'] || 'Enabled (Standard)',
      sec_otp_notice: settings['sec_otp_notice'] || '',
      sec_home_visibility: settings['sec_home_visibility'] || 'Show',
      sec_home_enabled: settings['sec_home_enabled_bool'] !== 'false',
      sec_home_rule_mode: settings['sec_home_rule_mode'] || 'Enabled (Standard)',
      sec_home_notice: settings['sec_home_notice'] || '',
      sec_business_income_visibility: settings['sec_business_income_visibility'] || 'Show',
      sec_business_income_enabled: settings['sec_business_income_enabled_bool'] !== 'false',
      sec_business_income_rule_mode: settings['sec_business_income_rule_mode'] || 'Enabled (Standard)',
      sec_business_income_notice: settings['sec_business_income_notice'] || '',
      sec_global_cycle_visibility: settings['sec_global_cycle_visibility'] || 'Show',
      sec_global_cycle_enabled: settings['sec_global_cycle_enabled_bool'] !== 'false',
      sec_global_cycle_rule_mode: settings['sec_global_cycle_rule_mode'] || 'Enabled (Standard)',
      sec_global_cycle_notice: settings['sec_global_cycle_notice'] || '',
      sec_captcha_visibility: settings['sec_captcha_visibility'] || settings['captcha_section_visibility'] || 'Show',
      sec_captcha_enabled: settings['sec_captcha_enabled_bool'] !== 'false',
      sec_captcha_rule_mode: settings['sec_captcha_rule_mode'] || 'Enabled (Standard)',
      sec_captcha_notice: settings['sec_captcha_notice'] || '',
      sec_bank_verification_visibility: settings['sec_bank_verification_visibility'] || 'Show',
      sec_bank_verification_enabled: settings['sec_bank_verification_enabled_bool'] !== 'false',
      sec_bank_verification_rule_mode: settings['sec_bank_verification_rule_mode'] || 'Enabled (Standard)',
      sec_bank_verification_notice: settings['sec_bank_verification_notice'] || '',
      sec_support_visibility: settings['sec_support_visibility'] || 'Show',
      sec_support_enabled: settings['sec_support_enabled_bool'] !== 'false',
      sec_support_rule_mode: settings['sec_support_rule_mode'] || 'Enabled (Standard)',
      sec_support_notice: settings['sec_support_notice'] || '',

      raw_settings: settings
    };

    res.json(visibility);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch visibility settings' });
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

