const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const { getMessaging } = require('firebase-admin/messaging');

let isInitialized = false;
let messaging = null;

function getServiceAccount() {
  // 1. Direct environment variable parse
  if (process.env.SERVICE_JSON) {
    try {
      return JSON.parse(process.env.SERVICE_JSON);
    } catch (_) {}
  }

  // 2. Regex extraction from backend/.env (handles unescaped multi-line JSON)
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
        return JSON.parse(jsonStr);
      }
    }
  } catch (_) {}

  // 3. Fallback to service-account.json if present
  try {
    const jsonPath = path.resolve(__dirname, '../service-account.json');
    if (fs.existsSync(jsonPath)) {
      return JSON.parse(fs.readFileSync(jsonPath, 'utf8'));
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
  try {
    topicResult = await fcm.send(topicMessage);
    console.log('📢 [FCM] Successfully broadcast push notification to topic "all":', topicResult);
  } catch (err) {
    console.error('❌ [FCM] Error sending topic message:', err.message);
  }

  try {
    await fcm.send({ ...topicMessage, topic: 'notifications' });
  } catch (_) {}

  // If specific device tokens are provided, send multicast batch
  let multicastResult = null;
  if (Array.isArray(tokens) && tokens.length > 0) {
    const validTokens = [...new Set(tokens.filter(t => typeof t === 'string' && t.trim() !== ''))];
    if (validTokens.length > 0) {
      try {
        const multicastMsg = {
          tokens: validTokens.slice(0, 500), // Firebase max batch is 500
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
  }

  return {
    success: !!topicResult || (multicastResult && multicastResult.successCount > 0),
    topicMessageId: topicResult,
    multicastResult
  };
}

module.exports = {
  initFirebase,
  sendFcmNotification
};
