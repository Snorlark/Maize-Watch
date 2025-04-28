import mqtt from 'mqtt';
import DummyData from '../models/dummy_data.model.js';

class MqttService {
  constructor(brokerUrl) {
    this.client = mqtt.connect(brokerUrl);
    this.setupEventHandlers();
  }

  setupEventHandlers() {
    this.client.on('connect', () => {
      console.log('Connected to MQTT broker');
      this.client.subscribe('maizewatch/sensors/#', (err) => {
        if (err) {
          console.error('Error subscribing to topic:', err);
        } else {
          console.log('Subscribed to maizewatch/sensors/#');
        }
      });
    });

    this.client.on('message', async (topic, message) => {
      try {
        console.log(`Received message on ${topic}`);
        const data = JSON.parse(message.toString());
        
        // Store in MongoDB (you could add additional processing here)
        const dummyData = new DummyData({
          timestamp: new Date(data.timestamp),
          field_id: data.field_id,
          measurements: data.measurements
        });
        
        await dummyData.save();
        console.log('Data saved to MongoDB');
      } catch (error) {
        console.error('Error processing MQTT message:', error);
      }
    });

    this.client.on('error', (err) => {
      console.error('MQTT client error:', err);
    });
  }
}

// Simply export the class directly
export default MqttService;