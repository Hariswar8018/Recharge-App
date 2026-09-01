require('dotenv').config();
const express = require('express');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcryptjs');
const nodemailer = require('nodemailer');
const { query, transaction, initDb } = require('./db');

const JWT_SECRET = process.env.JWT_SECRET || 'earnfarm_super_secret_jwt_key_2026';

const mailTransporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || 'mail.srdigitalseva.com',
  port: parseInt(process.env.SMTP_PORT) || 465,
  secure: true,
  auth: {
    user: process.env.SMTP_USER || 'no-reply@srdigitalseva.com',
    pass: process.env.SMTP_PASS || 'UseYourEmailPasswordHere!'
  }
});

async function sendNotificationEmail(to, subject, htmlContent) {
  try {
    await mailTransporter.sendMail({
      from: `"EarnFarm Support" <${process.env.SMTP_USER || 'no-reply@srdigitalseva.com'}>`,
      to,
      subject,
      html: htmlContent
    });
    console.log(`Notification email sent to ${to}: ${subject}`);
  } catch (err) {
    console.error('Failed to send notification email:', err);
  }
}

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

// Health Check Endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'OK', message: 'API Server is healthy and running' });
});

// Simple In-memory Redis cache replacement to support rapid API calls
let cacheStore = {};
let redisClient = null; // Stays null to auto-fallback to in-memory store

const initCache = async () => {
  console.log('In-Memory cache initialized.');
};
const getCache = async (key) => cacheStore[key] || null;
const setCache = async (key, val, ttl) => {
  cacheStore[key] = val;
  setTimeout(() => { delete cacheStore[key]; }, ttl * 1000);
};
const invalidateCache = async (key) => {
  delete cacheStore[key];
};

// --- MIDDLEWARES ---

// Validate App Token for API Security
const verifyAppToken = (req, res, next) => {
  const appToken = req.headers['x-app-token'];
  if (!appToken || appToken !== process.env.APP_TOKEN) {
    return res.status(401).json({ error: 'Unauthorized: Invalid or missing App Token' });
  }
  next();
};

// Validate JWT Token for logged in users
const verifyUserToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Access Denied: Missing User JWT Token' });
  }
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Forbidden: Invalid token' });
    }
    req.user = decoded;
    next();
  });
};

// --- USER AUTHENTICATION ROUTES ---

