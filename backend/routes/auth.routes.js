const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { query } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { JWT_SECRET, verifyAppToken } = require('../middleware/auth');

const router = express.Router();

// Register User
router.post('/register', verifyAppToken, async (req, res) => {
  const { fullName, email, mobileNumber, password, device_model, app_version, sponsor_id } = req.body;
  if (!fullName || !email || !mobileNumber || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  const cleanMobile = mobileNumber.toString().trim();
  if (!/^\d{10}$/.test(cleanMobile)) {
    return res.status(400).json({ error: 'Mobile number must be exactly 10 digits' });
  }

  try {
    const existing = await query('SELECT id FROM users WHERE email = ?', [email.toLowerCase()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
    }

    const existingMobile = await query('SELECT id FROM users WHERE mobileNumber = ?', [cleanMobile]);
    if (existingMobile.length > 0) {
      return res.status(400).json({ error: 'Mobile number already registered to another User ID' });
    }

    let sponsorIdVal = null;
    if (sponsor_id) {
      let cleanSponsorId = sponsor_id.toString().trim().toUpperCase();
      if (cleanSponsorId.startsWith('EARNFARMX7AQ96SD')) {
        cleanSponsorId = cleanSponsorId.replace('EARNFARMX7AQ96SD', '');
      } else if (cleanSponsorId.startsWith('EARNFARM')) {
        cleanSponsorId = cleanSponsorId.replace('EARNFARM', '');
      } else if (cleanSponsorId.startsWith('EARNKARO97US77')) {
        cleanSponsorId = cleanSponsorId.replace('EARNKARO97US77', '');
      }
      const sponsor = await query('SELECT id FROM users WHERE id = ?', [cleanSponsorId]);
      if (sponsor.length === 0) {
        return res.status(400).json({ error: 'Invalid Sponsor ID' });
      }
      sponsorIdVal = sponsor[0].id;
    } else {
      const userCount = await query('SELECT COUNT(id) as count FROM users WHERE role = "user"');
      if (userCount[0].count > 0) {
        return res.status(400).json({ error: 'Sponsor ID is mandatory' });
      }
      const admins = await query('SELECT id FROM users WHERE role = "admin" ORDER BY id ASC LIMIT 1');
      if (admins.length > 0) {
        sponsorIdVal = admins[0].id;
      }
    }

    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync(password, salt);

    await query(
      'INSERT INTO users (fullName, email, mobileNumber, passwordHash, fund_wallet_balance, main_wallet_balance, device_model, app_version, sponsor_id) VALUES (?, ?, ?, ?, 0.00, 0.00, ?, ?, ?)',
      [fullName, email.toLowerCase(), mobileNumber, passwordHash, device_model || 'Unknown', app_version || '1.0.0', sponsorIdVal]
    );

    await invalidateCache('admin_stats');

    sendNotificationEmail(email.toLowerCase(), "Welcome to EarnFarm!", `
      <h3>Welcome to EarnFarm, ${fullName}!</h3>
      <p>Your account was successfully registered.</p>
      <p>Please activate your account by purchasing the Basic Plan to start earning sponsor and pool income.</p>
    `);

    if (sponsorIdVal) {
      query('SELECT email, fullName FROM users WHERE id = ?', [sponsorIdVal]).then((sponsors) => {
        if (sponsors.length > 0) {
          sendNotificationEmail(sponsors[0].email, "New Affiliate Joined Your Team!", `
            <h3>Hi ${sponsors[0].fullName},</h3>
            <p>A new member <strong>${fullName}</strong> has joined your team using your referral code.</p>
          `);
        }
      }).catch((e) => console.error('Sponsor query fail:', e));
    }

    res.status(201).json({ message: 'User registered successfully' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Database error occurred during registration' });
  }
});

// Login User
router.post('/login', verifyAppToken, async (req, res) => {
  const { email, password, device_model, app_version } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const users = await query('SELECT * FROM users WHERE (email = ? OR mobileNumber = ?) AND role = "user"', [email.toLowerCase(), email]);
    if (users.length === 0) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    const user = users[0];
    const isMatch = bcrypt.compareSync(password, user.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid credentials' });
    }

    if (device_model || app_version) {
      await query(
        'UPDATE users SET device_model = ?, app_version = ? WHERE id = ?',
        [device_model || 'Unknown', app_version || '1.0.0', user.id]
      );
    }

    const token = jwt.sign(
      { id: user.id, email: user.email, role: 'user' },
      JWT_SECRET,
      { expiresIn: '30d' }
    );

    sendNotificationEmail(user.email, "New Login Detected - EarnFarm", `
      <h3>Hello ${user.fullName},</h3>
      <p>A new login was recorded for your EarnFarm account on ${new Date().toLocaleString()}.</p>
    `);

    res.json({
      token,
      user: {
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        mobileNumber: user.mobileNumber,
        fund_wallet_balance: user.fund_wallet_balance,
        main_wallet_balance: user.main_wallet_balance,
        status: user.status
      }
    });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred during login' });
  }
});

// Forgot Password
router.post('/forgot-password', verifyAppToken, async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ error: 'Email is required' });
  }

  try {
    const users = await query('SELECT id, fullName FROM users WHERE email = ?', [email.trim().toLowerCase()]);
    if (users.length === 0) {
      return res.status(404).json({ error: 'No user registered with this email address' });
    }

    const otp = Math.floor(100000 + Math.random() * 900000);
    const tempPassword = `Temp${otp}`;
    const salt = bcrypt.genSaltSync(10);
    const hash = bcrypt.hashSync(tempPassword, salt);

    await query('UPDATE users SET passwordHash = ? WHERE id = ?', [hash, users[0].id]);

    sendNotificationEmail(email.trim().toLowerCase(), "Temporary Password Reset - EarnFarm", `
      <h3>Hi ${users[0].fullName},</h3>
      <p>We received a password reset request for your EarnFarm account.</p>
      <p>Your password has been reset to the following temporary password:</p>
      <p style="font-size: 16px; font-weight: bold; color: #1e3a8a; background: #f1f5f9; padding: 10px; display: inline-block;">${tempPassword}</p>
      <p>Please log in using this temporary password and update it in your profile settings immediately.</p>
    `);

    res.json({ message: 'Temporary password sent to your email address successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to reset password. Please check backend log.' });
  }
});

module.exports = router;
