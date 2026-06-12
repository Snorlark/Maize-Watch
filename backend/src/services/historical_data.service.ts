import SensorReading from '../models/SensorReading';

type Period = 'daily' | 'weekly' | 'monthly';

interface HistoricalDataPoint {
  label: string;
  averages: {
    temperature: number;
    humidity: number;
    soilMoisture: number;
    ph: number;
  };
  count: number;
}

const historicalDataService = {
  async getHistoricalData(period: Period, limit: number): Promise<HistoricalDataPoint[]> {
    let groupId: any;
    let labelFormat: (doc: any) => string;

    switch (period) {
      case 'daily':
        groupId = { 
          year: { $year: '$timestamp' }, 
          month: { $month: '$timestamp' }, 
          day: { $dayOfMonth: '$timestamp' } 
        };
        labelFormat = (doc) => `${doc._id.month}/${doc._id.day}`;
        break;
      case 'weekly':
        groupId = { year: { $year: '$timestamp' }, week: { $week: '$timestamp' } };
        labelFormat = (doc) => `W${doc._id.week}`;
        break;
      case 'monthly':
        groupId = { year: { $year: '$timestamp' }, month: { $month: '$timestamp' } };
        labelFormat = (doc) => `${doc._id.month}/${doc._id.year}`;
        break;
    }

    const results = await SensorReading.aggregate([
      { 
        $group: {
          _id: groupId,
          avgTemperature: { $avg: '$data.temperature' },
          avgHumidity: { $avg: '$data.humidity' },
          avgSoilMoisture: { $avg: '$data.soilMoisture' },
          avgPh: { $avg: '$data.pH' },
          count: { $sum: 1 }
        }
      },
      { $sort: { '_id.year': -1, '_id.month': -1, '_id.day': -1 } },
      { $limit: limit }
    ]);

    return results.map((doc) => ({
      label: labelFormat(doc),
      averages: {
        temperature: doc.avgTemperature ?? 0,
        humidity: doc.avgHumidity ?? 0,
        soilMoisture: doc.avgSoilMoisture ?? 0,
        ph: doc.avgPh ?? 0
      },
      count: doc.count
    }));
  }
};

export default historicalDataService;
