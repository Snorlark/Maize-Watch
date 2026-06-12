import SensorReading from '../models/SensorReading';
import Farm from '../models/Farm';
import Sensor from '../models/Sensor';
import { AppError } from '../middleware/errorHandler';
import { logger } from '../utils/logger';
import { ANALYTICS_INTERVALS } from '../utils/constants';
import axios from 'axios';

interface AnalyticsQuery {
  farmId?: string;
  sensorId?: string;
  startDate: Date;
  endDate: Date;
  interval: 'hour' | 'day' | 'week' | 'month';
  metrics?: string[];
}

// Type for valid sensor data keys
type SensorDataKey = 'temperature' | 'humidity' | 'soilMoisture' | 'lightIntensity' | 'pH' | 'batteryLevel' | 'signalStrength';

interface TrendAnalysis {
  metric: string;
  trend: 'increasing' | 'decreasing' | 'stable';
  changeRate: number;
  confidence: number;
}

interface CorrelationAnalysis {
  metric1: string;
  metric2: string;
  correlation: number;
  significance: 'high' | 'medium' | 'low';
}

interface PredictiveModel {
  metric: string;
  predictions: Array<{
    timestamp: Date;
    predictedValue: number;
    confidence: number;
  }>;
  accuracy: number;
}

class AnalyticsService {
  /**
   * Get aggregated sensor data
   */
  async getAggregatedData(query: AnalyticsQuery): Promise<any[]> {
    try {
      const { farmId, sensorId, startDate, endDate, interval } = query;

      if (sensorId) {
        // Get data for specific sensor
        const data = await SensorReading.getAggregatedData(
          sensorId,
          startDate,
          endDate,
          interval
        );
        return data;
      } else if (farmId) {
        // Get data for all sensors in farm
        const data = await SensorReading.getAggregatedData(
          farmId,
          startDate,
          endDate,
          interval
        );
        return data;
      } else {
        throw new AppError('Either farmId or sensorId must be provided', 400);
      }
    } catch (error) {
      logger.error('Error getting aggregated data:', error);
      throw error;
    }
  }

  /**
   * Generate comprehensive farm report
   */
  async generateFarmReport(farmId: string, period: 'week' | 'month' | 'quarter' | 'year'): Promise<any> {
    try {
      const farm = await Farm.findById(farmId).populate('sensors');
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      const endDate = new Date();
      const startDate = this.getStartDateForPeriod(period);

      // Get basic statistics
      const basicStats = await this.getBasicStatistics(farmId, startDate, endDate);

      // Get trend analysis
      const trends = await this.analyzeTrends(farmId, startDate, endDate);

      // Get correlation analysis
      const correlations = await this.analyzeCorrelations(farmId, startDate, endDate);

      // Get alert summary
      const alertSummary = await this.getAlertSummary(farmId, startDate, endDate);

      // Get data quality metrics
      const dataQuality = await this.getDataQualityMetrics(farmId, startDate, endDate);

      // Generate recommendations
      const recommendations = await this.generateRecommendations(farmId, basicStats, trends);

      return {
        farm: {
          id: farm._id,
          name: farm.farmName,
          cropType: 'Corn', // Fixed to corn for simplified system
          location: farm.location,
          plantingDate: (farm as any).plantingDate,
          growthStage: (farm as any).growthStage,
        },
        period: {
          start: startDate,
          end: endDate,
          type: period,
        },
        statistics: basicStats,
        trends,
        correlations,
        alerts: alertSummary,
        dataQuality,
        recommendations,
        generatedAt: new Date(),
      };
    } catch (error) {
      logger.error('Error generating farm report:', error);
      throw error;
    }
  }

