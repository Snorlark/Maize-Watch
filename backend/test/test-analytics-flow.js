import SensorReading from '../models/sensor_reading.model.js';
import AnalyticsService from '../services/analytics.service.js';
import mongoose from 'mongoose';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import chalk from 'chalk';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Load environment variables
dotenv.config({ path: path.resolve(__dirname, '../../.env') });

// Get user ID from command line arguments or use default
const userId = process.argv[2] || '682302b10dffb990e14924e1';
console.log(chalk.yellow(`Using user ID: ${userId}`));

function simulateFlutterPrescriptionScreen(analysis) {
  console.log('\n' + chalk.bold.blue('═══════════════════════════════════════'));
  console.log(chalk.bold.blue('📱 Maize Watch - Prescription Details'));
  console.log(chalk.bold.blue('═══════════════════════════════════════\n'));

  // Header Section
  console.log(chalk.bold('🕒 Date: ') + new Date(analysis.timestamp).toLocaleString());
  console.log(chalk.bold('🌾 Field ID: ') + analysis.field_id);
  console.log(chalk.bold('🌱 Growth Stage: ') + analysis.corn_growth_stage);
  
  // Severity Level Indicator
  const severityColor = {
    'CRITICAL': 'red',
    'WARNING': 'yellow',
    'NORMAL': 'green'
  }[analysis.severity_level];
  console.log(chalk.bold('\n📊 Status: ') + chalk[severityColor](analysis.severity_level));

  // Current Measurements
  console.log(chalk.bold('\n📈 Current Measurements:'));
  console.log('├─ Temperature: ' + chalk.cyan(analysis.measurements.temperature + '°C'));
  console.log('├─ Humidity: ' + chalk.cyan(analysis.measurements.humidity + '%'));
  console.log('├─ Soil Moisture: ' + chalk.cyan(analysis.measurements.soil_moisture + '%'));
  console.log('├─ Soil pH: ' + chalk.cyan(analysis.measurements.soil_ph));
  console.log('└─ Light Intensity: ' + chalk.cyan(analysis.measurements.light_intensity + ' lux'));

  // Alerts Section
  if (analysis.alerts && analysis.alerts.length > 0) {
    console.log(chalk.bold('\n⚠️ Alerts:'));
    analysis.alerts.forEach((alert, index) => {
      const isLast = index === analysis.alerts.length - 1;
      const prefix = isLast ? '└─' : '├─';
      if (alert.includes('CRITICAL')) {
        console.log(`${prefix} ${chalk.red(alert)}`);
      } else {
        console.log(`${prefix} ${chalk.yellow(alert)}`);
      }
    });
  }

  // Recommendations Section
  if (analysis.recommendations && analysis.recommendations.length > 0) {
    console.log(chalk.bold('\n💡 Recommendations:'));
    analysis.recommendations.forEach((rec, index) => {
      const isLast = index === analysis.recommendations.length - 1;
      const prefix = isLast ? '└─' : '├─';
      if (rec.includes('URGENT')) {
        console.log(`${prefix} ${chalk.red(rec)}`);
      } else {
        console.log(`${prefix} ${chalk.green(rec)}`);
      }
    });
  }

  // Parameter Status with Importance Scores
  if (analysis.importance_scores) {
    console.log(chalk.bold('\n🎯 Priority Areas:'));
    const sortedScores = Object.entries(analysis.importance_scores)
      .sort(([,a], [,b]) => b - a);
    
    sortedScores.forEach(([param, score], index) => {
      const isLast = index === sortedScores.length - 1;
      const prefix = isLast ? '└─' : '├─';
      const percentage = (score * 100).toFixed(1);
      const bar = '█'.repeat(Math.floor(score * 20));
      console.log(`${prefix} ${chalk.bold(param)}: ${bar} ${percentage}%`);
    });
  }

  console.log('\n' + chalk.bold.blue('═══════════════════════════════════════\n'));
}

