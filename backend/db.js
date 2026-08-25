const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

const pool = process.env.DATABASE_URL
  ? mysql.createPool(process.env.DATABASE_URL)
  : mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0
    });

async function query(sql, params) {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (err) {
    console.error('MySQL query error:', err);
    throw err;
  }
}

async function transaction(callback) {
  const connection = await pool.getConnection();
  await connection.beginTransaction();
  try {
    const result = await callback(connection);
    await connection.commit();
    return result;
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

async function initDb() {
  try {
    console.log('Initializing MySQL Database schema...');

    // Users Table
    await query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        fullName VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        mobileNumber VARCHAR(20) NOT NULL,
        passwordHash VARCHAR(255) NOT NULL,
        fund_wallet_balance DECIMAL(15, 2) DEFAULT 0.00,
        main_wallet_balance DECIMAL(15, 2) DEFAULT 0.00,
        status VARCHAR(20) DEFAULT 'ACTIVE',
        role VARCHAR(20) DEFAULT 'user',
        device_model VARCHAR(100) DEFAULT 'Unknown',
        app_version VARCHAR(20) DEFAULT '1.0.0',
        sponsor_id INT DEFAULT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_email (email)
      ) ENGINE=InnoDB;
    `);

    // Fund Requests Table
    await query(`
      CREATE TABLE IF NOT EXISTS fund_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        amount DECIMAL(15, 2) NOT NULL,
        utr VARCHAR(50) DEFAULT NULL,
        status VARCHAR(20) DEFAULT 'PENDING',
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_id (user_id),
        INDEX idx_status (status)
      ) ENGINE=InnoDB;
    `);

    // Transactions Table
    await query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        wallet_type VARCHAR(20) NOT NULL, -- 'FUND' or 'MAIN'
        amount VARCHAR(50) NOT NULL, -- e.g. "₹12,600.00" or "-₹100.00"
        type VARCHAR(50) NOT NULL, -- 'Credit', 'Debit', 'Cashout', 'Affiliate Income', 'Direct Income', 'Level Income'
        date VARCHAR(100) NOT NULL,
        status VARCHAR(20) DEFAULT 'Success',
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_wallet (user_id, wallet_type)
      ) ENGINE=InnoDB;
    `);

    // Cycles Table
    await query(`
      CREATE TABLE IF NOT EXISTS cycles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        cycle_id VARCHAR(50) NOT NULL,
        status VARCHAR(20) DEFAULT 'ACTIVE',
        members_count INT DEFAULT 0,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_cycle (user_id),
        INDEX idx_status (status)
      ) ENGINE=InnoDB;
    `);

    // Single Leg Queue Table
    await query(`
      CREATE TABLE IF NOT EXISTS single_leg_queue (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cycle_id INT NOT NULL,
        user_id INT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_cycle_queue (cycle_id),
        INDEX idx_user_queue (user_id)
      ) ENGINE=InnoDB;
    `);

    // System Settings Table
    await query(`
      CREATE TABLE IF NOT EXISTS system_settings (
        key_name VARCHAR(50) PRIMARY KEY,
        val_value VARCHAR(255) NOT NULL
      ) ENGINE=InnoDB;
    `);

    // Seed Admin users (haris@gmail.com & earnfarm99@gmail.com with password 123456)
    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync('123456', salt);

    const checkHaris = await query('SELECT * FROM users WHERE email = ?', ['haris@gmail.com']);
    if (checkHaris.length === 0) {
      await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, role) VALUES (?, ?, ?, ?, ?)',
        ['Haris Admin', 'haris@gmail.com', '0000000000', passwordHash, 'admin']
      );
      console.log('Haris Admin user seeded.');
    }

    const checkEarnfarm = await query('SELECT * FROM users WHERE email = ?', ['earnfarm99@gmail.com']);
    if (checkEarnfarm.length === 0) {
      await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, role) VALUES (?, ?, ?, ?, ?)',
        ['Earnfarm Admin', 'earnfarm99@gmail.com', '1111111111', passwordHash, 'admin']
      );
      console.log('Earnfarm Admin user seeded.');
    }

    // Seed default system settings if table is empty
    const checkSettings = await query('SELECT COUNT(*) as count FROM system_settings');
    if (checkSettings[0].count === 0) {
      const settings = [
        ['min_wallet_balance', '50.00'],
        ['maintenance_mode', 'false'],
        ['force_update_version', '1.0.0'],
        ['scriza_api_mode', 'simulation'],
        ['razorpay_api_mode', 'test'],
        ['razorpay_key_id', 'rzp_test_dummyKey123'],
        ['razorpay_key_secret', 'dummySecretKey789'],
        ['marquee_text', 'Welcome to EarnFarm! Enjoy high commission margins on DTH and Mobile recharges. Fast wallet loads enabled via UPI.'],
        ['marquee_images', 'https://upload.wikimedia.org/wikipedia/commons/5/50/Reliance_Jio_Logo.svg,https://upload.wikimedia.org/wikipedia/commons/e/e5/Bharti_Airtel_Logo.svg,https://upload.wikimedia.org/wikipedia/commons/d/d4/Vodafone_Idea_logo.svg,https://upload.wikimedia.org/wikipedia/commons/e/ec/BSNL_logo.svg,https://upload.wikimedia.org/wikipedia/commons/8/89/Razorpay_logo.svg'],
        
        ['join_amount', '1200'],
        ['top_up_amount', '1200'],
        ['direct_income', '300'],
        ['level_pool', '600'],
        ['company_maintenance', '300'],
        ['cycle_size', '126'],
        ['withdrawal_percentage', '15'],
        ['minimum_withdrawal', '500'],
        ['withdrawal_days', 'Mon,Wed,Fri'],
        ['upi_vpa_id', 'vp110064@okaxis'],
        ['upi_payee_name', 'EarnFarm'],

        ['level_1_members', '2'],
        ['level_1_income', '200'],
        ['level_2_members', '4'],
        ['level_2_income', '400'],
        ['level_3_members', '8'],
        ['level_3_income', '800'],
        ['level_4_members', '16'],
        ['level_4_income', '1600'],
        ['level_5_members', '32'],
        ['level_5_income', '3200'],
        ['level_6_members', '64'],
        ['level_6_income', '6400']
      ];
      for (const [k, v] of settings) {
        await query('INSERT INTO system_settings (key_name, val_value) VALUES (?, ?)', [k, v]);
      }
      console.log('Production default system settings seeded.');
    }

    // Create Notifications Table
    await query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      ) ENGINE=InnoDB;
    `);

    // Ensure sponsor_id column exists in users table
    try {
      const cols = await query("SHOW COLUMNS FROM users LIKE 'sponsor_id'");
      if (cols.length === 0) {
        await query("ALTER TABLE users ADD COLUMN sponsor_id INT DEFAULT NULL");
        console.log("Migrated: Added sponsor_id column to users table.");
      }
    } catch (e) {
      console.warn("Sponsor_id migration check failed: ", e);
    }

    // Ensure utr column exists in fund_requests table
    try {
      const cols = await query("SHOW COLUMNS FROM fund_requests LIKE 'utr'");
      if (cols.length === 0) {
        await query("ALTER TABLE fund_requests ADD COLUMN utr VARCHAR(50) DEFAULT NULL");
        console.log("Migrated: Added utr column to fund_requests table.");
      }
    } catch (e) {
      console.warn("UTR migration check failed: ", e);
    }

    console.log('MySQL Database migration complete.');
  } catch (err) {
    console.error('Error during database migration:', err);
  }
}

module.exports = {
  query,
  transaction,
  initDb
};
