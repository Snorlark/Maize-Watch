import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import SensorReading from '../models/SensorReading';

type Period = 'daily' | 'weekly' | 'monthly';

export const getHistoricalData = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const period = req.query.period as Period;
    const limit = parseInt(req.query.limit as string) || 7;
    const baseDateParam = (req.query.baseDate as string) || '';
    const baseDate = baseDateParam ? new Date(baseDateParam) : new Date();


    // Validate period
    if (!period || !['daily', 'weekly', 'monthly'].includes(period)) {
      console.error('[CONTROLLER] Invalid period provided:', period);
      return res.status(400).json({
        success: false,
        error: 'Invalid or missing period. Must be daily, weekly, or monthly.',
        receivedPeriod: period,
        receivedQuery: req.query
      });
    }

    // Step 1: Check if we can connect to the database
    const dbState = mongoose.connection.readyState;
    
    if (dbState !== 1) {
      return res.status(500).json({
        success: false,
        error: 'Database not connected',
        dbState
      });
    }

    // Step 2: Calculate date ranges based on period and baseDate
    let startDate: Date;
    let endDate: Date;
    const d = new Date(baseDate);
    if (period === 'daily') {
      // Align to Sunday-Saturday week containing baseDate
      const dayOfWeek = d.getDay(); // 0=Sunday
      startDate = new Date(d);
      startDate.setHours(0, 0, 0, 0);
      startDate.setDate(d.getDate() - dayOfWeek); // back to Sunday
      endDate = new Date(startDate);
      endDate.setDate(startDate.getDate() + 6); // Saturday
      endDate.setHours(23, 59, 59, 999);
    } else if (period === 'weekly') {
      // Whole month of baseDate, grouped by Sunday-Saturday weeks inside month
      startDate = new Date(d.getFullYear(), d.getMonth(), 1);
      startDate.setHours(0, 0, 0, 0);
      endDate = new Date(d.getFullYear(), d.getMonth() + 1, 0);
      endDate.setHours(23, 59, 59, 999);
    } else {
      // Monthly: last `limit` months ending at baseDate's month
      const monthStart = new Date(d.getFullYear(), d.getMonth() - (limit - 1), 1);
      startDate = new Date(monthStart);
      startDate.setHours(0, 0, 0, 0);
      endDate = new Date(d.getFullYear(), d.getMonth() + 1, 0);
      endDate.setHours(23, 59, 59, 999);
    }



    // Step 3: Build aggregation pipeline based on period
    let groupBy: any = {};
    if (period === 'daily') {
      groupBy = {
        year: { $year: '$timestamp' },
        month: { $month: '$timestamp' },
        day: { $dayOfMonth: '$timestamp' }
      };
    } else if (period === 'weekly') {
      // Use $week (Sunday-based) to align with Sunday-Saturday
      groupBy = {
        year: { $year: '$timestamp' },
        week: { $week: '$timestamp' }
      };
    } else {
      groupBy = {
        year: { $year: '$timestamp' },
        month: { $month: '$timestamp' }
      };
    }

    // Step 4: Execute aggregation pipeline

    
    const aggregationPipeline = [
      {
        $match: {
          timestamp: { $gte: startDate, $lte: endDate },
          'metadata.quality': { $ne: 'error' },
          'data.temperature': { $exists: true, $ne: null }
        }
      },
      {
        $group: {
          _id: groupBy,
          temperature: { $avg: '$data.temperature' },
          humidity: { $avg: '$data.humidity' },
          soilMoisture: { $avg: '$data.soilMoisture' },
          soilPh: { $avg: '$data.pH' },
          lightIntensity: { $avg: '$data.lightIntensity' },
          dataPoints: { $sum: 1 },
          minTemp: { $min: '$data.temperature' },
          maxTemp: { $max: '$data.temperature' },
          firstTimestamp: { $min: '$timestamp' },
          lastTimestamp: { $max: '$timestamp' }
        }
      },
      {
        $sort: {
          '_id.year': 1,
          '_id.month': 1,
          '_id.day': 1,
          '_id.week': 1
        } as any
      },
      // No $limit here; range is controlled by startDate/endDate
    ];

    const aggregatedData = await SensorReading.aggregate(aggregationPipeline);


    // Utilities
    const round = (val: any, digits: number) => (typeof val === 'number' ? Math.round(val * Math.pow(10, digits)) / Math.pow(10, digits) : null);

    // Step 5: Format and fill the data for frontend consumption
    let formattedData: any[] = [];

    if (period === 'daily') {
      // Map by date string
      const byDate = new Map<string, any>();
      for (const item of aggregatedData) {
        const date = new Date(item._id.year, item._id.month - 1, item._id.day);
        const key = date.toDateString();
        byDate.set(key, {
          label: date.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
          timestamp: date.toISOString(),
          temperature: round(item.temperature, 1),
          humidity: round(item.humidity, 1),
          soilMoisture: round(item.soilMoisture, 1),
          soilPh: round(item.soilPh, 2),
          lightIntensity: round(item.lightIntensity, 0),
          dataPoints: item.dataPoints || 0,
          date: date.toISOString()
        });
      }
      // Fill Sunday-Saturday
      const cur = new Date(startDate);
      cur.setHours(0, 0, 0, 0);
      for (let i = 0; i < 7; i++) {
        const key = cur.toDateString();
        if (byDate.has(key)) {
          formattedData.push(byDate.get(key));
        } else {
          formattedData.push({
            label: cur.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
            timestamp: cur.toISOString(),
            temperature: null,
            humidity: null,
            soilMoisture: null,
            soilPh: null,
            lightIntensity: null,
            dataPoints: 0,
            date: cur.toISOString()
          });
        }
        cur.setDate(cur.getDate() + 1);
      }
    } else if (period === 'weekly') {
      // Grouped by Mongo week; compute weekStart (Sunday) for label
      const weeks: any[] = aggregatedData.map((item: any) => {
        const weekStart = new Date(item._id.year, 0, 1 + (item._id.week - 1) * 7);
        // Align back to Sunday of that week
        weekStart.setDate(weekStart.getDate() - weekStart.getDay());
        const weekEnd = new Date(weekStart);
        weekEnd.setDate(weekStart.getDate() + 6);
        return {
          key: `${weekStart.getFullYear()}-${weekStart.getMonth()}-${weekStart.getDate()}`,
          weekStart,
          weekEnd,
          temperature: round(item.temperature, 1),
          humidity: round(item.humidity, 1),
          soilMoisture: round(item.soilMoisture, 1),
          soilPh: round(item.soilPh, 2),
          lightIntensity: round(item.lightIntensity, 0),
          dataPoints: item.dataPoints || 0
        };
      });
      const byKey = new Map(weeks.map(w => [w.key, w]));
      // Iterate Sunday-Saturday weeks that intersect the month
      const firstMonthDay = new Date(baseDate.getFullYear(), baseDate.getMonth(), 1);
      const lastMonthDay = new Date(baseDate.getFullYear(), baseDate.getMonth() + 1, 0);
      // Start from the Sunday on/before the first of month
      const firstSunday = new Date(firstMonthDay);
      firstSunday.setDate(firstMonthDay.getDate() - firstMonthDay.getDay());
      for (let cur = new Date(firstSunday); cur <= lastMonthDay; cur.setDate(cur.getDate() + 7)) {
        const weekStart = new Date(cur);
        const weekEnd = new Date(cur);
        weekEnd.setDate(weekStart.getDate() + 6);
        const key = `${weekStart.getFullYear()}-${weekStart.getMonth()}-${weekStart.getDate()}`;
        const w = byKey.get(key);
        const label = `${weekStart.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })} - ${weekEnd.toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}`;
        formattedData.push({
          label,
          timestamp: weekStart.toISOString(),
          temperature: w ? w.temperature : null,
          humidity: w ? w.humidity : null,
          soilMoisture: w ? w.soilMoisture : null,
          soilPh: w ? w.soilPh : null,
          lightIntensity: w ? w.lightIntensity : null,
          dataPoints: w ? w.dataPoints : 0,
          weekStart: weekStart.toISOString(),
          weekEnd: weekEnd.toISOString()
        });
      }
    } else {
      // monthly: last `limit` months ending at baseDate month
      formattedData = aggregatedData.map((item: any) => {
        const date = new Date(item._id.year, item._id.month - 1, 1);
        return {
          label: date.toLocaleDateString('en-US', { month: 'long', year: 'numeric' }),
          timestamp: date.toISOString(),
          temperature: round(item.temperature, 1),
          humidity: round(item.humidity, 1),
          soilMoisture: round(item.soilMoisture, 1),
          soilPh: round(item.soilPh, 2),
          lightIntensity: round(item.lightIntensity, 0),
          dataPoints: item.dataPoints || 0,
          monthStart: date.toISOString(),
          monthEnd: new Date(item._id.year, item._id.month, 0).toISOString()
        };
      });
    }

    const response = {
      success: true,
      message: `Successfully fetched ${formattedData.length} ${period} temperature records`,
      data: formattedData,
      metadata: {
        period,
        limit,
        startDate: startDate.toISOString(),
        endDate: endDate.toISOString(),
        totalRecords: formattedData.length
      }
    };

    res.json(response);

  } catch (error: any) {
    console.error('[CONTROLLER] Error in getHistoricalData:', error);
    
    res.status(500).json({
      success: false,
      error: 'Internal server error while fetching historical data',
      message: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    });
  }
};