async function testAnalyticsFlow() {
  try {
    console.log('Starting analytics flow test...');

    // Connect to MongoDB
    console.log('Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_IOT_URI, {
      serverSelectionTimeoutMS: 30000,
      connectTimeoutMS: 30000,
      socketTimeoutMS: 45000,
      maxPoolSize: 50,
      retryWrites: true,
      retryReads: true,
      w: 'majority'
    });
    console.log('Connected to MongoDB successfully');

    // Create a test sensor reading with valid measurement values
    const testReading = new SensorReading({
      timestamp: new Date(),
      field_id: 'test_field_1',
      corn_growth_stage: 'Silking (R1)',
      userId: userId,
      measurements: {
        temperature: 26.5,    // High temperature
        humidity: 85.0,       // High humidity
        soil_moisture: 75.0,  // High soil moisture
        soil_ph: 7.8,        // High pH
        light_intensity: 11500 // High light intensity
      }
    });

    // Save the test reading
    console.log('Saving test sensor reading...');
    await testReading.save();
    console.log('Test sensor reading saved successfully');

    // Run Python analytics
    console.log('Running Python analytics...');
    try {
      await AnalyticsService.runPythonAnalytics();
      console.log('Python analytics completed');
    } catch (error) {
      console.error('Error running Python analytics:', error);
      throw error;
    }

    // Wait a bit for the Python script to finish processing
    console.log('Waiting for analytics to complete...');
    await new Promise(resolve => setTimeout(resolve, 5000));

    // Fetch latest analysis
    console.log('Fetching latest analysis...');
    const latestAnalysis = await mongoose.connection.db
      .collection('corn_analyses')
      .findOne({}, { sort: { timestamp: -1 } });

    if (!latestAnalysis) {
      console.error('No analysis found in database. Checking sensor readings...');
      const sensorReadings = await mongoose.connection.db
        .collection('sensor_readings')
        .find({}, { sort: { timestamp: -1 } })
        .toArray();
      
      console.log(`Found ${sensorReadings.length} sensor readings`);
      if (sensorReadings.length > 0) {
        console.log('Latest sensor reading:', sensorReadings[0]);
      }
      
      throw new Error('No analysis found after running analytics');
    }

    // Simulate Flutter prescription screen
    console.log('\nSimulating how this will appear in the Flutter app:');
    simulateFlutterPrescriptionScreen(latestAnalysis);

    // Verify analysis results
    console.log(chalk.bold('\n✅ Verification Results:'));
    const verificationResults = {
      hasTimestamp: !!latestAnalysis.timestamp,
      hasFieldId: !!latestAnalysis.field_id,
      hasUserId: !!latestAnalysis.userId,
      hasMeasurements: !!latestAnalysis.measurements,
      hasAlerts: Array.isArray(latestAnalysis.alerts),
      hasRecommendations: Array.isArray(latestAnalysis.recommendations),
      hasSeverityLevel: !!latestAnalysis.severity_level
    };

    Object.entries(verificationResults).forEach(([key, passed]) => {
      console.log(`${passed ? '✓' : '✗'} ${key}: ${passed ? chalk.green('PASSED') : chalk.red('FAILED')}`);
    });

    // Check if any verification failed
    const failedVerifications = Object.entries(verificationResults)
      .filter(([_, passed]) => !passed)
      .map(([key]) => key);

    if (failedVerifications.length > 0) {
      throw new Error(`Analysis verification failed for: ${failedVerifications.join(', ')}`);
    }

    // Don't clean up test data
    console.log('\nTest data has been saved and will be available for the app.');
    console.log(chalk.bold.green('\n✨ Test completed successfully!\n'));
  } catch (error) {
    console.error(chalk.red('\n❌ Error during test:'), error);
    throw error;
  } finally {
    // Close MongoDB connection
    await mongoose.connection.close();
    console.log('MongoDB connection closed');
  }
}

// Run the test
testAnalyticsFlow(); 