const { query } = require('./db');

async function resetSystemData() {
  console.log('--- Starting Database Data Reset ---');

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

    // 6. Identify the top-level user (lowest ID / earliest registered user)
    const topUserRows = await query('SELECT id, email, fullName, mobileNumber FROM users ORDER BY id ASC LIMIT 1');
    
    if (topUserRows && topUserRows.length > 0) {
      const topUser = topUserRows[0];
      console.log(`Preserving top-level user: #${topUser.id} (${topUser.fullName} - ${topUser.email})`);

      // Delete all users except the top-level user
      await query('DELETE FROM users WHERE id != ?', [topUser.id]);
      console.log(`✓ Deleted all other users except top-level user #${topUser.id}`);

      // Reset wallet balances for preserved top-level user
      await query('UPDATE users SET fund_wallet_balance = 0.00, main_wallet_balance = 0.00 WHERE id = ?', [topUser.id]);
      console.log(`✓ Reset wallet balances to ₹0.00 for top-level user #${topUser.id}`);
    } else {
      console.log('No users found in database to preserve.');
    }

    console.log('--- Database Reset Completed Successfully! ---');
    process.exit(0);
  } catch (err) {
    console.error('Error during database reset:', err);
    process.exit(1);
  }
}

resetSystemData();
