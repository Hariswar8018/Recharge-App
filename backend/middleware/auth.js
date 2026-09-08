const jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'earnfarm_super_secret_jwt_key_2026';

// Validate App Token for API Security
const verifyAppToken = (req, res, next) => {
  const appToken = req.headers['x-app-token'];
  if (!appToken || appToken !== process.env.APP_TOKEN) {
    return res.status(401).json({ error: 'Unauthorized: Invalid or missing App Token' });
  }
  next();
};

// Validate JWT Token for logged in users
const verifyUserToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Access Denied: Missing User JWT Token' });
  }
  jwt.verify(token, JWT_SECRET, (err, decoded) => {
    if (err) {
      return res.status(403).json({ error: 'Forbidden: Invalid token' });
    }
    req.user = decoded;
    next();
  });
};

// Validate Admin JWT Token
const verifyAdminToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];
  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  try {
    const decoded = jwt.verify(token, JWT_SECRET);
    if (decoded.role !== 'admin') {
      return res.status(403).json({ error: 'Forbidden' });
    }
    req.admin = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Session expired or invalid token' });
  }
};

module.exports = {
  JWT_SECRET,
  verifyAppToken,
  verifyUserToken,
  verifyAdminToken
};
