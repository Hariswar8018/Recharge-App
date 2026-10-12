const express = require('express');
const { query, transaction } = require('../db');
const { invalidateCache } = require('../cache');
const { sendNotificationEmail } = require('../config/mailer');
const { verifyAppToken, verifyUserToken } = require('../middleware/auth');

const router = express.Router();

// Cycle Activation / Top-Up / Plan Join (₹1,200)
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
      const numericId = parseInt(cleanTarget.replace(/^SR[MD]0*/i, ''), 10);

      let targetRows = [];
      if (digitsOnly.length === 10) {
        targetRows = await query('SELECT * FROM users WHERE mobileNumber = ? OR user_code = ? LIMIT 1', [digitsOnly, digitsOnly]);
      } else if (digitsOnly.length > 10) {
        targetRows = await query('SELECT * FROM users WHERE mobileNumber = ? OR mobileNumber = ? LIMIT 1', [last10, cleanTarget]);
      } else if (!isNaN(numericId) && numericId > 0) {
        targetRows = await query('SELECT * FROM users WHERE id = ? OR user_code = ? LIMIT 1', [numericId, cleanTarget]);
      } else {
        targetRows = await query('SELECT * FROM users WHERE user_code = ? OR email = ? LIMIT 1', [cleanTarget, cleanTarget.toLowerCase()]);
      }

      if (!targetRows || targetRows.length === 0) {
        return res.status(404).json({ error: `Member ID / Mobile number '${cleanTarget}' not found in registered users.` });
      }
      targetUser = targetRows[0];
    }

    // Check if target user has an ONGOING active cycle
    const activeCycleRows = await query(
      'SELECT id, cycle_id, members_count, status FROM cycles WHERE user_id = ? AND status = "ACTIVE" LIMIT 1',
      [targetUser.id]
    );

    if (activeCycleRows.length > 0) {
      const ongoing = activeCycleRows[0];
      if (ongoing.members_count < cycleSize) {
        return res.status(400).json({
          error: `Member ${targetUser.mobileNumber} already has an ongoing active cycle (${ongoing.cycle_id}) with ${ongoing.members_count}/${cycleSize} members. Re-entry is available once 126 members are reached.`,
          cycleId: ongoing.cycle_id,
          membersCount: ongoing.members_count
        });
      }
    }

    if (parseFloat(user.fund_wallet_balance || 0) < joinAmount) {
      return res.status(400).json({ error: `Insufficient Fund Wallet balance. (Required: ₹${joinAmount})` });
    }

    const result = await transaction(async (conn) => {
      const dateIso = new Date().toISOString();

      // 1. Deduct join amount strictly from payer's fund wallet & ensure target user status is ACTIVE
      await conn.execute(
        'UPDATE users SET fund_wallet_balance = fund_wallet_balance - ? WHERE id = ?',
        [joinAmount, user.id]
      );
      await conn.execute(
        'UPDATE users SET status = "ACTIVE" WHERE id = ?',
        [targetUser.id]
      );

      // Clean up any stale active cycle records for targetUser if members_count was >= 126
      await conn.execute(
        'UPDATE cycles SET status = "COMPLETED" WHERE user_id = ? AND status = "ACTIVE"',
        [targetUser.id]
      );
      await conn.execute(
        'DELETE FROM single_leg_queue WHERE user_id = ?',
        [targetUser.id]
      );

      // 2. Count existing cycles to generate sequential cycle number
      const [existingCycles] = await conn.execute('SELECT COUNT(id) as count FROM cycles WHERE user_id = ?', [targetUser.id]);
      const nextCycleNum = (existingCycles[0] && existingCycles[0].count ? existingCycles[0].count : 0) + 1;
      const isReentry = nextCycleNum > 1;
      const cycleIdStr = `CYCLE-${String(nextCycleNum).padStart(4, '0')}`;

      // Fund debit transaction log
      await conn.execute(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "FUND", ?, ?, ?, "Success")',
        [user.id, `-₹${joinAmount.toFixed(2)}`, isReentry ? 'Cycle Re-Entry (Top-Up)' : 'ID Activation', dateIso]
      );

      // 3. Credit Direct Sponsor Income (₹300) to targetUser's sponsor
      const sponsorIdToCredit = targetUser.sponsor_id || user.sponsor_id;
      if (sponsorIdToCredit) {
        const spRows = await conn.execute('SELECT id, mobileNumber FROM users WHERE id = ? OR mobileNumber = ?', [sponsorIdToCredit, sponsorIdToCredit]);
        const actualSponsorId = (spRows[0] && spRows[0].length > 0) ? spRows[0][0].id : sponsorIdToCredit;

        await conn.execute(
          'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
          [directIncome, actualSponsorId]
        );
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, "Direct Sponsor Income", ?, "Success")',
          [actualSponsorId, `+₹${directIncome.toFixed(2)}`, dateIso]
        );
      }

      // 4. Record Company Maintenance Fee (₹300) per ₹1,200 join
      const companyMaintenanceFee = parseFloat(settings['company_maintenance'] || '300');
      try {
        await conn.execute(
          'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (0, "COMPANY", ?, "Company Maintenance", ?, "Success")',
          [`+₹${companyMaintenanceFee.toFixed(2)}`, dateIso]
        );
      } catch (_) {}

      // 5. Create new cycle row for targetUser (0 members, status ACTIVE)
      const [cycleResult] = await conn.execute(
        'INSERT INTO cycles (user_id, cycle_id, status, members_count) VALUES (?, ?, "ACTIVE", 0)',
        [targetUser.id, cycleIdStr]
      );
      const newCycleDbId = cycleResult.insertId;

      // 6. Place targetUser cycle at the BOTTOM of the Single Leg Queue
      const [queueResult] = await conn.execute(
        'INSERT INTO single_leg_queue (cycle_id, user_id) VALUES (?, ?)',
        [newCycleDbId, targetUser.id]
      );
      const myQueueId = queueResult.insertId;

      // Calculate queue position of this newly inserted cycle
      const [posRows] = await conn.execute(
        'SELECT COUNT(*) as count FROM single_leg_queue WHERE id < ?',
        [myQueueId]
      );
      const queuePosition = (posRows[0]?.count || 0) + 1;

      // 7. Single Leg 6-Level Business Plan distribution for cycles ahead in the queue
      // Milestones:
      // Level 1: 2 members  -> ₹200
      // Level 2: 6 members  -> ₹400  (Cumulative: ₹600)
      // Level 3: 14 members -> ₹800  (Cumulative: ₹1,400)
      // Level 4: 30 members -> ₹1,600 (Cumulative: ₹3,000)
      // Level 5: 62 members -> ₹3,200 (Cumulative: ₹6,200)
      // Level 6: 126 members -> ₹6,400 (Cumulative: ₹12,600 - Cycle Completed!)
      const [activeCycles] = await conn.execute(
        `SELECT c.id, c.user_id, c.members_count 
         FROM cycles c
         JOIN single_leg_queue q ON c.id = q.cycle_id
         WHERE c.status = 'ACTIVE' AND c.id != ?
         ORDER BY q.id ASC`,
        [newCycleDbId]
      );

      const c1 = 2;    // Level 1: 2 members
      const c2 = 6;    // Level 2: 2 + 4 = 6 members
      const c3 = 14;   // Level 3: 6 + 8 = 14 members
      const c4 = 30;   // Level 4: 14 + 16 = 30 members
      const c5 = 62;   // Level 5: 30 + 32 = 62 members
      const c6 = 126;  // Level 6: 62 + 64 = 126 members

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
          levelLabel = 'Single Leg Level 1 Income (2 Members)';
        } else if (newMembersCount === c2) {
          payout = 400.00;
          levelLabel = 'Single Leg Level 2 Income (6 Members)';
        } else if (newMembersCount === c3) {
          payout = 800.00;
          levelLabel = 'Single Leg Level 3 Income (14 Members)';
        } else if (newMembersCount === c4) {
          payout = 1600.00;
          levelLabel = 'Single Leg Level 4 Income (30 Members)';
        } else if (newMembersCount === c5) {
          payout = 3200.00;
          levelLabel = 'Single Leg Level 5 Income (62 Members)';
        } else if (newMembersCount === c6) {
          payout = 6400.00;
          levelLabel = 'Single Leg Level 6 Income (126 Members Complete)';
        }

        if (payout > 0) {
          await conn.execute(
            'UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?',
            [payout, activeCycle.user_id]
          );
          await conn.execute(
            'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, "MAIN", ?, ?, ?, "Success")',
            [activeCycle.user_id, `+₹${payout.toFixed(2)}`, levelLabel, dateIso]
          );
        }

        if (newMembersCount >= c6) {
          // Cycle Completed at 126 members
          await conn.execute(
            'UPDATE cycles SET status = "COMPLETED", members_count = ? WHERE id = ?',
            [c6, activeCycle.id]
          );
          // Dequeue from single leg queue (Queue Position resets, old cycle moves to history)
          await conn.execute(
            'DELETE FROM single_leg_queue WHERE cycle_id = ?',
            [activeCycle.id]
          );

          // Record Company Level Pool Surplus (₹11,400) upon complete 126-member cycle
          try {
            await conn.execute(
              'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (0, "COMPANY", "+₹11400.00", "Company Level Pool Surplus", ?, "Success")',
              [dateIso]
            );
          } catch (_) {}
        }
      }

      return {
        cycleId: cycleIdStr,
        cycleNum: nextCycleNum,
        isReentry,
        queuePosition
      };
    });

    await invalidateCache(`user_profile_${user.id}`);
    await invalidateCache(`user_profile_${targetUser.id}`);
    await invalidateCache('admin_stats');

    sendNotificationEmail(targetUser.email, "SR Digital Seva - Account Activated!", `
      <h3>Hi ${targetUser.fullName},</h3>
      <p>We have successfully processed your plan payment of <strong>₹${joinAmount.toFixed(2)}</strong>.</p>
      <p>Your cycle ID <strong>${result.cycleId}</strong> has been placed in the single-leg business plan at Queue Position #${result.queuePosition}.</p>
      <p>Your Member ID is your registered Mobile Number: <strong>${targetUser.mobileNumber}</strong></p>
    `);

    res.status(201).json({
      message: `${result.isReentry ? 'Cycle Re-entry' : 'ID Activation'} for ${targetUser.mobileNumber} successful!`,
      cycleId: result.cycleId,
      cycleNumber: result.cycleNum,
      isReentry: result.isReentry,
      queuePosition: result.queuePosition,
      memberId: targetUser.mobileNumber
    });
  } catch (err) {
    console.error('Cycle activation error:', err);
    res.status(500).json({ error: 'Failed to activate cycle: ' + (err.message || '') });
  }
});

