import json
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional, List
import numpy as np
import pandas as pd
from scipy import stats
import pytz

from database.mongodb_setup import db_manager

logger = logging.getLogger('corn_system')

class PredictiveAnalytics:
    """Simple predictive analytics - weather forecast and risk assessment"""
    
    def __init__(self):
        """Initialize predictive analytics"""
        with open('config/settings.json', 'r') as f:
            self.config = json.load(f)
        
        self.weather_collection = db_manager.get_collection('historical_weather')
        self.forecast_periods = self.config['forecasting']
        
    def analyze_predictions(self, descriptive_results: Dict) -> Optional[Dict]:
        """
        Main function: Generate predictions based on descriptive results
        
        Args:
            descriptive_results: Output from descriptive analytics
            
        Returns:
            Complete prediction analysis
        """
        try:
            farmer_id = descriptive_results['farmer_id']
            current_date = descriptive_results['date']
            
            logger.info(f"Starting predictive analysis for {farmer_id} from {current_date}")
            
            # Step 1: Get historical weather patterns
            historical_data = self._get_historical_weather_patterns(current_date)
            if historical_data is None or historical_data.empty:
                logger.error("No historical weather data found")
                return None
            
            # Step 2: Generate weather forecast
            weather_forecast = self._generate_weather_forecast(historical_data, current_date)
            
            # Step 3: Calculate risk probabilities
            risk_assessment = self._calculate_risk_probabilities(
                descriptive_results, weather_forecast
            )
            
            # Step 4: Predict growth stage progression
            growth_timeline = self._predict_growth_progression(
                descriptive_results['growth_stage'], 
                descriptive_results['overall_stress']
            )
            
            # Step 5: Determine forecast period (adaptive)
            forecast_days = self._determine_forecast_period(weather_forecast)
            
            results = {
                "farmer_id": farmer_id,
                "prediction_date": current_date,
                "forecast_period_days": forecast_days,
                "weather_forecast": weather_forecast,
                "risk_assessment": risk_assessment,
                "growth_timeline": growth_timeline,
                "volatility_detected": forecast_days > self.forecast_periods['stable_period_days'],
                "prediction_timestamp": datetime.utcnow()
            }
            
            logger.info(f"Predictive analysis completed - {forecast_days} day forecast")
            return results
            
        except Exception as e:
            logger.error(f"Predictive analysis failed: {e}")
            return None
    
    def _get_historical_weather_patterns(self, current_date: datetime, years_back: int = 5) -> Optional[pd.DataFrame]:
        """Get historical weather data for same time period"""
        try:
            # Get same month/day for past years
            start_date = current_date.replace(year=current_date.year - years_back)
            end_date = current_date
            
            # Query database
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
            
            if df is None or df.empty:
                return None
            
            df['date'] = pd.to_datetime(df['date'])
            df = df.sort_values('date')
            
            return df
        
            
        except Exception as e:
            logger.error(f"Failed to get historical weather: {e}")
            return None
    
    def _generate_weather_forecast(self, historical_data: pd.DataFrame, current_date: datetime) -> Dict:
        """Simple weather forecast using historical averages and trends"""
        try:
            if historical_data is None or historical_data.empty:
                logger.warning("No historical data to generate forecast")
                return {}

            # Filter to same time period (±15 days) across years
            target_month = current_date.month
            target_day = current_date.day
            
            # Get data for similar dates
            similar_dates = historical_data[
                (historical_data['date'].dt.month == target_month) &
                (abs(historical_data['date'].dt.day - target_day) <= 15)
            ].copy()
            
            if similar_dates.empty:
                # Fallback to monthly averages
                similar_dates = historical_data[
                    historical_data['date'].dt.month == target_month
                ].copy()
            
            # Calculate simple forecast
            forecast = {
                "rainfall_probability": self._calculate_rainfall_probability(similar_dates),
                "temperature_forecast": {
                    "min_temp": round(similar_dates['min_temp_c'].mean(), 1),
                    "max_temp": round(similar_dates['max_temp_c'].mean(), 1),
                    "avg_temp": round(similar_dates['avg_temp_c'].mean(), 1)
                },
                "humidity_forecast": round(similar_dates['humidity_percent'].mean(), 1),
                "volatility_score": self._calculate_weather_volatility(similar_dates)
            }
            
            return forecast
            
        except Exception as e:
            logger.error(f"Failed to generate weather forecast: {e}")
            return {}
    
    def _calculate_rainfall_probability(self, data: pd.DataFrame) -> Dict:
        """Calculate rainfall probability"""
        try:
            total_days = len(data)
            rainy_days = len(data[data['rainfall_mm'] > 1.0])  # >1mm = rainy
            heavy_rain_days = len(data[data['rainfall_mm'] > 10.0])  # >10mm = heavy
            
            return {
                "light_rain_probability": round((rainy_days / total_days) * 100, 1) if total_days > 0 else 0,
                "heavy_rain_probability": round((heavy_rain_days / total_days) * 100, 1) if total_days > 0 else 0,
                "expected_rainfall_mm": round(data['rainfall_mm'].mean(), 1)
            }
        except:
            return {"light_rain_probability": 0, "heavy_rain_probability": 0, "expected_rainfall_mm": 0}
    
    def _calculate_weather_volatility(self, data: pd.DataFrame) -> float:
        """Calculate weather volatility score"""
        try:
            temp_volatility = data['avg_temp_c'].std() / data['avg_temp_c'].mean() if data['avg_temp_c'].mean() > 0 else 0
            humidity_volatility = data['humidity_percent'].std() / data['humidity_percent'].mean() if data['humidity_percent'].mean() > 0 else 0
            
            volatility_score = (temp_volatility + humidity_volatility) / 2
            return round(volatility_score, 3)
        except:
            return 0.0
    
    def _calculate_risk_probabilities(self, descriptive_results: Dict, weather_forecast: Dict) -> Dict:
        """Calculate risk probabilities based on current conditions and forecast"""
        try:
            stress_analysis = descriptive_results['stress_analysis']
            
            # Drought risk
            drought_risk = self._calculate_drought_risk(stress_analysis, weather_forecast)
            
            # Excess moisture risk
            moisture_risk = self._calculate_excess_moisture_risk(stress_analysis, weather_forecast)
            
            # Temperature stress risk
            temp_risk = self._calculate_temperature_stress_risk(stress_analysis, weather_forecast)
            
            # pH stress risk
            ph_risk = self._calculate_ph_stress_risk(stress_analysis)
            
            return {
                "drought_risk": drought_risk,
                "excess_moisture_risk": moisture_risk,
                "temperature_stress_risk": temp_risk,
                "ph_stress_risk": ph_risk,
                "overall_risk_level": self._determine_overall_risk([
                    drought_risk, moisture_risk, temp_risk, ph_risk
                ])
            }
            
        except Exception as e:
            logger.error(f"Failed to calculate risk probabilities: {e}")
            return {}
    
    def _calculate_drought_risk(self, stress_analysis: Dict, weather_forecast: Dict) -> Dict:
        """Calculate drought risk"""
        soil_moisture = stress_analysis.get('soil_moisture', {})
        current_stress = soil_moisture.get('stress_level', 'optimal')
        
        # Base risk from current moisture level
        risk_score = {
            'optimal': 10,
            'mild': 30,
            'moderate': 60,
            'severe': 80
        }.get(current_stress, 10)
        
        # Adjust based on rainfall forecast
        rain_prob = weather_forecast.get('rainfall_probability', {}).get('light_rain_probability', 50)
        if rain_prob < 30:
            risk_score += 15
        elif rain_prob > 70:
            risk_score -= 15
        
        return {
            "probability": min(max(risk_score, 0), 100),
            "level": "high" if risk_score > 60 else "medium" if risk_score > 30 else "low"
        }
    
    def _calculate_excess_moisture_risk(self, stress_analysis: Dict, weather_forecast: Dict) -> Dict:
        """Calculate excess moisture risk"""
        humidity = stress_analysis.get('humidity', {})
        current_humidity_stress = humidity.get('stress_level', 'optimal')
        
        # Base risk from current humidity
        risk_score = 20 if current_humidity_stress in ['moderate', 'severe'] else 10
        
        # Adjust based on rainfall forecast
        heavy_rain_prob = weather_forecast.get('rainfall_probability', {}).get('heavy_rain_probability', 10)
        risk_score += heavy_rain_prob
        
        return {
            "probability": min(max(risk_score, 0), 100),
            "level": "high" if risk_score > 60 else "medium" if risk_score > 30 else "low"
        }
    
    def _calculate_temperature_stress_risk(self, stress_analysis: Dict, weather_forecast: Dict) -> Dict:
        """Calculate temperature stress risk"""
        temp = stress_analysis.get('temperature', {})
        current_temp_stress = temp.get('stress_level', 'optimal')
        
        risk_score = {
            'optimal': 10,
            'mild': 35,
            'moderate': 55,
            'severe': 75
        }.get(current_temp_stress, 10)
        
        # Simple forecast adjustment
        forecasted_max = weather_forecast.get('temperature_forecast', {}).get('max_temp', 30)
        if forecasted_max > 35:
            risk_score += 20
        elif forecasted_max < 20:
            risk_score += 15
        
        return {
            "probability": min(max(risk_score, 0), 100),
            "level": "high" if risk_score > 60 else "medium" if risk_score > 30 else "low"
        }
    
    def _calculate_ph_stress_risk(self, stress_analysis: Dict) -> Dict:
        """Calculate pH stress risk"""
        ph = stress_analysis.get('soil_ph', {})
        current_ph_stress = ph.get('stress_level', 'optimal')
        
        risk_score = {
            'optimal': 5,
            'mild': 25,
            'moderate': 50,
            'severe': 75
        }.get(current_ph_stress, 5)
        
        return {
            "probability": min(max(risk_score, 0), 100),
            "level": "high" if risk_score > 60 else "medium" if risk_score > 30 else "low"
        }
    
    def _determine_overall_risk(self, risk_assessments: List[Dict]) -> str:
        """Determine overall risk level"""
        high_risks = sum(1 for risk in risk_assessments if risk.get('level') == 'high')
        medium_risks = sum(1 for risk in risk_assessments if risk.get('level') == 'medium')
        
        if high_risks >= 2:
            return "high"
        elif high_risks >= 1 or medium_risks >= 3:
            return "medium"
        else:
            return "low"
    
    def _predict_growth_progression(self, current_stage: str, overall_stress: str) -> Dict:
        """Predict growth stage progression timeline"""
        try:
            # Simple growth stage duration (in days)
            stage_durations = {
                "VE": 7,
                "V2-V4": 21,
                "V5-VT": 28,
                "R1-R3": 21,
                "R4-R5": 35,
                "R6": 14
            }
            
            stage_sequence = ["VE", "V2-V4", "V5-VT", "R1-R3", "R4-R5", "R6"]
            
            current_duration = stage_durations.get(current_stage, 21)
            
            # Adjust duration based on stress
            stress_multiplier = {
                'optimal': 1.0,
                'mild': 1.1,
                'moderate': 1.2,
                'severe': 1.4
            }.get(overall_stress, 1.0)
            
            adjusted_duration = round(current_duration * stress_multiplier)
            
            # Find next stage
            try:
                current_index = stage_sequence.index(current_stage)
                next_stage = stage_sequence[current_index + 1] if current_index < len(stage_sequence) - 1 else "Harvest Complete"
            except ValueError:
                next_stage = "Unknown"
            
            return {
                "current_stage": current_stage,
                "next_stage": next_stage,
                "estimated_days_to_next": adjusted_duration,
                "stress_delay_days": round((stress_multiplier - 1.0) * current_duration),
                "progression_status": "delayed" if stress_multiplier > 1.1 else "normal"
            }
            
        except Exception as e:
            logger.error(f"Failed to predict growth progression: {e}")
            return {}
    
    def _determine_forecast_period(self, weather_forecast: Dict) -> int:
        """Determine forecast period based on weather volatility"""
        volatility = weather_forecast.get('volatility_score', 0)
        threshold = self.config['forecasting']['volatility_threshold']
        
        if volatility > threshold:
            return self.config['forecasting']['volatile_period_days']
        else:
            return self.config['forecasting']['stable_period_days']
    
    def get_results_for_prescriptive(self, prediction_results: Dict) -> Dict:
        """Format prediction results for prescriptive analytics"""
        try:
            return {
                "farmer_id": prediction_results['farmer_id'],
                "forecast_period": prediction_results['forecast_period_days'],
                "weather_forecast": prediction_results['weather_forecast'],
                "risk_assessment": prediction_results['risk_assessment'],
                "growth_timeline": prediction_results['growth_timeline'],
                "volatility_detected": prediction_results['volatility_detected']
            }
        except Exception as e:
            logger.error(f"Failed to format results for prescriptive: {e}")
            return {}

# Global instance
predictive_analytics = PredictiveAnalytics()

