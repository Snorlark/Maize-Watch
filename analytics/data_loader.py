import pandas as pd
import pymongo
from pymongo import MongoClient
import json
import os
from dotenv import load_dotenv
import traceback

def load_live_data(data_source=None):
    """
    Load data either from a specified CSV file or directly from MongoDB
    """
    try:
        # Load environment variables
        load_dotenv()
        
        # If data source is a file, load from CSV
        if data_source and os.path.exists(data_source):
            print(f"Loading data from file: {data_source}")
            df = pd.read_csv(data_source)
            # Convert camelCase to snake_case column names if needed
            column_mapping = {
                'soilMoisture': 'soil_moisture',
                'cornStage': 'corn_stage',
                'fieldId': 'field_id'
            }
            
            # Rename columns that exist in the dataframe
            for old_col, new_col in column_mapping.items():
                if old_col in df.columns:
                    df.rename(columns={old_col: new_col}, inplace=True)
            
            return df
        
        # Otherwise, get from MongoDB
        print("Connecting to MongoDB to get live data...")
        mongo_uri = os.getenv("MONGODB_IOT_URI")
        
        if not mongo_uri:
            raise ValueError("MongoDB URI not found in environment variables")
        
        client = MongoClient(mongo_uri)
        db = client.iot_monitoring_db
        sensor_data = db.sensor_readings.find().sort("timestamp", -1).limit(10)
        
        # Convert MongoDB data to DataFrame
        data_list = []
        for doc in sensor_data:
            # Map MongoDB document fields to the expected DataFrame structure
            row = {
                "temperature": doc.get("temperature"),
                "humidity": doc.get("humidity"),
                "soil_moisture": doc.get("soilMoisture"),  # Note the camelCase to snake_case conversion
                "ph": doc.get("ph"),
                "light": doc.get("light"),
                "corn_stage": doc.get("cornStage", "Mid Vegetative (V5–VT)"),  # Default if not specified
                "field_id": doc.get("fieldId", "field_1")  # Field identifier
            }
            data_list.append(row)
            
        # Create DataFrame
        if not data_list:
            print("No sensor data found in MongoDB")
            return None
        
        df = pd.DataFrame(data_list)
        
        # Convert numeric columns to appropriate data types
        numeric_cols = ["temperature", "humidity", "soil_moisture", "ph", "light"]
        for col in numeric_cols:
            if col in df.columns:
                df[col] = pd.to_numeric(df[col], errors='coerce')
        
        print(f"Loaded {len(data_list)} records from MongoDB")
        return df
    
    
        
    except Exception as e:
        print(f"Error loading data: {str(e)}")
        print(traceback.format_exc())  # Print the full stack trace
        return None

def store_analysis_result(analysis, recommendations):
    """
    Store the analysis result and recommendations in MongoDB
    """
    try:
        # Log any missing or invalid values in sensor data
        for param in ["temperature", "humidity", "soil_moisture", "ph", "light"]:
            if pd.isna(analysis.get(param)):
                print(f"[Warning] Missing or invalid value for: {param}")
        
        
        
        # Load environment variables
        load_dotenv()
        
        mongo_uri = os.getenv("MONGODB_IOT_URI")
        
        if not mongo_uri:
            raise ValueError("MongoDB URI not found in environment variables")
        
        client = MongoClient(mongo_uri)
        db = client.iot_monitoring_db
        
        
        
        
        
        # Prepare analysis document
        analysis_doc = {
            "timestamp": pd.Timestamp.now(),
            "fieldId": analysis.get("field_id", "default"),
            "cornStage": analysis["corn_stage"],
            "healthStatus": analysis["health_status"],
            "parameters": {
                "temperature": None if pd.isna(analysis.get("temperature")) else analysis.get("temperature"),
                "humidity": None if pd.isna(analysis.get("humidity")) else analysis.get("humidity"),
                "soilMoisture": None if pd.isna(analysis.get("soil_moisture")) else analysis.get("soil_moisture"),
                "ph": None if pd.isna(analysis.get("ph")) else analysis.get("ph"),
                "light": None if pd.isna(analysis.get("light")) else analysis.get("light")
            },

            "recommendations": recommendations
        }
        
        # Add stress level if available
        if "stress_level" in analysis:
            analysis_doc["stressLevel"] = analysis["stress_level"]
        
        # Add issues if present
        if "issues" in analysis and analysis["issues"]:
            issues = []
            for param, details in analysis["issues"].items():
                issue = {
                    "parameter": param,
                    "condition": details["condition"],
                    "value": details["value"],
                    "optimalRange": {
                        "min": details["optimal_range"][0],
                        "max": details["optimal_range"][1]
                    },
                    "unit": details["unit"]
                }
                issues.append(issue)
            analysis_doc["issues"] = issues
        
        # Add predictions if available
        if "predictions" in analysis:
            predictions = {}
            
            if "stress_level" in analysis["predictions"]:
                predictions["stressLevel"] = {
                    "prediction": analysis["predictions"]["stress_level"]["prediction"],
                    "confidence": analysis["predictions"]["stress_level"]["confidence"]
                }
            
            if "parameter_importance" in analysis["predictions"]:
                param_importance = analysis["predictions"]["parameter_importance"]
                predictions["parameterImportance"] = {
                    "topParameters": param_importance.get("top_parameters", []),
                    "importanceScores": param_importance.get("importance_scores", {})
                }
            
            if predictions:
                analysis_doc["predictions"] = predictions
        
        # Add important issues if available
        if "important_issues" in analysis and analysis["important_issues"]:
            important_issues = []
            for issue in analysis["important_issues"]:
                important_issue = {
                    "parameter": issue["parameter"],
                    "condition": issue["condition"],
                    "value": issue["value"],
                    "optimalRange": {
                        "min": issue["optimal_range"][0],
                        "max": issue["optimal_range"][1]
                    },
                    "unit": issue["unit"],
                    "importanceScore": issue["importance_score"]
                }
                important_issues.append(important_issue)
            analysis_doc["importantIssues"] = important_issues
        
        # Insert into MongoDB
        result = db.corn_analyses.insert_one(analysis_doc)
        print(f"Analysis stored in MongoDB with ID: {result.inserted_id}")
        return result.inserted_id
        
    except Exception as e:
        print(f"Error storing analysis result: {str(e)}")
        print(traceback.format_exc())  # Print the full stack trace
        return None