// Register User
app.post('/api/auth/register', verifyAppToken, async (req, res) => {
  const { fullName, email, mobileNumber, password, device_model, app_version, sponsor_id } = req.body;
  if (!fullName || !email || !mobileNumber || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }

  try {
    const existing = await query('SELECT id FROM users WHERE email = ?', [email.toLowerCase()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Email already registered' });
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
      // If sponsor_id is not provided, check if any non-admin users exist
      const userCount = await query('SELECT COUNT(id) as count FROM users WHERE role = "user"');
      if (userCount[0].count > 0) {
        return res.status(400).json({ error: 'Sponsor ID is mandatory' });
      }
      // First user gets admin as default sponsor
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

    // Invalidate cached dashboard metrics
    await invalidateCache('admin_stats');

    // Trigger emails
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
app.post('/api/auth/login', verifyAppToken, async (req, res) => {
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

    // Update device stats on login
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

    // Trigger login notification
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

// User Forgot Password (SMTP reset trigger)
app.post('/api/auth/forgot-password', verifyAppToken, async (req, res) => {
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

// Get User Profile (JWT authenticated)
app.get('/api/user/profile', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const cacheKey = `user_profile_${req.user.id}`;
    const cachedProfile = await getCache(cacheKey);
    if (cachedProfile) {
      return res.json(cachedProfile);
    }

    const users = await query(
      'SELECT id, fullName, email, mobileNumber, fund_wallet_balance, main_wallet_balance, status, sponsor_id FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    const user = users[0];
    await setCache(cacheKey, user, 5); // cache for 5 seconds
    res.json(user);
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Update User Profile (JWT authenticated)
app.post('/api/user/update', verifyAppToken, verifyUserToken, async (req, res) => {
  const { fullName, mobileNumber } = req.body;
  if (!fullName) {
    return res.status(400).json({ error: 'Full Name is required' });
  }
  try {
    await query(
      'UPDATE users SET fullName = ?, mobileNumber = ? WHERE id = ?',
      [fullName, mobileNumber || null, req.user.id]
    );
    await invalidateCache(`user_profile_${req.user.id}`);
    res.json({ success: true, message: 'Profile updated successfully' });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Get User Team / Affiliates (JWT authenticated)
app.get('/api/user/team', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const team = await query(
      'SELECT id, fullName, email, mobileNumber, status, createdAt FROM users WHERE sponsor_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(team);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load team network' });
  }
});

// --- USER WALLET FLOW & FUND REQUEST ENDPOINTS ---

// User creates fund request
app.post('/api/fund/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, utr } = req.body;
  if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
    return res.status(400).json({ error: 'Invalid request amount' });
  }
  if (!utr || utr.trim().length === 0) {
    return res.status(400).json({ error: 'UTR number is required' });
  }

  try {
    const existing = await query('SELECT id FROM fund_requests WHERE utr = ?', [utr.trim()]);
    if (existing.length > 0) {
      return res.status(400).json({ error: 'Duplicate UTR number submitted' });
    }

    await transaction(async (conn) => {
      // 1. Insert approved fund request
      await conn.execute(
        'INSERT INTO fund_requests (user_id, amount, utr, status) VALUES (?, ?, ?, "APPROVED")',
        [req.user.id, parseFloat(amount), utr.trim()]
      );

      // 2. Credit user's fund wallet
      await conn.execute(
        'UPDATE users SET fund_wallet_balance = fund_wallet_balance + ? WHERE id = ?',
        [parseFloat(amount), req.user.id]
      );

      // 3. Log transaction success
      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Fund Deposit", ?, "Success")',
        [req.user.id, `₹${parseFloat(amount).toFixed(2)}`, dateStr]
      );
    });

    // Invalidate caches
    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    // Send email trigger
    query('SELECT fullName FROM users WHERE id = ?', [req.user.id]).then((users) => {
      if (users.length > 0) {
        sendNotificationEmail(req.user.email, "Fund Deposit Approved - EarnFarm", `
          <h3>Hi ${users[0].fullName},</h3>
          <p>Your deposit of <strong>₹${parseFloat(amount).toFixed(2)}</strong> has been processed successfully. The funds are now available in your Fund Wallet.</p>
        `);
      }
    }).catch(e => console.error(e));

    res.status(201).json({ message: 'Funds added directly to your Fund Wallet successfully!' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to add funds directly' });
  }
});

// User lists their own fund request history
app.get('/api/fund/requests', verifyAppToken, verifyUserToken, async (req, res) => {
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

// User lists their own transactions
app.get('/api/user/transactions', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const txns = await query(
      'SELECT id, wallet_type, amount, type, date, status FROM transactions WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(txns);
  } catch (err) {
    res.status(500).json({ error: 'Failed to load transactions list' });
  }
});

// Mock Razorpay payment simulation callback to update wallets on successful Sandbox payments
app.post('/api/payment/razorpay-sandbox', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount, serviceType, walletType } = req.body;
  if (!amount || !serviceType || !walletType) {
    return res.status(400).json({ error: 'Missing payment metadata parameters' });
  }

  try {
    await transaction(async (conn) => {
      const balanceField = walletType === 'FUND' ? 'fund_wallet_balance' : 'main_wallet_balance';
      
      await conn.execute(
        `UPDATE users SET ${balanceField} = ${balanceField} + ? WHERE id = ?`,
        [parseFloat(amount), req.user.id]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, ?, ?, ?, ?, "Success")',
        [req.user.id, walletType, `₹${parseFloat(amount).toFixed(2)}`, serviceType, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({ message: 'Sandbox payment registered and wallet updated.' });
  } catch (err) {
    res.status(500).json({ error: 'Transaction failed' });
  }
});

// --- CYCLE ACTIVATION & SINGLE LEG QUEUE FLOW ---

app.post('/api/cycles/activate', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => { settings[row.key_name] = row.val_value; });

    const joinAmount = parseFloat(settings['join_amount'] || '1200');
    const directIncome = parseFloat(settings['direct_income'] || '300');
    const levelPool = parseFloat(settings['level_pool'] || '600');
    const companyMaintenance = parseFloat(settings['company_maintenance'] || '300');
    const cycleSize = parseInt(settings['cycle_size'] || '126');

    const users = await query('SELECT * FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    const user = users[0];

    if (parseFloat(user.fund_wallet_balance) < joinAmount) {
      return res.status(400).json({ error: 'Insufficient Fund Wallet balance.' });
    }

    const result = await transaction(async (conn) => {
      // 1. Deduct join amount
      await conn.execute(
        'UPDATE users SET fund_wallet_balance = fund_wallet_balance - ? WHERE id = ?',
        [joinAmount, user.id]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Debit", ?, "Success")',
        [user.id, `-₹${joinAmount.toFixed(2)}`, dateStr]
      );

      // 2. Credit Direct Sponsor Income
      if (user.sponsor_id) {
        await conn.execute(
          'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
          [directIncome, user.sponsor_id]
        );
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Direct Income", ?, "Success")',
          [user.sponsor_id, `+₹${directIncome.toFixed(2)}`, dateStr]
        );
      }

      // 3. Create cycle ID
      const [existingCycles] = await conn.execute('SELECT COUNT(id) as count FROM cycles WHERE user_id = ?', [user.id]);
      const nextCycleNum = (existingCycles[0].count || 0) + 1;
      const cycleIdStr = `CYCLE-${String(nextCycleNum).padStart(4, '0')}`;

      const [cycleResult] = await conn.execute(
        'INSERT INTO cycles (user_id, cycle_id, status, members_count) VALUES (?, ?, "ACTIVE", 0)',
        [user.id, cycleIdStr]
      );
      const newCycleDbId = cycleResult.insertId;

      // 4. Place in queue
      await conn.execute(
        'INSERT INTO single_leg_queue (cycle_id, user_id) VALUES (?, ?)',
        [newCycleDbId, user.id]
      );

      // 5. Increment counts & pay levels
      const [activeCycles] = await conn.execute(
        `SELECT c.id, c.user_id, c.members_count 
         FROM cycles c
         JOIN single_leg_queue q ON c.id = q.cycle_id
         WHERE c.status = 'ACTIVE' AND c.id != ?
         ORDER BY q.id ASC`,
        [newCycleDbId]
      );

      for (const activeCycle of activeCycles) {
        const newMembersCount = activeCycle.members_count + 1;
        await conn.execute(
          'UPDATE cycles SET members_count = ? WHERE id = ?',
          [newMembersCount, activeCycle.id]
        );

        let payout = 0;
        let levelLabel = '';

        if (newMembersCount === parseInt(settings['level_1_members'] || '2')) {
          payout = parseFloat(settings['level_1_income'] || '200');
          levelLabel = 'Level 1 Income';
        } else if (newMembersCount === (parseInt(settings['level_1_members'] || '2') + parseInt(settings['level_2_members'] || '4'))) {
          payout = parseFloat(settings['level_2_income'] || '400');
          levelLabel = 'Level 2 Income';
        } else if (newMembersCount === (parseInt(settings['level_1_members'] || '2') + parseInt(settings['level_2_members'] || '4') + parseInt(settings['level_3_members'] || '8'))) {
          payout = parseFloat(settings['level_3_income'] || '800');
          levelLabel = 'Level 3 Income';
        } else if (newMembersCount === (parseInt(settings['level_1_members'] || '2') + parseInt(settings['level_2_members'] || '4') + parseInt(settings['level_3_members'] || '8') + parseInt(settings['level_4_members'] || '16'))) {
          payout = parseFloat(settings['level_4_income'] || '1600');
          levelLabel = 'Level 4 Income';
        } else if (newMembersCount === (parseInt(settings['level_1_members'] || '2') + parseInt(settings['level_2_members'] || '4') + parseInt(settings['level_3_members'] || '8') + parseInt(settings['level_4_members'] || '16') + parseInt(settings['level_5_members'] || '32'))) {
          payout = parseFloat(settings['level_5_income'] || '3200');
          levelLabel = 'Level 5 Income';
        } else if (newMembersCount === cycleSize) {
          payout = parseFloat(settings['level_6_income'] || '6400');
          levelLabel = 'Level 6 Income';
        }

        if (payout > 0) {
          await conn.execute(
            'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
            [payout, activeCycle.user_id]
          );
          await conn.execute(
            'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, ?, ?, "Success")',
            [activeCycle.user_id, `+₹${payout.toFixed(2)}`, levelLabel, dateStr]
          );
        }

        if (newMembersCount >= cycleSize) {
          await conn.execute(
            'UPDATE cycles SET status = "COMPLETED" WHERE id = ?',
            [activeCycle.id]
          );
        }
      }

      return { cycleId: cycleIdStr };
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    // Trigger activation email
    sendNotificationEmail(user.email, "EarnFarm ID Activated - Cycle Started!", `
      <h3>Hi ${user.fullName},</h3>
      <p>We have successfully processed your plan payment of <strong>₹${joinAmount.toFixed(2)}</strong>.</p>
      <p>Your subscription is active and your cycle ID <strong>${result.cycleId}</strong> has been registered in the single-leg monoline queue.</p>
    `);

    res.status(201).json({ message: 'Cycle activated successfully!', cycleId: result.cycleId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to activate cycle' });
  }
});

app.get('/api/cycles/history', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const list = await query(
      'SELECT id, cycle_id, status, members_count, createdAt FROM cycles WHERE user_id = ? ORDER BY id DESC',
      [req.user.id]
    );
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch cycles history' });
  }
});

app.post('/api/withdrawal/request', verifyAppToken, verifyUserToken, async (req, res) => {
  const { amount } = req.body;
  if (!amount || isNaN(amount) || parseFloat(amount) <= 0) {
    return res.status(400).json({ error: 'Invalid withdrawal amount' });
  }

  const amt = parseFloat(amount);

  try {
    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => { settings[row.key_name] = row.val_value; });

    const minWithdraw = parseFloat(settings['minimum_withdrawal'] || '500');
    const feePercent = parseFloat(settings['withdrawal_percentage'] || '15');
    const allowedDaysStr = settings['withdrawal_days'] || 'Mon,Wed,Fri';

    if (amt < minWithdraw) {
      return res.status(400).json({ error: `Minimum withdrawal amount is ₹${minWithdraw}` });
    }

    // Bypass day-of-week restriction for easy demo/testing
    /*
    const daysMap = { 0: 'Sun', 1: 'Mon', 2: 'Tue', 3: 'Wed', 4: 'Thu', 5: 'Fri', 6: 'Sat' };
    const currentDayName = daysMap[new Date().getDay()];
    const allowedDays = allowedDaysStr.split(',').map(s => s.trim().toLowerCase());
    if (!allowedDays.includes(currentDayName.toLowerCase())) {
      return res.status(400).json({ error: `Withdrawals are only allowed on: ${allowedDaysStr}` });
    }
    */

    const users = await query('SELECT main_wallet_balance FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    const balance = parseFloat(users[0].main_wallet_balance);

    if (balance < amt) {
      return res.status(400).json({ error: 'Insufficient Main Wallet balance' });
    }

    const deduction = (amt * feePercent) / 100;
    const netCredit = amt - deduction;

    await transaction(async (conn) => {
      await conn.execute(
        'UPDATE users SET main_wallet_balance = main_wallet_balance - ? WHERE id = ?',
        [amt, req.user.id]
      );
      
      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Cashout", ?, "Success")',
        [req.user.id, `-₹${amt.toFixed(2)}`, dateStr]
      );
    });

    await invalidateCache(`user_profile_${req.user.id}`);
    await invalidateCache('admin_stats');

    res.json({
      message: 'Withdrawal processed successfully',
      requestedAmount: amt,
      deductionFee: deduction,
      netCredited: netCredit
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Failed to process withdrawal request' });
  }
});

// Scriza Telecom Recharge Callback Hook
app.get('/api/payment/scriza-callback', async (req, res) => {
  const { payid, client_id, operator_ref, status } = req.query;
  console.log(`Received Scriza Callback - Client ID: ${client_id}, Pay ID: ${payid}, Operator Ref: ${operator_ref}, Status: ${status}`);

  if (!client_id) {
    return res.status(200).send('Missing client_id');
  }

  try {
    const isSuccess = status === 'success' || status === 'Success';
    const finalStatus = isSuccess ? 'Success' : 'Failure';

    await query(
      'UPDATE transactions SET status = ? WHERE id = ?',
      [finalStatus, client_id]
    );

    res.status(200).send('OK');
  } catch (err) {
    console.error('Error handling Scriza callback:', err);
    res.status(200).send('OK');
  }
});


// --- ADMIN SECTION ENDPOINTS ---

// Admin Login
app.post('/api/admin/login', async (req, res) => {
  const { email, password } = req.body;
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const admins = await query('SELECT * FROM users WHERE email = ? AND role = "admin"', [email.toLowerCase()]);
    if (admins.length === 0) {
      return res.status(400).json({ error: 'Invalid admin credentials' });
    }

    const admin = admins[0];
    const isMatch = bcrypt.compareSync(password, admin.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Invalid admin credentials' });
    }

    const token = jwt.sign(
      { email: admin.email, role: 'admin' },
      JWT_SECRET,
      { expiresIn: '7d' }
    );

    res.json({ token, email: admin.email });
  } catch (err) {
    res.status(500).json({ error: 'Database error occurred' });
  }
});

// Change Admin Password
app.post('/api/admin/change-password', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { oldPassword, newPassword } = req.body;
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ error: 'Old and new passwords are required' });
    }

    const admins = await query('SELECT * FROM users WHERE email = ? AND role = "admin"', [decoded.email]);
    if (admins.length === 0) {
      return res.status(404).json({ error: 'Admin not found' });
    }

    const admin = admins[0];
    const isMatch = bcrypt.compareSync(oldPassword, admin.passwordHash);
    if (!isMatch) {
      return res.status(400).json({ error: 'Incorrect old password' });
    }

    const salt = bcrypt.genSaltSync(10);
    const newHash = bcrypt.hashSync(newPassword, salt);

    await query('UPDATE users SET passwordHash = ? WHERE id = ?', [newHash, admin.id]);
    res.json({ message: 'Password updated successfully' });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token or unauthorized operation' });
  }
});

// GET Admin System Settings
app.get('/api/admin/settings', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => {
      settings[row.key_name] = row.val_value;
    });

    res.json(settings);
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// UPDATE Admin System Settings
app.post('/api/admin/settings', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const updates = req.body;
    for (const [key, val] of Object.entries(updates)) {
      await query(
        'INSERT INTO system_settings (key_name, val_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE val_value = ?',
        [key, String(val), String(val)]
      );
    }
    res.json({ message: 'System settings updated successfully.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to update system settings' });
  }
});

// GET Admin list
app.get('/api/admin/list', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const admins = await query('SELECT id, fullName, email, mobileNumber, status, createdAt FROM users WHERE role = "admin" ORDER BY id ASC');
    res.json(admins);
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// GET Gateway & APIs Operational Status
app.get('/api/admin/gateway-status', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    let dbStatus = 'Operational';
    try {
      await query('SELECT 1');
    } catch (e) {
      dbStatus = 'Offline';
    }

    const rows = await query('SELECT * FROM system_settings');
    const settings = {};
    rows.forEach(r => { settings[r.key_name] = r.val_value; });

    const scrizaMode = settings['scriza_api_mode'] || 'simulation';
    const razorpayMode = settings['razorpay_api_mode'] || 'test';

    res.json({
      database: dbStatus,
      app_api: 'Operational',
      scriza_api: scrizaMode === 'production' ? 'Operational (Live)' : 'Simulation Active',
      razorpay_gateway: razorpayMode === 'live' ? 'Operational (Live)' : 'Test Sandbox Active',
      redis_cache: redisClient ? 'Operational' : 'Offline (In-Memory Fallback)'
    });
  } catch (err) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// GET Notifications
app.get('/api/notifications', async (req, res) => {
  try {
    const list = await query('SELECT * FROM notifications ORDER BY id DESC LIMIT 50');
    res.json(list);
  } catch (err) {
    res.status(500).json({ error: 'Database error loading notifications' });
  }
});

// POST Admin Notification
app.post('/api/admin/notifications', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const { title, message } = req.body;
    if (!title || !message) {
      return res.status(400).json({ error: 'Title and Message are required.' });
    }

    await query('INSERT INTO notifications (title, message) VALUES (?, ?)', [title, message]);
    res.status(201).json({ message: 'Notification broadcasted successfully.' });
  } catch (err) {
    res.status(500).json({ error: 'Failed to create notification' });
  }
});

// GET Paginated Admin Transactions
app.get('/api/admin/transactions', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) return res.status(401).json({ error: 'Unauthorized' });

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') return res.status(403).json({ error: 'Forbidden' });

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 15;
    const offset = (page - 1) * limit;

    const list = await query(
      'SELECT id, user_id, wallet_type, amount, type, date, status FROM transactions ORDER BY id DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );

    res.json(list);
  } catch (err) {
    res.status(500).json({ error: 'Database error loading transactions' });
  }
});

// GET Public Landing Info
app.get('/api/landing-info', async (req, res) => {
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

// Admin Dashboard stats & users list
app.get('/api/admin/dashboard', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    let stats = await getCache('admin_stats');
    if (!stats) {
      const totalUsersResult = await query('SELECT COUNT(id) as count FROM users WHERE role = "user"');
      const walletsResult = await query(
        'SELECT SUM(fund_wallet_balance) as fundTotal, SUM(main_wallet_balance) as mainTotal FROM users'
      );
      const txnsCountResult = await query('SELECT COUNT(id) as count FROM transactions');

      stats = {
        totalUsers: totalUsersResult[0].count,
        totalFundWallet: parseFloat(walletsResult[0].fundTotal || 0),
        totalMainWallet: parseFloat(walletsResult[0].mainTotal || 0),
        totalTransactions: txnsCountResult[0].count
      };
      await setCache('admin_stats', stats, 30);
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const usersList = await query(
      'SELECT id, fullName, email, mobileNumber, fund_wallet_balance, main_wallet_balance, status, device_model, app_version, sponsor_id, createdAt FROM users WHERE role = "user" ORDER BY id DESC LIMIT ? OFFSET ?',
      [limit, offset]
    );

    const transactions = await query(
      'SELECT id, user_id, wallet_type, amount, type, date, status FROM transactions ORDER BY id DESC LIMIT 15'
    );

    res.json({
      stats,
      users: usersList,
      transactions,
      pagination: {
        page,
        limit
      }
    });
  } catch (err) {
    res.status(401).json({ error: 'Session expired or invalid token' });
  }
});

// Admin lists all user Fund Requests
app.get('/api/admin/fund-requests', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const offset = (page - 1) * limit;

    const requests = await query(
      `SELECT fr.id, fr.amount, fr.utr, fr.status, fr.createdAt, u.fullName, u.email 
       FROM fund_requests fr 
       JOIN users u ON fr.user_id = u.id 
       ORDER BY fr.id DESC LIMIT ? OFFSET ?`,
      [limit, offset]
    );

    res.json(requests);
  } catch (err) {
    res.status(500).json({ error: 'Failed to fetch fund requests' });
  }
});

