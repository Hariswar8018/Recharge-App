const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Cycle Activation
router.post('/activate', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const settingsRows = await query('SELECT * FROM system_settings');
    const settings = {};
    settingsRows.forEach(row => { settings[row.key_name] = row.val_value; });

    const joinAmount = parseFloat(settings['join_amount'] || '1200');
    const directIncome = parseFloat(settings['direct_income'] || '300');
    const cycleSize = parseInt(settings['cycle_size'] || '126');

    const users = await query('SELECT * FROM users WHERE id = ?', [req.user.id]);
    if (users.length === 0) return res.status(404).json({ error: 'User not found' });
    const user = users[0];

    if (parseFloat(user.fund_wallet_balance) < joinAmount) {
      return res.status(400).json({ error: 'Insufficient Fund Wallet balance.' });
    }

    const result = await transaction(async (conn) => {
      // 1. Deduct join amount & mark status ACTIVE
      await conn.execute(
        'UPDATE users SET fund_wallet_balance = fund_wallet_balance - ?, status = "ACTIVE" WHERE id = ?',
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
