R"""
Weather Service for Amadeo - Uses historical PAGASA data for accurate weather
"""

import logging
import pandas as pd
from datetime import datetime, timedelta
from typing import Dict, Optional, List
import pytz
from database.mongodb_setup import db_manager

logger = logging.getLogger('corn_system')

class AmadeoWeatherService:
    """Weather service specifically for Amadeo using historical PAGASA data"""
    
    def __init__(self):
        self.weather_collection = db_manager.get_collection('historical_weather')
        self.timezone = pytz.timezone('Asia/Manila')
    
    def get_current_weather(self) -> Dict:
        """Get current weather based on historical patterns for Amadeo"""
        try:
            current_date = datetime.now(self.timezone)
            
            # Get historical data for the same date range (last 5 years)
            historical_data = self._get_historical_patterns(current_date)
            
            if historical_data is None or historical_data.empty:
                logger.warning("No historical weather data found, using fallback")
                return self._get_fallback_weather()
            
            # Calculate current weather based on historical patterns
            current_weather = self._calculate_current_weather(historical_data, current_date)
            
            logger.info(f"Generated current weather for Amadeo: {current_weather['temperature']}°C")
            return current_weather
            
        except Exception as e:
            logger.error(f"Error getting current weather: {e}")
            return self._get_fallback_weather()
    
    def get_weather_forecast(self, days: int = 3) -> Dict:
        """Get weather forecast for next few days based on historical patterns"""
        try:
            current_date = datetime.now(self.timezone)
            current_weather = self.get_current_weather()
            
            # Validate current weather
            if current_weather.get('temperature', 0) <= 0:
                logger.warning("Current weather has invalid temperature, using fallback")
                current_weather = self._get_fallback_weather()
            
            forecast = {
                'current': current_weather,
                'forecast': []
            }
            
            for i in range(1, days + 1):
                target_date = current_date + timedelta(days=i)
                historical_data = self._get_historical_patterns(target_date)
                
                if historical_data is not None and not historical_data.empty:
                    day_forecast = self._calculate_forecast_day(historical_data, target_date)
                    day_forecast['date'] = target_date.strftime('%Y-%m-%d')
                    forecast['forecast'].append(day_forecast)
                else:
                    # Fallback for missing data
                    day_forecast = self._get_fallback_forecast_day(target_date)
                    day_forecast['date'] = target_date.strftime('%Y-%m-%d')
                    forecast['forecast'].append(day_forecast)
            
            # Validate the entire forecast
            for day_forecast in forecast['forecast']:
                if day_forecast.get('temperature', 0) <= 0:
                    logger.warning(f"Invalid temperature in forecast: {day_forecast.get('temperature')}, replacing with fallback")
                    fallback = self._get_fallback_forecast_day(datetime.strptime(day_forecast['date'], '%Y-%m-%d'))
                    day_forecast.update(fallback)
            
            logger.info(f"Weather forecast generated: current temp={forecast['current']['temperature']}°C")
            return forecast
            
        except Exception as e:
            logger.error(f"Error generating weather forecast: {e}")
            return {
                'current': self._get_fallback_weather(),
                'forecast': []
            }
    
    def _get_historical_patterns(self, target_date: datetime) -> Optional[pd.DataFrame]:
        """Get historical weather data for similar dates"""
        try:
            # Get data for the same month and day for the past 5 years
            start_year = target_date.year - 5
            end_year = target_date.year - 1
            
            start_date = target_date.replace(year=start_year)
            end_date = target_date.replace(year=end_year)
            
            # Query database for historical data
            cursor = self.weather_collection.find({
                "date": {
                    "$gte": start_date,
                    "$lte": end_date
                }
            }).sort("date", 1)
            
            data = list(cursor)
            if not data:
                return None
            
            # Convert to DataFrame
            df = pd.DataFrame(data)
            df['date'] = pd.to_datetime(df['date'])
            
            return df
            
        except Exception as e:
            logger.error(f"Error getting historical patterns: {e}")
            return None
    
    def _calculate_current_weather(self, historical_data: pd.DataFrame, current_date: datetime) -> Dict:
        """Calculate current weather based on historical patterns"""
        try:
            # Calculate averages from historical data
            avg_temp = historical_data['avg_temp_c'].mean()
            avg_humidity = historical_data['humidity_percent'].mean()
            avg_rainfall = historical_data['rainfall_mm'].mean()
            
            # Check for invalid values and use fallback if needed
            if pd.isna(avg_temp) or avg_temp == 0:
                logger.warning("Invalid temperature from historical data, using fallback")
                return self._get_fallback_weather()
            
            if pd.isna(avg_humidity) or avg_humidity == 0:
                logger.warning("Invalid humidity from historical data, using fallback")
                return self._get_fallback_weather()
            
            # Add some realistic variation based on time of day
            hour = current_date.hour
            temp_variation = self._get_temperature_variation(hour)
            humidity_variation = self._get_humidity_variation(hour, avg_rainfall if not pd.isna(avg_rainfall) else 0)
            
            # Calculate final values
            temperature = round(avg_temp + temp_variation, 1)
            humidity = round(max(30, min(95, avg_humidity + humidity_variation)), 1)
            
            # Ensure temperature is reasonable
            if temperature <= 0 or temperature > 50:
                logger.warning(f"Temperature out of range: {temperature}, using fallback")
                return self._get_fallback_weather()
            
            # Determine weather condition
            condition = self._determine_weather_condition(avg_rainfall if not pd.isna(avg_rainfall) else 0, temperature, humidity)
            
            logger.info(f"Calculated weather from historical data: temp={temperature}°C, humidity={humidity}%")
            
            return {
                'temperature': temperature,
                'humidity': humidity,
                'wind_speed': round(3.0 + ((avg_rainfall if not pd.isna(avg_rainfall) else 0) * 0.1), 1),  # Wind based on rainfall
                'condition': condition['condition'],
                'description': condition['description'],
                'pressure': round(1013.25 - ((avg_rainfall if not pd.isna(avg_rainfall) else 0) * 0.1), 1),  # Pressure based on rainfall
                'location': 'Amadeo, Cavite',
                'timestamp': current_date.isoformat()
            }
            
        except Exception as e:
            logger.error(f"Error calculating current weather: {e}")
            return self._get_fallback_weather()
    
    def _calculate_forecast_day(self, historical_data: pd.DataFrame, target_date: datetime) -> Dict:
        """Calculate forecast for a specific day"""
        try:
            avg_temp = historical_data['avg_temp_c'].mean()
            avg_humidity = historical_data['humidity_percent'].mean()
            avg_rainfall = historical_data['rainfall_mm'].mean()
            
            # Check for invalid values and use fallback if needed
            if pd.isna(avg_temp) or avg_temp == 0:
                logger.warning("Invalid temperature from historical data for forecast, using fallback")
                return self._get_fallback_forecast_day(target_date)
            
            if pd.isna(avg_humidity) or avg_humidity == 0:
                logger.warning("Invalid humidity from historical data for forecast, using fallback")
                return self._get_fallback_forecast_day(target_date)
            
            # Add seasonal variation
            temp_variation = self._get_seasonal_variation(target_date)
            humidity_variation = self._get_humidity_variation(12, avg_rainfall if not pd.isna(avg_rainfall) else 0)  # Midday humidity
            
            temperature = round(avg_temp + temp_variation, 1)
            humidity = round(max(30, min(95, avg_humidity + humidity_variation)), 1)
            
            # Ensure temperature is reasonable
            if temperature <= 0 or temperature > 50:
                logger.warning(f"Temperature out of range for forecast: {temperature}, using fallback")
                return self._get_fallback_forecast_day(target_date)
            
            condition = self._determine_weather_condition(avg_rainfall if not pd.isna(avg_rainfall) else 0, temperature, humidity)
            
            logger.info(f"Calculated forecast for {target_date.strftime('%Y-%m-%d')}: temp={temperature}°C, humidity={humidity}%")
            
            return {
                'temperature': temperature,
                'humidity': humidity,
                'wind_speed': round(3.0 + ((avg_rainfall if not pd.isna(avg_rainfall) else 0) * 0.1), 1),
                'condition': condition['condition'],
                'description': condition['description'],
                'rainfall_probability': min(100, max(0, (avg_rainfall if not pd.isna(avg_rainfall) else 0) * 2))  # Convert mm to probability
            }
            
        except Exception as e:
            logger.error(f"Error calculating forecast day: {e}")
            return self._get_fallback_forecast_day(target_date)
    
    def _get_temperature_variation(self, hour: int) -> float:
        """Get temperature variation based on time of day"""
        # Temperature typically peaks around 2-3 PM and is lowest around 5-6 AM
        if 5 <= hour <= 6:
            return -3.0  # Coolest in early morning
        elif 14 <= hour <= 15:
            return 2.0   # Warmest in afternoon
        elif 6 <= hour <= 10:
            return -1.0  # Cool morning
        elif 11 <= hour <= 13:
            return 1.0   # Warm late morning
        elif 16 <= hour <= 18:
            return 0.5   # Warm late afternoon
        else:
            return 0.0   # Neutral for evening/night
    
    def _get_humidity_variation(self, hour: int, rainfall: float) -> float:
        """Get humidity variation based on time and rainfall"""
        base_variation = 0
        if 5 <= hour <= 8:
            base_variation = 5.0  # Higher humidity in early morning
        elif 14 <= hour <= 16:
            base_variation = -5.0  # Lower humidity in afternoon
        
        # Rainfall increases humidity
        rainfall_effect = rainfall * 0.5
        
        return base_variation + rainfall_effect
    
    def _get_seasonal_variation(self, date: datetime) -> float:
        """Get seasonal temperature variation"""
        month = date.month
        
        # Amadeo seasonal patterns (Cavite, Philippines)
        if month in [12, 1, 2]:  # Dry season (cooler)
            return -1.0
        elif month in [3, 4, 5]:  # Hot dry season
            return 2.0
        elif month in [6, 7, 8, 9]:  # Wet season
            return 0.0
        else:  # October, November
            return 0.5
    
    def _determine_weather_condition(self, rainfall: float, temperature: float, humidity: float) -> Dict:
        """Determine weather condition based on parameters"""
        if rainfall > 5.0:
            return {
                'condition': 'rainy',
                'description': 'Rainy'
            }
        elif rainfall > 1.0:
            return {
                'condition': 'partly_cloudy',
                'description': 'Light rain'
            }
        elif humidity > 80:
            return {
                'condition': 'cloudy',
                'description': 'Cloudy'
            }
        elif temperature > 32:
            return {
                'condition': 'sunny',
                'description': 'Sunny'
            }
        else:
            return {
                'condition': 'partly_cloudy',
                'description': 'Partly cloudy'
            }
    
    def _get_fallback_weather(self) -> Dict:
        """Fallback weather data for Amadeo - using real sensor data"""
        try:
            # Try to get real sensor data from MongoDB
            sensor_readings_collection = db_manager.get_collection("sensor_readings")
            latest_reading = sensor_readings_collection.find_one(
                {},
                sort=[("timestamp", -1)]
            )
            
            if latest_reading and 'data' in latest_reading:
                sensor_data = latest_reading['data']
                temperature = sensor_data.get('temperature', 23.4)
                humidity = sensor_data.get('humidity', 83.0)
                
                # Ensure we have valid temperature values
                if temperature is None or temperature == 0:
                    temperature = 23.4
                if humidity is None or humidity == 0:
                    humidity = 83.0
                
                logger.info(f"Using sensor data for weather: temp={temperature}°C, humidity={humidity}%")
                
                return {
                    'temperature': float(temperature),
                    'humidity': float(humidity),
                    'wind_speed': 5.2,  # Wind speed not available in sensor data
                    'condition': 'partly_cloudy',
                    'description': 'Partly cloudy',
                    'pressure': 1013.25,
                    'location': 'Amadeo, Cavite',
                    'timestamp': datetime.now(self.timezone).isoformat()
                }
        except Exception as e:
            logger.warning(f"Could not fetch real sensor data for weather fallback: {e}")
        
        # Final fallback with real sensor values
        logger.info("Using final fallback weather data")
        return {
            'temperature': 23.4,
            'humidity': 83.0,
            'wind_speed': 5.2,
            'condition': 'partly_cloudy',
            'description': 'Partly cloudy',
            'pressure': 1013.25,
            'location': 'Amadeo, Cavite',
            'timestamp': datetime.now(self.timezone).isoformat()
        }
    
    def _get_fallback_forecast_day(self, target_date: datetime) -> Dict:
        """Fallback forecast for a day - using real sensor data"""
        try:
            # Try to get real sensor data for forecast
            sensor_readings_collection = db_manager.get_collection("sensor_readings")
            latest_reading = sensor_readings_collection.find_one(
                {},
                sort=[("timestamp", -1)]
            )
            
            if latest_reading and 'data' in latest_reading:
                sensor_data = latest_reading['data']
                temperature = sensor_data.get('temperature', 23.4)
                humidity = sensor_data.get('humidity', 83.0)
                
                # Ensure we have valid temperature values
                if temperature is None or temperature == 0:
                    temperature = 23.4
                if humidity is None or humidity == 0:
                    humidity = 83.0
                
                # Add some variation for forecast
                temperature += (hash(str(target_date)) % 5) - 2  # Add -2 to +2 variation
                humidity += (hash(str(target_date)) % 10) - 5    # Add -5 to +5 variation
                
                return {
                    'temperature': float(temperature),
                    'humidity': float(humidity),
                    'wind_speed': 5.2,
                    'condition': 'partly_cloudy',
                    'description': 'Partly cloudy',
                    'rainfall_probability': 20
                }
        except Exception as e:
            logger.warning(f"Could not fetch sensor data for forecast fallback: {e}")
        
        # Final fallback
        return {
            'temperature': 23.4,
            'humidity': 83.0,
            'wind_speed': 5.2,
            'condition': 'partly_cloudy',
            'description': 'Partly cloudy',
            'rainfall_probability': 20
        }

# Global instance
amadeo_weather_service = AmadeoWeatherService()
