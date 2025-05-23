import SensorReading from '../models/sensor_reading.model.js';
import Prescription from '../models/prescription.model.js';
import { spawn } from 'child_process';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

class AnalyticsService {
  // ... existing code ...

  static async runPythonAnalytics() {
    try {
      console.log('Starting Python analytics process...');
      
      // Path to the Python analytics script and virtual environment
      const scriptPath = path.resolve(__dirname, '../../analytics/main.py');
      const venvPath = path.resolve(__dirname, '../../analytics/.venv');
      const venvPythonPath = path.resolve(venvPath, 'bin/python3');
      
      // Set up environment variables for the Python process
      const env = {
        ...process.env,
        PYTHONPATH: path.resolve(__dirname, '../../analytics'),
        VIRTUAL_ENV: venvPath,
        PATH: `${path.resolve(venvPath, 'bin')}:${process.env.PATH}`
      };
      
      return new Promise((resolve, reject) => {
        const pythonProcess = spawn(venvPythonPath, [scriptPath], { env });

        pythonProcess.stdout.on('data', (data) => {
          console.log('Python analytics output:', data.toString());
        });

        pythonProcess.stderr.on('data', (data) => {
          console.error('Python analytics error:', data.toString());
        });

        pythonProcess.on('close', (code) => {
          if (code !== 0) {
            console.error(`Python analytics process exited with code ${code}`);
            reject(new Error(`Analytics process failed with code ${code}`));
          } else {
            console.log('Python analytics process completed successfully');
            resolve();
          }
        });
      });
    } catch (error) {
      console.error('Error running Python analytics:', error);
      throw error;
    }
  }

  // ... existing code ...
}

export default AnalyticsService; 