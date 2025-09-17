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

    def analyze_daily_performance(self, farmer_id: str, use_today: bool = False) -> Optional[Dict[str, Any]]:
        """
        Analyze daily performance data.
        
        Args:
            farmer_id: The ID of the farmer to analyze
            use_today: If True, analyze today's data. Otherwise, analyze yesterday's data.
            
        Returns:
            Dictionary with analysis results or None if analysis fails
        """
        try:
            # Use today's date if use_today is True, otherwise use yesterday's date
            target_date = datetime.now() if use_today else datetime.now() - timedelta(days=1)
            start_of_day = datetime(target_date.year, target_date.month, target_date.day)
            end_of_day = start_of_day + timedelta(days=1)

            # ✅ Explicitly check for None instead of truthiness
            if self.stress_collection is None:
                logger.error("Stress collection not initialized")
                return None
            if self.growth_collection is None:
                logger.error("Growth collection not initialized")
                return None
            if self.weather_collection is None:
                logger.error("Weather collection not initialized")
                return None

            logger.info(f"Starting descriptive analysis for {farmer_id} on {start_of_day}")

            # Fetch data safely
            stress_data = list(
                self.stress_collection.find(
                    {"farmer_id": farmer_id, "date": {"$gte": start_of_day, "$lt": end_of_day}}
                )
            )
            growth_data = list(
                self.growth_collection.find(
                    {"farmer_id": farmer_id}
                ).sort("created_at", -1).limit(1)
            )
            weather_data = list(
                self.weather_collection.find(
                    {"date": {"$gte": start_of_day, "$lt": end_of_day}}
                )
            )

            if not stress_data:
                logger.warning(f"No stress data found for {farmer_id} on {start_of_day}")
                # Check for the most recent data available
                most_recent = list(self.stress_collection.find(
                    {"farmer_id": farmer_id},
                    sort=[("date", -1)],
                    limit=1
                ))
                
                if most_recent:
                    last_date = most_recent[0]['date'].strftime('%Y-%m-%d')
                    logger.warning(f"Most recent data for {farmer_id} is from {last_date} ({(yesterday - most_recent[0]['date']).days} days ago)")
                else:
                    logger.warning(f"No historical stress data found for {farmer_id}")
                
                # Safely get growth stage from growth_data
                growth_stage = "Unknown"
                if growth_data and isinstance(growth_data, list) and len(growth_data) > 0:
                    growth_stage = growth_data[0].get("stage", 
                                                    growth_data[0].get("growth_stage", 
                                                                    "Unknown"))
                
                # Return a minimal response with available data
                return {
                    "farmer_id": farmer_id,  # Added for consistency
                    "date": start_of_day.strftime("%Y-%m-%d"),
                    "growth_stage": growth_stage,
                    "overall_stress": "unknown",
                    "stress_analysis": {},
                    "weather_summary": self._summarize_weather(weather_data) if weather_data else {},
                    "status": "no_recent_data",
                    "message": f"No stress data available for {start_of_day.strftime('%Y-%m-%d')}"
                }

            # Perform analysis (simplified example)
            overall_stress = self._calculate_overall_stress(stress_data)
            
            # Safely get growth stage from growth_data
            growth_stage = "Unknown"
            if growth_data and isinstance(growth_data, list) and len(growth_data) > 0:
                growth_stage = growth_data[0].get("stage", 
                                               growth_data[0].get("growth_stage", 
                                                               "Unknown"))

            results = {
                "farmer_id": farmer_id,  # Added for compatibility with predictive analytics
                "date": start_of_day.strftime("%Y-%m-%d"),
                "growth_stage": growth_stage,
                "overall_stress": overall_stress,
                "stress_analysis": self._analyze_stress_factors(stress_data),
                "weather_summary": self._summarize_weather(weather_data)
            }

            return results

        except Exception as e:
            logger.error(f"XX Descriptive analysis failed: {e}")
            return None

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


# Global instance
descriptive_analytics = DescriptiveAnalytics()
