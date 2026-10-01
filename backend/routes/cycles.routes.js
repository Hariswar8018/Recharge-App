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
    if (mobile) {
      const targetRows = await query('SELECT * FROM users WHERE mobileNumber = ? OR id = ?', [mobile.toString().trim(), mobile.toString().trim()]);
      if (targetRows.length > 0) {
        targetUser = targetRows[0];
      }
    }

    if (targetUser.status === 'ACTIVE') {
      return res.status(400).json({ error: 'This user ID is already activated. Subscription is active.' });
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

      // 2. Credit Direct Sponsor Income to targetUser's sponsor
      const sponsorIdToCredit = targetUser.sponsor_id || user.sponsor_id;
      if (sponsorIdToCredit) {
        // Resolve numeric sponsor ID if stored as mobile
        const spRows = await conn.execute('SELECT id FROM users WHERE id = ? OR mobileNumber = ?', [sponsorIdToCredit, sponsorIdToCredit]);
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

      // 3. Create cycle ID for targetUser
      const [existingCycles] = await conn.execute('SELECT COUNT(id) as count FROM cycles WHERE user_id = ?', [targetUser.id]);
      const nextCycleNum = (existingCycles[0].count || 0) + 1;
      const cycleIdStr = `CYCLE-${String(nextCycleNum).padStart(4, '0')}`;

      const [cycleResult] = await conn.execute(
        'INSERT INTO cycles (user_id, cycle_id, status, members_count) VALUES (?, ?, "ACTIVE", 0)',
        [targetUser.id, cycleIdStr]
      );
      const newCycleDbId = cycleResult.insertId;

      // 4. Place targetUser cycle in Single Leg Queue
      await conn.execute(
        'INSERT INTO single_leg_queue (cycle_id, user_id) VALUES (?, ?)',
        [newCycleDbId, targetUser.id]
      );

      // 5. Increment counts & distribute 6-Level Single Leg Pool Income to preceding active cycles
      const [activeCycles] = await conn.execute(
        `SELECT c.id, c.user_id, c.members_count 
         FROM cycles c
         JOIN single_leg_queue q ON c.id = q.cycle_id
         WHERE c.status = 'ACTIVE' AND c.id != ?
         ORDER BY q.id ASC`,
        [newCycleDbId]
      );

      const l1 = parseInt(settings['level_1_members'] || '2');
      const l2 = parseInt(settings['level_2_members'] || '4');
      const l3 = parseInt(settings['level_3_members'] || '8');
      const l4 = parseInt(settings['level_4_members'] || '16');
      const l5 = parseInt(settings['level_5_members'] || '32');
      const l6 = parseInt(settings['level_6_members'] || '64');

      const c1 = l1;                   // 2
      const c2 = c1 + l2;              // 6
      const c3 = c2 + l3;              // 14
      const c4 = c3 + l4;              // 30
      const c5 = c4 + l5;              // 62
      const c6 = c5 + l6;              // 126

      for (const activeCycle of activeCycles) {
        const newMembersCount = activeCycle.members_count + 1;
        await conn.execute(
          'UPDATE cycles SET members_count = ? WHERE id = ?',
          [newMembersCount, activeCycle.id]
        );

        let payout = 0;
        let levelLabel = '';

        if (newMembersCount === c1) {
          payout = parseFloat(settings['level_1_income'] || '50');
          levelLabel = 'Single Leg Level 1 Income';
        } else if (newMembersCount === c2) {
          payout = parseFloat(settings['level_2_income'] || '100');
          levelLabel = 'Single Leg Level 2 Income';
        } else if (newMembersCount === c3) {
          payout = parseFloat(settings['level_3_income'] || '150');
          levelLabel = 'Single Leg Level 3 Income';
        } else if (newMembersCount === c4) {
          payout = parseFloat(settings['level_4_income'] || '200');
          levelLabel = 'Single Leg Level 4 Income';
        } else if (newMembersCount === c5) {
          payout = parseFloat(settings['level_5_income'] || '300');
          levelLabel = 'Single Leg Level 5 Income';
        } else if (newMembersCount === c6) {
          payout = parseFloat(settings['level_6_income'] || '400');
          levelLabel = 'Single Leg Level 6 Income';
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
        }
      }

      return { cycleId: cycleIdStr };
    });

    await invalidateCache(`user_profile_${targetUser.id}`);
    await invalidateCache('admin_stats');

    sendNotificationEmail(targetUser.email, "EarnFarm ID Activated - 6 Level Single-Leg Cycle Started!", `
      <h3>Hi ${targetUser.fullName},</h3>
      <p>We have successfully processed your plan payment of <strong>₹${joinAmount.toFixed(2)}</strong>.</p>
      <p>Your subscription is active and your cycle ID <strong>${result.cycleId}</strong> has been placed in the single-leg monoline queue.</p>
    `);

    res.status(201).json({ message: 'Cycle activated successfully!', cycleId: result.cycleId });
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
