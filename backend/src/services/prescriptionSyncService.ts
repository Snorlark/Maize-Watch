import Prescription from '../models/Prescription';
import { logger } from '../utils/logger';
import mongoose from 'mongoose';

interface AnalyticsPrescription {
  id: string;
  title: string;
  description: string;
  category: string;
  urgency: 'LOW' | 'MEDIUM' | 'HIGH' | 'URGENT';
  timeline: string;
  parameter: string;
  fieldName: string;
  soilType: string;
  growthStage: string;
  fieldId: string;
  instructions: string[];
  createdAt: Date;
  isCompleted?: boolean;
}

export class PrescriptionSyncService {
  /**
   * Sync analytics prescriptions with MongoDB
   * This ensures prescriptions from analytics_v2 are stored in the database
   * and can be tracked for completion status
   */
  static async syncAnalyticsPrescriptions(
    farmId: string,
    analyticsPrescriptions: AnalyticsPrescription[]
  ): Promise<any[]> {
    try {
      const farmObjectId = new mongoose.Types.ObjectId(farmId);
      const syncedPrescriptions = [];

      for (const analyticsPrescription of analyticsPrescriptions) {
        // Check if prescription already exists in database
        const existingPrescription = await Prescription.findOne({
          farmId: farmObjectId,
          title: analyticsPrescription.title,
          parameter: analyticsPrescription.parameter,
          fieldName: analyticsPrescription.fieldName,
          // Find prescriptions created within the last 24 hours to avoid duplicates
          createdAt: {
            $gte: new Date(Date.now() - 24 * 60 * 60 * 1000)
          }
        });

        if (existingPrescription) {
          // Update existing prescription if needed
          if (analyticsPrescription.isCompleted !== undefined) {
            existingPrescription.status = analyticsPrescription.isCompleted ? 'completed' : 'pending';
            if (analyticsPrescription.isCompleted) {
              existingPrescription.completedAt = new Date();
            }
            await existingPrescription.save();
          }
          syncedPrescriptions.push(existingPrescription);
        } else {
          // Create new prescription from analytics
          const newPrescription = new Prescription({
            farmId: farmObjectId,
            title: analyticsPrescription.title,
            description: analyticsPrescription.description,
            priority: this.mapUrgencyToPriority(analyticsPrescription.urgency),
            status: analyticsPrescription.isCompleted ? 'completed' : 'pending',
            dueDate: this.calculateDueDate(analyticsPrescription.timeline, analyticsPrescription.urgency),
            category: analyticsPrescription.category,
            estimatedDuration: this.estimateDuration(analyticsPrescription.urgency, analyticsPrescription.category),
            materials: this.getMaterialsForCategory(analyticsPrescription.category),
            instructions: analyticsPrescription.instructions || [],
            urgency: analyticsPrescription.urgency,
            timeline: analyticsPrescription.timeline,
            parameter: analyticsPrescription.parameter,
            fieldName: analyticsPrescription.fieldName,
            soilType: analyticsPrescription.soilType,
            growthStage: analyticsPrescription.growthStage,
            completedAt: analyticsPrescription.isCompleted ? new Date() : undefined,
            createdAt: analyticsPrescription.createdAt,
            updatedAt: new Date()
          });

          await newPrescription.save();
          syncedPrescriptions.push(newPrescription);
        }
      }

      logger.info(`Synced ${syncedPrescriptions.length} analytics prescriptions for farm ${farmId}`);
      return syncedPrescriptions;

    } catch (error) {
      logger.error('Error syncing analytics prescriptions:', error);
      throw error;
    }
  }

  /**
   * Get prescriptions for a farm, including both database and analytics prescriptions
   */
  static async getFarmPrescriptions(farmId: string): Promise<any[]> {
    try {
      const farmObjectId = new mongoose.Types.ObjectId(farmId);
      
      // Get prescriptions from database
      const dbPrescriptions = await Prescription.find({ farmId: farmObjectId })
        .sort({ createdAt: -1 });

      return dbPrescriptions;

    } catch (error) {
      logger.error('Error getting farm prescriptions:', error);
      throw error;
    }
  }

  /**
   * Update prescription completion status
   */
  static async updatePrescriptionStatus(
    prescriptionId: string,
    isCompleted: boolean,
    userId?: string
  ): Promise<any> {
    try {
      const updateData: any = {
        status: isCompleted ? 'completed' : 'pending',
        updatedAt: new Date()
      };

      if (isCompleted) {
        updateData.completedAt = new Date();
        if (userId) {
          updateData.completedBy = new mongoose.Types.ObjectId(userId);
        }
      } else {
        updateData.completedAt = undefined;
        updateData.completedBy = undefined;
      }

      const updatedPrescription = await Prescription.findByIdAndUpdate(
        prescriptionId,
        updateData,
        { new: true }
      );

      if (!updatedPrescription) {
        throw new Error('Prescription not found');
      }

      logger.info(`Updated prescription ${prescriptionId} status to ${isCompleted ? 'completed' : 'pending'}`);
      return updatedPrescription;

    } catch (error) {
      logger.error('Error updating prescription status:', error);
      throw error;
    }
  }

