import { spawn } from 'child_process';
import path from 'path';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import farmService from './farmService';
import axios from 'axios';

interface AnalyticsV2Results {
  descriptive: {
    farmer_id: string;
    date: string;
    growth_stage: string;
    overall_stress: string;
    stress_analysis: Record<string, any>;
    daysSincePlanting: number;
  };
  predictive: {
    forecast_period_days: number;
    weather_forecast: Record<string, any>;
    risk_assessment: Record<string, any>;
    growth_timeline: Record<string, any>;
  };
  prescriptive: {
    total_recommendations: number;
    priority_score: number;
    recommendations: Array<{
      action: string;
      details: string;
      urgency: 'URGENT' | 'HIGH' | 'MEDIUM' | 'LOW';
      timeline: string;
      category: string;
    }>;
  };
}

interface PythonAnalyticsConfig {
  pythonPath: string;
  analyticsPath: string;
  timeout: number;
  enabled: boolean;
}

class PythonAnalyticsService {
  private config: PythonAnalyticsConfig;

  constructor() {
    this.config = {
      pythonPath: process.env.PYTHON_PATH || 'python3',
      analyticsPath: process.env.ANALYTICS_V2_PATH || path.join(process.cwd(), '../../analytics_v2'),
      timeout: parseInt(process.env.ANALYTICS_TIMEOUT || '60000'),
      enabled: process.env.ENABLE_PYTHON_ANALYTICS === 'true'
    };
  }

  /**
   * Run complete analytics system for a farm
   */
  async runCompleteAnalytics(farmId: string): Promise<AnalyticsV2Results> {
    try {
      if (!this.config.enabled) {
        throw new AppError('Python analytics system is disabled', 503);
      }

      // Get farm details and validate
      const farm = await farmService.getFarmById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Map farm to farmer_id format expected by Python system
      const farmerId = this.mapFarmToFarmerId(farm);

      logger.info(`Running analytics_v2 for farm ${farmId} (farmer: ${farmerId})`);

      // Execute Python analytics system
      const results = await this.executePythonScript('run_complete_system.py', [farmerId]);

      // Validate and parse results
      const parsedResults = this.parseAnalyticsResults(results);

      // Store results in cache for quick access
      await this.cacheResults(farmId, parsedResults);

      logger.info(`Analytics_v2 completed successfully for farm ${farmId}`);
      return parsedResults;

    } catch (error) {
      logger.error(`Failed to run analytics_v2 for farm ${farmId}:`, error);
      throw error;
    }
  }

  /**
   * Get daily recommendations for a farm
   */
  async getDailyRecommendations(farmId: string): Promise<any> {
    try {
      // Try to get cached results first
      const cachedResults = await this.getCachedResults(farmId);
      if (cachedResults && this.isResultsFresh(cachedResults.timestamp)) {
        return cachedResults.prescriptive;
      }

      // Run fresh analytics if no cache or stale
      const results = await this.runCompleteAnalytics(farmId);
      return results.prescriptive;

    } catch (error) {
      logger.error(`Failed to get recommendations for farm ${farmId}:`, error);
      throw error;
    }
  }

  /**
   * Get growth stage analysis for a farm
   */
  async getGrowthStageAnalysis(farmId: string): Promise<any> {
    try {
      const cachedResults = await this.getCachedResults(farmId);
      if (cachedResults && this.isResultsFresh(cachedResults.timestamp)) {
        return {
          current_stage: cachedResults.descriptive.growth_stage,
          days_since_planting: cachedResults.descriptive.daysSincePlanting,
          stress_level: cachedResults.descriptive.overall_stress,
          next_stage_info: cachedResults.predictive.growth_timeline
        };
      }

      const results = await this.runCompleteAnalytics(farmId);
      return {
        current_stage: results.descriptive.growth_stage,
        days_since_planting: results.descriptive.daysSincePlanting,
        stress_level: results.descriptive.overall_stress,
        next_stage_info: results.predictive.growth_timeline
      };

    } catch (error) {
      logger.error(`Failed to get growth analysis for farm ${farmId}:`, error);
      throw error;
    }
  }

  /**
   * Get risk assessment for a farm
   */
  async getRiskAssessment(farmId: string): Promise<any> {
    try {
      const cachedResults = await this.getCachedResults(farmId);
      if (cachedResults && this.isResultsFresh(cachedResults.timestamp)) {
        return cachedResults.predictive.risk_assessment;
      }

      const results = await this.runCompleteAnalytics(farmId);
      return results.predictive.risk_assessment;

    } catch (error) {
      logger.error(`Failed to get risk assessment for farm ${farmId}:`, error);
      throw error;
    }
  }

  /**
   * Schedule daily analytics run for all active farms
   */
  async scheduleDailyAnalytics(): Promise<void> {
    try {
      logger.info('Starting scheduled daily analytics run');

      // Get all active farms with devices
      const farms = await farmService.getFarmsByOwner('');
      const activeFarms = farms.filter((farm: any) => farm.deviceId);
      
      const results = [];
      for (const farm of activeFarms) {
        try {
          const farmId = (farm as any)._id.toString();
          const result = await this.runCompleteAnalytics(farmId);
          results.push({ farmId, success: true, result });
        } catch (error) {
          const farmId = (farm as any)._id.toString();
          logger.error(`Failed analytics for farm ${farmId}:`, error);
          results.push({ farmId, success: false, error: (error as Error).message });
        }
      }

      logger.info(`Daily analytics completed for ${results.length} farms`);

    } catch (error) {
      logger.error('Failed to run scheduled analytics:', error);
      throw error;
    }
  }

