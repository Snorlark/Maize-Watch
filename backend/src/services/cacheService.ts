import { redisUtils } from '../config/redis';
import { logger } from '../utils/logger';

export class CacheService {
  // Cache keys
  private static readonly KEYS = {
    SENSOR_LATEST: (sensorId: string) => `sensor:${sensorId}:latest`,
    SENSOR_READINGS: (sensorId: string, page: number) => `sensor:${sensorId}:readings:${page}`,
    FARM_ANALYTICS: (farmId: string) => `analytics:${farmId}`,
    FARM_SENSORS: (farmId: string) => `farm:${farmId}:sensors`,
    USER_FARMS: (userId: string) => `user:${userId}:farms`,
    ALERT_QUEUE: (farmId: string) => `alerts:${farmId}`,
    THINGSPEAK_DATA: (channelId: string) => `thingspeak:${channelId}:data`,
  };

  // Cache TTL values (in seconds)
  private static readonly TTL = {
    SENSOR_LATEST: 300, // 5 minutes
    SENSOR_READINGS: 600, // 10 minutes
    FARM_ANALYTICS: 3600, // 1 hour
    FARM_SENSORS: 1800, // 30 minutes
    USER_FARMS: 900, // 15 minutes
    THINGSPEAK_DATA: 180, // 3 minutes
  };

  /**
   * Get latest sensor reading from cache
   */
  static async getSensorLatest(sensorId: string): Promise<any | null> {
    try {
      const cached = await redisUtils.get(this.KEYS.SENSOR_LATEST(sensorId));
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get sensor latest error:', error);
      return null;
    }
  }

  /**
   * Cache latest sensor reading
   */
  static async cacheSensorLatest(sensorId: string, data: any): Promise<void> {
    try {
      await redisUtils.setWithExpiry(
        this.KEYS.SENSOR_LATEST(sensorId),
        JSON.stringify(data),
        this.TTL.SENSOR_LATEST
      );
      logger.debug(`Cached latest reading for sensor ${sensorId}`);
    } catch (error) {
      logger.error('Cache set sensor latest error:', error);
    }
  }

  /**
   * Get sensor readings from cache
   */
  static async getSensorReadings(sensorId: string, page: number = 1): Promise<any | null> {
    try {
      const cached = await redisUtils.get(this.KEYS.SENSOR_READINGS(sensorId, page));
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get sensor readings error:', error);
      return null;
    }
  }

  /**
   * Cache sensor readings
   */
  static async cacheSensorReadings(sensorId: string, page: number, data: any): Promise<void> {
    try {
      await redisUtils.setWithExpiry(
        this.KEYS.SENSOR_READINGS(sensorId, page),
        JSON.stringify(data),
        this.TTL.SENSOR_READINGS
      );
      logger.debug(`Cached readings for sensor ${sensorId}, page ${page}`);
    } catch (error) {
      logger.error('Cache set sensor readings error:', error);
    }
  }

  /**
   * Get farm analytics from cache
   */
  static async getFarmAnalytics(farmId: string): Promise<any | null> {
    try {
      const cached = await redisUtils.get(this.KEYS.FARM_ANALYTICS(farmId));
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get farm analytics error:', error);
      return null;
    }
  }

  /**
   * Cache farm analytics
   */
  static async cacheFarmAnalytics(farmId: string, analytics: any): Promise<void> {
    try {
      await redisUtils.setWithExpiry(
        this.KEYS.FARM_ANALYTICS(farmId),
        JSON.stringify(analytics),
        this.TTL.FARM_ANALYTICS
      );
      logger.debug(`Cached analytics for farm ${farmId}`);
    } catch (error) {
      logger.error('Cache set farm analytics error:', error);
    }
  }

  /**
   * Get farm sensors from cache
   */
  static async getFarmSensors(farmId: string): Promise<any | null> {
    try {
      const cached = await redisUtils.get(this.KEYS.FARM_SENSORS(farmId));
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get farm sensors error:', error);
      return null;
    }
  }

  /**
   * Cache farm sensors
   */
  static async cacheFarmSensors(farmId: string, sensors: any): Promise<void> {
    try {
      await redisUtils.setWithExpiry(
        this.KEYS.FARM_SENSORS(farmId),
        JSON.stringify(sensors),
        this.TTL.FARM_SENSORS
      );
      logger.debug(`Cached sensors for farm ${farmId}`);
    } catch (error) {
      logger.error('Cache set farm sensors error:', error);
    }
  }

  /**
   * Get user farms from cache
   */
  static async getUserFarms(userId: string): Promise<any | null> {
    try {
      const cached = await redisUtils.get(this.KEYS.USER_FARMS(userId));
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get user farms error:', error);
      return null;
    }
  }

  /**
   * Cache user farms
   */
  static async cacheUserFarms(userId: string, farms: any): Promise<void> {
    try {
      await redisUtils.setWithExpiry(
        this.KEYS.USER_FARMS(userId),
        JSON.stringify(farms),
        this.TTL.USER_FARMS
      );
      logger.debug(`Cached farms for user ${userId}`);
    } catch (error) {
      logger.error('Cache set user farms error:', error);
    }
  }

  /**
   * Queue alert for farm
   */
  static async queueAlert(farmId: string, alert: any): Promise<void> {
    try {
      await redisUtils.sadd(this.KEYS.ALERT_QUEUE(farmId), JSON.stringify(alert));
      logger.debug(`Queued alert for farm ${farmId}`);
    } catch (error) {
      logger.error('Cache queue alert error:', error);
    }
  }

