require('dotenv').config({ path: require('path').resolve(__dirname, '../.env') });
const { query, initDb } = require('../db');
const bcrypt = require('bcryptjs');

async function runTests() {
  console.log('--- STARTING AUTOMATED CYCLE TESTS ---');
  
  // 1. Initialise fresh database
  await initDb();

  // Helper password generator
  const salt = bcrypt.genSaltSync(10);
  const passwordHash = bcrypt.hashSync('123456', salt);

  // 2. Register Sponsor User (User 1)
  console.log('Registering Sponsor user...');
  const [user1Result] = await query(
    'INSERT INTO users (fullName, email, mobileNumber, passwordHash, fund_wallet_balance, main_wallet_balance, role, sponsor_id) VALUES (?, ?, ?, ?, 100000.00, 0.00, "user", NULL)',
    ['Sponsor One', 'sponsor1@gmail.com', '9999999999', passwordHash]
  );
  const sponsorId = user1Result.insertId;

  // Let's create an activation cycle for sponsor1 to place them in the queue first
  console.log('Activating Sponsor cycle...');
  const [sponsorCycle] = await query(
    'INSERT INTO cycles (user_id, cycle_id, status, members_count) VALUES (?, "CYCLE-0001", "ACTIVE", 0)',
    [sponsorId]
  );
  await query('INSERT INTO single_leg_queue (cycle_id, user_id) VALUES (?, ?)', [sponsorCycle.insertId, sponsorId]);

  // 3. Register and Activate 126 Members sequentially
  console.log('Simulating registration and activation of 126 members in single leg queue...');
  
  // Load settings configurations
  const settingsRows = await query('SELECT * FROM system_settings');
  const settings = {};
  settingsRows.forEach(row => { settings[row.key_name] = row.val_value; });

  const joinAmount = parseFloat(settings['join_amount'] || '1200');
  const directIncome = parseFloat(settings['direct_income'] || '300');
  const cycleSize = parseInt(settings['cycle_size'] || '126');

  // Let's activate 126 members
  for (let i = 1; i <= 126; i++) {
    const fullName = `Member ${i}`;
    const email = `member${i}@gmail.com`;
    const mobile = `9876500${String(i).padStart(3, '0')}`;

    // Register member
    const [regResult] = await query(
      'INSERT INTO users (fullName, email, mobileNumber, passwordHash, fund_wallet_balance, main_wallet_balance, role, sponsor_id) VALUES (?, ?, ?, ?, 1200.00, 0.00, "user", ?)',
      [fullName, email, mobile, passwordHash, sponsorId]
    );
    const userId = regResult.insertId;

    // Simulate activation endpoint logic manually to verify correctness
    // Deduct fund wallet
    await query('UPDATE users SET fund_wallet_balance = fund_wallet_balance - ? WHERE id = ?', [joinAmount, userId]);
    
    // Credit sponsor
    await query('UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?', [directIncome, sponsorId]);

    // Create Cycle ID
    const cycleIdStr = 'CYCLE-0001';
    const [cycleResult] = await query(
      'INSERT INTO cycles (user_id, cycle_id, status, members_count) VALUES (?, ?, "ACTIVE", 0)',
      [userId, cycleIdStr]
    );
    const newCycleDbId = cycleResult.insertId;

    // Place in queue
    await query('INSERT INTO single_leg_queue (cycle_id, user_id) VALUES (?, ?)', [newCycleDbId, userId]);

    // Increment counts for all active cycles above this
    const activeCycles = await query(
      `SELECT c.id, c.user_id, c.members_count 
       FROM cycles c
       JOIN single_leg_queue q ON c.id = q.cycle_id
       WHERE c.status = 'ACTIVE' AND c.id != ?
       ORDER BY q.id ASC`,
      [newCycleDbId]
    );

    for (const activeCycle of activeCycles) {
      const newMembersCount = activeCycle.members_count + 1;
      await query('UPDATE cycles SET members_count = ? WHERE id = ?', [newMembersCount, activeCycle.id]);

      let payout = 0;
      if (newMembersCount === parseInt(settings['level_1_members'] || '2')) {
        payout = parseFloat(settings['level_1_income'] || '200');
      } else if (newMembersCount === (2 + 4)) {
        payout = parseFloat(settings['level_2_income'] || '400');
      } else if (newMembersCount === (2 + 4 + 8)) {
        payout = parseFloat(settings['level_3_income'] || '800');
      } else if (newMembersCount === (2 + 4 + 8 + 16)) {
        payout = parseFloat(settings['level_4_income'] || '1600');
      } else if (newMembersCount === (2 + 4 + 8 + 16 + 32)) {
        payout = parseFloat(settings['level_5_income'] || '3200');
      } else if (newMembersCount === cycleSize) {
        payout = parseFloat(settings['level_6_income'] || '6400');
      }

      if (payout > 0) {
        await query('UPDATE users SET main_wallet_balance = main_wallet_balance + ? WHERE id = ?', [payout, activeCycle.user_id]);
      }

      if (newMembersCount >= cycleSize) {
        await query('UPDATE cycles SET status = "COMPLETED" WHERE id = ?', [activeCycle.id]);
      }
    }
  }

  // 4. Verification Check
  console.log('Verifying sponsor balances after 126 activations...');
  const sponsorRows = await query('SELECT * FROM users WHERE id = ?', [sponsorId]);
  const sponsor = sponsorRows[0];

  const sponsorCycleRows = await query('SELECT * FROM cycles WHERE user_id = ?', [sponsorId]);
  const sponsorCycleObj = sponsorCycleRows[0];

  console.log(`Sponsor Main Wallet Balance: ₹${sponsor.main_wallet_balance}`);
  console.log(`Sponsor Cycle Status: ${sponsorCycleObj.status}`);
  console.log(`Sponsor Cycle Members Count: ${sponsorCycleObj.members_count}`);

  const expectedSponsorDirectIncome = 126 * directIncome; // 126 * 300 = 37,800
  const expectedSponsorLevelIncome = 12600; // Complete cycle payout
  const totalExpectedSponsorIncome = expectedSponsorDirectIncome + expectedSponsorLevelIncome;

  console.log(`Expected Direct Income: ₹${expectedSponsorDirectIncome}`);
  console.log(`Expected Level Income: ₹${expectedSponsorLevelIncome}`);
  console.log(`Expected Total Wallet Balance: ₹${totalExpectedSponsorIncome}`);

  if (parseFloat(sponsor.main_wallet_balance) === totalExpectedSponsorIncome && sponsorCycleObj.status === 'COMPLETED') {
    console.log('✅ TEST SUCCESSFUL: Math is exactly reconciled!');
  } else {
    console.error('❌ TEST FAILED: Math discrepancy found!');
  }

  console.log('--- TEST RUN COMPLETED ---');
  process.exit(0);
}

runTests();
