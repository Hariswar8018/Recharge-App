require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { initDb } = require('./db');
const { initCache } = require('./cache');

// Import modular API route modules
const publicRoutes = require('./routes/public.routes');
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const fundRoutes = require('./routes/fund.routes');
const cyclesRoutes = require('./routes/cycles.routes');
const captchaRoutes = require('./routes/captcha.routes');
const bankRoutes = require('./routes/bank.routes');
const withdrawalRoutes = require('./routes/withdrawal.routes');
const paymentRoutes = require('./routes/payment.routes');
const adminRoutes = require('./routes/admin.routes');

const app = express();
const PORT = process.env.PORT || 5000;

// Enable CORS & JSON Body Parser
app.use(cors());
app.use(express.json());

// Android App Links Verification Endpoint
app.get('/.well-known/assetlinks.json', (req, res) => {
  res.json([{
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "com.srdigitalseva",
      "sha256_cert_fingerprints": [
        "FA:C6:17:45:DC:09:03:78:6F:B9:ED:E6:2A:96:2B:39:9F:73:48:F0:BB:6F:89:9B:83:32:66:75:91:03:3B:9C"
      ]
    }
  }]);
});

// Mount Modular Router Endpoints
app.use('/api', publicRoutes);
app.use('/api/public', publicRoutes);
app.use('/api/auth', authRoutes);
app.use('/api/user', userRoutes);
app.use('/api/fund', fundRoutes);
app.use('/api/cycles', cyclesRoutes);
app.use('/api/captcha', captchaRoutes);
app.use('/api/bank', bankRoutes);
app.use('/api/withdrawal', withdrawalRoutes);
app.use('/api/payment', paymentRoutes);
app.use('/api/admin', adminRoutes);

async function startup() {
  await initDb();
  await initCache();

  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Production-ready modular server listening on port ${PORT}`);
  });
}

startup();
