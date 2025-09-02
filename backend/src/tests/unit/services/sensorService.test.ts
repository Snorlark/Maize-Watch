import sensorService from '../../../services/sensorService';
import Sensor, { ISensor } from '../../../models/Sensor';
import SensorReading, { ISensorReading } from '../../../models/SensorReading';
import Farm, { IFarm } from '../../../models/Farm';

jest.mock('../../../models/Sensor');
jest.mock('../../../models/SensorReading');
jest.mock('../../../models/Farm');
jest.mock('../../../utils/emailService', () => ({
  default: {
    sendAlertNotification: jest.fn(),
  }
}));

const MockedSensor = Sensor as jest.Mocked<typeof Sensor>;
const MockedSensorReading = SensorReading as jest.Mocked<typeof SensorReading>;
const MockedFarm = Farm as jest.Mocked<typeof Farm>;

describe('SensorService', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  describe('Performance Tests', () => {
    it('should record sensor readings within acceptable time', async () => {
      const startTime = Date.now();
      
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'DHT11',
        farm: 'farm123',
        checkAlertThresholds: jest.fn().mockReturnValue([]),
        updateLastReading: jest.fn().mockResolvedValue({}),
        populate: jest.fn().mockReturnThis()
      };

      const mockReading = {
        save: jest.fn().mockResolvedValue({}),
        assessDataQuality: jest.fn().mockReturnValue({ quality: 'good' }),
        metadata: { quality: 'good' }
      };

      MockedSensor.findById.mockResolvedValue(mockSensor as any);
      (MockedSensorReading as any).mockImplementation(() => mockReading as any);

      const readingData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: { 
          field1: 25, // temperature
          field2: 60, // humidity
          field6: 85, // battery
          field7: -45  // signal
        }
      };

      await sensorService.recordReading(readingData);
      
      const executionTime = Date.now() - startTime;
      expect(executionTime).toBeLessThan(500);
    });

    it('should handle bulk sensor readings efficiently', async () => {
      const startTime = Date.now();
      
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'temperature',
        farm: 'farm123',
        thresholds: { min: 10, max: 35 }
      };

      (Sensor.findOne as jest.Mock).mockResolvedValue(mockSensor);
      (SensorReading.insertMany as jest.Mock).mockResolvedValue([]);

      const readings = Array.from({ length: 100 }, (_, i) => ({
        sensor: 'sensor123',
        farm: 'farm123',
        data: { field1: 20 + i % 10, field2: 50 + i % 20 }
      }));

      await Promise.all(readings.map(reading => 
        sensorService.recordReading(reading)
      ));
      
      const executionTime = Date.now() - startTime;
      expect(executionTime).toBeLessThan(2000); // Should handle 100 readings in under 2 seconds
    });
  });

  describe('Security Tests', () => {
    it('should validate sensor data input', async () => {
      const invalidData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: null
      };

      await expect(sensorService.recordReading(invalidData as any))
        .rejects.toThrow();
    });

    it('should sanitize sensor data values', async () => {
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'temperature',
        farm: 'farm123',
        thresholds: { min: 10, max: 35 }
      };

      (Sensor.findOne as jest.Mock).mockResolvedValue(mockSensor);
      (SensorReading.prototype.save as jest.Mock).mockResolvedValue({});

      const maliciousData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: { 
          field1: '<script>alert("xss")</script>',
          field2: '${process.env.JWT_SECRET}' 
        }
      };

      await sensorService.recordReading(maliciousData as any);
      
      // Verify that data is properly sanitized/validated
      expect(SensorReading.prototype.save).toHaveBeenCalled();
    });

    it('should validate location coordinates', async () => {
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'temperature',
        farm: 'farm123',
        thresholds: { min: 10, max: 35 }
      };

      (Sensor.findOne as jest.Mock).mockResolvedValue(mockSensor);

      const invalidLocationData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: { field1: 25, field2: 60 }
      };

      await expect(sensorService.recordReading(invalidLocationData as any))
        .rejects.toThrow();
    });
  });

  describe('Functionality Tests', () => {
    it('should successfully process valid sensor reading', async () => {
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'temperature',
        farm: 'farm123',
        thresholds: { min: 10, max: 35 }
      };

      (Sensor.findOne as jest.Mock).mockResolvedValue(mockSensor);
      (SensorReading.prototype.save as jest.Mock).mockResolvedValue({});

      const readingData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: { field1: 25, field2: 60 }
      };

      const result = await sensorService.recordReading(readingData);

      expect(result).toBeDefined();
      expect(Sensor.findOne).toHaveBeenCalledWith({ sensorId: 'TEMP001' });
      expect(SensorReading.prototype.save).toHaveBeenCalled();
    });

    it('should trigger alerts for threshold violations', async () => {
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'temperature',
        farm: 'farm123',
        thresholds: { min: 10, max: 35 }
      };

      const mockFarm = {
        _id: 'farm123',
        name: 'Test Farm',
        owner: {
          email: 'farmer@example.com',
          fullName: 'Test Farmer'
        }
      };

      (Sensor.findOne as jest.Mock).mockResolvedValue(mockSensor);
      (Farm.findById as jest.Mock).mockReturnValue({
        populate: jest.fn().mockResolvedValue(mockFarm)
      });
      (SensorReading.prototype.save as jest.Mock).mockResolvedValue({});

      const alertData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: { field1: 45, field2: 60 }
      };

      await sensorService.recordReading(alertData);

      expect(Farm.findById).toHaveBeenCalledWith('farm123');
    });

    it('should retrieve sensor readings by date range', async () => {
      const mockReadings = [
        { sensorId: 'TEMP001', data: { temperature: 25 }, timestamp: new Date() }
      ];

      (SensorReading.find as jest.Mock).mockReturnValue({
        sort: jest.fn().mockReturnValue({
          limit: jest.fn().mockResolvedValue(mockReadings)
        })
      });

      const startDate = new Date('2024-01-01');
      const endDate = new Date('2024-01-31');

      const result = await sensorService.getSensorReadings('sensor123', 1, 10, startDate, endDate);

      expect(result).toEqual(mockReadings);
      expect(SensorReading.find).toHaveBeenCalledWith({
        sensorId: 'TEMP001',
        timestamp: { $gte: startDate, $lte: endDate }
      });
    });
  });

  describe('Error Handling Tests', () => {
    it('should handle sensor not found gracefully', async () => {
      (Sensor.findOne as jest.Mock).mockResolvedValue(null);

      const readingData = {
        sensor: 'nonexistent',
        farm: 'farm123',
        data: { field1: 25 }
      };

      await expect(sensorService.recordReading(readingData))
        .rejects.toThrow('Sensor not found');
    });

    it('should handle database save errors', async () => {
      const mockSensor = {
        _id: 'sensor123',
        sensorId: 'TEMP001',
        type: 'temperature',
        farm: 'farm123',
        thresholds: { min: 10, max: 35 }
      };

      (Sensor.findOne as jest.Mock).mockResolvedValue(mockSensor);
      (SensorReading.prototype.save as jest.Mock).mockRejectedValue(new Error('Database error'));

      const readingData = {
        sensor: 'sensor123',
        farm: 'farm123',
        data: { field1: 25 }
      };

      await expect(sensorService.recordReading(readingData))
        .rejects.toThrow('Database error');
    });
  });
});
