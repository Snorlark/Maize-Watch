import pandas as pd
import numpy as np
from datetime import datetime, UTC
from pymongo import MongoClient
import os
from dotenv import load_dotenv
from prescriptive import generate_recommendations
from bson import ObjectId

# Load environment variables
load_dotenv()

class CornAnalytics:
    def __init__(self):
        self.client = MongoClient(os.getenv('MONGODB_IOT_URI'))
        self.db = self.client.get_default_database()
        
        # Define thresholds for corn growth parameters
        self.thresholds = {
            'temperature': {'min': 20, 'max': 30, 'critical_min': 15, 'critical_max': 35},
            'humidity': {'min': 40, 'max': 80, 'critical_min': 30, 'critical_max': 90},
            'soil_moisture': {'min': 30, 'max': 70, 'critical_min': 20, 'critical_max': 80},
            'soil_ph': {'min': 5.5, 'max': 7.5, 'critical_min': 5.0, 'critical_max': 8.0},
            'light_intensity': {'min': 5000, 'max': 12000, 'critical_min': 3000, 'critical_max': 15000}
        }

    def get_latest_readings(self):
        """Get latest sensor readings from MongoDB"""
        try:
            readings = list(self.db.sensor_readings.find().sort('timestamp', -1).limit(100))
            print(f"Found {len(readings)} sensor readings")
            if readings:
                print(f"Latest reading timestamp: {readings[0]['timestamp']}")
            return readings
        except Exception as e:
            print(f"Error fetching readings: {str(e)}")
            return []

    def analyze_readings(self, readings_df):
        """Analyze sensor readings and generate prescription"""
        if readings_df.empty:
            print("No readings to analyze")
            return None

        try:
            # Sort by timestamp to ensure we're using the most recent reading
            readings_df = readings_df.sort_values('timestamp', ascending=False)
            latest_reading = readings_df.iloc[0]
            measurements = latest_reading['measurements']
            
            print(f"Analyzing reading from {latest_reading['timestamp']}")
            print(f"Measurements: {measurements}")
            
            # Initialize analysis results with real-time data
            user_id = str(latest_reading.get('userId') or latest_reading.get('user_id') or '')
            if not user_id or user_id == 'nan':
                print('[WARNING] userId is missing or nan in latest reading!')
                user_id = None
            corn_growth_stage = latest_reading.get('corn_growth_stage')
            if pd.isna(corn_growth_stage):
                print('[WARNING] corn_growth_stage is missing or nan in latest reading!')
                corn_growth_stage = None
            analysis = {
                'timestamp': datetime.now(UTC),
                'field_id': latest_reading['field_id'],
                'userId': user_id,
                'corn_growth_stage': corn_growth_stage,
                'measurements': {
                    'temperature': float(measurements['temperature']),
                    'humidity': float(measurements['humidity']),
                    'soil_moisture': float(measurements['soil_moisture']),
                    'soil_ph': float(measurements['soil_ph']),
                    'light_intensity': float(measurements['light_intensity'])
                },
                'parameter_status': {},
                'alerts': [],
                'recommendations': [],
                'is_realtime': True  # Flag to indicate this is a real-time analysis
            }

            # Analyze each parameter
            importance_scores = {}
            for param, value in measurements.items():
                value = float(value)
                thresholds = self.thresholds[param]
                status = self.get_parameter_status(param, value, thresholds)
                
                if status['condition'] != 'normal':
                    analysis['alerts'].append(f"{status['severity']}: {param} is {status['condition']} ({value})")
                    
                    # Calculate importance score based on deviation
                    deviation = abs(value - (thresholds['max'] + thresholds['min'])/2) / ((thresholds['max'] - thresholds['min'])/2)
                    importance_scores[param] = deviation
                
                analysis['parameter_status'][param] = status

            # Calculate overall severity
            if any(status['severity'] == 'CRITICAL' for status in analysis['parameter_status'].values()):
                analysis['severity_level'] = 'CRITICAL'
            elif any(status['severity'] == 'WARNING' for status in analysis['parameter_status'].values()):
                analysis['severity_level'] = 'WARNING'
            else:
                analysis['severity_level'] = 'NORMAL'

            # Sort and normalize importance scores
            if importance_scores:
                total_score = sum(importance_scores.values())
                normalized_scores = {k: v/total_score for k, v in importance_scores.items()}
                analysis['importance_scores'] = normalized_scores

            # Generate recommendations using prescriptive analytics
            health_analysis = {
                'health_status': 'Healthy' if analysis['severity_level'] == 'NORMAL' else 'Unhealthy',
                'corn_stage': analysis['corn_growth_stage'],
                'issues': {},
                'stress_level': 'Severe' if analysis['severity_level'] == 'CRITICAL' else 'Moderate' if analysis['severity_level'] == 'WARNING' else 'Mild'
            }

            # Map parameter names to match prescriptive.py expectations
            param_mapping = {
                'temperature': 'temperature',
                'humidity': 'humidity',
                'soil_moisture': 'soil_moisture',
                'soil_ph': 'soil_ph',
                'light_intensity': 'light_intensity'
            }

            # Add issues with mapped parameter names
            for param, status in analysis['parameter_status'].items():
                if status['condition'] != 'normal':
                    mapped_param = param_mapping[param]
                    health_analysis['issues'][mapped_param] = {'condition': status['condition']}

            # Add important issues if available
            if importance_scores:
                health_analysis['important_issues'] = [
                    {
                        'parameter': param_mapping[param],
                        'condition': analysis['parameter_status'][param]['condition'],
                        'importance_score': score
                    }
                    for param, score in sorted(importance_scores.items(), key=lambda x: x[1], reverse=True)
                ]

            # Generate recommendations using prescriptive analytics
            analysis['recommendations'] = generate_recommendations(health_analysis)
            
            print(f"Analysis generated with {len(analysis['alerts'])} alerts and {len(analysis['recommendations'])} recommendations")
            return analysis
            
        except Exception as e:
            print(f"Error analyzing readings: {str(e)}")
            return None

    def get_parameter_status(self, param, value, thresholds):
        """Determine parameter status"""
        if value < thresholds['critical_min']:
            return {
                'condition': 'critically_low',
                'severity': 'CRITICAL'
            }
        elif value > thresholds['critical_max']:
            return {
                'condition': 'critically_high',
                'severity': 'CRITICAL'
            }
        elif value < thresholds['min']:
            return {
                'condition': 'low',
                'severity': 'WARNING'
            }
        elif value > thresholds['max']:
            return {
                'condition': 'high',
                'severity': 'WARNING'
            }
        else:
            return {
                'condition': 'normal',
                'severity': 'NORMAL'
            }

    def save_analysis(self, analysis):
        """Save analysis results to corn_analyses collection"""
        if analysis:
            try:
                # Debug: Print the MongoDB URI and collection name
                print(f"[DEBUG] Using MongoDB URI: {os.getenv('MONGODB_IOT_URI')}")
                print(f"[DEBUG] Saving to collection: {self.db.name}.corn_analyses")
                print(f"[DEBUG] Analysis document to save: {analysis}")
                # Convert ObjectId to string if present
                if 'userId' in analysis and isinstance(analysis['userId'], ObjectId):
                    analysis['userId'] = str(analysis['userId'])
                result = self.db.corn_analyses.insert_one(analysis)
                print(f"Analysis saved with ID: {result.inserted_id}")
                return result.inserted_id
            except Exception as e:
                print(f"Error saving analysis: {str(e)}")
                return None
        return None

def main():
    try:
        print("Starting analytics process...")
        
        # Initialize analytics
        analytics = CornAnalytics()
        
        # Get sensor readings
        readings = analytics.get_latest_readings()
        if not readings:
            print("No sensor readings found")
            return
        
        # Convert to DataFrame for analysis
        df = pd.DataFrame(readings)
        print(f"Processing {len(df)} readings")
        
        # Generate analysis and prescription
        analysis = analytics.analyze_readings(df)
        if not analysis:
            print("Could not generate analysis")
            return
        
        # Save analysis results
        analysis_id = analytics.save_analysis(analysis)
        if analysis_id:
            print(f"Analysis completed and saved successfully")
            print(f"Severity Level: {analysis['severity_level']}")
            print(f"Alerts: {len(analysis['alerts'])}")
            print(f"Recommendations: {len(analysis['recommendations'])}")
        else:
            print("Failed to save analysis results")
            
    except Exception as e:
        print(f"Error in main analytics process: {str(e)}")
        raise
    finally:
        # Close MongoDB connection
        if 'analytics' in locals():
            analytics.client.close()
            print("MongoDB connection closed")

if __name__ == "__main__":
    main()
