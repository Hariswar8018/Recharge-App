const mysql = require('mysql2/promise');
const path = require('path');
const bcrypt = require('bcryptjs');

let useSqlite = false;
let sqliteDb = null;
let sqliteModule = null;

function getSqliteModule() {
  if (sqliteModule === null) {
    try {
      sqliteModule = require('sqlite3').verbose();
    } catch (e) {
      console.warn('SQLite3 native module notice (GLIBC/binary):', e.message);
      sqliteModule = false;
    }
  }
  return sqliteModule || null;
}

const useDbUrl = process.env.DATABASE_URL && process.env.DATABASE_URL.trim() !== '';

const pool = useDbUrl
  ? mysql.createPool(process.env.DATABASE_URL)
  : mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      charset: 'utf8mb4',
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      connectTimeout: 3000
    });

function getSqliteDb() {
  const mod = getSqliteModule();
  if (!mod) return null;
  if (!sqliteDb) {
    const dbPath = path.join(__dirname, 'local_database.sqlite');
    sqliteDb = new mod.Database(dbPath);
  }
  return sqliteDb;
}

function runSqlite(sql, params = []) {
  return new Promise((resolve) => {
    const db = getSqliteDb();
    if (!db) {
      return resolve([]);
    }
    let cleanSql = sql.trim();

    // Adapt MySQL specific syntax for SQLite compatibility
    cleanSql = cleanSql.replace(/INT AUTO_INCREMENT PRIMARY KEY/gi, 'INTEGER PRIMARY KEY AUTOINCREMENT');
    cleanSql = cleanSql.replace(/INTEGER AUTO_INCREMENT PRIMARY KEY/gi, 'INTEGER PRIMARY KEY AUTOINCREMENT');
    cleanSql = cleanSql.replace(/AUTO_INCREMENT PRIMARY KEY/gi, 'PRIMARY KEY AUTOINCREMENT');
    cleanSql = cleanSql.replace(/AUTO_INCREMENT/gi, 'AUTOINCREMENT');
    cleanSql = cleanSql.replace(/ENGINE=InnoDB;/gi, ';');
    cleanSql = cleanSql.replace(/ENGINE=InnoDB/gi, '');
    cleanSql = cleanSql.replace(/TINYINT\(1\)/gi, 'INTEGER');
    cleanSql = cleanSql.replace(/\bINT\b/gi, 'INTEGER');
    cleanSql = cleanSql.replace(/DATETIME DEFAULT CURRENT_TIMESTAMP/gi, 'TEXT DEFAULT CURRENT_TIMESTAMP');
    cleanSql = cleanSql.replace(/ON DUPLICATE KEY UPDATE.*/gi, '');

    const isSelect = cleanSql.toUpperCase().startsWith('SELECT') || cleanSql.toUpperCase().startsWith('SHOW') || cleanSql.toUpperCase().startsWith('PRAGMA');

    if (isSelect) {
      db.all(cleanSql, params, (err, rows) => {
        if (err) {
          console.error('SQLite SELECT Error:', err.message, 'SQL:', cleanSql);
          resolve([]);
        } else {
          resolve(rows || []);
        }
      });
    } else {
      db.run(cleanSql, params, function (err) {
        if (err) {
          console.error('SQLite RUN Error:', err.message, 'SQL:', cleanSql, 'Params:', params);
          resolve({ insertId: 0, affectedRows: 0 });
        } else {
          resolve({ insertId: this ? this.lastID || 0 : 0, affectedRows: this ? this.changes || 0 : 0 });
        }
      });
    }
  });
}

async function query(sql, params = []) {
  if (useSqlite) {
    return await runSqlite(sql, params);
  }

  try {
    const [results] = await pool.query(sql, params);
    return results;
  } catch (err) {
    console.error(`MySQL Query Error (${err.code || err.message}):`, sql);
    const sqliteAvail = getSqliteModule() !== null;
    if (sqliteAvail && (err.code === 'ECONNREFUSED' || err.code === 'ENOTFOUND' || err.code === 'ER_BAD_DB_ERROR')) {
      console.warn(`MySQL Connection Failed (${err.code}). Switching to local SQLite fallback database.`);
      useSqlite = true;
      return await runSqlite(sql, params);
    }
    throw err;
  }
}

