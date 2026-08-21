const fs = require('fs');
const path = require('path');
const bcrypt = require('bcryptjs');

const dbPath = path.join(__dirname, 'db.json');

const defaultDb = {
  users: [],
  admin: {
    email: 'hari@gmail.com',
    passwordHash: '' // Will be generated on first run
  },
  transactions: [
    {
      id: 1,
      type: 'Cashout',
      amount: '₹12,600.00',
      date: '2026-08-21 12:30 PM',
      status: 'Success'
    },
    {
      id: 2,
      type: 'Affiliate Income',
      amount: '₹300.00',
      date: '2026-08-21 10:15 AM',
      status: 'Success'
    }
  ]
};

function getDb() {
  if (!fs.existsSync(dbPath)) {
    // Generate initial password hash for hari@gmail.com / 123456
    const salt = bcrypt.genSaltSync(10);
    defaultDb.admin.passwordHash = bcrypt.hashSync('123456', salt);
    fs.writeFileSync(dbPath, JSON.stringify(defaultDb, null, 2), 'utf-8');
  }
  try {
    const data = fs.readFileSync(dbPath, 'utf-8');
    return JSON.parse(data);
  } catch (err) {
    console.error('Error reading database:', err);
    return defaultDb;
  }
}

function saveDb(data) {
  try {
    fs.writeFileSync(dbPath, JSON.stringify(data, null, 2), 'utf-8');
  } catch (err) {
    console.error('Error saving database:', err);
  }
}

module.exports = {
  getDb,
  saveDb
};
