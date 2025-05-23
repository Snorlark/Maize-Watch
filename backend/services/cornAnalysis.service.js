import mongoose from 'mongoose';
import { cornAnalysisSchema } from '../models/cornAnalysis.model.js';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

// Create a separate connection for IOT database
const iotConnection = mongoose.createConnection(process.env.MONGODB_IOT_URI, {
  serverSelectionTimeoutMS: 15000,
});

// Register the model on the IOT connection with explicit collection name
const CornAnalysis = iotConnection.model('CornAnalysis', cornAnalysisSchema, 'corn_analyses');

// Get all corn analysis records
export async function getAllCornAnalysis() {
  try {
    const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
    const db = client.connection.db;
    
    const analyses = await db.collection('corn_analyses')
      .find({})
      .sort({ timestamp: -1 })
      .toArray();
    
    return analyses;
  } catch (error) {
    console.error('Error getting all corn analyses:', error);
    throw error;
  }
}

// Get corn analysis by field ID
export async function getCornAnalysisByFieldId(fieldId) {
  try {
    const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
    const db = client.connection.db;
    
    const analyses = await db.collection('corn_analyses')
      .find({ field_id: fieldId })
      .sort({ timestamp: -1 })
      .toArray();
    
    return analyses;
  } catch (error) {
    console.error('Error getting corn analyses by field ID:', error);
    throw error;
  }
}

// Get most recent corn analysis
export async function getMostRecentAnalysis(fieldId = null) {
  try {
    const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
    const db = client.connection.db;
    
    const query = fieldId ? { field_id: fieldId } : {};
    const analysis = await db.collection('corn_analyses')
      .findOne(query, { sort: { timestamp: -1 } });
    
    return analysis;
  } catch (error) {
    console.error('Error getting most recent corn analysis:', error);
    throw error;
  }
}

// Get new prescriptions since last check
export async function getNewPrescriptions(userId, lastCheckTimestamp = null) {
  try {
    const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
    const db = client.connection.db;
    
    const query = {
      userId: userId,
      ...(lastCheckTimestamp && {
        timestamp: { $gt: new Date(lastCheckTimestamp) }
      })
    };
    
    const prescriptions = await db.collection('corn_analyses')
      .find(query)
      .sort({ timestamp: -1 })
      .toArray();
    
    return prescriptions;
  } catch (error) {
    console.error('Error getting new prescriptions:', error);
    throw error;
  }
}

// Update prescription status
export async function updatePrescriptionStatus(analysisId, prescriptionId, status) {
  try {
    const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
    const db = client.connection.db;
    
    const result = await db.collection('corn_analyses')
      .findOneAndUpdate(
        { 
          _id: new mongoose.Types.ObjectId(analysisId),
          'prescriptions._id': new mongoose.Types.ObjectId(prescriptionId)
        },
        { 
          $set: { 
            'prescriptions.$.status': status,
            'prescriptions.$.updated_at': new Date()
          } 
        },
        { returnDocument: 'after' }
      );
    
    return result.value;
  } catch (error) {
    console.error('Error updating prescription status:', error);
    throw error;
  }
}

// Export the connection for cleanup
export { iotConnection };