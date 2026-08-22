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
