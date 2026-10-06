const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Cycle Activation / Top-Up / Plan Join
router.post('/activate', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => { settings[row.key_name] = row.val_value; });

    const joinAmount = parseFloat(settings['join_amount'] || settings['top_up_amount'] || '1200');
    const directIncome = parseFloat(settings['direct_income'] || '300');
    const cycleSize = parseInt(settings['cycle_size'] || '126');

    const users = await query('SELECT * FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    const user = users[0];

    const { mobile } = req.body;
    let targetUser = user;
    if (mobile && mobile.toString().trim()) {
      const cleanTarget = mobile.toString().trim();
      const digitsOnly = cleanTarget.replace(/\D/g, '');
      const last10 = digitsOnly.length >= 10 ? digitsOnly.slice(-10) : digitsOnly;
      const targetRows = await query(
        'SELECT * FROM users WHERE mobileNumber = ? OR mobileNumber = ? OR user_code = ? OR id = ? LIMIT 1',
        [last10, cleanTarget, cleanTarget, isNaN(parseInt(cleanTarget, 10)) ? -1 : parseInt(cleanTarget, 10)]
      );
      if (!targetRows || targetRows.length === 0) {
        return res.status(404).json({ error: `Member ID / Mobile number '${cleanTarget}' not found in registered users.` });
      }
      targetUser = targetRows[0];
    }

    if (targetUser.status === 'ACTIVE') {
      return res.status(400).json({ error: `User ID / Mobile ${targetUser.mobileNumber} is already activated. Subscription is active.` });
    }

    if (parseFloat(user.fund_wallet_balance || 0) < joinAmount) {
      return res.status(400).json({ error: `Insufficient Fund Wallet balance. (Required: ₹${joinAmount})` });
    }

    const result = await transaction(async (conn) => {
      // 1. Deduct join amount from payer's fund wallet & mark target user ACTIVE
      await conn.execute(
        'UPDATE users SET fund_wallet_balance = fund_wallet_balance - ? WHERE id = ?',
        [joinAmount, user.id]
      );
      await conn.execute(
        'UPDATE users SET status = "ACTIVE" WHERE id = ?',
        [targetUser.id]
      );

      const dateStr = new Date().toLocaleString('en-US', { hour12: true });
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, "Debit", ?, "Success")',
        [user.id, `-₹${joinAmount.toFixed(2)}`, dateStr]
      );

      // 2. Credit Direct Sponsor Income (₹300) to targetUser's sponsor
      const sponsorIdToCredit = targetUser.sponsor_id || user.sponsor_id;
      if (sponsorIdToCredit) {
        // Resolve sponsor by numeric ID or mobile number
        const spRows = await conn.execute('SELECT id, mobileNumber FROM users WHERE id = ? OR mobileNumber = ?', [sponsorIdToCredit, sponsorIdToCredit]);
        const actualSponsorId = (spRows[0] && spRows[0].length > 0) ? spRows[0][0].id : sponsorIdToCredit;

        await conn.execute(
          'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
          [directIncome, actualSponsorId]
        );
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Direct Sponsor Income", ?, "Success")',
          [actualSponsorId, `+₹${directIncome.toFixed(2)}`, dateStr]
        );
      }

      // 3. Record Company Maintenance Fee (₹300) per ₹1,200 join
      const companyMaintenanceFee = parseFloat(settings['company_maintenance'] || '300');
      try {
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (0, "COMPANY", ?, "Company Maintenance", ?, "Success")',
          [`+₹${companyMaintenanceFee.toFixed(2)}`, dateStr]
        );
      } catch (_) {}

      // 4. Create cycle ID for targetUser
      const [existingCycles] = await conn.execute('SELECT COUNT(id) as count FROM cycles WHERE user_id = ?', [targetUser.id]);
      const nextCycleNum = (existingCycles[0] && existingCycles[0].count ? existingCycles[0].count : 0) + 1;
      const cycleIdStr = `CYCLE-${String(nextCycleNum).padStart(4, '0')}`;

      const [cycleResult] = await conn.execute(
        'INSERT INTO cycles (user_id, cycle_id, status, members_count) VALUES (?, ?, "ACTIVE", 0)',
        [targetUser.id, cycleIdStr]
      );
      const newCycleDbId = cycleResult.insertId;

      // 5. Place targetUser cycle in Single Leg Queue
      await conn.execute(
        'INSERT INTO single_leg_queue (cycle_id, user_id) VALUES (?, ?)',
        [newCycleDbId, targetUser.id]
      );

      // 6. 126-Member Single Leg 6-Level Business Plan distribution
      // Cumulative thresholds:
      // Level 5 (2 members)   -> ₹200
      // Level 4 (6 members)   -> ₹400  (Cumulative: ₹600)
      // Level 3 (14 members)  -> ₹800  (Cumulative: ₹1,400)
      // Level 2 (30 members)  -> ₹1,600 (Cumulative: ₹3,000)
      // Level 1 (62 members)  -> ₹3,200 (Cumulative: ₹6,200)
      // Top User (126 members)-> ₹6,400 (Cumulative: ₹12,600)
      const [activeCycles] = await conn.execute(
        `SELECT c.id, c.user_id, c.members_count 
         FROM cycles c
         JOIN single_leg_queue q ON c.id = q.cycle_id
         WHERE c.status = 'ACTIVE' AND c.id != ?
         ORDER BY q.id ASC`,
        [newCycleDbId]
      );

      const c1 = 2;    // Level 5: 2 members
      const c2 = 6;    // Level 4: 2 + 4 = 6 members
      const c3 = 14;   // Level 3: 6 + 8 = 14 members
      const c4 = 30;   // Level 2: 14 + 16 = 30 members
      const c5 = 62;   // Level 1: 30 + 32 = 62 members
      const c6 = 126;  // Top User: 62 + 64 = 126 members

      for (const activeCycle of activeCycles) {
        const newMembersCount = activeCycle.members_count + 1;
        await conn.execute(
          'UPDATE cycles SET members_count = ? WHERE id = ?',
          [newMembersCount, activeCycle.id]
        );

        let payout = 0;
        let levelLabel = '';

        if (newMembersCount === c1) {
          payout = 200.00;
          levelLabel = 'Single Leg Level 5 Income (2 Members)';
        } else if (newMembersCount === c2) {
          payout = 400.00;
          levelLabel = 'Single Leg Level 4 Income (6 Members)';
        } else if (newMembersCount === c3) {
          payout = 800.00;
          levelLabel = 'Single Leg Level 3 Income (14 Members)';
        } else if (newMembersCount === c4) {
          payout = 1600.00;
          levelLabel = 'Single Leg Level 2 Income (30 Members)';
        } else if (newMembersCount === c5) {
          payout = 3200.00;
          levelLabel = 'Single Leg Level 1 Income (62 Members)';
        } else if (newMembersCount === c6) {
          payout = 6400.00;
          levelLabel = 'Single Leg Top User Income (126 Members Complete)';
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

        if (newMembersCount >= c6) {
          await conn.execute(
            'UPDATE cycles SET status = "COMPLETED" WHERE id = ?',
            [activeCycle.id]
          );

          // Record Company Level Pool Surplus (₹11,400) upon complete 126-member cycle
          try {
            await conn.execute(
              'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (0, "COMPANY", "+₹11400.00", "Company Level Pool Surplus", ?, "Success")',
              [dateStr]
            );
          } catch (_) {}
        }
      }

      return { cycleId: cycleIdStr };
    });

    await invalidateCache(`user_profile_${user.id}`);
    await invalidateCache(`user_profile_${targetUser.id}`);
    await invalidateCache('admin_stats');

    sendNotificationEmail(targetUser.email, "SR Digital Seva - Account Activated!", `
      <h3>Hi ${targetUser.fullName},</h3>
      <p>We have successfully processed your plan payment of <strong>₹${joinAmount.toFixed(2)}</strong>.</p>
      <p>Your subscription is active and your cycle ID <strong>${result.cycleId}</strong> has been placed in the single-leg business plan.</p>
      <p>Your Member ID is your registered Mobile Number: <strong>${targetUser.mobileNumber}</strong></p>
    `);

    res.status(201).json({ message: `ID ${targetUser.mobileNumber} activated successfully!`, cycleId: result.cycleId, memberId: targetUser.mobileNumber });
  } catch (err) {
    console.error('Cycle activation error:', err);
    res.status(500).json({ error: 'Failed to activate cycle: ' + (err.message || '') });
  }
});

// Cycle History
router.get('/history', verifyAppToken, verifyUserToken, async (req, res) => {
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

module.exports = router;