async function transaction(callback) {
  if (useSqlite) {
    return await callback({
      execute: async (sql, params) => await runSqlite(sql, params)
    });
  }

  try {
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
  } catch (err) {
    useSqlite = true;
    return await callback({
      execute: async (sql, params) => await runSqlite(sql, params)
    });
  }
}

async function initDb() {
  try {
    console.log('Initializing Database schema...');

    // Users Table
    await query(`
      CREATE TABLE IF NOT EXISTS users (
        id INT AUTO_INCREMENT PRIMARY KEY,
        fullName VARCHAR(255) NOT NULL,
        email VARCHAR(255) UNIQUE NOT NULL,
        mobileNumber VARCHAR(20) NOT NULL,
        passwordHash TEXT NOT NULL,
        plain_password TEXT DEFAULT NULL,
        fund_wallet_balance DECIMAL(15,2) DEFAULT 0.00,
        main_wallet_balance DECIMAL(15,2) DEFAULT 0.00,
        status VARCHAR(50) DEFAULT 'PENDING',
        role VARCHAR(50) DEFAULT 'user',
        device_model VARCHAR(100) DEFAULT 'Unknown',
        app_version VARCHAR(50) DEFAULT '1.0.0',
        sponsor_id INT DEFAULT NULL,
        bank_name VARCHAR(255) DEFAULT NULL,
        account_holder VARCHAR(255) DEFAULT NULL,
        account_no VARCHAR(100) DEFAULT NULL,
        ifsc VARCHAR(50) DEFAULT NULL,
        branch VARCHAR(255) DEFAULT NULL,
        account_type VARCHAR(50) DEFAULT 'Savings',
        bank_verified INT DEFAULT 0,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Fund Requests Table
    await query(`
      CREATE TABLE IF NOT EXISTS fund_requests (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        utr VARCHAR(255) DEFAULT NULL,
        status VARCHAR(50) DEFAULT 'PENDING',
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Withdrawals Table
    await query(`
      CREATE TABLE IF NOT EXISTS withdrawals (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        amount DECIMAL(15,2) NOT NULL,
        deduction_fee DECIMAL(15,2) DEFAULT 0.00,
        net_amount DECIMAL(15,2) DEFAULT 0.00,
        account_holder VARCHAR(255) DEFAULT NULL,
        account_no VARCHAR(100) DEFAULT NULL,
        ifsc VARCHAR(50) DEFAULT NULL,
        bank_name VARCHAR(255) DEFAULT NULL,
        branch VARCHAR(255) DEFAULT NULL,
        account_type VARCHAR(50) DEFAULT 'Savings',
        status VARCHAR(50) DEFAULT 'PENDING',
        rejection_reason TEXT DEFAULT NULL,
        processed_at DATETIME DEFAULT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Transactions Table
    await query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        wallet_type VARCHAR(50) NOT NULL,
        amount VARCHAR(50) NOT NULL,
        type VARCHAR(50) NOT NULL,
        date VARCHAR(100) NOT NULL,
        status VARCHAR(50) DEFAULT 'Success',
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Cycles Table
    await query(`
      CREATE TABLE IF NOT EXISTS cycles (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        cycle_id VARCHAR(100) NOT NULL,
        status VARCHAR(50) DEFAULT 'ACTIVE',
        members_count INT DEFAULT 0,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Single Leg Queue Table
    await query(`
      CREATE TABLE IF NOT EXISTS single_leg_queue (
        id INT AUTO_INCREMENT PRIMARY KEY,
        cycle_id INT NOT NULL,
        user_id INT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // System Settings Table
    await query(`
      CREATE TABLE IF NOT EXISTS system_settings (
        key_name VARCHAR(255) PRIMARY KEY,
        val_value TEXT NOT NULL
      )
    `);

    // Create Notifications Table
    await query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Seed single Admin user (srdigitalseva9@gmail.com with password Rajesh@1819)
    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync('Rajesh@1819', salt);

    // Remove legacy admin accounts
    await query('DELETE FROM users WHERE role = "admin" AND email != "srdigitalseva9@gmail.com"');

    const checkAdmin = await query('SELECT * FROM users WHERE email = ?', ['srdigitalseva9@gmail.com']);
    if (Array.isArray(checkAdmin) && checkAdmin.length === 0) {
      await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, role, status) VALUES (?, ?, ?, ?, ?, ?, "ACTIVE")',
        ['SR Digital Seva Admin', 'srdigitalseva9@gmail.com', '9988494936', passwordHash, 'Rajesh@1819', 'admin']
      );
      console.log('SR Digital Seva Admin user seeded.');
    } else {
      await query(
        'UPDATE users SET mobileNumber = "9988494936", passwordHash = ?, plain_password = ?, role = "admin", status = "ACTIVE" WHERE email = ?',
        [passwordHash, 'Rajesh@1819', 'srdigitalseva9@gmail.com']
      );
    }

    // Seed Top-Level Master User for Mobile Registration Sponsor ID (Mobile: 9988494936)
    const checkMaster = await query('SELECT * FROM users WHERE email = "master@srdigitalseva.com"');
    if (Array.isArray(checkMaster) && checkMaster.length === 0) {
      await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, fund_wallet_balance, main_wallet_balance, status, role) VALUES (?, ?, ?, ?, ?, 10000.00, 10000.00, "ACTIVE", "user")',
        ['SR Digital Seva Master', 'master@srdigitalseva.com', '9988494936', passwordHash, 'Rajesh@1819']
      );
      console.log('Master Top-Level User seeded (Mobile: 9988494936).');
    }

    // Seed default system settings
    const checkSettings = await query('SELECT count(*) as count FROM system_settings');
    const settingsCount = (Array.isArray(checkSettings) && checkSettings.length > 0 && checkSettings[0].count !== undefined) ? checkSettings[0].count : 0;
    
    if (settingsCount === 0) {
      const defaultSettings = [
        ['min_wallet_balance', '50.00'],
        ['maintenance_mode', 'false'],
        ['force_update_version', '1.0.0'],
        ['scriza_api_mode', 'simulation'],
        ['razorpay_api_mode', 'test'],
        ['razorpay_key_id', 'rzp_test_dummyKey123'],
        ['razorpay_key_secret', 'dummySecretKey789'],
        ['marquee_text', 'Welcome to EarnFarm! Enjoy high commission margins on DTH and Mobile recharges. Fast wallet loads enabled via UPI.'],
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
        ['registration_enabled', 'true'],
        ['login_enabled', 'true'],
        ['otp_enabled', 'true'],
        ['add_money_enabled', 'true'],
        ['withdrawal_enabled', 'true'],
        ['captcha_enabled', 'true'],
        ['captcha_reward_amount', '0.50'],
        ['captcha_maintenance_msg', 'CAPTCHA Work is currently under maintenance. Please check back later.'],
        ['forgot_password_enabled', 'true'],
        ['app_share_text', 'Download our App to Earn Money from Scratch Cards'],
        ['playstore_link', 'https://play.google.com/store/apps/details?id=com.app.earnfarm'],
        ['playstore_package_id', 'com.app.earnfarm'],
        ['upi_qr_url', '']
      ];
      for (const [k, v] of defaultSettings) {
        await query('INSERT INTO system_settings (key_name, val_value) VALUES (?, ?)', [k, v]);
      }
      console.log('Production default system settings seeded.');
    }

    try { await query('ALTER TABLE users ADD COLUMN branch VARCHAR(255) DEFAULT NULL'); } catch(e) {}
    try { await query('ALTER TABLE users ADD COLUMN account_type VARCHAR(50) DEFAULT "Savings"'); } catch(e) {}

    console.log('Database initialization complete.');
  } catch (err) {
    console.error('Error during database migration:', err);
  }
}

module.exports = {
  query,
  transaction,
  initDb
};
