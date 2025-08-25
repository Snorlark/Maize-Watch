import { Server as SocketIOServer, Socket } from 'socket.io';
import mongoose from 'mongoose';
import SensorReading from '../models/SensorReading';
import farmService from '../services/farmService';
import { logger } from '../utils/logger';
import { USER_ROLES, ALERT_SEVERITY } from '../utils/constants';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  user?: any;
}

export default function alertHandler(io: SocketIOServer, socket: AuthenticatedSocket) {
  
  /**
   * Subscribe to alerts for a specific farm
   */
  socket.on('alert:subscribe', async (data: { farmId: string }) => {
    try {
      const { farmId } = data;
      
      // Verify user has access to the farm
      const farm = await farmService.getFarmById(farmId);
      if ((farm.owner._id as mongoose.Types.ObjectId).toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Join farm-specific alert room
      socket.join(`alerts:${farmId}`);
      
      logger.info('User subscribed to farm alerts', {
        userId: socket.userId,
        farmId,
        socketId: socket.id
      });

      socket.emit('alert:subscribed', { farmId });
    } catch (error) {
      logger.error('Error subscribing to alerts:', error);
      socket.emit('error', { message: 'Failed to subscribe to alerts' });
    }
  });

  /**
   * Unsubscribe from farm alerts
   */
  socket.on('alert:unsubscribe', (data: { farmId: string }) => {
    const { farmId } = data;
    socket.leave(`alerts:${farmId}`);
    
    logger.info('User unsubscribed from farm alerts', {
      userId: socket.userId,
      farmId,
      socketId: socket.id
    });

    socket.emit('alert:unsubscribed', { farmId });
  });

  /**
   * Get active alerts for a farm
   */
  socket.on('alert:getActive', async (data: { farmId: string }) => {
    try {
      const { farmId } = data;
      
      // Verify access to farm
      const farm = await farmService.getFarmById(farmId);
      if ((farm.owner._id as mongoose.Types.ObjectId).toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Get active alerts (unacknowledged alerts from last 24 hours)
      const yesterday = new Date();
      yesterday.setDate(yesterday.getDate() - 1);

      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: yesterday },
        alerts: { $exists: true, $ne: [] },
        'alerts.acknowledged': false
      })
      .populate('sensor', 'name sensorId type')
      .sort({ timestamp: -1 })
      .limit(50);

      const activeAlerts = readings.flatMap(reading => 
        reading.alerts?.filter(alert => !alert.acknowledged).map(alert => {
          // Type assertion for populated sensor
          const populatedSensor = reading.sensor as any;
          return {
            id: `${reading._id}_${alert.type}`,
            readingId: reading._id,
            sensorId: populatedSensor._id || reading.sensor,
            sensorName: populatedSensor.name || 'Unknown Sensor',
            type: alert.type,
            severity: alert.severity,
            message: alert.message,
            timestamp: reading.timestamp,
            acknowledged: alert.acknowledged
          };
        }) || []
      );

      socket.emit('alert:activeAlerts', {
        farmId,
        alerts: activeAlerts,
        count: activeAlerts.length,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Error getting active alerts:', error);
      socket.emit('error', { message: 'Failed to get active alerts' });
    }
  });

  /**
   * Acknowledge an alert
   */
  socket.on('alert:acknowledge', async (data: { readingId: string, alertType: string }) => {
    try {
      const { readingId, alertType } = data;
      
      // Get the reading
      const reading = await SensorReading.findById(readingId).populate('sensor');
      if (!reading) {
        socket.emit('error', { message: 'Reading not found' });
        return;
      }

      // Verify access to farm
      const farm = await farmService.getFarmById(reading.farm.toString());
      if ((farm.owner._id as mongoose.Types.ObjectId).toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Find and acknowledge the alert
      const alert = reading.alerts?.find(a => a.type === alertType);
      if (alert) {
        alert.acknowledged = true;
        alert.acknowledgedAt = new Date();
        alert.acknowledgedBy = socket.userId ? new mongoose.Types.ObjectId(socket.userId) : undefined;
        await reading.save();

        // Notify all subscribers to this farm
        io.to(`alerts:${(farm._id as mongoose.Types.ObjectId)}`).emit('alert:acknowledged', {
          farmId: (farm._id as mongoose.Types.ObjectId).toString(),
          readingId,
          alertType,
          acknowledgedBy: socket.user?.username,
          timestamp: new Date().toISOString()
        });

        logger.info('Alert acknowledged via socket', {
          readingId,
          alertType,
          userId: socket.userId,
          farmId: farm._id as mongoose.Types.ObjectId
        });
      } else {
        socket.emit('error', { message: 'Alert not found' });
      }
    } catch (error) {
      logger.error('Error acknowledging alert:', error);
      socket.emit('error', { message: 'Failed to acknowledge alert' });
    }
  });

  /**
   * Get alert statistics for a farm
   */
  socket.on('alert:getStats', async (data: { farmId: string, days?: number }) => {
    try {
      const { farmId, days = 7 } = data;
      
      // Verify access to farm
      const farm = await farmService.getFarmById(farmId);
      if ((farm.owner._id as mongoose.Types.ObjectId).toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Get alert statistics
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate },
        alerts: { $exists: true, $ne: [] }
      });

      const allAlerts = readings.flatMap(r => r.alerts || []);
      
      const stats = {
        total: allAlerts.length,
        acknowledged: allAlerts.filter(a => a.acknowledged).length,
        unacknowledged: allAlerts.filter(a => !a.acknowledged).length,
        bySeverity: {
          [ALERT_SEVERITY.CRITICAL]: allAlerts.filter(a => a.severity === ALERT_SEVERITY.CRITICAL).length,
          [ALERT_SEVERITY.HIGH]: allAlerts.filter(a => a.severity === ALERT_SEVERITY.HIGH).length,
          [ALERT_SEVERITY.MEDIUM]: allAlerts.filter(a => a.severity === ALERT_SEVERITY.MEDIUM).length,
          [ALERT_SEVERITY.LOW]: allAlerts.filter(a => a.severity === ALERT_SEVERITY.LOW).length
        },
        byType: allAlerts.reduce((acc, alert) => {
          acc[alert.type] = (acc[alert.type] || 0) + 1;
          return acc;
        }, {} as Record<string, number>)
      };

      socket.emit('alert:stats', {
        farmId,
        stats,
        period: `${days} days`,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Error getting alert statistics:', error);
      socket.emit('error', { message: 'Failed to get alert statistics' });
    }
  });

  /**
   * Subscribe to global alerts (admin only)
   */
  socket.on('alert:subscribeGlobal', async () => {
    try {
      if (socket.user?.role !== USER_ROLES.ADMIN && socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Admin access required' });
        return;
      }

      // Join global alerts room
      socket.join('alerts:global');
      
      logger.info('Admin subscribed to global alerts', {
        userId: socket.userId,
        socketId: socket.id
      });

      socket.emit('alert:globalSubscribed');
    } catch (error) {
      logger.error('Error subscribing to global alerts:', error);
      socket.emit('error', { message: 'Failed to subscribe to global alerts' });
    }
  });
}

/**
 * Broadcast new alert to farm subscribers
 */
export function broadcastAlert(io: SocketIOServer, farmId: string, alert: any) {
  io.to(`alerts:${farmId}`).emit('alert:new', {
    farmId,
    alert: {
      id: `${alert.readingId}_${alert.type}`,
      readingId: alert.readingId,
      sensorId: alert.sensorId,
      sensorName: alert.sensorName,
      type: alert.type,
      severity: alert.severity,
      message: alert.message,
      timestamp: alert.timestamp
    },
    timestamp: new Date().toISOString()
  });

  // Also broadcast to global alerts for admins
  io.to('alerts:global').emit('alert:global', {
    farmId,
    farmName: alert.farmName,
    alert: {
      id: `${alert.readingId}_${alert.type}`,
      readingId: alert.readingId,
      sensorId: alert.sensorId,
      sensorName: alert.sensorName,
      type: alert.type,
      severity: alert.severity,
      message: alert.message,
      timestamp: alert.timestamp
    },
    timestamp: new Date().toISOString()
  });
}

/**
 * Broadcast critical system alert
 */
export function broadcastSystemAlert(io: SocketIOServer, alert: any) {
  io.emit('alert:system', {
    type: alert.type,
    severity: ALERT_SEVERITY.CRITICAL,
    message: alert.message,
    timestamp: new Date().toISOString()
  });
}
