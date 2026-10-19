const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const { getMessaging } = require('firebase-admin/messaging');

let isInitialized = false;
let messaging = null;

function getServiceAccount() {
  // 1. Check embedded credentials module (Most reliable, completely immune to hosting/cPanel env truncation)
  try {
    const creds = require('./firebase-credentials');
    if (creds && creds.project_id && creds.private_key) {
      return creds;
    }
  } catch (_) {}

  // 2. Check local or deployed service-account.json file
  const candidatePaths = [
    path.resolve(__dirname, '../service-account.json'),
    path.resolve(process.cwd(), 'service-account.json'),
    '/home/wpzumbof/backend/service-account.json'
  ];

  for (const p of candidatePaths) {
    try {
      if (fs.existsSync(p)) {
        const raw = fs.readFileSync(p, 'utf8');
        const parsed = JSON.parse(raw);
        if (parsed && parsed.project_id) {
          return parsed;
        }
      }
    } catch (_) {}
  }

  // 2. Direct environment variable parse
  if (process.env.SERVICE_JSON) {
    try {
      let val = process.env.SERVICE_JSON;
      if (typeof val === 'object' && val !== null && val.project_id) {
        return val;
      }
      if (typeof val === 'string') {
        val = val.trim();
        // Remove enclosing quotes if cPanel stored them
        if ((val.startsWith("'") && val.endsWith("'")) || (val.startsWith('"') && val.endsWith('"'))) {
          try {
            val = JSON.parse(val);
          } catch (_) {
            val = val.slice(1, -1).trim();
          }
        }

        // Check for base64 encoded JSON
        if (!val.startsWith('{') && val.length > 100) {
          try {
            const decoded = Buffer.from(val, 'base64').toString('utf8').trim();
            if (decoded.startsWith('{')) {
              const parsed = JSON.parse(decoded);
              if (parsed && parsed.project_id) return parsed;
            }
          } catch (_) {}
        }
      }
      if (typeof val === 'string') {
        val = JSON.parse(val);
      }
      if (typeof val === 'object' && val !== null && val.project_id) {
        return val;
      }

      // Try regex field extraction if JSON parsing failed
      if (typeof val === 'string') {
        const extracted = extractCredentialsFromRaw(val);
        if (extracted) return extracted;
      }
    } catch (err) {
      console.warn('⚠️ [FCM] Could not parse process.env.SERVICE_JSON:', err.message);
    }
  }

  // 3. Base64 environment variable check (SERVICE_ACCOUNT_B64)
  if (process.env.SERVICE_ACCOUNT_B64) {
    try {
      const decoded = Buffer.from(process.env.SERVICE_ACCOUNT_B64.trim(), 'base64').toString('utf8').trim();
      const parsed = JSON.parse(decoded);
      if (parsed && parsed.project_id) return parsed;
    } catch (_) {}
  }

  // 4. Regex extraction from backend/.env (handles unescaped multi-line JSON)
  try {
    const envPath = path.resolve(__dirname, '../.env');
    if (fs.existsSync(envPath)) {
      const content = fs.readFileSync(envPath, 'utf8');
      const match = content.match(/SERVICE_JSON\s*=\s*(["\x27]?)([\s\S]*?)\1\s*(\n[A-Z_]+|\n*$)/);
      if (match) {
        let jsonStr = match[2].trim();
        if (jsonStr.startsWith('"') && jsonStr.endsWith('"')) {
          jsonStr = jsonStr.slice(1, -1);
        }
        try {
          const parsed = JSON.parse(jsonStr);
          if (parsed && parsed.project_id) return parsed;
        } catch (_) {
          const extracted = extractCredentialsFromRaw(jsonStr);
          if (extracted) return extracted;
        }
      }
    }
  } catch (_) {}

  return null;
}

function extractCredentialsFromRaw(str) {
  try {
    const projectIdMatch = str.match(/"project_id"\s*:\s*"([^"]+)"/);
    const clientEmailMatch = str.match(/"client_email"\s*:\s*"([^"]+)"/);
    const privateKeyMatch = str.match(/"private_key"\s*:\s*"([\s\S]*?)(?="\s*,\s*"client_email"|"\s*,\s*"client_id"|"\s*\})/);
    if (projectIdMatch && clientEmailMatch && privateKeyMatch) {
      let key = privateKeyMatch[1];
      key = key.replace(/\\n/g, '\n');
      return {
        type: 'service_account',
        project_id: projectIdMatch[1],
        client_email: clientEmailMatch[1],
        private_key: key
      };
    }
  } catch (_) {}
  return null;
}

