import { Request, Response, NextFunction } from 'express';
import mongoose from 'mongoose';
import SensorReading from '../models/SensorReading';
import { getThingSpeakService } from '../config/thingspeak';

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
      // Monthly: show entire year (Jan 1 - Dec 31) of baseDate's year
      startDate = new Date(d.getFullYear(), 0, 1); // January 1st
      startDate.setHours(0, 0, 0, 0);
      endDate = new Date(d.getFullYear(), 11, 31); // December 31st
      endDate.setHours(23, 59, 59, 999);
    }



    // Step 4: Execute aggregation pipeline by querying ThingSpeak
    const thingSpeakService = getThingSpeakService();
    // Fetch up to 8000 feeds in the date range
    const feeds = await thingSpeakService.readHistoricalData(
      8000,
      startDate.toISOString(),
      endDate.toISOString()
    );

    // Grouping container
    const groups = new Map<string, any>();

    // Helper function to calculate Sunday-based week of the year (0-53)
    const getSundayBasedWeek = (date: Date): number => {
      const jan1 = new Date(Date.UTC(date.getUTCFullYear(), 0, 1));
      const days = Math.floor((date.getTime() - jan1.getTime()) / (24 * 60 * 60 * 1000));
      return Math.floor((days + jan1.getUTCDay()) / 7);
    };

    // Iterate over feeds and group them
    for (const feed of feeds) {
      if (!feed.created_at) continue;
      
      const timestamp = new Date(feed.created_at);
      if (isNaN(timestamp.getTime())) continue;

      // Ensure timestamp is within the range
      if (timestamp < startDate || timestamp > endDate) continue;

      const year = timestamp.getUTCFullYear();
      const month = timestamp.getUTCMonth() + 1; // 1-12
      const day = timestamp.getUTCDate(); // 1-31
      
      let groupKey = '';
      let groupKeyObj: any = {};

      if (period === 'daily') {
        groupKey = `${year}-${month}-${day}`;
        groupKeyObj = { year, month, day };
      } else if (period === 'weekly') {
        const week = getSundayBasedWeek(timestamp);
        groupKey = `${year}-${week}`;
        groupKeyObj = { year, week };
      } else {
        groupKey = `${year}-${month}`;
        groupKeyObj = { year, month };
      }

      let group = groups.get(groupKey);
      if (!group) {
        group = {
          _id: groupKeyObj,
          sumTemp: 0, countTemp: 0,
          sumHum: 0, countHum: 0,
          sumMoist: 0, countMoist: 0,
          sumPh: 0, countPh: 0,
          sumLight: 0, countLight: 0,
          dataPoints: 0,
          minTemp: Infinity,
          maxTemp: -Infinity,
          firstTimestamp: feed.created_at,
          lastTimestamp: feed.created_at
        };
        groups.set(groupKey, group);
      }

      // Map ThingSpeak fields:
      // field1: Temperature, field2: Humidity, field3: Soil Moisture, field4: Soil pH, field5: Light Intensity
      const temp = feed.field1;
      const humidity = feed.field2;
      const soilMoisture = feed.field3;
      const soilPh = feed.field4;
      const lightIntensity = feed.field5;

      if (temp !== undefined && temp !== null && !isNaN(temp)) {
        group.sumTemp += temp;
        group.countTemp++;
        group.minTemp = Math.min(group.minTemp, temp);
        group.maxTemp = Math.max(group.maxTemp, temp);
      }
      if (humidity !== undefined && humidity !== null && !isNaN(humidity)) {
        group.sumHum += humidity;
        group.countHum++;
      }
      if (soilMoisture !== undefined && soilMoisture !== null && !isNaN(soilMoisture)) {
        group.sumMoist += soilMoisture;
        group.countMoist++;
      }
      if (soilPh !== undefined && soilPh !== null && !isNaN(soilPh)) {
        group.sumPh += soilPh;
        group.countPh++;
      }
      if (lightIntensity !== undefined && lightIntensity !== null && !isNaN(lightIntensity)) {
        group.sumLight += lightIntensity;
        group.countLight++;
      }

      group.dataPoints++;
      
      const feedTime = timestamp.getTime();
      if (feedTime < new Date(group.firstTimestamp).getTime()) {
        group.firstTimestamp = feed.created_at;
      }
      if (feedTime > new Date(group.lastTimestamp).getTime()) {
        group.lastTimestamp = feed.created_at;
      }
    }

    // Convert groups to array and compute averages
    const aggregatedData = Array.from(groups.values()).map(g => ({
      _id: g._id,
      temperature: g.countTemp > 0 ? g.sumTemp / g.countTemp : null,
      humidity: g.countHum > 0 ? g.sumHum / g.countHum : null,
      soilMoisture: g.countMoist > 0 ? g.sumMoist / g.countMoist : null,
      soilPh: g.countPh > 0 ? g.sumPh / g.countPh : null,
      lightIntensity: g.countLight > 0 ? g.sumLight / g.countLight : null,
      dataPoints: g.dataPoints,
      minTemp: g.minTemp === Infinity ? null : g.minTemp,
      maxTemp: g.maxTemp === -Infinity ? null : g.maxTemp,
      firstTimestamp: g.firstTimestamp,
      lastTimestamp: g.lastTimestamp
    }));

    // Sort aggregated data chronologically
    aggregatedData.sort((a: any, b: any) => {
      if (period === 'daily') {
        return a._id.year !== b._id.year ? a._id.year - b._id.year :
               a._id.month !== b._id.month ? a._id.month - b._id.month :
               a._id.day - b._id.day;
      } else if (period === 'weekly') {
        return a._id.year !== b._id.year ? a._id.year - b._id.year :
               a._id.week - b._id.week;
      } else {
        return a._id.year !== b._id.year ? a._id.year - b._id.year :
               a._id.month - b._id.month;
      }
    });


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
      
      // Add hardcoded data for October 5 and 6, 2025 if not already present
      const oct5 = new Date(2025, 9, 5);
      const oct6 = new Date(2025, 9, 6);
      const oct5Key = oct5.toDateString();
      const oct6Key = oct6.toDateString();
      
      if (!byDate.has(oct5Key) && d.getFullYear() === 2025) {
        byDate.set(oct5Key, {
          label: oct5.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
          timestamp: oct5.toISOString(),
          temperature: 27.9,
          humidity: 98,
          soilMoisture: 46,
          soilPh: 7,
          lightIntensity: 25960,
          dataPoints: 1,
          date: oct5.toISOString()
        });
      }
      
      if (!byDate.has(oct6Key) && d.getFullYear() === 2025) {
        byDate.set(oct6Key, {
          label: oct6.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
          timestamp: oct6.toISOString(),
          temperature: 27.9,
          humidity: 98,
          soilMoisture: 46,
          soilPh: 7,
          lightIntensity: 25960,
          dataPoints: 1,
          date: oct6.toISOString()
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
          // Hardcoded data for October 5 and 6, 2025 (as requested by user)
          const isOct5 = cur.getFullYear() === 2025 && cur.getMonth() === 9 && cur.getDate() === 5;
          const isOct6 = cur.getFullYear() === 2025 && cur.getMonth() === 9 && cur.getDate() === 6;
          
          if (isOct5 || isOct6) {
            formattedData.push({
              label: cur.toLocaleDateString('en-US', { month: 'short', day: 'numeric' }),
              timestamp: cur.toISOString(),
              temperature: 27.9,
              humidity: 98,
              soilMoisture: 46,
              soilPh: 7,
              lightIntensity: 25960,
              dataPoints: 1,
              date: cur.toISOString()
            });
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
      // monthly: show all 12 months of the year (Jan - Dec)
      const monthNames = [
        "January", "February", "March", "April", "May", "June",
        "July", "August", "September", "October", "November", "December"
      ];
      const byMonth = new Map<number, any>();
      for (const item of aggregatedData) {
        byMonth.set(item._id.month, item);
      }
      
      // Generate all 12 months of the year
      formattedData = monthNames.map((monthName, index) => {
        const monthNum = index + 1;
        const date = new Date(d.getFullYear(), index, 1);
        const item = byMonth.get(monthNum);
        return {
          label: monthName,
          timestamp: date.toISOString(),
          temperature: item ? round(item.temperature, 1) : null,
          humidity: item ? round(item.humidity, 1) : null,
          soilMoisture: item ? round(item.soilMoisture, 1) : null,
          soilPh: item ? round(item.soilPh, 2) : null,
          lightIntensity: item ? round(item.lightIntensity, 0) : null,
          dataPoints: item ? item.dataPoints : 0,
          monthStart: date.toISOString(),
          monthEnd: new Date(d.getFullYear(), index + 1, 0).toISOString()
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