  /**
   * Find prescription by analytics ID or create a new one
   */
  static async findOrCreatePrescription(
    farmId: string,
    analyticsPrescription: AnalyticsPrescription
  ): Promise<any> {
    try {
      const farmObjectId = new mongoose.Types.ObjectId(farmId);
      
      // Try to find existing prescription by analytics ID or similar characteristics
      let prescription = await Prescription.findOne({
        farmId: farmObjectId,
        title: analyticsPrescription.title,
        parameter: analyticsPrescription.parameter,
        fieldName: analyticsPrescription.fieldName,
        createdAt: {
          $gte: new Date(Date.now() - 24 * 60 * 60 * 1000) // Within last 24 hours
        }
      });

      if (!prescription) {
        // Create new prescription
        prescription = new Prescription({
          farmId: farmObjectId,
          title: analyticsPrescription.title,
          description: analyticsPrescription.description,
          priority: this.mapUrgencyToPriority(analyticsPrescription.urgency),
          status: analyticsPrescription.isCompleted ? 'completed' : 'pending',
          dueDate: this.calculateDueDate(analyticsPrescription.timeline, analyticsPrescription.urgency),
          category: analyticsPrescription.category,
          estimatedDuration: this.estimateDuration(analyticsPrescription.urgency, analyticsPrescription.category),
          materials: this.getMaterialsForCategory(analyticsPrescription.category),
          instructions: analyticsPrescription.instructions || [],
          urgency: analyticsPrescription.urgency,
          timeline: analyticsPrescription.timeline,
          parameter: analyticsPrescription.parameter,
          fieldName: analyticsPrescription.fieldName,
          soilType: analyticsPrescription.soilType,
          growthStage: analyticsPrescription.growthStage,
          completedAt: analyticsPrescription.isCompleted ? new Date() : undefined,
          createdAt: analyticsPrescription.createdAt,
          updatedAt: new Date()
        });

        await prescription.save();
      }

      return prescription;

    } catch (error) {
      logger.error('Error finding or creating prescription:', error);
      throw error;
    }
  }

  // Helper methods
  private static mapUrgencyToPriority(urgency: string): string {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return 'urgent';
      case 'HIGH':
        return 'high';
      case 'MEDIUM':
        return 'medium';
      case 'LOW':
        return 'low';
      default:
        return 'medium';
    }
  }

  private static calculateDueDate(timeline: string, urgency: string): Date {
    const now = new Date();
    const lowerTimeline = timeline.toLowerCase();
    
    if (lowerTimeline === 'today') {
      return new Date(now.getTime() + 24 * 60 * 60 * 1000); // End of day
    } else if (lowerTimeline.includes('this week')) {
      return new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000); // End of week
    } else if (lowerTimeline.includes('next') && lowerTimeline.includes('day')) {
      const match = lowerTimeline.match(/(\d+)/);
      const days = parseInt(match?.[1] || '1');
      return new Date(now.getTime() + days * 24 * 60 * 60 * 1000);
    } else if (lowerTimeline.includes('week')) {
      const match = lowerTimeline.match(/(\d+)/);
      const weeks = parseInt(match?.[1] || '1');
      return new Date(now.getTime() + weeks * 7 * 24 * 60 * 60 * 1000);
    } else if (lowerTimeline.includes('hour')) {
      const match = lowerTimeline.match(/(\d+)/);
      const hours = parseInt(match?.[1] || '1');
      return new Date(now.getTime() + hours * 60 * 60 * 1000);
    }
    
    // Default based on urgency
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return new Date(now.getTime() + 2 * 60 * 60 * 1000); // 2 hours
      case 'HIGH':
        return new Date(now.getTime() + 24 * 60 * 60 * 1000); // 1 day
      case 'MEDIUM':
        return new Date(now.getTime() + 3 * 24 * 60 * 60 * 1000); // 3 days
      case 'LOW':
        return new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000); // 1 week
      default:
        return new Date(now.getTime() + 24 * 60 * 60 * 1000); // 1 day
    }
  }

  private static estimateDuration(urgency: string, category: string): string {
    const baseDuration: { [key: string]: string } = {
      'irrigation': '30 minutes',
      'fertilization': '45 minutes',
      'pest_control': '60 minutes',
      'weather': '15 minutes',
      'soil_treatment': '90 minutes',
      'general': '30 minutes'
    };

    const urgencyMultiplier: { [key: string]: number } = {
      'URGENT': 0.5,
      'HIGH': 0.75,
      'MEDIUM': 1,
      'LOW': 1.25
    };

    const base = baseDuration[category] || baseDuration['general'];
    const multiplier = urgencyMultiplier[urgency] || 1;
    
    // Simple duration estimation (in real app, this would be more sophisticated)
    return base;
  }

  private static getMaterialsForCategory(category: string): string[] {
    const materials: { [key: string]: string[] } = {
      'irrigation': ['Water source', 'Irrigation equipment', 'Moisture meter'],
      'fertilization': ['Fertilizer', 'Spreader', 'Protective gear'],
      'pest_control': ['Pesticide', 'Sprayer', 'Protective gear'],
      'weather': ['Weather app', 'Thermometer', 'Rain gauge'],
      'soil_treatment': ['Soil amendments', 'Tiller', 'Testing kit'],
      'general': ['Basic tools', 'Safety equipment']
    };

    return materials[category] || materials['general'];
  }
}

export default PrescriptionSyncService;
