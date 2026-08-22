const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  waitForConnections: true,
  connectionLimit: 10, // Connection pooling to handle heavy concurrent users
  queueLimit: 0
});

// Helper to execute queries
async function query(sql, params) {
  try {
    const [results] = await pool.execute(sql, params);
    return results;
  } catch (err) {
    console.error('MySQL query error:', err);
    throw err;
  }
}

// Transaction helper
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

// Database schema migration
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
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_email (email)
      ) ENGINE=InnoDB;
    `);

    // Dynamically upgrade existing tables
    try { await query('ALTER TABLE users ADD COLUMN device_model VARCHAR(100) DEFAULT "Unknown"'); } catch(e){}
    try { await query('ALTER TABLE users ADD COLUMN app_version VARCHAR(20) DEFAULT "1.0.0"'); } catch(e){}

    // Fund Requests Table
    await query(`
      CREATE TABLE IF NOT EXISTS fund_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        amount DECIMAL(15, 2) NOT NULL,
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
        type VARCHAR(50) NOT NULL, -- 'Credit', 'Debit', 'Cashout', 'Affiliate Income'
        date VARCHAR(100) NOT NULL,
        status VARCHAR(20) DEFAULT 'Success',
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX idx_user_wallet (user_id, wallet_type)
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

    // Seed default system settings
    const settings = await query('SELECT * FROM system_settings');
    if (settings.length === 0) {
      await query('INSERT INTO system_settings (key_name, val_value) VALUES ?', [
        [
          ['min_wallet_balance', '50.00'],
          ['maintenance_mode', 'false'],
          ['force_update_version', '1.0.0'],
          ['scriza_api_mode', 'simulation'],
          ['razorpay_api_mode', 'test'],
          ['razorpay_key_id', 'rzp_test_dummyKey123'],
          ['razorpay_key_secret', 'dummySecretKey789'],
          ['marquee_text', 'Welcome to SR Digital Seva! Enjoy high commission margins on DTH and Mobile recharges. Fast wallet loads enabled via UPI.'],
          ['marquee_images', '/assets/image.png']
        ]
      ]);
      console.log('Default system settings seeded.');
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

    // Seed initial dummy transactions for visual display if table is empty
    const txns = await query('SELECT * FROM transactions LIMIT 1');
    if (txns.length === 0) {
      // Dummy data representing home screen logs
      await query(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, ?, ?, ?, ?, ?)',
        [1, 'MAIN', '₹12,600.00', 'Cashout', '2026-08-21 12:30 PM', 'Success']
      );
      await query(
        'INSERT INTO transactions (user_id, wallet_type, amount, type, date, status) VALUES (?, ?, ?, ?, ?, ?)',
        [1, 'MAIN', '₹300.00', 'Affiliate Income', '2026-08-21 10:15 AM', 'Success']
      );
      console.log('Dummy transactions seeded.');
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