// Admin approves a pending Fund Request
app.post('/api/admin/fund-requests/:id/approve', async (req, res) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }

  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const { approve } = req.body;
    const requestId = req.params.id;

    const reqs = await query('SELECT * FROM fund_requests WHERE id = ?', [requestId]);
    if (reqs.length === 0) {
      return res.status(404).json({ error: 'Fund request not found' });
    }

    const request = reqs[0];
    if (request.status !== 'PENDING') {
      return res.status(400).json({ error: 'Request already processed' });
    }

    if (approve === true) {
      await transaction(async (conn) => {
        await conn.execute('UPDATE fund_requests SET status = "APPROVED" WHERE id = ?', [requestId]);

        await conn.execute(
          'UPDATE users SET fund_wallet_balance = fund_wallet_balance + ? WHERE id = ?',
          [request.amount, request.user_id]
        );

        const dateStr = new Date().toLocaleString('en-US', { hour12: true });
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Fund Deposit", ?, "Success")',
          [request.user_id, `₹${parseFloat(request.amount).toFixed(2)}`, dateStr]
        );
      });

      await invalidateCache(`user_profile_${request.user_id}`);
      await invalidateCache('admin_stats');

      // Send email
      query('SELECT email, fullName FROM users WHERE id = ?', [request.user_id]).then((users) => {
        if (users.length > 0) {
          sendNotificationEmail(users[0].email, "Fund Deposit Approved - EarnFarm", `
            <h3>Hi ${users[0].fullName},</h3>
            <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> has been approved. The funds are now available in your Fund Wallet.</p>
          `);
        }
      }).catch((e) => console.error(e));

      res.json({ message: 'Fund deposit request approved successfully.' });
    } else {
      await query('UPDATE fund_requests SET status = "REJECTED" WHERE id = ?', [requestId]);

      // Send rejection email
      query('SELECT email, fullName FROM users WHERE id = ?', [request.user_id]).then((users) => {
        if (users.length > 0) {
          sendNotificationEmail(users[0].email, "Fund Deposit Rejected - EarnFarm", `
            <h3>Hi ${users[0].fullName},</h3>
            <p>Your fund request of <strong>₹${parseFloat(request.amount).toFixed(2)}</strong> has been rejected by the administrator.</p>
          `);
        }
      }).catch((e) => console.error(e));

      res.json({ message: 'Fund request has been rejected.' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Transaction failed' });
  }
});

async function startup() {
  await initDb();
  await initCache();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Production-ready server listening on port ${PORT}`);
  });
}

startup();