  /**
   * Execute Python script with arguments
   */
  private async executePythonScript(scriptName: string, args: string[] = []): Promise<string> {
    return new Promise((resolve, reject) => {
      const scriptPath = path.join(this.config.analyticsPath, scriptName);
      const pythonProcess = spawn(this.config.pythonPath, [scriptPath, ...args], {
        cwd: this.config.analyticsPath,
        env: { ...process.env }
      });

      let stdout = '';
      let stderr = '';

      pythonProcess.stdout.on('data', (data) => {
        stdout += data.toString();
      });

      pythonProcess.stderr.on('data', (data) => {
        stderr += data.toString();
      });

      pythonProcess.on('close', (code) => {
        if (code === 0) {
          resolve(stdout);
        } else {
          reject(new AppError(`Python script failed with code ${code}: ${stderr}`, 500));
        }
      });

      pythonProcess.on('error', (error) => {
        reject(new AppError(`Failed to execute Python script: ${error.message}`, 500));
      });

      // Set timeout
      setTimeout(() => {
        pythonProcess.kill();
        reject(new AppError('Python script execution timeout', 504));
      }, this.config.timeout);
    });
  }

  /**
   * Map farm object to farmer_id format expected by Python system
   */
  private mapFarmToFarmerId(farm: any): string {
    // Use farm ID or create a farmer ID based on user and farm
    return farm.deviceId || `FARM_${farm._id.toString().slice(-8).toUpperCase()}`;
  }

  /**
   * Parse analytics results from Python output
   */
  private parseAnalyticsResults(output: string): AnalyticsV2Results {
    try {
      // Look for JSON output in the Python script output
      const lines = output.split('\n');
      let jsonLine = '';
      
      for (const line of lines) {
        if (line.trim().startsWith('{') && line.includes('descriptive')) {
          jsonLine = line.trim();
          break;
        }
      }

      if (!jsonLine) {
        // If no JSON found, parse from structured output
        return this.parseStructuredOutput(output);
      }

      return JSON.parse(jsonLine);

    } catch (error) {
      logger.error('Failed to parse analytics results:', error);
      throw new AppError('Invalid analytics output format', 500);
    }
  }

  /**
   * Parse structured text output from Python script
   */
  private parseStructuredOutput(output: string): AnalyticsV2Results {
    const lines = output.split('\n');
    
    // Extract key information from the structured output
    const result: AnalyticsV2Results = {
      descriptive: {
        farmer_id: '',
        date: new Date().toISOString().split('T')[0],
        growth_stage: 'VE',
        overall_stress: 'low',
        stress_analysis: {},
        daysSincePlanting: 0
      },
      predictive: {
        forecast_period_days: 7,
        weather_forecast: {},
        risk_assessment: { overall_risk_level: 'low' },
        growth_timeline: {}
      },
      prescriptive: {
        total_recommendations: 0,
        priority_score: 50,
        recommendations: []
      }
    };

    // Parse specific patterns from output
    for (const line of lines) {
      if (line.includes('Overall condition is')) {
        const match = line.match(/Overall condition is (\w+)/i);
        if (match) result.descriptive.overall_stress = match[1].toLowerCase();
      }
      
      if (line.includes('Growth Stage:')) {
        const match = line.match(/Growth Stage: (\w+)/);
        if (match) result.descriptive.growth_stage = match[1];
      }

      if (line.includes('recommendations generated')) {
        const match = line.match(/(\d+) recommendations generated/);
        if (match) result.prescriptive.total_recommendations = parseInt(match[1]);
      }

      if (line.includes('priority score')) {
        const match = line.match(/priority score (\d+)/);
        if (match) result.prescriptive.priority_score = parseInt(match[1]);
      }
    }

    return result;
  }

  /**
   * Cache analytics results
   */
  private async cacheResults(farmId: string, results: AnalyticsV2Results): Promise<void> {
    try {
      const cacheKey = `analytics_v2:${farmId}`;
      const cacheData = {
        ...results,
        timestamp: new Date(),
        farmId
      };

      // Store in Redis if available, otherwise skip caching
      if (process.env.REDIS_URL) {
        // Implementation would use Redis client
        logger.info(`Cached analytics results for farm ${farmId}`);
      }

    } catch (error) {
      logger.warn('Failed to cache analytics results:', error);
      // Don't throw error for caching failure
    }
  }

  /**
   * Get cached analytics results
   */
  private async getCachedResults(farmId: string): Promise<any> {
    try {
      const cacheKey = `analytics_v2:${farmId}`;
      
      // Get from Redis if available
      if (process.env.REDIS_URL) {
        // Implementation would use Redis client
        return null; // Placeholder
      }

      return null;

    } catch (error) {
      logger.warn('Failed to get cached results:', error);
      return null;
    }
  }

  /**
   * Check if results are fresh (less than 24 hours old)
   */
  private isResultsFresh(timestamp: Date): boolean {
    const now = new Date();
    const hoursDiff = (now.getTime() - timestamp.getTime()) / (1000 * 60 * 60);
    return hoursDiff < 24;
  }

  /**
   * Health check for Python analytics system
   */
  async healthCheck(): Promise<{ status: string; message: string }> {
    try {
      if (!this.config.enabled) {
        return { status: 'disabled', message: 'Python analytics system is disabled' };
      }

      // Test Python environment
      await this.executePythonScript('validate_setup.py');
      
      return { status: 'healthy', message: 'Python analytics system is operational' };

    } catch (error) {
      return { 
        status: 'unhealthy', 
        message: `Python analytics system error: ${(error as Error).message}` 
      };
    }
  }
}

export default new PythonAnalyticsService();
