import { Server as SocketIOServer, Socket } from 'socket.io';
import farmService from '../services/farmService';
import { logger } from '../utils/logger';
import { USER_ROLES } from '../utils/constants';

interface AuthenticatedSocket extends Socket {
  userId?: string;
  user?: any;
}

export default function farmHandler(io: SocketIOServer, socket: AuthenticatedSocket) {
  
  /**
   * Subscribe to farm updates
   */
  socket.on('farm:subscribe', async (data: { farmId: string }) => {
    try {
      const { farmId } = data;
      
      // Verify user has access to the farm
      const farm = await farmService.getFarmById(farmId);
      if (farm.userId._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Join farm-specific room
      socket.join(`farm:${farmId}`);
      
      logger.info('User subscribed to farm updates', {
        userId: socket.userId,
        farmId,
        socketId: socket.id
      });

      socket.emit('farm:subscribed', { farmId });
    } catch (error) {
      logger.error('Error subscribing to farm updates:', error);
      socket.emit('error', { message: 'Failed to subscribe to farm updates' });
    }
  });

  /**
   * Unsubscribe from farm updates
   */
  socket.on('farm:unsubscribe', (data: { farmId: string }) => {
    const { farmId } = data;
    socket.leave(`farm:${farmId}`);
    
    logger.info('User unsubscribed from farm updates', {
      userId: socket.userId,
      farmId,
      socketId: socket.id
    });

    socket.emit('farm:unsubscribed', { farmId });
  });

  /**
   * Get real-time farm analytics
   */
  socket.on('farm:getAnalytics', async (data: { farmId: string, days?: number }) => {
    try {
      const { farmId, days = 7 } = data;
      
      // Verify access to farm
      const farm = await farmService.getFarmById(farmId);
      if (farm.userId._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Get analytics
      const analytics = await farmService.getFarmAnalytics(farmId, days);
      
      socket.emit('farm:analytics', {
        farmId,
        analytics,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Error getting farm analytics:', error);
      socket.emit('error', { message: 'Failed to get farm analytics' });
    }
  });

  /**
   * Update farm status
   */
  socket.on('farm:updateStatus', async (data: { farmId: string, status: string }) => {
    try {
      const { farmId, status } = data;
      
      // Verify access to farm
      const existingFarm = await farmService.getFarmById(farmId);
      if (existingFarm.userId._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Update status
      const farm = await farmService.updateFarmStatus(farmId, status);
      
      // Notify all subscribers to this farm
      io.to(`farm:${farmId}`).emit('farm:statusUpdated', {
        farmId,
        status,
        updatedBy: socket.user?.username,
        timestamp: new Date().toISOString()
      });

      logger.info('Farm status updated via socket', {
        farmId,
        status,
        userId: socket.userId
      });
    } catch (error) {
      logger.error('Error updating farm status:', error);
      socket.emit('error', { message: 'Failed to update farm status' });
    }
  });

  /**
   * Get harvest predictions
   */
  socket.on('farm:getPredictions', async (data: { farmId: string }) => {
    try {
      const { farmId } = data;
      
      // Verify access to farm
      const farm = await farmService.getFarmById(farmId);
      if (farm.userId._id.toString() !== socket.userId && 
          socket.user?.role !== USER_ROLES.ADMIN && 
          socket.user?.role !== USER_ROLES.SUPER_ADMIN) {
        socket.emit('error', { message: 'Access denied to farm' });
        return;
      }

      // Get predictions
      const predictions = await farmService.getHarvestPredictions(farmId);
      
      socket.emit('farm:predictions', {
        farmId,
        predictions,
        timestamp: new Date().toISOString()
      });
    } catch (error) {
      logger.error('Error getting harvest predictions:', error);
      socket.emit('error', { message: 'Failed to get harvest predictions' });
    }
  });

  /**
   * Subscribe to all user's farms
   */
  socket.on('farm:subscribeAll', async () => {
    try {
      // Get user's farms
      const result = await farmService.getFarmsByOwner(socket.userId!);
      
      // Join all farm rooms
      result.forEach(farm => {
        socket.join(`farm:${farm._id}`);
      });
      
      logger.info('User subscribed to all farms', {
        userId: socket.userId,
        farmCount: result.length,
        socketId: socket.id
      });

      socket.emit('farm:subscribedAll', { 
        farmCount: result.length,
        farms: result.map(f => ({ id: f._id, name: f.fieldName }))
      });
    } catch (error) {
      logger.error('Error subscribing to all farms:', error);
      socket.emit('error', { message: 'Failed to subscribe to farms' });
    }
  });
}

/**
 * Broadcast farm update to all subscribers
 */
export function broadcastFarmUpdate(io: SocketIOServer, farmId: string, updateType: string, data: any) {
  io.to(`farm:${farmId}`).emit('farm:updated', {
    farmId,
    updateType,
    data,
    timestamp: new Date().toISOString()
  });
}

/**
 * Broadcast weather update
 */
export function broadcastWeatherUpdate(io: SocketIOServer, farmId: string, weatherData: any) {
  io.to(`farm:${farmId}`).emit('farm:weatherUpdated', {
    farmId,
    weatherData,
    timestamp: new Date().toISOString()
  });
}

/**
 * Broadcast soil data update
 */
export function broadcastSoilUpdate(io: SocketIOServer, farmId: string, soilData: any) {
  io.to(`farm:${farmId}`).emit('farm:soilUpdated', {
    farmId,
    soilData,
    timestamp: new Date().toISOString()
  });
}
