import json
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional, List
import pytz

# Import our modules
from database.mongodb_setup import db_manager
from apis.thingspeak_client import thingspeak_client
from apis.iot_data_service import iot_data_service

logger = logging.getLogger('corn_system')

class DescriptiveAnalytics:
    """Simple descriptive analytics - yesterday's performance"""
    
    def __init__(self):
        """Initialize descriptive analytics"""
        # Load configurations
        with open('config/settings.json', 'r') as f:
            self.config = json.load(f)
        
        # Get collections
        self.growth_collection = db_manager.get_collection('growth_stages')
        self.stress_collection = db_manager.get_collection('stress_assessments')
        self.config_collection = db_manager.get_collection('system_config')
        
        # Load growth matrix
        self.growth_matrix = self._load_growth_matrix()
        self.stress_thresholds = self.config['thresholds']['stress_levels']
    
    def _load_growth_matrix(self) -> Dict:
        """Load growth matrix from database"""
        try:
            matrix_doc = self.config_collection.find_one(
                {"config_type": "growth_matrix", "is_active": True}
            )
            if matrix_doc:
                return matrix_doc['config_data']
            else:
                # Fallback to file if not in database
                with open('config/growth_matrix.json', 'r') as f:
                    return json.load(f)
        except Exception as e:
            logger.error(f"Failed to load growth matrix: {e}")
            return {}
    
    def analyze_daily_performance(self, farmer_id: str, target_date: datetime = None) -> Optional[Dict]:
        """
        Main function: Analyze yesterday's performance
        
        Args:
            farmer_id: Farmer identifier
            target_date: Date to analyze (defaults to yesterday)
        
        Returns:
            Complete stress assessment or None if failed
        """
        try:
            # Default to yesterday if no date provided
            if target_date is None:
                manila_tz = pytz.timezone(self.config['system']['timezone'])
                target_date = datetime.now(manila_tz).date() - timedelta(days=1)
                target_date = datetime.combine(target_date, datetime.min.time())

            
            logger.info(f" Starting descriptive analysis for {farmer_id} on {target_date}")
            
            # Step 1: Get farmer's current growth stage
            current_stage = self._get_current_growth_stage(farmer_id)
            if not current_stage:
                logger.error(f"No growth stage found for farmer {farmer_id}")
                return None
            
            # Step 2: Get yesterday's sensor averages from IoT DB first, fallback to ThingSpeak
            field_id = None  # Optionally derive from farmer's active field if available
            sensor_data = iot_data_service.get_daily_averages(target_date, field_id=field_id)
            if not sensor_data:
                sensor_data = thingspeak_client.get_daily_averages(target_date)
            if not sensor_data:
                logger.error(f"No sensor data found for {target_date}")
                return None
            
            # Step 3: Get optimal ranges for current growth stage
            optimal_ranges = self._get_optimal_ranges(current_stage['growth_stage'])
            if not optimal_ranges:
                logger.error(f"No optimal ranges found for stage {current_stage['growth_stage']}")
                return None
            
            # Step 4: Compare actual vs optimal (stress analysis)
            stress_analysis = self._calculate_stress_levels(sensor_data, optimal_ranges)
            
            # Step 5: Determine overall condition
            overall_stress = self._determine_overall_stress(stress_analysis)
            
            # Step 6: Create results
            results = {
                "farmer_id": farmer_id,
                "date": target_date,
                "growth_stage": current_stage['growth_stage'],
                "sensor_data": sensor_data,
                "optimal_ranges": optimal_ranges,
                "stress_analysis": stress_analysis,
                "overall_stress": overall_stress,
                "analysis_timestamp": datetime.utcnow()
            }
            
            # Step 7: Save to database
            self._save_assessment(results)
            
            logger.info(f"// Descriptive analysis completed - Overall: {overall_stress}")
            return results
            
        except Exception as e:
            logger.error(f"XX Descriptive analysis failed: {e}")
            return None
    
    def _get_current_growth_stage(self, farmer_id: str) -> Optional[Dict]:
        """Get farmer's current active growth stage"""
        try:
            stage_doc = self.growth_collection.find_one(
                {"farmer_id": farmer_id, "is_active": True},
                sort=[("updated_at", -1)]
            )
            return stage_doc
        except Exception as e:
            logger.error(f"Failed to get growth stage: {e}")
            return None
    
    def _get_optimal_ranges(self, growth_stage: str) -> Optional[Dict]:
        """Get optimal parameter ranges for growth stage"""
        try:
            stages = self.growth_matrix.get('growth_stages', {})
            stage_data = stages.get(growth_stage, {})
            
            if not stage_data:
                logger.error(f"Growth stage {growth_stage} not found in matrix")
                return None
            
            return {
                "temperature": stage_data.get('temperature_range'),
                "humidity": stage_data.get('humidity_range'),
                "soil_moisture": stage_data.get('soil_moisture_range'),
                "soil_ph": stage_data.get('ph_range'),
                "light_intensity": stage_data.get('light_intensity_range')
            }
        except Exception as e:
            logger.error(f"Failed to get optimal ranges: {e}")
            return None
    
    def _calculate_stress_levels(self, sensor_data: Dict, optimal_ranges: Dict) -> Dict:
        """
        Simple stress calculation: compare actual vs optimal
        
        Returns stress level for each parameter:
        - optimal: within range
        - mild: 10-20% deviation  
        - moderate: 20-35% deviation
        - severe: >35% deviation
        """
        stress_results = {}
        
        for param, actual_value in sensor_data.items():
            if param in ['data_points', 'date'] or actual_value is None:
                continue
                
            optimal_range = optimal_ranges.get(param)
            if not optimal_range or len(optimal_range) != 2:
                continue
            
            min_val, max_val = optimal_range
            
            # Calculate deviation percentage
            if min_val <= actual_value <= max_val:
                # Within optimal range
                deviation_percent = 0
                stress_level = "optimal"
            else:
                # Calculate how far outside the range
                if actual_value < min_val:
                    deviation_percent = ((min_val - actual_value) / min_val) * 100
                else:  # actual_value > max_val
                    deviation_percent = ((actual_value - max_val) / max_val) * 100
                
                # Classify stress level
                if deviation_percent <= self.stress_thresholds['mild'][1]:
                    stress_level = "mild"
                elif deviation_percent <= self.stress_thresholds['moderate'][1]:
                    stress_level = "moderate"
                else:
                    stress_level = "severe"
            
            stress_results[param] = {
                "actual_value": actual_value,
                "optimal_range": optimal_range,
                "deviation_percent": round(deviation_percent, 2),
                "stress_level": stress_level,
                "status": "/" if stress_level == "optimal" else "!" if stress_level == "mild" else "!!" if stress_level == "moderate" else "!!!"
            }
        
        return stress_results
    

    # Add this method to the existing DescriptiveAnalytics class
    def get_results_for_predictive(self, farmer_id: str) -> Optional[Dict]:
        """Get descriptive results formatted for predictive analytics"""
        try:
            latest = self.get_latest_assessment(farmer_id)
            if not latest:
                return None
            
            return {
                "farmer_id": farmer_id,
                "date": latest['date'],
                "growth_stage": latest['growth_stage'],
                "stress_analysis": latest['stress_analysis'],
                "overall_stress": latest['overall_stress'],
                "sensor_data": latest['sensor_data']
            }
        except Exception as e:
            logger.error(f"Failed to get results for predictive: {e}")
            return None

    # if only one sensor screams severe but four others are fine, the system says “okei naman sila! overall is mild/moderate, but hey! — temp is severe haha lagot"
    def _determine_overall_stress(self, stress_analysis: Dict) -> str:
        """Determine overall stress by majority levels instead of worst-case only"""
        stress_levels = [param['stress_level'] for param in stress_analysis.values()]

        if not stress_levels:
            return "unknown"

        # Count occurrences of each stress level
        counts = {level: stress_levels.count(level) for level in ["severe", "moderate", "mild", "optimal"]}

        # Pick the most common stress level
        overall = max(counts, key=counts.get)
        return overall

    
    def _save_assessment(self, results: Dict):
        """Save stress assessment to database"""
        try:
            # Prepare document
            from database.data_models import StressAssessment
            
            assessment_doc = StressAssessment.create_document(
                farmer_id=results['farmer_id'],
                date=results['date'],
                sensor_data=results['sensor_data'],
                stress_analysis=results['stress_analysis']
            )
            
            # Add extra fields
            assessment_doc.update({
                "growth_stage": results['growth_stage'],
                "overall_stress": results['overall_stress'],
                "optimal_ranges": results['optimal_ranges']
            })
            
            # Upsert (update if exists, insert if new)
            self.stress_collection.update_one(
                {
                    "farmer_id": results['farmer_id'],
                    "date": results['date']
                },
                {"$set": assessment_doc},
                upsert=True
            )
            
            logger.info(" Stress assessment saved to database")
            
        except Exception as e:
            logger.error(f"Failed to save assessment: {e}")
    
    def get_latest_assessment(self, farmer_id: str) -> Optional[Dict]:
        """Get the most recent assessment for a farmer"""
        try:
            assessment = self.stress_collection.find_one(
                {"farmer_id": farmer_id},
                sort=[("date", -1)]
            )
            return assessment
        except Exception as e:
            logger.error(f"Failed to get latest assessment: {e}")
            return None
    
    def print_simple_report(self, results: Dict):
        """Print a simple readable report"""
        if not results:
            print("XXX No results to display")
            return
        
        print(f"\n Daily Corn Report - {results['date']}")
        print(f" Growth Stage: {results['growth_stage']}")
        print(f" Overall Condition: {results['overall_stress'].upper()}")
        print("-" * 50)
        
        for param, analysis in results['stress_analysis'].items():
            print(f"{analysis['status']} {param.replace('_', ' ').title()}: {analysis['stress_level'].upper()}")
            print(f"   Value: {analysis['actual_value']}")
            print(f"   Optimal: {analysis['optimal_range'][0]}-{analysis['optimal_range'][1]}")
            if analysis['deviation_percent'] > 0:
                print(f"   Deviation: {analysis['deviation_percent']}%")
            print()

# Global instance for easy access
descriptive_analytics = DescriptiveAnalytics()
