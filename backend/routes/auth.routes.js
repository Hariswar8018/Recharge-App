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

  const weakPasswords = ['123456', '12345678', '123456789', '1234567890', 'password', 'qwerty', '11111111', 'abcdef'];
  if (!password || password.length < 8) {
    return res.status(400).json({ error: 'Password must be at least 8 characters long' });
  }
  if (weakPasswords.includes(password.toLowerCase()) || /^(\d)\1+$/.test(password)) {
    return res.status(400).json({ error: 'Simple or predictable passwords (like 123456) are not allowed' });
  }
  if (!/[A-Z]/.test(password) || !/[a-z]/.test(password) || !/[0-9]/.test(password) || !/[!@#\$&*~%]/.test(password)) {
    return res.status(400).json({ error: 'Password must contain uppercase, lowercase, number, and special character' });
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
      } else if (cleanSponsorId.startsWith('SRM')) {
        cleanSponsorId = cleanSponsorId.replace('SRM', '');
      } else if (cleanSponsorId.startsWith('SRSPO')) {
        cleanSponsorId = cleanSponsorId.replace('SRSPO', '');
      } else if (cleanSponsorId.startsWith('R')) {
        cleanSponsorId = cleanSponsorId.replace('R', '');
      }
      const numericId = parseInt(cleanSponsorId, 10);
      const sponsor = await query('SELECT id FROM users WHERE id = ? OR mobileNumber = ?', [isNaN(numericId) ? cleanSponsorId : numericId, cleanSponsorId]);
      if (sponsor.length === 0) {
        return res.status(400).json({ error: 'User Not Found' });
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
      'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, fund_wallet_balance, main_wallet_balance, status, device_model, app_version, sponsor_id) VALUES (?, ?, ?, ?, ?, 0.00, 0.00, "PENDING", ?, ?, ?)',
      [fullName, email.toLowerCase(), cleanMobile, passwordHash, password, device_model || 'Unknown', app_version || '1.0.0', sponsorIdVal]
    );

    await invalidateCache('admin_stats');

    sendNotificationEmail(email.toLowerCase(), "Welcome to SR Digital Seva!", `
      <h3>Welcome, ${fullName}!</h3>
      <p>Your account was successfully registered.</p>
      <p>Your Mobile Number / User ID is: <strong>${cleanMobile}</strong></p>
    `);

    if (sponsorIdVal) {
      query('SELECT email, fullName FROM users WHERE id = ?', [sponsorIdVal]).then((sponsors) => {
        if (sponsors.length > 0) {
          sendNotificationEmail(sponsors[0].email, "New Affiliate Joined Your Team!", `
            <h3>Hi ${sponsors[0].fullName},</h3>
            <p>A new member <strong>${fullName}</strong> has joined your team.</p>
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

// Check Sponsor ID for registration
router.post('/check-sponsor', verifyAppToken, async (req, res) => {
  const { sponsor_id } = req.body;
  if (!sponsor_id || !sponsor_id.toString().trim()) {
    return res.status(400).json({ valid: false, error: 'Sponsor ID is required' });
  }

  let cleanSponsorId = sponsor_id.toString().trim().toUpperCase();
  if (cleanSponsorId.startsWith('EARNFARMX7AQ96SD')) {
    cleanSponsorId = cleanSponsorId.replace('EARNFARMX7AQ96SD', '');
  } else if (cleanSponsorId.startsWith('EARNFARM')) {
    cleanSponsorId = cleanSponsorId.replace('EARNFARM', '');
  } else if (cleanSponsorId.startsWith('EARNKARO97US77')) {
    cleanSponsorId = cleanSponsorId.replace('EARNKARO97US77', '');
  } else if (cleanSponsorId.startsWith('SRM')) {
    cleanSponsorId = cleanSponsorId.replace('SRM', '');
  } else if (cleanSponsorId.startsWith('SRSPO')) {
    cleanSponsorId = cleanSponsorId.replace('SRSPO', '');
  } else if (cleanSponsorId.startsWith('R')) {
    cleanSponsorId = cleanSponsorId.replace('R', '');
  }
  const numericId = parseInt(cleanSponsorId, 10);

  try {
    const users = await query(
      'SELECT id, fullName FROM users WHERE id = ? OR mobileNumber = ?',
      [isNaN(numericId) ? cleanSponsorId : numericId, cleanSponsorId]
    );
    if (users.length === 0) {
      return res.json({ valid: false, error: 'User Not Found' });
    }
    return res.json({ valid: true, name: users[0].fullName, sponsorId: users[0].id });
  } catch (err) {
    console.error('Check sponsor error:', err);
    res.status(500).json({ valid: false, error: 'Server error checking sponsor ID' });
  }
});

// Check Mobile Number availability for registration
router.post('/check-mobile-available', verifyAppToken, async (req, res) => {
  const { mobileNumber } = req.body;
  if (!mobileNumber) {
    return res.status(400).json({ valid: false, message: 'Enter 10 digit mobile number' });
  }

  const cleanMobile = mobileNumber.toString().trim();
  if (!/^\d{10}$/.test(cleanMobile)) {
    return res.status(400).json({ valid: false, message: 'Enter 10 digit mobile number' });
  }

  // Check dummy / repeated numbers
  if (/^(\d)\1{9}$/.test(cleanMobile) || cleanMobile === '1234567890' || cleanMobile === '0987654321') {
    return res.json({ valid: false, message: 'Invalid mobile number' });
  }

  try {
    const users = await query('SELECT id FROM users WHERE mobileNumber = ?', [cleanMobile]);
    if (users.length > 0) {
      return res.json({ valid: false, registered: true, message: 'Already Registered' });
    } else {
      return res.json({ valid: true, registered: false, message: 'Valid (Can Register)' });
    }
  } catch (err) {
    console.error('Check mobile available error:', err);
    res.status(500).json({ valid: false, message: 'Server error checking mobile number' });
  }
});

// Check if Email is registered (for Forgot Password real-time validation)
router.post('/check-email', verifyAppToken, async (req, res) => {
  const { email } = req.body;
  if (!email || !email.toString().trim()) {
    return res.status(400).json({ registered: false, message: 'Email ID not found. Please enter a registered email ID.' });
  }

  try {
    const users = await query('SELECT id FROM users WHERE email = ?', [email.toString().trim().toLowerCase()]);
    if (users.length > 0) {
      return res.json({ registered: true, message: 'Valid registered email address' });
    } else {
      return res.json({ registered: false, message: 'Email ID not found. Please enter a registered email ID.' });
    }
  } catch (err) {
    console.error('Check email error:', err);
    res.status(500).json({ registered: false, message: 'Server error checking email' });
  }
});

// Check if Email is available for Registration
router.post('/check-email-available', verifyAppToken, async (req, res) => {
  const { email } = req.body;
  if (!email || !email.toString().trim()) {
    return res.status(400).json({ valid: false, message: 'Enter valid email address' });
  }

  const cleanEmail = email.toString().trim().toLowerCase();
  const emailRegex = /^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/;
  if (!emailRegex.test(cleanEmail)) {
    return res.status(400).json({ valid: false, message: 'Enter valid email address' });
  }

  try {
    const users = await query('SELECT id FROM users WHERE email = ?', [cleanEmail]);
    if (users.length > 0) {
      return res.json({ valid: false, registered: true, message: 'Email Already Registered' });
    } else {
      return res.json({ valid: true, registered: false, message: 'Valid Email (Available)' });
    }
  } catch (err) {
    console.error('Check email available error:', err);
    res.status(500).json({ valid: false, message: 'Server error checking email' });
  }
});

// Check if Mobile Number is Registered in system (for Login screen)
router.post('/check-mobile', verifyAppToken, async (req, res) => {
  const { mobileNumber } = req.body;
  if (!mobileNumber) {
    return res.status(400).json({ registered: false, error: 'Mobile number is required' });
  }

  const cleanMobile = mobileNumber.toString().trim();
  if (!/^\d{10}$/.test(cleanMobile)) {
    return res.status(400).json({ registered: false, error: 'Mobile number must be exactly 10 digits' });
  }

  try {
    const users = await query('SELECT id FROM users WHERE (mobileNumber = ? OR email = ?) AND (role = "user" OR role IS NULL)', [cleanMobile, cleanMobile]);
    if (users.length > 0) {
      return res.json({ registered: true, message: 'Valid registered mobile number' });
    } else {
      return res.json({ registered: false, message: 'This mobile number is not registered. Please use your registered mobile number.' });
    }
  } catch (err) {
    console.error('Check mobile error:', err);
    res.status(500).json({ registered: false, error: 'Server error checking mobile number' });
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

    sendNotificationEmail(user.email, "New Login Detected - SR Digital Seva", `
      <h3>Hello ${user.fullName},</h3>
      <p>A new login was recorded for your SR Digital Seva account on ${new Date().toLocaleString()}.</p>
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

// Forgot Password - Sends registered password directly to user email
router.post('/forgot-password', verifyAppToken, async (req, res) => {
  const { email } = req.body;
  if (!email || !email.toString().trim()) {
    return res.status(400).json({ registered: false, error: 'Email ID not found. Please enter a registered email ID.' });
  }

  const cleanEmail = email.toString().trim().toLowerCase();

  try {
    const users = await query('SELECT id, fullName, email, plain_password FROM users WHERE email = ? OR mobileNumber = ?', [cleanEmail, cleanEmail]);
    if (users.length === 0) {
      return res.status(404).json({ registered: false, error: 'Email ID not found. Please enter a registered email ID.' });
    }

    const user = users[0];
    let passwordToSend = user.plain_password;

    if (!passwordToSend) {
      // Generate standard readable temporary password if plain_password wasn't saved previously
      const rand = Math.floor(1000 + Math.random() * 9000);
      passwordToSend = `Pass@${rand}`;
      const salt = bcrypt.genSaltSync(10);
      const hash = bcrypt.hashSync(passwordToSend, salt);
      await query('UPDATE users SET passwordHash = ?, plain_password = ? WHERE id = ?', [hash, passwordToSend, user.id]);
    }

    const mailRes = await sendNotificationEmail(user.email, "Your Account Password - SR Digital Seva", `
      <h3>Hello ${user.fullName},</h3>
      <p>Your account password is: <strong style="font-size: 16px; color: #10B981;">${passwordToSend}</strong></p>
      <p>Please use this password to login to your account.</p>
    `);

    if (mailRes && mailRes.success === false) {
      return res.status(500).json({
        registered: true,
        success: false,
        error: `Failed to send email via SMTP: ${mailRes.error}`
      });
    }

    res.json({
      registered: true,
      success: true,
      message: 'Password has been sent to your registered email ID.'
    });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ registered: false, success: false, error: 'Failed to send password. Please check backend log.' });
  }
});

module.exports = router;
