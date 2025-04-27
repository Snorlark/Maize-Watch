import paho.mqtt.client as mqtt
import json
import time
import random
import datetime

# MQTT Configuration
MQTT_BROKER = "your-mqtt-broker-address"  # Change this
MQTT_PORT = 1883
MQTT_TOPIC = "maize/sensors"
MQTT_USERNAME = None  # Set if your broker requires authentication
MQTT_PASSWORD = None  # Set if your broker requires authentication

# Number of simulated devices
DEVICE_COUNT = 3
# Seconds between data transmission
INTERVAL = 60

def generate_sensor_data(device_id):
    """Generate a simple set of sensor readings for maize monitoring"""
    current_time = datetime.datetime.now()
    
    # Generate basic readings - simple random values within realistic ranges
    data = {
        "device_id": device_id,
        "timestamp": current_time.isoformat(),
        "location": {
            "latitude": round(-1.286389 + random.uniform(-0.05, 0.05), 6),
            "longitude": round(36.817223 + random.uniform(-0.05, 0.05), 6)
        },
        "air_temperature": round(random.uniform(20, 35), 1),
        "soil_temperature": round(random.uniform(18, 30), 1),
        "humidity": round(random.uniform(40, 90), 1),
        "soil_moisture": round(random.uniform(30, 70), 1),
        "light_intensity": round(random.uniform(100, 900), 1),
        "soil_ph": round(random.uniform(5.5, 7.5), 2),
        "rainfall": round(random.uniform(0, 5) if random.random() < 0.1 else 0, 1),
    }
    
    # Add a simple health index based on the readings
    optimal_temp = data["air_temperature"] >= 22 and data["air_temperature"] <= 30
    optimal_moisture = data["soil_moisture"] >= 40 and data["soil_moisture"] <= 60
    optimal_ph = data["soil_ph"] >= 5.8 and data["soil_ph"] <= 7.0
    
    # Calculate health index (0-100)
    health_score = 100
    if not optimal_temp:
        health_score -= 20
    if not optimal_moisture:
        health_score -= 25
    if not optimal_ph:
        health_score -= 15
    
    # Add some randomness
    health_score += random.uniform(-10, 10)
    data["health_index"] = max(0, min(100, round(health_score)))
    
    # Add an alert if health is poor
    data["alerts"] = []
    if data["health_index"] < 50:
        data["alerts"].append({
            "type": "warning",
            "message": "Plant health below 50%"
        })
    if data["soil_moisture"] < 35:
        data["alerts"].append({
            "type": "critical",
            "message": "Low soil moisture detected"
        })
    
    return data

def on_connect(client, userdata, flags, rc):
    """Callback when connected to MQTT broker"""
    if rc == 0:
        print(f"Connected to MQTT broker at {MQTT_BROKER}")
    else:
        print(f"Failed to connect to MQTT broker, return code: {rc}")

def main():
    # Set up MQTT client
    client = mqtt.Client()
    client.on_connect = on_connect
    
    # Set username and password if provided
    if MQTT_USERNAME and MQTT_PASSWORD:
        client.username_pw_set(MQTT_USERNAME, MQTT_PASSWORD)
    
    # Connect to broker
    try:
        print(f"Connecting to MQTT broker at {MQTT_BROKER}:{MQTT_PORT}...")
        client.connect(MQTT_BROKER, MQTT_PORT)
        client.loop_start()
        
        # Create device IDs
        device_ids = [f"maize_sensor_{i+1:03d}" for i in range(DEVICE_COUNT)]
        
        print(f"Starting data simulation for {DEVICE_COUNT} devices...")
        print(f"Press Ctrl+C to stop the simulation")
        
        while True:
            for device_id in device_ids:
                # Generate data
                sensor_data = generate_sensor_data(device_id)
                
                # Publish to device-specific topic
                topic = f"{MQTT_TOPIC}/{device_id}"
                client.publish(topic, json.dumps(sensor_data))
                print(f"Published data for {device_id}")
            
            time.sleep(INTERVAL)
            
    except KeyboardInterrupt:
        print("Simulation stopped by user")
    except Exception as e:
        print(f"Error: {e}")
    finally:
        # Clean up
        client.loop_stop()
        client.disconnect()
        print("Disconnected from MQTT broker")

if __name__ == "__main__":
    main()