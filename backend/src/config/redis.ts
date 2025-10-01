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

const getRedisConfig = (): RedisConfig | null => {
  const redisUrl = process.env.REDIS_URL;
  
  if (!redisUrl) {
    logger.warn('REDIS_URL not provided, Redis features will be disabled');
    return null;
  }
  
  try {
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
  } catch (error) {
    logger.error('Invalid REDIS_URL:', error);
    return null;
  }
};

// Create Redis client
const config = getRedisConfig();
export const redis = config ? new Redis(config) : null;

// Redis event listeners (only if Redis is available)
if (redis) {
  redis.on('connect', () => {
    logger.info('Redis client connected');
  });

  redis.on('ready', () => {
    logger.info('Redis client ready');
  });

  redis.on('error', (err) => {
    logger.error('Redis client error:', err);
    // Don't crash the app on Redis errors
  });

  redis.on('close', () => {
    logger.warn('Redis client connection closed');
  });

  redis.on('reconnecting', () => {
    logger.info('Redis client reconnecting');
  });

  // Handle unhandled rejections from Redis
  redis.on('end', () => {
    logger.warn('Redis client connection ended');
  });
} else {
  logger.warn('Redis client not initialized - caching and session features disabled');
}

// Redis utility functions
export const redisUtils = {
  // Set key with expiration
  setWithExpiry: async (key: string, value: string, expiryInSeconds: number): Promise<void> => {
    if (!redis) return;
    await redis.setex(key, expiryInSeconds, value);
  },

  // Get key
  get: async (key: string): Promise<string | null> => {
    if (!redis) return null;
    return await redis.get(key);
  },

  // Delete key
  del: async (key: string): Promise<number> => {
    if (!redis) return 0;
    return await redis.del(key);
  },

  // Check if key exists
  exists: async (key: string): Promise<boolean> => {
    if (!redis) return false;
    const result = await redis.exists(key);
    return result === 1;
  },

  // Set hash
  hset: async (key: string, field: string, value: string): Promise<number> => {
    if (!redis) return 0;
    return await redis.hset(key, field, value);
  },

  // Get hash field
  hget: async (key: string, field: string): Promise<string | null> => {
    if (!redis) return null;
    return await redis.hget(key, field);
  },

  // Get all hash fields
  hgetall: async (key: string): Promise<Record<string, string>> => {
    if (!redis) return {};
    return await redis.hgetall(key);
  },

  // Add to set
  sadd: async (key: string, ...members: string[]): Promise<number> => {
    if (!redis) return 0;
    return await redis.sadd(key, ...members);
  },

  // Get set members
  smembers: async (key: string): Promise<string[]> => {
    if (!redis) return [];
    return await redis.smembers(key);
  },

  // Remove from set
  srem: async (key: string, ...members: string[]): Promise<number> => {
    if (!redis) return 0;
    return await redis.srem(key, ...members);
  },

  // Increment counter
  incr: async (key: string): Promise<number> => {
    if (!redis) return 0;
    return await redis.incr(key);
  },

  // Set expiration
  expire: async (key: string, seconds: number): Promise<number> => {
    if (!redis) return 0;
    return await redis.expire(key, seconds);
  },

  // Get TTL
  ttl: async (key: string): Promise<number> => {
    if (!redis) return -1;
    return await redis.ttl(key);
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
