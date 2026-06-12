import mongoose, { Connection, Model, Schema } from 'mongoose';
import getIotConnection from '../config/iotDatabase';
import { logger } from '../utils/logger';

export interface IIotSensorReading {
  timestamp: Date;
  field_id: string;
  measurements: {
    temperature: number;
    humidity: number;
    soil_moisture: number;
    soil_ph: number;
    light_intensity: number;
  };
}

let IotSensorReadingModel: Model<IIotSensorReading> | null = null;

export const getIotSensorReadingModel = async (): Promise<Model<IIotSensorReading> | null> => {
  try {
    const conn = await getIotConnection();
    if (!conn) return null;

    if (IotSensorReadingModel) return IotSensorReadingModel;

    const schema = new Schema<IIotSensorReading>({
      timestamp: { type: Date, required: true, index: true },
      field_id: { type: String, required: true },
      measurements: {
        temperature: { type: Number, required: true },
        humidity: { type: Number, required: true },
        soil_moisture: { type: Number, required: true },
        soil_ph: { type: Number, required: true },
        light_intensity: { type: Number, required: true },
      },
    }, { collection: 'sensor_readings' });

    IotSensorReadingModel = (conn as Connection).model<IIotSensorReading>('IotSensorReading', schema, 'sensor_readings');
    return IotSensorReadingModel;
  } catch (error) {
    logger.error('Failed to init IOT model:', error);
    return null;
  }
};

export default getIotSensorReadingModel;


