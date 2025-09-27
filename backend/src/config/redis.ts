import Redis from 'ioredis';
import { logger } from '../utils/logger';

interface RedisConfig {
  host: string;
  port: number;
  password?: string;
  db: number;
  retryDelayOnFailover: number;
  maxRetriesPerRequest: number;
  lazyConnect: boolean;
}

const getRedisConfig = (): RedisConfig => {
  const redisUrl = process.env.REDIS_URL || 'redis://localhost:6379';
  const url = new URL(redisUrl);
  
  return {
    host: url.hostname || 'localhost',
    port: parseInt(url.port) || 6379,
    password: process.env.REDIS_PASSWORD || url.password || undefined,
    db: parseInt(process.env.REDIS_DB || '0'),
    retryDelayOnFailover: 100,
    maxRetriesPerRequest: 3,
    lazyConnect: true,
  };
};

// Create Redis client (optional - gracefully handle when Redis is not available)
let redis: Redis | null = null;
let redisAvailable = false;

try {
  // Only create Redis client if REDIS_ENABLED is not explicitly set to false
  const redisEnabled = process.env.REDIS_ENABLED !== 'false';
  
  if (redisEnabled) {
    const config = getRedisConfig();
    redis = new Redis({
      ...config,
      maxRetriesPerRequest: 1, // Reduce retries to fail faster
      connectTimeout: 2000, // 2 second timeout
      lazyConnect: true,
    });

    // Redis event listeners
    redis.on('connect', () => {
      logger.info('Redis client connected');
      redisAvailable = true;
    });

    redis.on('ready', () => {
      logger.info('Redis client ready');
      redisAvailable = true;
    });

    redis.on('error', (err) => {
      logger.warn('Redis client error (running without cache):', err.message);
      redisAvailable = false;
    });

    redis.on('close', () => {
      logger.warn('Redis client connection closed (running without cache)');
      redisAvailable = false;
    });

    redis.on('reconnecting', () => {
      logger.info('Redis client reconnecting');
      redisAvailable = false;
    });
  } else {
    logger.info('Redis disabled - running without cache');
  }
} catch (error) {
  logger.warn('Failed to initialize Redis client - running without cache:', error);
  redis = null;
  redisAvailable = false;
}

export { redis };

// Redis utility functions (gracefully handle when Redis is not available)
export const redisUtils = {
  // Set key with expiration
  setWithExpiry: async (key: string, value: string, expiryInSeconds: number): Promise<void> => {
    if (!redis || !redisAvailable) return;
    try {
      await redis.setex(key, expiryInSeconds, value);
    } catch (error) {
      logger.warn('Redis setWithExpiry failed:', error);
    }
  },

  // Get key
  get: async (key: string): Promise<string | null> => {
    if (!redis || !redisAvailable) return null;
    try {
      return await redis.get(key);
    } catch (error) {
      logger.warn('Redis get failed:', error);
      return null;
    }
  },

  // Delete key
  del: async (key: string): Promise<number> => {
    if (!redis || !redisAvailable) return 0;
    try {
      return await redis.del(key);
    } catch (error) {
      logger.warn('Redis del failed:', error);
      return 0;
    }
  },

  // Check if key exists
  exists: async (key: string): Promise<boolean> => {
    if (!redis || !redisAvailable) return false;
    try {
      const result = await redis.exists(key);
      return result === 1;
    } catch (error) {
      logger.warn('Redis exists failed:', error);
      return false;
    }
  },

  // Set hash
  hset: async (key: string, field: string, value: string): Promise<number> => {
    if (!redis || !redisAvailable) return 0;
    try {
      return await redis.hset(key, field, value);
    } catch (error) {
      logger.warn('Redis hset failed:', error);
      return 0;
    }
  },

  // Get hash field
  hget: async (key: string, field: string): Promise<string | null> => {
    if (!redis || !redisAvailable) return null;
    try {
      return await redis.hget(key, field);
    } catch (error) {
      logger.warn('Redis hget failed:', error);
      return null;
    }
  },

  // Get all hash fields
  hgetall: async (key: string): Promise<Record<string, string>> => {
    if (!redis || !redisAvailable) return {};
    try {
      return await redis.hgetall(key);
    } catch (error) {
      logger.warn('Redis hgetall failed:', error);
      return {};
    }
  },

  // Add to set
  sadd: async (key: string, ...members: string[]): Promise<number> => {
    if (!redis || !redisAvailable) return 0;
    try {
      return await redis.sadd(key, ...members);
    } catch (error) {
      logger.warn('Redis sadd failed:', error);
      return 0;
    }
  },

  // Get set members
  smembers: async (key: string): Promise<string[]> => {
    if (!redis || !redisAvailable) return [];
    try {
      return await redis.smembers(key);
    } catch (error) {
      logger.warn('Redis smembers failed:', error);
      return [];
    }
  },

  // Remove from set
  srem: async (key: string, ...members: string[]): Promise<number> => {
    if (!redis || !redisAvailable) return 0;
    try {
      return await redis.srem(key, ...members);
    } catch (error) {
      logger.warn('Redis srem failed:', error);
      return 0;
    }
  },

  // Increment counter
  incr: async (key: string): Promise<number> => {
    if (!redis || !redisAvailable) return 0;
    try {
      return await redis.incr(key);
    } catch (error) {
      logger.warn('Redis incr failed:', error);
      return 0;
    }
  },

  // Set expiration
  expire: async (key: string, seconds: number): Promise<number> => {
    if (!redis || !redisAvailable) return 0;
    try {
      return await redis.expire(key, seconds);
    } catch (error) {
      logger.warn('Redis expire failed:', error);
      return 0;
    }
  },

  // Get TTL
  ttl: async (key: string): Promise<number> => {
    if (!redis || !redisAvailable) return -1;
    try {
      return await redis.ttl(key);
    } catch (error) {
      logger.warn('Redis ttl failed:', error);
      return -1;
    }
  },
};

// Session store configuration for express-session (if needed)
export const getRedisStore = () => {
  return redis;
};

// Graceful shutdown
export const disconnectRedis = async (): Promise<void> => {
  if (!redis) return;
  try {
    await redis.quit();
    logger.info('Redis client disconnected');
  } catch (error) {
    logger.error('Error disconnecting Redis:', error);
  }
};

export default redis;
