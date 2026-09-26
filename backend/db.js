const mysql = require('mysql2/promise');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const bcrypt = require('bcryptjs');

let useSqlite = false;
let sqliteDb = null;

const useDbUrl = process.env.DATABASE_URL && process.env.DATABASE_URL.trim() !== '';

const pool = useDbUrl
  ? mysql.createPool(process.env.DATABASE_URL)
  : mysql.createPool({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: process.env.DB_NAME,
      waitForConnections: true,
      connectionLimit: 10,
      queueLimit: 0,
      connectTimeout: 3000
    });

function getSqliteDb() {
  if (!sqliteDb) {
    const dbPath = path.join(__dirname, 'local_database.sqlite');
    sqliteDb = new sqlite3.Database(dbPath);
  }
  return sqliteDb;
}

function runSqlite(sql, params = []) {
  return new Promise((resolve, reject) => {
    const db = getSqliteDb();
    let cleanSql = sql.trim();

    // Adapt MySQL specific syntax for SQLite compatibility
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
    console.warn(`MySQL notice (${err.code || err.message}). Switching to local SQLite fallback database.`);
    useSqlite = true;
    return await runSqlite(sql, params);
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
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        fullName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        mobileNumber TEXT NOT NULL,
        passwordHash TEXT NOT NULL,
        plain_password TEXT DEFAULT NULL,
        fund_wallet_balance REAL DEFAULT 0.00,
        main_wallet_balance REAL DEFAULT 0.00,
        status TEXT DEFAULT 'PENDING',
        role TEXT DEFAULT 'user',
        device_model TEXT DEFAULT 'Unknown',
        app_version TEXT DEFAULT '1.0.0',
        sponsor_id INTEGER DEFAULT NULL,
        bank_name TEXT DEFAULT NULL,
        account_holder TEXT DEFAULT NULL,
        account_no TEXT DEFAULT NULL,
        ifsc TEXT DEFAULT NULL,
        bank_verified INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Fund Requests Table
    await query(`
      CREATE TABLE IF NOT EXISTS fund_requests (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        utr TEXT DEFAULT NULL,
        status TEXT DEFAULT 'PENDING',
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Transactions Table
    await query(`
      CREATE TABLE IF NOT EXISTS transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        wallet_type TEXT NOT NULL,
        amount TEXT NOT NULL,
        type TEXT NOT NULL,
        date TEXT NOT NULL,
        status TEXT DEFAULT 'Success',
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Cycles Table
    await query(`
      CREATE TABLE IF NOT EXISTS cycles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        cycle_id TEXT NOT NULL,
        status TEXT DEFAULT 'ACTIVE',
        members_count INTEGER DEFAULT 0,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Single Leg Queue Table
    await query(`
      CREATE TABLE IF NOT EXISTS single_leg_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cycle_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // System Settings Table
    await query(`
      CREATE TABLE IF NOT EXISTS system_settings (
        key_name TEXT PRIMARY KEY,
        val_value TEXT NOT NULL
      )
    `);

    // Create Notifications Table
    await query(`
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        createdAt TEXT DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // Seed Admin users (haris@gmail.com & earnfarm99@gmail.com with password 123456)
    const salt = bcrypt.genSaltSync(10);
    const passwordHash = bcrypt.hashSync('123456', salt);

    const checkHaris = await query('SELECT * FROM users WHERE email = ?', ['haris@gmail.com']);
    if (Array.isArray(checkHaris) && checkHaris.length === 0) {
      await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, role, status) VALUES (?, ?, ?, ?, ?, ?, "ACTIVE")',
        ['Haris Admin', 'haris@gmail.com', '0000000000', passwordHash, '123456', 'admin']
      );
      console.log('Haris Admin user seeded.');
    }

    const checkEarnfarm = await query('SELECT * FROM users WHERE email = ?', ['earnfarm99@gmail.com']);
    if (Array.isArray(checkEarnfarm) && checkEarnfarm.length === 0) {
      await query(
        'INSERT INTO users (fullName, email, mobileNumber, passwordHash, plain_password, role, status) VALUES (?, ?, ?, ?, ?, ?, "ACTIVE")',
        ['Earnfarm Admin', 'earnfarm99@gmail.com', '1111111111', passwordHash, '123456', 'admin']
      );
      console.log('Earnfarm Admin user seeded.');
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
        ['forgot_password_enabled', 'true'],
        ['app_share_text', 'Download our App to Earn Money from Scratch Cards'],
        ['playstore_link', 'https://play.google.com/store/apps/details?id=com.app.earnfarm'],
        ['playstore_package_id', 'com.app.earnfarm']
      ];
      for (const [k, v] of defaultSettings) {
        await query('INSERT INTO system_settings (key_name, val_value) VALUES (?, ?)', [k, v]);
      }
      console.log('Production default system settings seeded.');
    }

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
