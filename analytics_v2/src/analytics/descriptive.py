import logging
from datetime import datetime, timedelta
from typing import Optional, Dict, Any

from database.mongodb_setup import db_manager

logger = logging.getLogger("corn_system")

class DescriptiveAnalytics:
    def __init__(self):
        try:
            self.stress_collection = db_manager.get_collection("stress_assessments")
            self.growth_collection = db_manager.get_collection("growth_stages")
            self.weather_collection = db_manager.get_collection("historical_weather")
            self.recommendation_collection = db_manager.get_collection("daily_recommendations")
        except Exception as e:
            logger.error(f"Failed to initialize collections: {e}")
            self.stress_collection = None
            self.growth_collection = None
            self.weather_collection = None
            self.recommendation_collection = None

    def analyze_daily_performance(self, farmer_id: str, use_today: bool = False, field_id: str = None) -> Optional[Dict[str, Any]]:
        """
        Analyze daily performance data from MongoDB sensor readings.
        
        Args:
            farmer_id: The ID of the farmer to analyze
            use_today: If True, analyze today's data. Otherwise, analyze yesterday's data.
            field_id: Optional field ID to filter data
            
        Returns:
            Dictionary with analysis results or None if analysis fails
        """
        try:
            # Use today's date if use_today is True, otherwise use yesterday's date
            target_date = datetime.now() if use_today else datetime.now() - timedelta(days=1)
            start_of_day = datetime(target_date.year, target_date.month, target_date.day)
            end_of_day = start_of_day + timedelta(days=1)

            logger.info(f"Starting descriptive analysis for {farmer_id} on {start_of_day}")

            # Get sensor readings from MongoDB instead of stress assessments
            sensor_readings_collection = db_manager.get_collection("sensor_readings")
            farms_collection = db_manager.get_collection("farms")
            
            # First, get the farm for this farmer
            from bson import ObjectId
            try:
                # Convert farmer_id to ObjectId if it's a string
                if isinstance(farmer_id, str):
                    farmer_object_id = ObjectId(farmer_id)
                else:
                    farmer_object_id = farmer_id
                    
                farm = farms_collection.find_one({"userId": farmer_object_id})
                if not farm:
                    logger.error(f"No farm found for farmer {farmer_id}")
                    return None
            except Exception as e:
                logger.error(f"Invalid farmer ID format: {farmer_id}, error: {e}")
                return None
            
            farm_id = str(farm["_id"])
            logger.info(f"Found farm {farm_id} for farmer {farmer_id}")

            # Build query for sensor readings - look for data from the last 7 days
            query = {
                "farm": ObjectId(farm_id),  # Convert farm_id to ObjectId
                "timestamp": {"$gte": start_of_day - timedelta(days=7), "$lt": end_of_day}
            }
            
            # Add field filter if provided
            if field_id:
                query["field_id"] = field_id

            # Fetch sensor readings
            sensor_data = list(sensor_readings_collection.find(query).sort("timestamp", -1))
            
            if not sensor_data:
                logger.warning(f"No sensor data found for farm {farm_id} on {start_of_day}")
                
                # Try to get the most recent data
                recent_query = {"farm": ObjectId(farm_id)}  # Convert farm_id to ObjectId
                if field_id:
                    recent_query["field_id"] = field_id
                    
                most_recent = list(sensor_readings_collection.find(
                    recent_query,
                    sort=[("timestamp", -1)],
                    limit=1
                ))
                
                if most_recent:
                    last_date = most_recent[0]['timestamp'].strftime('%Y-%m-%d')
                    days_ago = (datetime.now() - most_recent[0]['timestamp']).days
                    logger.warning(f"Most recent data for farm {farm_id} is from {last_date} ({days_ago} days ago)")
                else:
                    logger.warning(f"No historical sensor data found for farm {farm_id}")
                
                # Get growth stage from farm fields
                growth_stage = "Unknown"
                if farm.get("fields") and len(farm["fields"]) > 0:
                    # Use the first field's growth stage or the specified field
                    if field_id:
                        field = next((f for f in farm["fields"] if f.get("fieldName") == field_id), None)
                        if field:
                            growth_stage = field.get("growthStage", "Unknown")
                    else:
                        growth_stage = farm["fields"][0].get("growthStage", "Unknown")
                
                # Return a minimal response with available data
                return {
                    "farmer_id": farmer_id,
                    "farm_id": farm_id,
                    "field_id": field_id,
                    "date": start_of_day.strftime("%Y-%m-%d"),
                    "growth_stage": growth_stage,
                    "overall_stress": "unknown",
                    "stress_analysis": {},
                    "weather_summary": {},
                    "status": "no_recent_data",
                    "message": f"No sensor data available for {start_of_day.strftime('%Y-%m-%d')}"
                }

            # Process sensor data to calculate stress analysis
            overall_stress = self._calculate_overall_stress_from_sensor_data(sensor_data)
            
            # Get growth stage from farm fields
            growth_stage = "Unknown"
            if farm.get("fields") and len(farm["fields"]) > 0:
                if field_id:
                    field = next((f for f in farm["fields"] if f.get("fieldName") == field_id), None)
                    if field:
                        growth_stage = field.get("growthStage", "Unknown")
                else:
                    growth_stage = farm["fields"][0].get("growthStage", "Unknown")

            # Calculate days since planting for this field
            days_since_planting = self._calculate_days_since_planting(farm, field_id)
            
            results = {
                "farmer_id": farmer_id,
                "farm_id": farm_id,
                "field_id": field_id,
                "date": start_of_day.strftime("%Y-%m-%d"),
                "growth_stage": growth_stage,
                "overall_stress": overall_stress,
                "stress_analysis": self._analyze_stress_factors_from_sensor_data(sensor_data),
                "weather_summary": self._summarize_sensor_data(sensor_data),
                "daysSincePlanting": days_since_planting
            }

            return results

        except Exception as e:
            logger.error(f"XX Descriptive analysis failed: {e}")
            return None

    def _calculate_overall_stress_from_sensor_data(self, sensor_data: list) -> str:
        """
        Calculate overall stress level based on sensor data.
        
        Args:
            sensor_data: List of sensor reading records
            
        Returns:
            String indicating overall stress level: 'low', 'medium', 'high', or 'unknown'
        """
        if not sensor_data:
            return "unknown"
            
        # Calculate averages from sensor data
        temps = []
        humidities = []
        soil_moistures = []
        soil_phs = []
        
        for reading in sensor_data:
            if 'data' in reading:
                data = reading['data']
                if 'temperature' in data and data['temperature'] is not None:
                    temps.append(data['temperature'])
                if 'humidity' in data and data['humidity'] is not None:
                    humidities.append(data['humidity'])
                if 'soilMoisture' in data and data['soilMoisture'] is not None:
                    soil_moistures.append(data['soilMoisture'])
                if 'soilPh' in data and data['soilPh'] is not None:
                    soil_phs.append(data['soilPh'])
        
        if not any([temps, humidities, soil_moistures, soil_phs]):
            return "unknown"
        
        # Calculate stress score
        stress_score = 0
        total_factors = 0
        
        if temps:
            avg_temp = sum(temps) / len(temps)
            if avg_temp > 30 or avg_temp < 20:
                stress_score += 1
            total_factors += 1
            
        if humidities:
            avg_humidity = sum(humidities) / len(humidities)
            if avg_humidity < 40 or avg_humidity > 80:
                stress_score += 1
            total_factors += 1
            
        if soil_moistures:
            avg_soil_moisture = sum(soil_moistures) / len(soil_moistures)
            if avg_soil_moisture < 30 or avg_soil_moisture > 70:
                stress_score += 1
            total_factors += 1
            
        if soil_phs:
            avg_soil_ph = sum(soil_phs) / len(soil_phs)
            if avg_soil_ph < 6.0 or avg_soil_ph > 7.5:
                stress_score += 1
            total_factors += 1
        
        if total_factors == 0:
            return "unknown"
            
        stress_ratio = stress_score / total_factors
        
        if stress_ratio > 0.7:
            return "high"
        elif stress_ratio > 0.3:
            return "medium"
        else:
            return "low"

    def _calculate_overall_stress(self, stress_data: list) -> str:
        """
        Calculate overall stress level based on stress data.
        
        Args:
            stress_data: List of stress assessment records
            
        Returns:
            String indicating overall stress level: 'low', 'medium', 'high', or 'unknown'
        """
        if not stress_data:
            return "unknown"
            
        # Define stress indicators and their weights
        stress_indicators = [
            ('temperature', 0.3, lambda x: x > 30 or x < 20),  # Outside 20-30°C is stressful
            ('humidity', 0.2, lambda x: x < 40 or x > 80),     # Outside 40-80% is stressful
            ('soil_moisture', 0.3, lambda x: x < 30 or x > 70), # Outside 30-70% is stressful
            ('leaf_wetness', 0.2, lambda x: x > 50),            # Above 50% is stressful
        ]
        
        try:
            # Calculate stress score (0-100)
            total_score = 0
            total_weight = 0
            
            for record in stress_data:
                for field, weight, is_stress_condition in stress_indicators:
                    if field in record and record[field] is not None:
                        if is_stress_condition(record[field]):
                            total_score += weight * 100  # Full stress for this factor
                        total_weight += weight
            
            if total_weight == 0:
                return "unknown"
                
            # Normalize score to 0-100 range
            normalized_score = total_score / total_weight
            
            # Determine stress level
            if normalized_score > 70:
                return "high"
            elif normalized_score > 30:
                return "medium"
            else:
                return "low"
                
        except Exception as e:
            logger.warning(f"Error calculating stress level: {e}")
            return "unknown"

    def _analyze_stress_factors(self, stress_data: list) -> Dict[str, Any]:
        """
        Generate stress analysis for each factor in the stress data.
        
        Args:
            stress_data: List of stress assessment records
            
        Returns:
            Dictionary with analysis for each stress factor
        """
        if not stress_data:
            return {}
            
        # Define optimal ranges for each factor
        optimal_ranges = {
            'temperature': (20, 30),      # °C
            'humidity': (40, 80),         # %
            'soil_moisture': (30, 70),    # %
            'leaf_wetness': (0, 50),      # % (lower is better)
            'ndvi': (0.7, 0.9)           # Normalized Difference Vegetation Index
        }
        
        # Define human-readable factor names
        factor_names = {
            'temperature': 'Temperature',
            'humidity': 'Humidity',
            'soil_moisture': 'Soil Moisture',
            'leaf_wetness': 'Leaf Wetness',
            'ndvi': 'Vegetation Health (NDVI)'
        }
        
        analysis = {}
        
        # Process each record in the stress data
        for record in stress_data:
            for field, value in record.items():
                # Skip non-numeric fields and None values
                if not isinstance(value, (int, float)) or field.startswith('_'):
                    continue
                    
                # Get optimal range for this field
                opt_min, opt_max = optimal_ranges.get(field, (None, None))
                
                # Determine status and stress level
                status = "OK"
                stress_level = "low"
                
                if opt_min is not None and opt_max is not None:
                    if value < opt_min:
                        status = "LOW"
                        stress_level = "high" if (opt_min - value) > (opt_min * 0.3) else "medium"
                    elif value > opt_max:
                        status = "HIGH"
                        stress_level = "high" if (value - opt_max) > (opt_max * 0.3) else "medium"
                
                # Add to analysis
                factor_name = factor_names.get(field, field.replace('_', ' ').title())
                analysis[factor_name] = {
                    "status": status,
                    "stress_level": stress_level,
                    "actual_value": round(value, 2) if isinstance(value, float) else value,
                    "optimal_range": [opt_min, opt_max] if opt_min is not None else ["N/A", "N/A"],
                    "recommendation": self._get_recommendation(field, value, status, stress_level)
                }
        
        return analysis

    def _get_recommendation(self, factor: str, value: float, status: str, stress_level: str) -> str:
        """
        Generate a recommendation for a stress factor.
        
        Args:
            factor: The stress factor (e.g., 'temperature', 'humidity')
            value: The measured value
            status: Status of the factor ('OK', 'LOW', 'HIGH')
            stress_level: Stress level ('low', 'medium', 'high')
            
        Returns:
            A recommendation string
        """
        if status == "OK":
            return f"Optimal {factor} level maintained."
            
        factor_name = factor.lower()
        recommendations = {
            'temperature': {
                'LOW': "Consider using row covers or mulch to retain soil heat.",
                'HIGH': "Provide shade or increase irrigation to cool the plants."
            },
            'humidity': {
                'LOW': "Increase irrigation or use misting to raise humidity levels.",
                'HIGH': "Improve ventilation or reduce irrigation to lower humidity."
            },
            'soil_moisture': {
                'LOW': "Increase irrigation to maintain proper soil moisture.",
                'HIGH': "Reduce irrigation and improve drainage to prevent waterlogging."
            },
            'leaf wetness': {
                'HIGH': "Reduce overhead irrigation and improve air circulation.",
            },
            'vegetation health (ndvi)': {
                'LOW': "Check for nutrient deficiencies, pests, or diseases.",
                'HIGH': "Excellent vegetation health detected."
            }
        }
        
        # Get the appropriate recommendation
        factor_key = factor_name
        if factor_name not in recommendations:
            for key in recommendations:
                if key in factor_name:
                    factor_key = key
                    break
        
        if status in recommendations.get(factor_key, {}):
            return recommendations[factor_key][status]
            
        return f"Monitor {factor_name} levels and adjust management practices as needed."

    def _summarize_weather(self, weather_data: list) -> Dict[str, Any]:
        """Summarize weather data for yesterday."""
        if not weather_data:
            return {}
            
        # Extract relevant data points
        temps = []
        humidity = []
        rainfall = []
        
        for w in weather_data:
            if isinstance(w.get('temperature'), (int, float)):
                temps.append(w['temperature'])
            if isinstance(w.get('humidity'), (int, float)):
                humidity.append(w['humidity'])
            if isinstance(w.get('rainfall'), (int, float)):
                rainfall.append(w['rainfall'])
        
        # Calculate statistics
        summary = {}
        if temps:
            summary['avg_temp'] = round(sum(temps) / len(temps), 1)
            summary['min_temp'] = min(temps)
            summary['max_temp'] = max(temps)
            
        if humidity:
            summary['avg_humidity'] = round(sum(humidity) / len(humidity), 1)
            summary['min_humidity'] = min(humidity)
            summary['max_humidity'] = max(humidity)
            
        if rainfall:
            summary['total_rainfall'] = round(sum(rainfall), 1)
            summary['rain_events'] = len([r for r in rainfall if r > 0])
        
        return summary

    def _analyze_stress_factors_from_sensor_data(self, sensor_data: list) -> Dict[str, Any]:
        """
        Generate stress analysis for each factor from sensor data.
        
        Args:
            sensor_data: List of sensor reading records
            
        Returns:
            Dictionary with analysis for each stress factor
        """
        if not sensor_data:
            return {}
        
        # Calculate averages from sensor data
        temps = []
        humidities = []
        soil_moistures = []
        soil_phs = []
        light_intensities = []
        
        for reading in sensor_data:
            if 'data' in reading:
                data = reading['data']
                if 'temperature' in data and data['temperature'] is not None:
                    temps.append(data['temperature'])
                if 'humidity' in data and data['humidity'] is not None:
                    humidities.append(data['humidity'])
                if 'soilMoisture' in data and data['soilMoisture'] is not None:
                    soil_moistures.append(data['soilMoisture'])
                if 'soilPh' in data and data['soilPh'] is not None:
                    soil_phs.append(data['soilPh'])
                if 'lightIntensity' in data and data['lightIntensity'] is not None:
                    light_intensities.append(data['lightIntensity'])
        
        analysis = {}
        
        # Temperature analysis
        if temps:
            avg_temp = sum(temps) / len(temps)
            status = "OK"
            stress_level = "low"
            
            if avg_temp < 20:
                status = "LOW"
                stress_level = "high" if avg_temp < 15 else "medium"
            elif avg_temp > 30:
                status = "HIGH"
                stress_level = "high" if avg_temp > 35 else "medium"
            
            analysis["Temperature"] = {
                "status": status,
                "stress_level": stress_level,
                "actual_value": round(avg_temp, 2),
                "optimal_range": [20, 30],
                "recommendation": self._get_recommendation("temperature", avg_temp, status, stress_level)
            }
        
        # Humidity analysis
        if humidities:
            avg_humidity = sum(humidities) / len(humidities)
            status = "OK"
            stress_level = "low"
            
            if avg_humidity < 40:
                status = "LOW"
                stress_level = "high" if avg_humidity < 30 else "medium"
            elif avg_humidity > 80:
                status = "HIGH"
                stress_level = "high" if avg_humidity > 85 else "medium"
            
            analysis["Humidity"] = {
                "status": status,
                "stress_level": stress_level,
                "actual_value": round(avg_humidity, 2),
                "optimal_range": [40, 80],
                "recommendation": self._get_recommendation("humidity", avg_humidity, status, stress_level)
            }
        
        # Soil Moisture analysis
        if soil_moistures:
            avg_soil_moisture = sum(soil_moistures) / len(soil_moistures)
            status = "OK"
            stress_level = "low"
            
            if avg_soil_moisture < 30:
                status = "LOW"
                stress_level = "high" if avg_soil_moisture < 20 else "medium"
            elif avg_soil_moisture > 70:
                status = "HIGH"
                stress_level = "high" if avg_soil_moisture > 80 else "medium"
            
            analysis["Soil Moisture"] = {
                "status": status,
                "stress_level": stress_level,
                "actual_value": round(avg_soil_moisture, 2),
                "optimal_range": [30, 70],
                "recommendation": self._get_recommendation("soil_moisture", avg_soil_moisture, status, stress_level)
            }
        
        # Soil pH analysis
        if soil_phs:
            avg_soil_ph = sum(soil_phs) / len(soil_phs)
            status = "OK"
            stress_level = "low"
            
            if avg_soil_ph < 6.0:
                status = "LOW"
                stress_level = "high" if avg_soil_ph < 5.5 else "medium"
            elif avg_soil_ph > 7.5:
                status = "HIGH"
                stress_level = "high" if avg_soil_ph > 8.0 else "medium"
            
            analysis["Soil pH"] = {
                "status": status,
                "stress_level": stress_level,
                "actual_value": round(avg_soil_ph, 2),
                "optimal_range": [6.0, 7.5],
                "recommendation": self._get_recommendation("soil_ph", avg_soil_ph, status, stress_level)
            }
        
        # Light Intensity analysis
        if light_intensities:
            avg_light = sum(light_intensities) / len(light_intensities)
            status = "OK"
            stress_level = "low"
            
            if avg_light < 200:
                status = "LOW"
                stress_level = "high"
            elif avg_light > 1200:
                status = "HIGH"
                stress_level = "high"
            
            analysis["Light Intensity"] = {
                "status": status,
                "stress_level": stress_level,
                "actual_value": round(avg_light, 2),
                "optimal_range": [400, 800],
                "recommendation": self._get_recommendation("light_intensity", avg_light, status, stress_level)
            }
        
        return analysis

    def _summarize_sensor_data(self, sensor_data: list) -> Dict[str, Any]:
        """Summarize sensor data for the day."""
        if not sensor_data:
            return {}
        
        # Extract relevant data points
        temps = []
        humidities = []
        soil_moistures = []
        soil_phs = []
        light_intensities = []
        
        for reading in sensor_data:
            if 'data' in reading:
                data = reading['data']
                if 'temperature' in data and data['temperature'] is not None:
                    temps.append(data['temperature'])
                if 'humidity' in data and data['humidity'] is not None:
                    humidities.append(data['humidity'])
                if 'soilMoisture' in data and data['soilMoisture'] is not None:
                    soil_moistures.append(data['soilMoisture'])
                if 'soilPh' in data and data['soilPh'] is not None:
                    soil_phs.append(data['soilPh'])
                if 'lightIntensity' in data and data['lightIntensity'] is not None:
                    light_intensities.append(data['lightIntensity'])
        
        # Calculate statistics
        summary = {}
        if temps:
            summary['avg_temp'] = round(sum(temps) / len(temps), 1)
            summary['min_temp'] = min(temps)
            summary['max_temp'] = max(temps)
            
        if humidities:
            summary['avg_humidity'] = round(sum(humidities) / len(humidities), 1)
            summary['min_humidity'] = min(humidities)
            summary['max_humidity'] = max(humidities)
            
        if soil_moistures:
            summary['avg_soil_moisture'] = round(sum(soil_moistures) / len(soil_moistures), 1)
            summary['min_soil_moisture'] = min(soil_moistures)
            summary['max_soil_moisture'] = max(soil_moistures)
            
        if soil_phs:
            summary['avg_soil_ph'] = round(sum(soil_phs) / len(soil_phs), 1)
            summary['min_soil_ph'] = min(soil_phs)
            summary['max_soil_ph'] = max(soil_phs)
            
        if light_intensities:
            summary['avg_light_intensity'] = round(sum(light_intensities) / len(light_intensities), 1)
            summary['min_light_intensity'] = min(light_intensities)
            summary['max_light_intensity'] = max(light_intensities)
        
        summary['data_points'] = len(sensor_data)
        
        return summary

    def _calculate_days_since_planting(self, farm: dict, field_id: str = None) -> int:
        """Calculate days since planting for a specific field"""
        try:
            if not farm or 'fields' not in farm:
                return 0
            
            # Find the specific field
            target_field = None
            if field_id:
                for field in farm['fields']:
                    if str(field.get('_id', '')) == field_id:
                        target_field = field
                        break
            else:
                target_field = farm['fields'][0] if farm['fields'] else None
            
            if not target_field:
                return 0
            
            # Get planting date from field data
            planting_date = target_field.get('plantingDate')
            if planting_date:
                if isinstance(planting_date, str):
                    planting_date = datetime.strptime(planting_date, '%Y-%m-%d')
                days_since = (datetime.now() - planting_date).days
                return max(0, days_since)
            
            # Fallback: estimate based on growth stage
            growth_stage = target_field.get('growthStage', 'VE')
            stage_days = {
                'VE': 7,
                'V2': 14,
                'V3': 21,
                'V4': 28,
                'V5': 35,
                'V6': 42,
                'V7': 49,
                'V8': 56,
                'VT': 63,
                'R1': 70,
                'R2': 77,
                'R3': 84,
                'R4': 91,
                'R5': 98,
                'R6': 105
            }
            return stage_days.get(growth_stage, 30)
            
        except Exception as e:
            logger.warning(f"Could not calculate days since planting: {e}")
            return 30  # Default fallback


# Global instance
descriptive_analytics = DescriptiveAnalytics()
