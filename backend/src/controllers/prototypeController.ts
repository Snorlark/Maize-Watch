import { Request, Response } from 'express';
import Prototype from '../models/Prototype';
import { authenticate } from '../middleware/auth';

export class PrototypeController {
  /**
   * Validate if a prototype ID exists and is available
   */
  public static async validatePrototype(req: Request, res: Response) {
    try {
      const { prototype_id } = req.body;

      if (!prototype_id) {
        return res.status(400).json({
          success: false,
          message: 'Prototype ID is required'
        });
      }

      const prototype = await Prototype.findByPrototypeId(prototype_id);

      if (!prototype) {
        return res.status(404).json({
          success: false,
          message: 'Prototype ID not found or inactive',
          available: false
        });
      }

      const isAvailable = !prototype.registeredBy;

      return res.status(200).json({
        success: true,
        message: isAvailable ? 'Prototype ID is available' : 'Prototype ID is already registered',
        available: isAvailable,
        prototype: {
          prototype_id: prototype.prototype_id,
          channel_id: prototype.channel_id,
          thingspeak_url: prototype.thingspeak_url,
          measurements: prototype.measurements
        }
      });

    } catch (error) {
      console.error('Error validating prototype:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Register a prototype ID to a user
   */
  public static async registerPrototype(req: Request, res: Response) {
    try {
      const { prototype_id } = req.body;
      const userId = (req as any).user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
      }

      if (!prototype_id) {
        return res.status(400).json({
          success: false,
          message: 'Prototype ID is required'
        });
      }

      // Check if prototype exists and is available
      const isAvailable = await Prototype.isAvailable(prototype_id);
      if (!isAvailable) {
        return res.status(400).json({
          success: false,
          message: 'Prototype ID is not available or already registered'
        });
      }

      // Register the prototype
      const registeredPrototype = await Prototype.registerPrototype(prototype_id, userId);

      if (!registeredPrototype) {
        return res.status(400).json({
          success: false,
          message: 'Failed to register prototype ID'
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Prototype ID registered successfully',
        prototype: {
          prototype_id: registeredPrototype.prototype_id,
          channel_id: registeredPrototype.channel_id,
          thingspeak_url: registeredPrototype.thingspeak_url,
          measurements: registeredPrototype.measurements,
          registeredAt: registeredPrototype.registeredAt
        }
      });

    } catch (error) {
      console.error('Error registering prototype:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get available prototypes
   */
  public static async getAvailablePrototypes(req: Request, res: Response) {
    try {
      const prototypes = await Prototype.getAvailablePrototypes();

      return res.status(200).json({
        success: true,
        message: 'Available prototypes retrieved successfully',
        prototypes
      });

    } catch (error) {
      console.error('Error getting available prototypes:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Get user's registered prototypes
   */
  public static async getUserPrototypes(req: Request, res: Response) {
    try {
      const userId = (req as any).user?.id;

      if (!userId) {
        return res.status(401).json({
          success: false,
          message: 'User not authenticated'
        });
      }

      const prototypes = await Prototype.find({ 
        registeredBy: userId,
        isActive: true 
      }).select('prototype_id channel_id thingspeak_url measurements registeredAt');

      return res.status(200).json({
        success: true,
        message: 'User prototypes retrieved successfully',
        prototypes
      });

    } catch (error) {
      console.error('Error getting user prototypes:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }

  /**
   * Unregister a prototype (admin function)
   */
  public static async unregisterPrototype(req: Request, res: Response) {
    try {
      const { prototype_id } = req.body;

      if (!prototype_id) {
        return res.status(400).json({
          success: false,
          message: 'Prototype ID is required'
        });
      }

      // Unregister the prototype by removing registeredBy and registeredAt fields
      const result = await Prototype.updateOne(
        { prototype_id: prototype_id.toUpperCase() },
        { 
          $unset: { 
            registeredBy: 1, 
            registeredAt: 1 
          } 
        }
      );

      if (result.matchedCount === 0) {
        return res.status(404).json({
          success: false,
          message: 'Prototype ID not found'
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Prototype unregistered successfully',
        prototype_id: prototype_id.toUpperCase()
      });

    } catch (error) {
      console.error('Error unregistering prototype:', error);
      return res.status(500).json({
        success: false,
        message: 'Internal server error'
      });
    }
  }
}
