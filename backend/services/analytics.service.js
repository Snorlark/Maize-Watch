import { spawn } from 'child_process';
import mongoose from 'mongoose';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class AnalyticsService {
  static async runPythonAnalytics() {
    return new Promise((resolve, reject) => {
      console.log('Starting Python analytics process...');
      
      const analyticsDir = path.resolve(__dirname, '../../analytics');
      const pythonScript = path.resolve(analyticsDir, 'main.py');
      const venvPython = process.platform === 'win32' 
        ? path.resolve(analyticsDir, 'venv', 'Scripts', 'python.exe')
        : path.resolve(analyticsDir, 'venv', 'bin', 'python3');

      const pythonProcess = spawn(venvPython, [pythonScript], {
        cwd: analyticsDir,
        env: { ...process.env, PYTHONUNBUFFERED: '1' }
      });

      let output = '';
      let errorOutput = '';

      pythonProcess.stdout.on('data', (data) => {
        output += data.toString();
        console.log('Python analytics output:', data.toString().trim());
      });

      pythonProcess.stderr.on('data', (data) => {
        errorOutput += data.toString();
        console.error('Python analytics error:', data.toString().trim());
      });

      pythonProcess.on('close', (code) => {
        if (code === 0) {
          console.log('Python analytics process completed successfully');
          resolve(output);
        } else {
          console.error(`Python analytics process exited with code ${code}`);
          reject(new Error(`Python process failed: ${errorOutput}`));
        }
      });

      pythonProcess.on('error', (error) => {
        console.error('Failed to start Python process:', error);
        reject(error);
      });
    });
  }

  static async getLatestPrescription() {
    try {
      console.log('Fetching latest prescription from IoT database...');
      
      const client = await mongoose.connect(process.env.MONGODB_IOT_URI, {
        serverSelectionTimeoutMS: 30000,
        connectTimeoutMS: 30000,
        socketTimeoutMS: 45000
      });
      
      const db = client.connection.db;
      const prescription = await db.collection('corn_analyses')
        .findOne({}, { sort: { timestamp: -1 } });

      if (prescription) {
        // Ensure all numeric values are properly converted
        if (prescription.measurements) {
          Object.keys(prescription.measurements).forEach(key => {
            prescription.measurements[key] = parseFloat(prescription.measurements[key]) || null;
          });
        }

        if (prescription.parameter_status) {
          Object.keys(prescription.parameter_status).forEach(key => {
            const status = prescription.parameter_status[key];
            if (status.value) {
              status.value = parseFloat(status.value);
            }
            if (status.optimal_range) {
              status.optimal_range.min = parseFloat(status.optimal_range.min);
              status.optimal_range.max = parseFloat(status.optimal_range.max);
            }
          });
        }

        if (prescription.importance_scores) {
          Object.keys(prescription.importance_scores).forEach(key => {
            prescription.importance_scores[key] = parseFloat(prescription.importance_scores[key]);
          });
        }
      }

      console.log('Latest prescription:', prescription);
      return prescription;
    } catch (error) {
      console.error('Error fetching latest prescription:', error);
      throw error;
    }
  }

  static async getUnnotifiedPrescriptions() {
    try {
      console.log('Fetching unnotified prescriptions...');
      
      const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
      const db = client.connection.db;
      
      const prescriptions = await db.collection('corn_analyses')
        .find({ is_notified: false })
        .sort({ timestamp: -1 })
        .toArray();
      
      console.log(`Found ${prescriptions.length} unnotified prescriptions`);
      return prescriptions;
    } catch (error) {
      console.error('Error fetching unnotified prescriptions:', error);
      throw error;
    }
  }

  static async markPrescriptionAsNotified(prescriptionId) {
    try {
      console.log(`Marking prescription ${prescriptionId} as notified`);
      
      const client = await mongoose.connect(process.env.MONGODB_IOT_URI);
      const db = client.connection.db;
      
      const result = await db.collection('corn_analyses')
        .findOneAndUpdate(
          { _id: new mongoose.Types.ObjectId(prescriptionId) },
          { 
            $set: { 
              is_notified: true,
              updatedAt: new Date()
            } 
          },
          { returnDocument: 'after' }
        );
      
      console.log('Prescription updated:', result.value);
      return result.value;
    } catch (error) {
      console.error('Error marking prescription as notified:', error);
      throw error;
    }
  }
}

export default AnalyticsService; 