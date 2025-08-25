import { Server as SocketIOServer, Socket } from 'socket.io';
import sensorService from '../services/sensorService';
import farmService from '../services/farmService';
import { logger } from '../utils/logger';
import { USER_ROLES } from '../utils/constants';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  user?: any;
}

export default function sensorHandler(io: SocketIOServer, socket: AuthenticatedSocket) {
  
  /**
   * Subscribe to sensor updates for a specific farm
   */
  socket.on('sensor:subscribe', async (data: { farmId: string }) => {
    try {
      const { farmId } = data;
      
      // Verify user has access to the farm
      const farm = await farmService.getFarmById(farmId);
      if (farm.owner._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Join farm-specific sensor room
      socket.join(`sensors:${farmId}`);
      
      logger.info('User subscribed to sensor updates', {
        userId: socket.userId,
        farmId,
        socketId: socket.id
      });

      socket.emit('sensor:subscribed', { farmId });
    } catch (error) {
      logger.error('Error subscribing to sensor updates:', error);
      socket.emit('error', { message: 'Failed to subscribe to sensor updates' });
    }
  });

  /**
   * Unsubscribe from sensor updates
   */
  socket.on('sensor:unsubscribe', (data: { farmId: string }) => {
    const { farmId } = data;
    socket.leave(`sensors:${farmId}`);
    
    logger.info('User unsubscribed from sensor updates', {
      userId: socket.userId,
      farmId,
      socketId: socket.id
    });

    socket.emit('sensor:unsubscribed', { farmId });
  });

  /**
   * Get real-time sensor status
   */
  socket.on('sensor:getStatus', async (data: { sensorId: string }) => {
    try {
      const { sensorId } = data;
      
      // Get sensor and verify access
      const sensor = await sensorService.getSensorById(sensorId);
      const farm = await farmService.getFarmById(sensor.farm._id.toString());
      
      if (farm.owner._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to sensor' });
        return;
      }

      // Get latest readings
      const readings = await sensorService.getSensorReadings(sensorId, 1, 1);
      
      socket.emit('sensor:status', {
        sensorId,
        sensor: {
          id: sensor._id,
          name: sensor.name,
          type: sensor.type,
          status: sensor.status,
          lastReading: sensor.lastReading,
          batteryLevel: readings.readings[0]?.data?.batteryLevel,
          signalStrength: readings.readings[0]?.data?.signalStrength
        },
        latestReading: readings.readings[0] || null
      });
    } catch (error) {
      logger.error('Error getting sensor status:', error);
      socket.emit('error', { message: 'Failed to get sensor status' });
    }
  });

  /**
   * Request sensor calibration
   */
  socket.on('sensor:calibrate', async (data: { sensorId: string, calibrationData: any }) => {
    try {
      const { sensorId, calibrationData } = data;
      
      // Get sensor and verify access
      const existingSensor = await sensorService.getSensorById(sensorId);
      const farm = await farmService.getFarmById(existingSensor.farm._id.toString());
      
      if (farm.owner._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to sensor' });
        return;
      }

      // Perform calibration
      const sensor = await sensorService.calibrateSensor(sensorId, calibrationData);
      
      // Notify all subscribers to this farm
      io.to(`sensors:${farm._id}`).emit('sensor:calibrated', {
        sensorId,
        sensor: {
          id: sensor._id,
          name: sensor.name,
          calibration: sensor.calibration
        },
        calibratedBy: socket.user?.username,
        timestamp: new Date().toISOString()
      });

      logger.info('Sensor calibrated via socket', {
        sensorId,
        userId: socket.userId,
        farmId: farm._id
      });
    } catch (error) {
      logger.error('Error calibrating sensor:', error);
      socket.emit('error', { message: 'Failed to calibrate sensor' });
    }
  });

  /**
   * Sync sensor data from ThingSpeak
   */
  socket.on('sensor:sync', async (data: { sensorId: string }) => {
    try {
      const { sensorId } = data;
      
      // Get sensor and verify access
      const sensor = await sensorService.getSensorById(sensorId);
      const farm = await farmService.getFarmById(sensor.farm._id.toString());
      
      if (farm.owner._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to sensor' });
        return;
      }

      // Sync data
      await sensorService.syncFromThingSpeak(sensorId);
      
      // Get updated readings
      const readings = await sensorService.getSensorReadings(sensorId, 1, 5);
      
      // Notify all subscribers
      io.to(`sensors:${farm._id}`).emit('sensor:synced', {
        sensorId,
        newReadings: readings.readings,
        syncedBy: socket.user?.username,
        timestamp: new Date().toISOString()
      });

      logger.info('Sensor data synced via socket', {
        sensorId,
        userId: socket.userId,
        farmId: farm._id
      });
    } catch (error) {
      logger.error('Error syncing sensor data:', error);
      socket.emit('error', { message: 'Failed to sync sensor data' });
    }
  });

  /**
   * Get live sensor readings for a farm
   */
  socket.on('sensor:getLiveReadings', async (data: { farmId: string }) => {
    try {
      const { farmId } = data;
      
      // Verify access to farm
      const farm = await farmService.getFarmById(farmId);
      if (farm.owner._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Get latest readings for all sensors in farm
      const readings = await sensorService.getLatestReadingsByFarm(farmId);
      
      socket.emit('sensor:liveReadings', {
        farmId,
        readings,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Error getting live readings:', error);
      socket.emit('error', { message: 'Failed to get live readings' });
    }
  });
}

/**
 * Broadcast new sensor reading to all subscribers
 */
export function broadcastSensorReading(io: SocketIOServer, farmId: string, sensorId: string, reading: any) {
  io.to(`sensors:${farmId}`).emit('sensor:newReading', {
    farmId,
    sensorId,
    reading,
    timestamp: new Date().toISOString()
  });
}

/**
 * Broadcast sensor status change
 */
export function broadcastSensorStatusChange(io: SocketIOServer, farmId: string, sensorId: string, status: string, reason?: string) {
  io.to(`sensors:${farmId}`).emit('sensor:statusChanged', {
    farmId,
    sensorId,
    status,
    reason,
    timestamp: new Date().toISOString()
  });
}
