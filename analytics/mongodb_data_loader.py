import os
import pandas as pd
from pymongo import MongoClient
from dotenv import load_dotenv

def load_live_data_from_mongodb():
    """
    Load live data from MongoDB database instead of CSV.
    
    Returns:
        DataFrame containing the most recent corn monitoring data
    """
    try:
        # Load environment variables if using .env file
        load_dotenv()
        
        # Get MongoDB connection string
        mongodb_uri = os.getenv("MONGODB_IOT_URI", "mongodb+srv://larksigmuondbabao:aKO5hHmP0ZZYQPfp@maizewatch-db.snrxrjs.mongodb.net/iot_monitoring_db?retryWrites=true&w=majority&appName=maizewatch-db")
        
        # Connect to MongoDB
        client = MongoClient(mongodb_uri)
        
        # Access the database and collection
        db = client.get_database("iot_monitoring_db")
        collection = db.get_collection("sensor_readings")
        
        # Get the most recent 10 records
        cursor = collection.find().sort("timestamp", -1).limit(10)
        records = list(cursor)
        
        if not records:
            print("No records found in the database.")
            return None
            
        # Transform records by extracting from nested "measurements"
        transformed_data = []
        for record in records:
            try:
                measurements = record.get("measurements", {})
                row_data = {
                    "temperature": measurements.get("temperature", 0),
                    "humidity": measurements.get("humidity", 0),
                    "soil_moisture": measurements.get("soil_moisture", 0),
                    "ph": measurements.get("soil_ph", 7.0),
                    "light": measurements.get("light_intensity", 0),
                    "corn_stage": record.get("corn_stage", "Emergence (VE)")
                }
                transformed_data.append(row_data)
            except Exception as e:
                print(f"Error processing record: {e}")
                continue
        
        # Convert to DataFrame
        df = pd.DataFrame(transformed_data)
        
        # Close MongoDB connection
        client.close()
        
        return df
        
    except Exception as e:
        print(f"Error connecting to MongoDB: {e}")
        return None