function initFirebase() {
  if (isInitialized && messaging) return messaging;

  try {
    const serviceAccount = getServiceAccount();
    if (!serviceAccount) {
      console.warn('⚠️ [FCM] No valid SERVICE_JSON found. FCM push notifications disabled.');
      return null;
    }

    const app = admin.getApps().length === 0
      ? admin.initializeApp({ credential: admin.cert(serviceAccount) })
      : admin.getApp();

    messaging = getMessaging(app);
    isInitialized = true;
    console.log(`✅ [FCM] Firebase Admin initialized successfully (Project: ${serviceAccount.project_id || 'earnfarm'})`);
    return messaging;
  } catch (err) {
    console.error('❌ [FCM] Failed to initialize Firebase Admin SDK:', err.message);
    return null;
  }
}

/**
 * Send FCM push notification to all users subscribed to the 'all' topic
 * and optionally to specific device tokens.
 *
 * @param {Object} options
 * @param {string} options.title Notification title
 * @param {string} options.body Notification text content
 * @param {string} [options.imageUrl] Optional 1:1 or banner image URL
 * @param {Object} [options.data] Key-value custom payload
 * @param {Array<string>} [options.tokens] Optional array of device FCM tokens
 */
async function sendFcmNotification({ title, body, imageUrl, data = {}, tokens = [] }) {
  const fcm = initFirebase();
  if (!fcm) {
    console.warn('⚠️ [FCM] Skipping push notification: Firebase Admin not initialized.');
    return { success: false, reason: 'Firebase Admin not initialized' };
  }

  const cleanTitle = String(title || 'SR Digital Seva Alert').trim();
  const cleanBody = String(body || '').trim();

  // Prepare standard payload for Topic broadcast ('all' & 'notifications')
  const topicMessage = {
    topic: 'all',
    notification: {
      title: cleanTitle,
      body: cleanBody
    },
    data: {
      click_action: 'FLUTTER_NOTIFICATION_CLICK',
      title: cleanTitle,
      body: cleanBody,
      ...Object.fromEntries(Object.entries(data).map(([k, v]) => [k, String(v)]))
    },
    android: {
      priority: 'high',
      notification: {
        channelId: 'sr_digital_seva_high_importance',
        priority: 'max',
        defaultSound: true,
        defaultVibrateTimings: true,
        visibility: 'public'
      }
    }
  };

  if (imageUrl) {
    topicMessage.notification.imageUrl = String(imageUrl).trim();
    topicMessage.data.image = String(imageUrl).trim();
    topicMessage.android.notification.imageUrl = String(imageUrl).trim();
  }

  let topicResult = null;
  let multicastResult = null;

  // If specific device tokens are targeted (e.g. Active or Pending segment), send directly to tokens
  if (Array.isArray(tokens) && tokens.length > 0) {
    const validTokens = [...new Set(tokens.filter(t => typeof t === 'string' && t.trim() !== ''))];
    if (validTokens.length > 0) {
      try {
        const multicastMsg = {
          tokens: validTokens.slice(0, 500),
          notification: topicMessage.notification,
          data: topicMessage.data,
          android: topicMessage.android
        };
        multicastResult = await fcm.sendEachForMulticast(multicastMsg);
        console.log(`📢 [FCM] Sent to ${multicastResult.successCount} / ${validTokens.length} device tokens.`);
      } catch (err) {
        console.error('❌ [FCM] Error sending multicast message:', err.message);
      }
    }
  } else {
    // General broadcast: send exactly once to topic 'all'
    try {
      topicResult = await fcm.send(topicMessage);
      console.log('📢 [FCM] Successfully broadcast push notification to topic "all":', topicResult);
    } catch (err) {
      console.error('❌ [FCM] Error sending topic message:', err.message);
    }
  }

  return {
    success: !!topicResult || (multicastResult && multicastResult.successCount > 0),
    topicMessageId: topicResult,
    multicastResult
  };
}

module.exports = {
  initFirebase,
  getServiceAccount,
  sendFcmNotification
};
