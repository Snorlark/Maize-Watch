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

// Create Redis client
const config = getRedisConfig();
export const redis = new Redis(config);

// Redis event listeners
redis.on('connect', () => {
  logger.info('Redis client connected');
});

redis.on('ready', () => {
  logger.info('Redis client ready');
});

redis.on('error', (err) => {
  logger.error('Redis client error:', err);
});

redis.on('close', () => {
  logger.warn('Redis client connection closed');
});

redis.on('reconnecting', () => {
  logger.info('Redis client reconnecting');
});

// Redis utility functions
export const redisUtils = {
  // Set key with expiration
  setWithExpiry: async (key: string, value: string, expiryInSeconds: number): Promise<void> => {
    await redis.setex(key, expiryInSeconds, value);
  },

  // Get key
  get: async (key: string): Promise<string | null> => {
    return await redis.get(key);
  },

  // Delete key
  del: async (key: string): Promise<number> => {
    return await redis.del(key);
  },

  // Check if key exists
  exists: async (key: string): Promise<boolean> => {
    const result = await redis.exists(key);
    return result === 1;
  },

  // Set hash
  hset: async (key: string, field: string, value: string): Promise<number> => {
    return await redis.hset(key, field, value);
  },

  // Get hash field
  hget: async (key: string, field: string): Promise<string | null> => {
    return await redis.hget(key, field);
  },

  // Get all hash fields
  hgetall: async (key: string): Promise<Record<string, string>> => {
    return await redis.hgetall(key);
  },

  // Add to set
  sadd: async (key: string, ...members: string[]): Promise<number> => {
    return await redis.sadd(key, ...members);
  },

  // Get set members
  smembers: async (key: string): Promise<string[]> => {
    return await redis.smembers(key);
  },

  // Remove from set
  srem: async (key: string, ...members: string[]): Promise<number> => {
    return await redis.srem(key, ...members);
  },

  // Increment counter
  incr: async (key: string): Promise<number> => {
    return await redis.incr(key);
  },

  // Set expiration
  expire: async (key: string, seconds: number): Promise<number> => {
    return await redis.expire(key, seconds);
  },

  // Get TTL
  ttl: async (key: string): Promise<number> => {
    return await redis.ttl(key);
  },
};

// Session store configuration for express-session (if needed)
export const getRedisStore = () => {
  return redis;
};

// Graceful shutdown
export const disconnectRedis = async (): Promise<void> => {
  try {
    await redis.quit();
    logger.info('Redis client disconnected');
  } catch (error) {
    logger.error('Error disconnecting Redis:', error);
  }
};

export default redis;