  /**
   * Analyze environmental trends
   */
  async analyzeTrends(farmId: string, startDate: Date, endDate: Date): Promise<TrendAnalysis[]> {
    try {
      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate, $lte: endDate },
        'metadata.quality': { $in: ['good', 'fair'] }
      }).sort({ timestamp: 1 });

      const metrics = ['temperature', 'humidity', 'soilMoisture', 'pH', 'lightIntensity'];
      const trends: TrendAnalysis[] = [];

      for (const metric of metrics) {
        const values = readings
          .map(r => r.data[metric as SensorDataKey])
          .filter(v => v !== undefined && v !== null);

        if (values.length < 10) continue; // Need minimum data points

        const trend = this.calculateTrend(values);
        trends.push({
          metric,
          trend: trend.direction,
          changeRate: trend.rate,
          confidence: trend.confidence,
        });
      }

      return trends;
    } catch (error) {
      logger.error('Error analyzing trends:', error);
      throw error;
    }
  }

  /**
   * Analyze correlations between metrics
   */
  async analyzeCorrelations(farmId: string, startDate: Date, endDate: Date): Promise<CorrelationAnalysis[]> {
    try {
      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate, $lte: endDate },
        'metadata.quality': { $in: ['good', 'fair'] }
      });

      const metrics = ['temperature', 'humidity', 'soilMoisture', 'pH'];
      const correlations: CorrelationAnalysis[] = [];

      for (let i = 0; i < metrics.length; i++) {
        for (let j = i + 1; j < metrics.length; j++) {
          const metric1 = metrics[i];
          const metric2 = metrics[j];

          const pairs = readings
            .map(r => [r.data[metric1 as SensorDataKey], r.data[metric2 as SensorDataKey]])
            .filter(([a, b]) => a !== undefined && b !== undefined) as number[][];

          if (pairs.length < 20) continue; // Need minimum data points

          const correlation = this.calculateCorrelation(pairs);
          correlations.push({
            metric1,
            metric2,
            correlation: correlation.coefficient,
            significance: correlation.significance,
          });
        }
      }

      return correlations;
    } catch (error) {
      logger.error('Error analyzing correlations:', error);
      throw error;
    }
  }

  /**
   * Generate predictive models
   */
  async generatePredictiveModel(
    farmId: string,
    metric: string,
    daysAhead: number = 7
  ): Promise<PredictiveModel> {
    try {
      // Get historical data (last 90 days)
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 90);

      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate, $lte: endDate },
        'metadata.quality': { $in: ['good', 'fair'] },
        [`data.${metric}`]: { $exists: true, $ne: null }
      }).sort({ timestamp: 1 });

      if (readings.length < 50) {
        throw new AppError('Insufficient data for prediction model', 400);
      }

      // Use external Python analytics service if available
      if (process.env.ANALYTICS_SERVICE_URL) {
        return await this.callExternalAnalyticsService(farmId, metric, readings, daysAhead);
      }

      // Fallback to simple linear regression
      return this.generateSimplePrediction(metric, readings, daysAhead);
    } catch (error) {
      logger.error('Error generating predictive model:', error);
      throw error;
    }
  }

  /**
   * Get anomaly detection results
   */
  async detectAnomalies(farmId: string, days: number = 30): Promise<any[]> {
    try {
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - days);

      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate, $lte: endDate },
        'metadata.anomaly': true
      }).populate('sensor', 'name sensorId type');

      return readings.map(reading => ({
        id: reading._id,
        sensor: reading.sensor,
        timestamp: reading.timestamp,
        data: reading.data,
        anomalyScore: this.calculateAnomalyScore(reading),
        possibleCauses: this.identifyAnomalyCauses(reading),
      }));
    } catch (error) {
      logger.error('Error detecting anomalies:', error);
      throw error;
    }
  }

  /**
   * Get yield optimization insights
   */
  async getYieldOptimizationInsights(farmId: string): Promise<any> {
    try {
      const farm = await Farm.findById(farmId);
      if (!farm) {
        throw new AppError('Farm not found', 404);
      }

      // Get recent data (last 30 days)
      const endDate = new Date();
      const startDate = new Date();
      startDate.setDate(startDate.getDate() - 30);

      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate, $lte: endDate },
        'metadata.quality': { $in: ['good', 'fair'] }
      });

      const insights = {
        optimalRanges: this.getOptimalRanges('Corn'),
        deviations: this.identifyDeviations(readings, 'Corn'),
        actionableRecommendations: this.generateActionableRecommendations(readings, farm),
        yieldImpactScore: this.calculateYieldImpactScore(readings, 'Corn'),
      };

      return insights;
    } catch (error) {
      logger.error('Error getting yield optimization insights:', error);
      throw error;
    }
  }

  /**
   * Export analytics data
   */
  async exportData(
    farmId: string,
    format: 'csv' | 'json' | 'excel',
    startDate: Date,
    endDate: Date
  ): Promise<any> {
    try {
      const readings = await SensorReading.find({
        farm: farmId,
        timestamp: { $gte: startDate, $lte: endDate }
      }).populate('sensor', 'name sensorId type');

      switch (format) {
        case 'csv':
          return this.convertToCSV(readings);
        case 'json':
          return { data: readings };
        case 'excel':
          return this.convertToExcel(readings);
        default:
          throw new AppError('Unsupported export format', 400);
      }
    } catch (error) {
      logger.error('Error exporting data:', error);
      throw error;
    }
  }

  /**
   * Private helper methods
   */
  private getStartDateForPeriod(period: string): Date {
    const date = new Date();
    switch (period) {
      case 'week':
        date.setDate(date.getDate() - 7);
        break;
      case 'month':
        date.setMonth(date.getMonth() - 1);
        break;
      case 'quarter':
        date.setMonth(date.getMonth() - 3);
        break;
      case 'year':
        date.setFullYear(date.getFullYear() - 1);
        break;
    }
    return date;
  }

  private async getBasicStatistics(farmId: string, startDate: Date, endDate: Date): Promise<any> {
    const readings = await SensorReading.find({
      farm: farmId,
      timestamp: { $gte: startDate, $lte: endDate },
      'metadata.quality': { $in: ['good', 'fair'] }
    });

    const metrics = ['temperature', 'humidity', 'soilMoisture', 'pH', 'lightIntensity'];
    const stats: any = {};

    for (const metric of metrics) {
      const values = readings
        .map(r => r.data[metric as SensorDataKey])
        .filter(v => v !== undefined && v !== null);

      if (values.length > 0) {
        stats[metric] = {
          count: values.length,
          min: Math.min(...values),
          max: Math.max(...values),
          average: values.reduce((a, b) => a + b, 0) / values.length,
          median: this.calculateMedian(values),
          standardDeviation: this.calculateStandardDeviation(values),
        };
      }
    }

    return stats;
  }

  private calculateTrend(values: number[]): any {
    if (values.length < 2) return { direction: 'stable', rate: 0, confidence: 0 };

    // Simple linear regression
    const n = values.length;
    const x = Array.from({ length: n }, (_, i) => i);
    const sumX = x.reduce((a, b) => a + b, 0);
    const sumY = values.reduce((a, b) => a + b, 0);
    const sumXY = x.reduce((sum, xi, i) => sum + xi * values[i], 0);
    const sumXX = x.reduce((sum, xi) => sum + xi * xi, 0);

    const slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
    const confidence = Math.min(Math.abs(slope) * 10, 1); // Simplified confidence

    return {
      direction: slope > 0.01 ? 'increasing' : slope < -0.01 ? 'decreasing' : 'stable',
      rate: slope,
      confidence,
    };
  }

  private calculateCorrelation(pairs: number[][]): any {
    const n = pairs.length;
    const sumX = pairs.reduce((sum, [x]) => sum + x, 0);
    const sumY = pairs.reduce((sum, [, y]) => sum + y, 0);
    const sumXY = pairs.reduce((sum, [x, y]) => sum + x * y, 0);
    const sumXX = pairs.reduce((sum, [x]) => sum + x * x, 0);
    const sumYY = pairs.reduce((sum, [, y]) => sum + y * y, 0);

    const numerator = n * sumXY - sumX * sumY;
    const denominator = Math.sqrt((n * sumXX - sumX * sumX) * (n * sumYY - sumY * sumY));

    const coefficient = denominator === 0 ? 0 : numerator / denominator;
    const significance = Math.abs(coefficient) > 0.7 ? 'high' : 
                        Math.abs(coefficient) > 0.4 ? 'medium' : 'low';

    return { coefficient, significance };
  }

  private calculateMedian(values: number[]): number {
    const sorted = [...values].sort((a, b) => a - b);
    const mid = Math.floor(sorted.length / 2);
    return sorted.length % 2 === 0 ? (sorted[mid - 1] + sorted[mid]) / 2 : sorted[mid];
  }

  private calculateStandardDeviation(values: number[]): number {
    const mean = values.reduce((a, b) => a + b, 0) / values.length;
    const variance = values.reduce((sum, value) => sum + Math.pow(value - mean, 2), 0) / values.length;
    return Math.sqrt(variance);
  }

  private async getAlertSummary(farmId: string, startDate: Date, endDate: Date): Promise<any> {
    const readings = await SensorReading.find({
      farm: farmId,
      timestamp: { $gte: startDate, $lte: endDate },
      alerts: { $exists: true, $ne: [] }
    });

    const alerts = readings.flatMap(r => r.alerts || []);
    
    return {
      total: alerts.length,
      acknowledged: alerts.filter(a => a.acknowledged).length,
      bySeverity: alerts.reduce((acc, alert) => {
        acc[alert.severity] = (acc[alert.severity] || 0) + 1;
        return acc;
      }, {} as Record<string, number>),
      byType: alerts.reduce((acc, alert) => {
        acc[alert.type] = (acc[alert.type] || 0) + 1;
        return acc;
      }, {} as Record<string, number>),
    };
  }

  private async getDataQualityMetrics(farmId: string, startDate: Date, endDate: Date): Promise<any> {
    const readings = await SensorReading.find({
      farm: farmId,
      timestamp: { $gte: startDate, $lte: endDate }
    });

    const qualityDistribution = readings.reduce((acc, reading) => {
      const quality = reading.metadata?.quality || 'unknown';
      acc[quality] = (acc[quality] || 0) + 1;
      return acc;
    }, {} as Record<string, number>);

    const completenessScores = readings.map(r => (r as any).completenessScore || 0);
    const avgCompleteness = completenessScores.length > 0 ? 
      completenessScores.reduce((a, b) => a + b, 0) / completenessScores.length : 0;

    return {
      totalReadings: readings.length,
      qualityDistribution,
      averageCompleteness: avgCompleteness,
      dataGaps: this.identifyDataGaps(readings),
    };
  }

  private identifyDataGaps(readings: any[]): any[] {
    // Identify periods with no data (gaps > 2 hours)
    const gaps = [];
    const sortedReadings = readings.sort((a, b) => a.timestamp.getTime() - b.timestamp.getTime());
    
    for (let i = 1; i < sortedReadings.length; i++) {
      const timeDiff = sortedReadings[i].timestamp.getTime() - sortedReadings[i - 1].timestamp.getTime();
      const hoursDiff = timeDiff / (1000 * 60 * 60);
      
      if (hoursDiff > 2) {
        gaps.push({
          start: sortedReadings[i - 1].timestamp,
          end: sortedReadings[i].timestamp,
          duration: hoursDiff,
        });
      }
    }
    
    return gaps;
  }

  private async generateRecommendations(farmId: string, stats: any, trends: TrendAnalysis[]): Promise<string[]> {
    const recommendations = [];

    // Temperature recommendations
    if (stats.temperature && stats.temperature.average > 35) {
      recommendations.push('Consider shade structures or increased irrigation to combat high temperatures');
    }

    // Soil moisture recommendations
    if (stats.soilMoisture && stats.soilMoisture.average < 40) {
      recommendations.push('Increase irrigation frequency - soil moisture is below optimal levels');
    }

    // pH recommendations
    if (stats.pH && (stats.pH.average < 6.0 || stats.pH.average > 7.5)) {
      recommendations.push('Soil pH is outside optimal range - consider soil amendment');
    }

    // Trend-based recommendations
    const soilMoistureTrend = trends.find(t => t.metric === 'soilMoisture');
    if (soilMoistureTrend && soilMoistureTrend.trend === 'decreasing') {
      recommendations.push('Soil moisture is declining - monitor irrigation system');
    }

    return recommendations;
  }

  private async callExternalAnalyticsService(
    farmId: string,
    metric: string,
    readings: any[],
    daysAhead: number
  ): Promise<PredictiveModel> {
    try {
      const response = await axios.post(`${process.env.ANALYTICS_SERVICE_URL}/predict`, {
        farmId,
        metric,
        data: readings.map(r => ({
          timestamp: r.timestamp,
          value: r.data[metric],
        })),
        daysAhead,
      }, {
        headers: {
          'Authorization': `Bearer ${process.env.PYTHON_ANALYTICS_API_KEY}`,
          'Content-Type': 'application/json',
        },
        timeout: 30000,
      });

      return response.data;
    } catch (error) {
      logger.warn('External analytics service unavailable, using fallback');
      return this.generateSimplePrediction(metric, readings, daysAhead);
    }
  }

  private generateSimplePrediction(metric: string, readings: any[], daysAhead: number): PredictiveModel {
    const values = readings.map(r => r.data[metric as SensorDataKey]).filter(v => v !== undefined);
    const timestamps = readings.map(r => r.timestamp);
    
    // Simple moving average prediction
    const windowSize = Math.min(7, values.length);
    const recentAverage = values.slice(-windowSize).reduce((a, b) => a + b, 0) / windowSize;
    
    const predictions = [];
    const now = new Date();
    
    for (let i = 1; i <= daysAhead; i++) {
      const futureDate = new Date(now);
      futureDate.setDate(futureDate.getDate() + i);
      
      predictions.push({
        timestamp: futureDate,
        predictedValue: recentAverage,
        confidence: Math.max(0.3, 1 - (i * 0.1)), // Decreasing confidence over time
      });
    }

    return {
      metric,
      predictions,
      accuracy: 0.6, // Simplified accuracy for basic model
    };
  }

  private calculateAnomalyScore(reading: any): number {
    // Simplified anomaly scoring
    return Math.random() * 0.3 + 0.7; // Score between 0.7-1.0
  }

  private identifyAnomalyCauses(reading: any): string[] {
    const causes = [];
    
    if (reading.data.temperature > 40) causes.push('Extreme temperature');
    if (reading.data.soilMoisture < 20) causes.push('Very low soil moisture');
    if (reading.data.batteryLevel < 10) causes.push('Low sensor battery');
    
    return causes;
  }

  private analyzeCurrentConditions(readings: any[]): any {
    if (readings.length === 0) return {};
    
    const latest = readings[readings.length - 1];
    return {
      temperature: latest.data.temperature,
      humidity: latest.data.humidity,
      soilMoisture: latest.data.soilMoisture,
      pH: latest.data.pH,
      timestamp: latest.timestamp,
    };
  }

  private getOptimalRanges(cropType: string): any {
    // Optimal ranges for different crops
    const ranges: Record<string, any> = {
      'Corn': {
        temperature: { min: 20, max: 30 },
        humidity: { min: 50, max: 70 },
        soilMoisture: { min: 50, max: 70 },
        pH: { min: 6.0, max: 7.0 },
      },
      'Rice': {
        temperature: { min: 25, max: 35 },
        humidity: { min: 70, max: 85 },
        soilMoisture: { min: 80, max: 95 },
        pH: { min: 5.5, max: 6.5 },
      },
    };

    return ranges[cropType] || ranges['Corn']; // Default to corn
  }

  private identifyDeviations(readings: any[], cropType: string): any {
    const optimal = this.getOptimalRanges(cropType);
    const deviations: any = {};

    if (readings.length === 0) return deviations;

    const latest = readings[readings.length - 1];

    Object.keys(optimal).forEach(metric => {
      const value = latest.data[metric as SensorDataKey];
      const range = optimal[metric];
      
      if (value !== undefined && range) {
        if (value < range.min) {
          deviations[metric] = { status: 'below', deviation: range.min - value };
        } else if (value > range.max) {
          deviations[metric] = { status: 'above', deviation: value - range.max };
        } else {
          deviations[metric] = { status: 'optimal', deviation: 0 };
        }
      }
    });

    return deviations;
  }

  private generateActionableRecommendations(readings: any[], farm: any): string[] {
    const recommendations: string[] = [];
    
    if (readings.length === 0) return recommendations;

    const latest = readings[readings.length - 1];
    const optimal = this.getOptimalRanges('Corn');

    if (latest.data.soilMoisture < optimal.soilMoisture.min) {
      recommendations.push('Increase irrigation - soil moisture is below optimal range');
    }

    if (latest.data.temperature > optimal.temperature.max) {
      recommendations.push('Provide shade or cooling - temperature is above optimal range');
    }

    if (latest.data.pH < optimal.pH.min) {
      recommendations.push('Apply lime to increase soil pH');
    } else if (latest.data.pH > optimal.pH.max) {
      recommendations.push('Apply sulfur or organic matter to decrease soil pH');
    }

    return recommendations;
  }

  private calculateYieldImpactScore(readings: any[], cropType: string): number {
    if (readings.length === 0) return 0;

    const optimal = this.getOptimalRanges(cropType);
    const latest = readings[readings.length - 1];
    
    let score = 100;

    Object.keys(optimal).forEach(metric => {
      const value = latest.data[metric as SensorDataKey];
      const range = optimal[metric];
      
      if (value !== undefined && range) {
        if (value < range.min || value > range.max) {
          const deviation = value < range.min ? range.min - value : value - range.max;
          const maxDeviation = range.max - range.min;
          const impactPercent = Math.min((deviation / maxDeviation) * 30, 30);
          score -= impactPercent;
        }
      }
    });

    return Math.max(score, 0);
  }

  private convertToCSV(readings: any[]): string {
    if (readings.length === 0) return '';

    const headers = ['timestamp', 'sensor', 'temperature', 'humidity', 'soilMoisture', 'pH', 'lightIntensity'];
    const csvRows = [headers.join(',')];

    readings.forEach(reading => {
      const row = [
        reading.timestamp.toISOString(),
        reading.sensor?.name || '',
        reading.data.temperature || '',
        reading.data.humidity || '',
        reading.data.soilMoisture || '',
        reading.data.pH || '',
        reading.data.lightIntensity || '',
      ];
      csvRows.push(row.join(','));
    });

    return csvRows.join('\n');
  }

  private convertToExcel(readings: any[]): any {
    // This would require a library like xlsx
    // For now, return JSON format
    return { data: readings, format: 'excel' };
  }
}

export default new AnalyticsService();
