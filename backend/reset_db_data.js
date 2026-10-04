require('dotenv').config({ path: require('path').resolve(__dirname, '.env') });
const bcrypt = require('bcryptjs');
const { query } = require('./db');

async function resetSystemData() {
  console.log('--- Starting Database Data Reset ---');

  const passedPassword = (process.argv[2] || process.env.RESET_PASS || '').trim();
  const expectedPassword = (process.env.SYSTEM_RESET_PASSWORD || '').trim();

  if (!expectedPassword || expectedPassword.length !== 16) {
    console.error('❌ ERROR: SYSTEM_RESET_PASSWORD is not configured as a 16-digit key in .env');
    process.exit(1);
  }

  if (passedPassword !== expectedPassword) {
    console.error('❌ ERROR: Invalid 16-digit System Reset Password provided. Reset operation aborted.');
    console.log('Usage: node reset_db_data.js <16-digit-password>');
    process.exit(1);
  }

  try {
    // 1. Delete all notifications
    await query('DELETE FROM notifications');
    console.log('✓ Cleared all notifications');

    // 2. Delete all transactions
    await query('DELETE FROM transactions');
    console.log('✓ Cleared all transactions');

    // 3. Delete all withdrawals
    await query('DELETE FROM withdrawals');
    console.log('✓ Cleared all withdrawals');

    // 4. Delete all fund_requests
    await query('DELETE FROM fund_requests');
    console.log('✓ Cleared all fund requests');

    // 5. Delete all single leg queues & cycles
    await query('DELETE FROM single_leg_queue');
    await query('DELETE FROM cycles');
    console.log('✓ Cleared all single leg queues & cycles');

    // 6. Create / Ensure Top-Level Master User "SR Admin"
    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync('Rajesh@1819', salt);

    const existingTop = await query('SELECT * FROM users WHERE email = "srdigitalseva9@gmail.com" OR mobileNumber = "9988494936" ORDER BY id ASC LIMIT 1');
    let topUserId;

    if (existingTop && existingTop.length > 0) {
      topUserId = existingTop[0].id;
      await query(
        'UPDATE users SET fullName = "SR Admin", role = "user", status = "ACTIVE", main_wallet_balance = 0.00, fund_wallet_balance = 0.00, sponsor_id = NULL WHERE id = ?',
        [topUserId]
      );
      console.log(`✓ Preserved & updated top-level user #${topUserId}: SR Admin (9988494936)`);
    } else {
      const res = await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, role, status, fund_wallet_balance, main_wallet_balance, sponsor_id) VALUES (?, ?, ?, ?, ?, 0.00, 0.00, "ACTIVE", "user", NULL)',
        ['SR Admin', 'srdigitalseva9@gmail.com', '9988494936', passwordHash, 'Rajesh@1819']
      );
      topUserId = res.insertId || 1;
      console.log(`✓ Created top-level user #${topUserId}: SR Admin (9988494936)`);
    }

    // Delete all other users except topUserId
    await query('DELETE FROM users WHERE id != ?', [topUserId]);
    console.log(`✓ Deleted all other users except top-level user #${topUserId}`);

    console.log('--- Database Reset Completed Successfully! ---');
    process.exit(0);
  } catch (err) {
    console.error('Error during database reset:', err);
    process.exit(1);
  }
}

resetSystemData();
