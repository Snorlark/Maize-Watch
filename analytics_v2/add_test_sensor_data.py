#!/usr/bin/env python3
"""
Add test sensor data to MongoDB for testing analytics
"""
import os
import sys
from datetime import datetime, timedelta
from bson import ObjectId

# Add the src directory to the path
sys.path.append(os.path.join(os.path.dirname(__file__), 'src'))

from database.mongodb_setup import db_manager

def add_test_sensor_data():
    """Add realistic test sensor data to MongoDB"""
    
    # Connect to database
    db_manager.connect()
    
    # Get collections
    sensor_readings_collection = db_manager.get_collection("sensor_readings")
    farms_collection = db_manager.get_collection("farms")
    
    # Get a farm that has fields
    farm = farms_collection.find_one({"fields": {"$exists": True, "$not": {"$size": 0}}})
    if not farm:
        print("❌ No farms with fields found in database")
        return
    
    farm_id = farm['_id']
    print(f"🏡 Using farm: {farm.get('farmName', 'Unknown')} (ID: {farm_id})")
    
    # Get fields from the farm
    fields = farm.get('fields', [])
    if not fields:
        print("❌ No fields found in farm")
        return
    
    field = fields[0]
    field_id = field.get('field_id', 'field_123')
    print(f"🌾 Using field: {field.get('fieldName', 'Unknown')} (ID: {field_id})")
    
    # Generate realistic sensor data for the last 7 days
    base_time = datetime.now()
    data_points = []
    
    for day in range(7):
        for hour in range(24):
            timestamp = base_time - timedelta(days=day, hours=hour)
            
            # Generate realistic sensor values based on time of day
            hour_of_day = timestamp.hour
            
            # Temperature: 20-35°C, cooler at night
            if 6 <= hour_of_day <= 18:
                temperature = 25 + (hour_of_day - 12) * 0.5 + (day * 0.1)
            else:
                temperature = 22 + (day * 0.1)
            
            # Humidity: 40-80%, higher at night
            if 6 <= hour_of_day <= 18:
                humidity = 50 + (hour_of_day - 12) * 1.5 + (day * 0.2)
            else:
                humidity = 70 + (day * 0.2)
            
            # Soil moisture: 30-80%, varies by day
            soil_moisture = 45 + (day * 2) + (hour_of_day * 0.5)
            
            # Soil pH: 6.0-7.5, stable
            soil_ph = 6.5 + (day * 0.05)
            
            # Light intensity: 0-1000 lux, 0 at night
            if 6 <= hour_of_day <= 18:
                light_intensity = max(0, 200 + (hour_of_day - 6) * 50 - (hour_of_day - 12) * 25)
            else:
                light_intensity = 0
            
            # Create sensor reading
            sensor_reading = {
                "timestamp": timestamp,
                "farm": farm_id,
                "field_id": field_id,
                "data": {
                    "temperature": round(temperature, 1),
                    "humidity": round(humidity, 1),
                    "soilMoisture": round(soil_moisture, 1),
                    "soilPh": round(soil_ph, 1),
                    "lightIntensity": round(light_intensity, 1)
                },
                "metadata": {
                    "source": "test_data",
                    "quality": "good",
                    "processed": False,
                    "anomaly": False,
                    "calibrated": True
                }
            }
            
            data_points.append(sensor_reading)
    
    # Insert all data points
    if data_points:
        result = sensor_readings_collection.insert_many(data_points)
        print(f"✅ Inserted {len(result.inserted_ids)} sensor readings")
        
        # Show sample data
        print("\n📊 Sample sensor data:")
        sample = sensor_readings_collection.find_one({"farm": farm_id})
        if sample:
            print(f"  Temperature: {sample['data']['temperature']}°C")
            print(f"  Humidity: {sample['data']['humidity']}%")
            print(f"  Soil Moisture: {sample['data']['soilMoisture']}%")
            print(f"  Soil pH: {sample['data']['soilPh']}")
            print(f"  Light Intensity: {sample['data']['lightIntensity']} lux")
            print(f"  Timestamp: {sample['timestamp']}")
    
    print("\n🎯 Test sensor data added successfully!")
    print("   You can now test the analytics system with real sensor data.")

if __name__ == "__main__":
    add_test_sensor_data()