// Comprehensive Cycle, Queue, Levels & Income Status Endpoint
router.get('/status', verifyAppToken, verifyUserToken, async (req, res) => {
  try {
    const userId = req.user.id;
    const userRows = await query('SELECT id, fullName, mobileNumber, status, main_wallet_balance, fund_wallet_balance FROM users WHERE id = ?', [userId]);
    if (userRows.length === 0) return res.status(404).json({ error: 'User not found' });
    const user = userRows[0];

    const userCycles = await query('SELECT * FROM cycles WHERE user_id = ? ORDER BY id DESC', [userId]);
    const activeCycle = userCycles.find(c => c.status === 'ACTIVE') || null;
    const latestCycle = userCycles[0] || null;

    let queuePosition = 0;
    if (activeCycle) {
      const qRows = await query('SELECT id FROM single_leg_queue WHERE cycle_id = ? LIMIT 1', [activeCycle.id]);
      if (qRows.length > 0) {
        const queueEntryId = qRows[0].id;
        const posRows = await query('SELECT COUNT(*) as count FROM single_leg_queue WHERE id < ?', [queueEntryId]);
        queuePosition = (posRows[0]?.count || 0) + 1;
      }
    }

    const isTopUpRequired = (!activeCycle && latestCycle && (latestCycle.status === 'COMPLETED' || latestCycle.members_count >= 126)) ||
                            (activeCycle && activeCycle.members_count >= 126);

    const membersCount = activeCycle ? activeCycle.members_count : (isTopUpRequired ? 126 : 0);

    const targets = [
      { level: '1', team: 2, income: 200, cumTarget: 2 },
      { level: '2', team: 4, income: 400, cumTarget: 6 },
      { level: '3', team: 8, income: 800, cumTarget: 14 },
      { level: '4', team: 16, income: 1600, cumTarget: 30 },
      { level: '5', team: 32, income: 3200, cumTarget: 62 },
      { level: '6', team: 64, income: 6400, cumTarget: 126 },
    ];

    const levels = targets.map((t, idx) => {
      const prevTarget = idx > 0 ? targets[idx - 1].cumTarget : 0;
      let statusStr = 'Locked';
      if (membersCount >= t.cumTarget) {
        statusStr = 'Completed';
      } else if (membersCount > prevTarget || (idx === 0 && membersCount > 0)) {
        statusStr = 'In Progress';
      } else if (idx === 0 && membersCount === 0 && activeCycle) {
        statusStr = 'In Progress';
      }
      return {
        ...t,
        status: statusStr,
        isCompleted: membersCount >= t.cumTarget,
      };
    });

    const todayStart = new Date();
    todayStart.setHours(0, 0, 0, 0);
    const todayDatePrefix = todayStart.toISOString().slice(0, 10);

    const txRows = await query(
      `SELECT amount, type, date, createdAt, status FROM transactions 
       WHERE user_id = ? AND wallet_type = 'MAIN' AND status = 'Success'`,
      [userId]
    );

    let todayIncome = 0;
    let directIncome = 0;
    let levelIncome = 0;

    for (const tx of txRows) {
      const rawAmt = parseFloat(String(tx.amount || '').replace(/[^\d.]/g, '')) || 0;
      const typeStr = (tx.type || '').toLowerCase();
      const isLevel = typeStr.includes('level') || typeStr.includes('single leg') || typeStr.includes('cycle') || typeStr.includes('top user');
      const isDirect = typeStr.includes('direct') || typeStr.includes('sponsor') || typeStr.includes('affiliate');

      if (isLevel) levelIncome += rawAmt;
      if (isDirect) directIncome += rawAmt;

      const txCreatedAt = tx.createdAt ? new Date(tx.createdAt) : null;
      const txDateStr = String(tx.date || '');
      const isToday = (txCreatedAt && txCreatedAt >= todayStart) ||
                      txDateStr.includes(todayDatePrefix);

      if (isToday && (isLevel || isDirect)) {
        todayIncome += rawAmt;
      }
    }

    res.json({
      success: true,
      userId: user.id,
      mobileNumber: user.mobileNumber,
      userStatus: user.status,
      activeCycle: activeCycle ? {
        id: activeCycle.id,
        cycle_id: activeCycle.cycle_id,
        members_count: activeCycle.members_count,
        status: activeCycle.status,
        queuePosition: queuePosition,
        progressPercent: Math.min(100, (activeCycle.members_count / 126) * 100).toFixed(1),
      } : null,
      latestCycle: latestCycle ? {
        id: latestCycle.id,
        cycle_id: latestCycle.cycle_id,
        members_count: latestCycle.members_count,
        status: latestCycle.status,
      } : null,
      cycleCount: userCycles.length,
      queuePosition,
      isTopUpRequired,
      membersCount,
      levels,
      incomeSummary: {
        todayIncome: parseFloat(todayIncome.toFixed(2)),
        directIncome: parseFloat(directIncome.toFixed(2)),
        levelIncome: parseFloat(levelIncome.toFixed(2)),
        totalIncome: parseFloat((directIncome + levelIncome).toFixed(2)),
        mainWalletBalance: parseFloat(user.main_wallet_balance || 0),
        fundWalletBalance: parseFloat(user.fund_wallet_balance || 0),
      }
    });
  } catch (err) {
    console.error('Cycle status error:', err);
    res.status(500).json({ error: 'Failed to fetch cycle status' });
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
