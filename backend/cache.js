const redis = require('redis');

let redisClient = null;
const memoryCache = new Map();

// Initialize Redis connection
async function initCache() {
  const host = process.env.REDIS_HOST || '127.0.0.1';
  const port = process.env.REDIS_PORT || 6379;

  redisClient = redis.createClient({
    url: `redis://${host}:${port}`,
    socket: {
      reconnectStrategy: (retries) => {
        // Stop retrying reconnection after 2 attempts to prevent console log spam
        if (retries >= 2) {
          return false;
        }
        return 1000; // wait 1s before retry
      }
    }
  });

  redisClient.on('error', (err) => {
    console.warn('Redis connection error. Falling back to memory cache.', err.message);
    redisClient = null; // Mark client as inactive to trigger fallback
  });

  try {
    await redisClient.connect();
    console.log('Redis Cache connection established successfully.');
  } catch (err) {
    console.warn('Could not establish Redis connection. Falling back to memory cache.');
    redisClient = null;
  }
}

// Get value from cache
async function getCache(key) {
  if (redisClient) {
    try {
      const val = await redisClient.get(key);
      return val ? JSON.parse(val) : null;
    } catch (err) {
      console.error('Redis get error:', err);
    }
  }
  // Fallback to in-memory Cache
  const memoryItem = memoryCache.get(key);
  if (memoryItem && memoryItem.expiry > Date.now()) {
    return memoryItem.value;
  }
  memoryCache.delete(key);
  return null;
}

// Set value to cache (expire in seconds)
async function setCache(key, value, expirySeconds = 60) {
  if (redisClient) {
    try {
      await redisClient.set(key, JSON.stringify(value), {
        EX: expirySeconds
      });
      return;
    } catch (err) {
      console.error('Redis set error:', err);
    }
  }
  // Fallback to in-memory Cache
  memoryCache.set(key, {
    value,
    expiry: Date.now() + (expirySeconds * 1000)
  });
}

// Invalidate key
async function invalidateCache(key) {
  if (redisClient) {
    try {
      await redisClient.del(key);
      return;
    } catch (err) {
      console.error('Redis delete error:', err);
    }
  }
  memoryCache.delete(key);
}

module.exports = {
  initCache,
  getCache,
  setCache,
  invalidateCache
};
