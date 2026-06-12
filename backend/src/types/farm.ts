import { Types } from 'mongoose';

// Updated interface for simplified Farm model
export interface FarmCreationData {
  userId: Types.ObjectId;
  fieldName: string;
  location: string;
  soilType: string;
  plantingDate: Date;
  growthStage?: string;
  deviceId?: string;
  deviceMacAddress?: string;
}

export interface SimplifiedFarmData {
  userId: string;
  fieldName: string;
  location: string;
  soilType: string;
  plantingDate: Date;
  growthStage?: string;
}
