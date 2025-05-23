import pandas as pd
import numpy as np
from datetime import datetime, UTC
from pymongo import MongoClient
import os
from dotenv import load_dotenv

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
            'soil_ph': {'min': 5.5, 'max': 7.0, 'critical_min': 5.0, 'critical_max': 7.5},
            'light_intensity': {'min': 1000, 'max': 10000, 'critical_min': 500, 'critical_max': 12000}
        }

    def get_latest_readings(self):
        """Get latest sensor readings from MongoDB"""
        return list(self.db.sensor_readings.find().sort('timestamp', -1).limit(100))

    def analyze_readings(self, readings_df):
        """Analyze sensor readings and generate prescription"""
        if readings_df.empty:
            return None

        latest_reading = readings_df.iloc[0]
        measurements = latest_reading['measurements']
        
        # Initialize analysis results
        analysis = {
            'timestamp': datetime.now(UTC),
            'field_id': latest_reading['field_id'],
            'userId': str(latest_reading['userId']),
            'corn_growth_stage': latest_reading['corn_growth_stage'],
            'measurements': {
                'temperature': float(measurements['temperature']),
                'humidity': float(measurements['humidity']),
                'soil_moisture': float(measurements['soil_moisture']),
                'soil_ph': float(measurements['soil_ph']),
                'light_intensity': float(measurements['light_intensity'])
            },
            'parameter_status': {},
            'alerts': [],
            'recommendations': []
        }

        # Analyze each parameter
        importance_scores = {}
        for param, value in measurements.items():
            value = float(value)
            thresholds = self.thresholds[param]
            status = self.get_parameter_status(param, value, thresholds)
            
            if status['condition'] != 'normal':
                analysis['alerts'].append(f"{status['severity']}: {param} is {status['condition']} ({value})")
                analysis['recommendations'].append(status['recommendation'])
                
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
        
        return analysis

    def get_parameter_status(self, param, value, thresholds):
        """Determine parameter status and generate recommendations"""
        if value < thresholds['critical_min']:
            return {
                'condition': 'critically_low',
                'severity': 'CRITICAL',
                'recommendation': self.get_recommendation(param, 'increase', True)
            }
        elif value > thresholds['critical_max']:
            return {
                'condition': 'critically_high',
                'severity': 'CRITICAL',
                'recommendation': self.get_recommendation(param, 'decrease', True)
            }
        elif value < thresholds['min']:
            return {
                'condition': 'low',
                'severity': 'WARNING',
                'recommendation': self.get_recommendation(param, 'increase', False)
            }
        elif value > thresholds['max']:
            return {
                'condition': 'high',
                'severity': 'WARNING',
                'recommendation': self.get_recommendation(param, 'decrease', False)
            }
        else:
            return {
                'condition': 'normal',
                'severity': 'NORMAL',
                'recommendation': None
            }

    def get_recommendation(self, param, action, is_critical):
        """Generate specific recommendations based on parameter and condition"""
        recommendations = {
            'temperature': {
                'increase': 'Increase temperature by improving greenhouse heating or adding heat lamps',
                'decrease': 'Reduce temperature through ventilation or shade cloth'
            },
            'humidity': {
                'increase': 'Increase humidity through misting or reducing ventilation',
                'decrease': 'Reduce humidity by improving air circulation and ventilation'
            },
            'soil_moisture': {
                'increase': 'Increase irrigation frequency or duration',
                'decrease': 'Reduce irrigation and improve soil drainage'
            },
            'soil_ph': {
                'increase': 'Add lime to increase soil pH',
                'decrease': 'Add sulfur or acidifying amendments to decrease soil pH'
            },
            'light_intensity': {
                'increase': 'Increase light exposure or add supplemental lighting',
                'decrease': 'Provide shade or reduce light exposure during peak hours'
            }
        }
        
        base_recommendation = recommendations[param][action]
        if is_critical:
            return f"URGENT: {base_recommendation} immediately"
        return base_recommendation

    def save_analysis(self, analysis):
        """Save analysis results to corn_analyses collection"""
        if analysis:
            try:
                result = self.db.corn_analyses.insert_one(analysis)
                print(f"Analysis saved with ID: {result.inserted_id}")
                return result.inserted_id
            except Exception as e:
                print(f"Error saving analysis: {str(e)}")
                return None
        return None

def main():
    try:
        # Initialize analytics
        analytics = CornAnalytics()
        
        # Get sensor readings
        readings = analytics.get_latest_readings()
        if not readings:
            print("No sensor readings found")
            return
        
        # Convert to DataFrame for analysis
        df = pd.DataFrame(readings)
        
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

if __name__ == "__main__":
    main()