  /**
   * Get queued alerts for farm
   */
  static async getQueuedAlerts(farmId: string): Promise<any[]> {
    try {
      const alerts = await redisUtils.smembers(this.KEYS.ALERT_QUEUE(farmId));
      return alerts.map(alert => JSON.parse(alert));
    } catch (error) {
      logger.error('Cache get queued alerts error:', error);
      return [];
    }
  }

  /**
   * Clear queued alerts for farm
   */
  static async clearQueuedAlerts(farmId: string): Promise<void> {
    try {
      await redisUtils.del(this.KEYS.ALERT_QUEUE(farmId));
      logger.debug(`Cleared queued alerts for farm ${farmId}`);
    } catch (error) {
      logger.error('Cache clear queued alerts error:', error);
    }
  }

  /**
   * Cache ThingSpeak data
   */
  static async cacheThingSpeakData(channelId: string, data: any): Promise<void> {
    try {
      await redisUtils.setWithExpiry(
        this.KEYS.THINGSPEAK_DATA(channelId),
        JSON.stringify(data),
        this.TTL.THINGSPEAK_DATA
      );
      logger.debug(`Cached ThingSpeak data for channel ${channelId}`);
    } catch (error) {
      logger.error('Cache set ThingSpeak data error:', error);
    }
  }

  /**
   * Get ThingSpeak data from cache
   */
  static async getThingSpeakData(channelId: string): Promise<any | null> {
    try {
      const cached = await redisUtils.get(this.KEYS.THINGSPEAK_DATA(channelId));
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get ThingSpeak data error:', error);
      return null;
    }
  }

  /**
   * Invalidate cache for a specific pattern
   */
  static async invalidatePattern(pattern: string): Promise<void> {
    try {
      // Note: This requires Redis SCAN command for production use
      // For now, we'll implement basic key deletion
      logger.debug(`Invalidating cache pattern: ${pattern}`);
    } catch (error) {
      logger.error('Cache invalidate pattern error:', error);
    }
  }

  /**
   * Invalidate all sensor-related cache for a sensor
   */
  static async invalidateSensorCache(sensorId: string): Promise<void> {
    try {
      await Promise.all([
        redisUtils.del(this.KEYS.SENSOR_LATEST(sensorId)),
        // Clear paginated readings (we'd need to track pages in production)
        redisUtils.del(this.KEYS.SENSOR_READINGS(sensorId, 1)),
        redisUtils.del(this.KEYS.SENSOR_READINGS(sensorId, 2)),
      ]);
      logger.debug(`Invalidated cache for sensor ${sensorId}`);
    } catch (error) {
      logger.error('Cache invalidate sensor error:', error);
    }
  }

  /**
   * Invalidate all farm-related cache
   */
  static async invalidateFarmCache(farmId: string): Promise<void> {
    try {
      await Promise.all([
        redisUtils.del(this.KEYS.FARM_ANALYTICS(farmId)),
        redisUtils.del(this.KEYS.FARM_SENSORS(farmId)),
        redisUtils.del(this.KEYS.ALERT_QUEUE(farmId)),
      ]);
      logger.debug(`Invalidated cache for farm ${farmId}`);
    } catch (error) {
      logger.error('Cache invalidate farm error:', error);
    }
  }

  /**
   * Generic get method for any cache key
   */
  static async get(key: string): Promise<any | null> {
    try {
      const cached = await redisUtils.get(key);
      return cached ? JSON.parse(cached) : null;
    } catch (error) {
      logger.error('Cache get error:', error);
      return null;
    }
  }

  /**
   * Generic set method for any cache key with TTL
   */
  static async set(key: string, data: any, ttlSeconds: number = 300): Promise<void> {
    try {
      await redisUtils.setWithExpiry(key, JSON.stringify(data), ttlSeconds);
      logger.debug(`Cached data for key ${key}`);
    } catch (error) {
      logger.error('Cache set error:', error);
    }
  }

  /**
   * Clear farm analytics cache
   */
  static async clearFarmAnalyticsCache(farmId: string): Promise<void> {
    try {
      const key = this.KEYS.FARM_ANALYTICS(farmId);
      await redisUtils.del(key);
      logger.info(`Cleared analytics cache for farm ${farmId}`);
    } catch (error) {
      logger.error('Cache clear farm analytics error:', error);
    }
  }

  /**
   * Clear all ThingSpeak data cache
   */
  static async clearThingSpeakCache(): Promise<void> {
    try {
      // Clear specific ThingSpeak cache keys
      const keysToDelete = [
        'thingspeak:data',
        'thingspeak:last_sync',
        'thingspeak:channels',
      ];
      
      for (const key of keysToDelete) {
        await redisUtils.del(key);
      }
      
      logger.info('Cleared all ThingSpeak cache');
    } catch (error) {
      logger.error('Cache clear ThingSpeak error:', error);
    }
  }

  /**
   * Get cache statistics
   */
  static async getCacheStats(): Promise<any> {
    try {
      // Basic cache statistics
      return {
        connected: true,
        timestamp: new Date().toISOString(),
      };
    } catch (error) {
      logger.error('Cache get stats error:', error);
      return {
        connected: false,
        error: error instanceof Error ? error.message : 'Unknown error',
      };
    }
  }
}

export default CacheService;
