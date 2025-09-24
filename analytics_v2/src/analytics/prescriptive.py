import json
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional, List
import pytz

from database.mongodb_setup import db_manager
from database.data_models import DailyRecommendation

logger = logging.getLogger('corn_system')

class PrescriptiveAnalytics:
    """Simple prescriptive analytics - actionable recommendations"""
    
    def __init__(self):
        """Initialize prescriptive analytics"""
        with open('config/settings.json', 'r') as f:
            self.config = json.load(f)
        
        with open('config/growth_matrix.json', 'r') as f:
            self.growth_matrix = json.load(f)
        
        self.recommendations_collection = db_manager.get_collection('daily_recommendations')
        
    def generate_recommendations(self, descriptive_results: Dict, predictive_results: Dict, field_id: str = None) -> Optional[Dict]:
        """
        Main function: Generate daily recommendations
        
        Args:
            descriptive_results: Output from descriptive analytics
            predictive_results: Output from predictive analytics
            field_id: Specific field ID for field-specific recommendations
            
        Returns:
            Complete recommendations with priorities
        """
        try:
            farmer_id = descriptive_results['farmer_id']
            field_info = f" for field {field_id}" if field_id else ""
            
            logger.info(f"Generating recommendations for {farmer_id}{field_info}")
            
            # Get field-specific data
            field_data = self._get_field_data(farmer_id, field_id)
            
            # Step 1: Analyze current stress conditions
            immediate_actions = self._generate_immediate_actions(descriptive_results, field_data)
            logger.info(f"Generated {len(immediate_actions)} immediate actions")
            
            # Step 2: Generate preventive measures based on predictions
            preventive_actions = self._generate_preventive_actions(
                descriptive_results, predictive_results, field_data
            )
            logger.info(f"Generated {len(preventive_actions)} preventive actions")
            
            # Step 3: Generate growth stage preparations
            growth_preparations = self._generate_growth_preparations(
                descriptive_results, predictive_results, field_data
            )
            logger.info(f"Generated {len(growth_preparations)} growth preparations")
            
            # Step 4: Prioritize all recommendations
            all_recommendations = immediate_actions + preventive_actions + growth_preparations
            prioritized_recommendations = self._prioritize_recommendations(all_recommendations)
            
            # Step 5: Calculate priority score
            priority_score = self._calculate_priority_score(descriptive_results, predictive_results)
            
            results = {
                "farmer_id": farmer_id,
                "field_id": field_id,
                "date": descriptive_results['date'],
                "recommendation_date": datetime.combine(datetime.now(pytz.timezone(self.config['system']['timezone'])).date(), datetime.min.time()),
                "total_recommendations": len(prioritized_recommendations),
                "priority_score": priority_score,
                "recommendations": prioritized_recommendations,
                "forecast_period": predictive_results['forecast_period_days'],
                "overall_risk": predictive_results['risk_assessment']['overall_risk_level'],
                "field_info": field_data,
                "growth_stage": field_data.get('growth_stage', descriptive_results.get('growth_stage', 'VE')),
                "days_since_planting": descriptive_results.get('daysSincePlanting', 0),
                "created_timestamp": datetime.utcnow()
            }
            
            # Step 6: Save recommendations
            self._save_recommendations(results)
            
            logger.info(f"Generated {len(prioritized_recommendations)} recommendations with priority {priority_score}")
            return results
            
        except Exception as e:
            logger.error(f"Failed to generate recommendations: {e}")
            return None
    
    def _get_field_data(self, farmer_id: str, field_id: str = None) -> Dict:
        """Get field-specific data including soil type and growth stage"""
        try:
            farms_collection = db_manager.get_collection("farms")
            from bson import ObjectId
            
            # Convert farmer_id to ObjectId if it's a string
            if isinstance(farmer_id, str):
                farmer_object_id = ObjectId(farmer_id)
            else:
                farmer_object_id = farmer_id
                
            farm = farms_collection.find_one({"userId": farmer_object_id})
            
            logger.info(f"Farm found: {farm is not None}")
            if farm:
                logger.info(f"Farm has fields: {'fields' in farm}")
                if 'fields' in farm:
                    logger.info(f"Number of fields: {len(farm['fields'])}")
                    if farm['fields']:
                        logger.info(f"First field: {farm['fields'][0]}")
            
            if not farm or 'fields' not in farm:
                logger.warning("No farm or fields found, using default field data")
                return {
                    "field_id": field_id,
                    "field_name": "Unknown Field",
                    "soil_type": "loam",
                    "growth_stage": "VE",
                    "area": 1.0,
                    "crop_type": "corn"
                }
            
            # If field_id is provided, find specific field
            if field_id:
                for field in farm['fields']:
                    if str(field.get('_id', '')) == field_id:
                        return {
                            "field_id": field_id,
                            "field_name": field.get('fieldName', 'Unknown Field'),
                            "soil_type": field.get('soilType', 'loam'),
                            "growth_stage": field.get('growthStage', 'VE'),
                            "area": field.get('area', 1.0),
                            "crop_type": field.get('cropType', 'corn')
                        }
            
            # If no field_id or field not found, use first field
            if farm['fields']:
                field = farm['fields'][0]
                logger.info(f"Using first field: {field.get('fieldName', 'Unknown Field')} (ID: {field.get('_id', 'unknown')})")
                return {
                    "field_id": str(field.get('_id', 'unknown')),
                    "field_name": field.get('fieldName', 'Unknown Field'),
                    "soil_type": field.get('soilType', 'loam'),
                    "growth_stage": field.get('growthStage', 'VE'),
                    "area": field.get('area', 1.0),
                    "crop_type": field.get('cropType', 'corn')
                }
            
            return {
                "field_id": field_id,
                "field_name": "Unknown Field",
                "soil_type": "loam",
                "growth_stage": "VE",
                "area": 1.0,
                "crop_type": "corn"
            }
        except Exception as e:
            logger.warning(f"Could not fetch field data: {e}")
            return {
                "field_id": field_id,
                "field_name": "Unknown Field",
                "soil_type": "loam",
                "growth_stage": "VE",
                "area": 1.0,
                "crop_type": "corn"
            }

    def _generate_immediate_actions(self, descriptive_results: Dict, field_data: Dict = None) -> List[Dict]:
        """Generate immediate actions for current stress conditions"""
        actions = []
        stress_analysis = descriptive_results.get('stress_analysis', {})
        growth_stage = field_data.get('growth_stage', 'VE') if field_data else descriptive_results.get('growth_stage', 'VE')
        soil_type = field_data.get('soil_type', 'loam') if field_data else 'loam'
        field_name = field_data.get('field_name', 'Unknown Field') if field_data else 'Unknown Field'
        
        logger.info(f"Generating immediate actions for field '{field_name}' (stage: {growth_stage}, soil: {soil_type})")
        logger.info(f"Stress analysis available: {len(stress_analysis)} factors")
        
        # Use comprehensive stress analysis from descriptive analytics
        if stress_analysis:
            logger.info("Using comprehensive stress analysis for recommendations")
            
            # Temperature stress actions
            if 'Temperature' in stress_analysis:
                temp_stress = stress_analysis['Temperature']
                if temp_stress['stress_level'] in ['severe', 'moderate', 'high', 'medium']:
                    if temp_stress['status'] == 'HIGH':
                        actions.append({
                            "type": "immediate",
                            "category": "temperature_management",
                            "priority": 2 if temp_stress['stress_level'] == 'high' else 1,
                            "action": "Provide shade or increase irrigation frequency",
                            "details": f"Field '{field_name}': Temperature at {temp_stress['actual_value']}°C, above optimal {temp_stress['optimal_range'][1]}°C for {growth_stage} stage",
                            "timeline": "Today",
                            "parameter": "temperature",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
                    else:
                        actions.append({
                            "type": "immediate",
                            "category": "temperature_management",
                            "priority": 3,
                            "action": "Protect from cold stress",
                            "details": f"Field '{field_name}': Temperature at {temp_stress['actual_value']}°C, below optimal {temp_stress['optimal_range'][0]}°C for {growth_stage} stage",
                            "timeline": "Today",
                            "parameter": "temperature",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
            
            # Humidity stress actions
            if 'Humidity' in stress_analysis:
                humidity_stress = stress_analysis['Humidity']
                if humidity_stress['stress_level'] in ['severe', 'moderate', 'high', 'medium']:
                    if humidity_stress['status'] == 'LOW':
                        actions.append({
                            "type": "immediate",
                            "category": "humidity_management",
                            "priority": 2 if humidity_stress['stress_level'] == 'high' else 3,
                            "action": "Increase irrigation or use misting",
                            "details": f"Field '{field_name}': Humidity at {humidity_stress['actual_value']}%, below optimal {humidity_stress['optimal_range'][0]}% for {growth_stage} stage",
                            "timeline": "Today",
                            "parameter": "humidity",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
                    else:
                        actions.append({
                            "type": "immediate",
                            "category": "humidity_management",
                            "priority": 2,
                            "action": "Improve ventilation or reduce irrigation",
                            "details": f"Field '{field_name}': Humidity at {humidity_stress['actual_value']}%, above optimal {humidity_stress['optimal_range'][1]}% for {growth_stage} stage",
                            "timeline": "Today",
                            "parameter": "humidity",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
            
            # Soil moisture stress actions
            if 'Soil Moisture' in stress_analysis:
                moisture_stress = stress_analysis['Soil Moisture']
                if moisture_stress['stress_level'] in ['severe', 'moderate', 'high', 'medium']:
                    if moisture_stress['status'] == 'LOW':
                        actions.append({
                            "type": "immediate",
                            "category": "irrigation",
                            "priority": 1 if moisture_stress['stress_level'] == 'high' else 2,
                            "action": "Irrigate immediately" if moisture_stress['stress_level'] == 'high' else "Increase irrigation",
                            "details": f"Field '{field_name}': Soil moisture at {moisture_stress['actual_value']}%, below optimal {moisture_stress['optimal_range'][0]}% for {soil_type} soil in {growth_stage} stage",
                            "timeline": "Today",
                            "parameter": "soil_moisture",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
            else:
                        actions.append({
                            "type": "immediate",
                            "category": "drainage",
                            "priority": 2,
                            "action": "Reduce irrigation and improve drainage",
                            "details": f"Field '{field_name}': Soil moisture at {moisture_stress['actual_value']}%, above optimal {moisture_stress['optimal_range'][1]}% for {soil_type} soil in {growth_stage} stage",
                            "timeline": "Today",
                            "parameter": "soil_moisture",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
            
            # Soil pH stress actions
            if 'Soil pH' in stress_analysis:
                ph_stress = stress_analysis['Soil pH']
                if ph_stress['stress_level'] in ['severe', 'moderate', 'high', 'medium']:
                    if ph_stress['status'] == 'LOW':
                        lime_amount = self._calculate_lime_requirement(ph_stress['actual_value'], soil_type)
                        actions.append({
                            "type": "immediate",
                            "category": "soil_treatment",
                            "priority": 2,
                            "action": "Apply lime to increase pH",
                            "details": f"Field '{field_name}': Soil pH at {ph_stress['actual_value']}, below optimal {ph_stress['optimal_range'][0]}. Apply {lime_amount} mt/ha lime for {soil_type} soil in {growth_stage} stage",
                            "timeline": "This week",
                            "parameter": "soil_ph",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
                    else:
                        actions.append({
                            "type": "immediate",
                            "category": "soil_treatment",
                            "priority": 2,
                            "action": "Apply sulfur to decrease pH",
                            "details": f"Field '{field_name}': Soil pH at {ph_stress['actual_value']}, above optimal {ph_stress['optimal_range'][1]}. Apply sulfur for {soil_type} soil in {growth_stage} stage",
                            "timeline": "This week",
                            "parameter": "soil_ph",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
            
            # Light intensity stress actions
            if 'Light Intensity' in stress_analysis:
                light_stress = stress_analysis['Light Intensity']
                if light_stress['stress_level'] in ['severe', 'moderate', 'high', 'medium']:
                    if light_stress['status'] == 'LOW':
                        actions.append({
                            "type": "immediate",
                            "category": "light_management",
                            "priority": 3,
                            "action": "Adjust plant spacing for better light penetration",
                            "details": f"Field '{field_name}': Light intensity at {light_stress['actual_value']} lux, below optimal {light_stress['optimal_range'][0]} lux for {growth_stage} stage",
                            "timeline": "This week",
                            "parameter": "light_intensity",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage
                        })
            
            # Growth stage specific recommendations
            if growth_stage == 'VE':
                actions.append({
                    "type": "preventive",
                    "category": "growth_management",
                    "priority": 3,
                    "action": "Ensure proper seed depth",
                    "details": f"Field '{field_name}': Check that seeds are planted at correct depth (1-2 inches) for {soil_type} soil",
                    "timeline": "This week",
                    "parameter": "growth_stage",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage
                })
            elif growth_stage in ['V2', 'V3', 'V4']:
                actions.append({
                    "type": "preventive",
                    "category": "growth_management",
                    "priority": 3,
                    "action": "Begin side-dressing with nitrogen",
                    "details": f"Field '{field_name}': Apply nitrogen fertilizer when plants have 3-4 leaves. Recommended for {soil_type} soil in {growth_stage} stage",
                    "timeline": "This week",
                    "parameter": "growth_stage",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage
                })
            elif growth_stage in ['R1', 'R2', 'R3']:
                actions.append({
                    "type": "preventive",
                    "category": "growth_management",
                    "priority": 2,
                    "action": "Critical moisture period - increase irrigation",
                    "details": f"Field '{field_name}': Reproductive stage requires consistent moisture for kernel development in {soil_type} soil",
                    "timeline": "This week",
                    "parameter": "growth_stage",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage
                })
            
            # Default recommendations if no specific issues
            if not actions:
                actions.append({
                    "type": "preventive",
                    "category": "general",
                    "priority": 3,
                    "action": "Continue regular monitoring",
                    "details": f"Field '{field_name}': All parameters within normal ranges for {growth_stage} stage, maintain current practices for {soil_type} soil",
                    "timeline": "Ongoing",
                    "parameter": "general",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage
                })
        
        else:
            logger.warning("No stress analysis available, using fallback recommendations")
            # Fallback recommendations when no stress analysis is available
            actions.append({
                "type": "preventive",
                "category": "general",
                "priority": 3,
                "action": "Check sensor connectivity",
                "details": f"Field '{field_name}': Unable to fetch comprehensive analysis, verify sensor connections for {growth_stage} stage",
                "timeline": "Today",
                "parameter": "general",
                "field_id": field_data.get('field_id') if field_data else None,
                "field_name": field_name,
                "soil_type": soil_type,
                "growth_stage": growth_stage
            })
        
        logger.info(f"Generated {len(actions)} immediate actions")
        return actions

    
    
    def _generate_preventive_actions(self, descriptive_results: Dict, predictive_results: Dict, field_data: Dict = None) -> List[Dict]:
        """Generate preventive actions based on predictions"""
        actions = []
        risk_assessment = predictive_results['risk_assessment']
        weather_forecast = predictive_results['weather_forecast']
        
        logger.info(f"Generating preventive actions - Risk assessment: {risk_assessment}")
        logger.info(f"Weather forecast: {weather_forecast}")
        
        # Drought prevention
        drought_risk = risk_assessment.get('drought_risk', {})
        if drought_risk.get('level') in ['high', 'medium']:
            actions.append({
                "type": "preventive",
                "category": "drought_prevention",
                "priority": 1 if drought_risk['level'] == 'high' else 2,
                "action": "Prepare irrigation system and water storage",
                "details": f"Drought risk: {drought_risk['probability']}%, low rainfall expected",
                "timeline": "Next 2-3 days",
                "parameter": "drought_risk"
            })
        
        # Excess moisture prevention
        moisture_risk = risk_assessment.get('excess_moisture_risk', {})
        rain_prob = weather_forecast.get('rainfall_probability', {}).get('heavy_rain_probability', 0)
        if moisture_risk.get('level') == 'high' or rain_prob > 60:
            actions.append({
                "type": "preventive",
                "category": "drainage",
                "priority": 2,
                "action": "Ensure proper field drainage",
                "details": f"Heavy rain probability: {rain_prob}%, prepare drainage systems",
                "timeline": "Today",
                "parameter": "excess_moisture_risk"
            })
        
        # Temperature stress prevention
        temp_risk = risk_assessment.get('temperature_stress_risk', {})
        max_temp = weather_forecast.get('temperature_forecast', {}).get('max_temp', 30)
        if temp_risk.get('level') == 'high' or max_temp > 35:
            actions.append({
                "type": "preventive",
                "category": "heat_protection",
                "priority": 2,
                "action": "Prepare heat stress mitigation measures",
                "details": f"Expected max temperature: {max_temp}°C, prepare shade or cooling",
                "timeline": "Next 1-2 days",
                "parameter": "temperature_stress_risk"
            })
        
        return actions
    
    def _generate_growth_preparations(self, descriptive_results: Dict, predictive_results: Dict, field_data: Dict = None) -> List[Dict]:
        """Generate growth stage preparation actions"""
        actions = []
        growth_timeline = predictive_results.get('growth_timeline', {})
        
        current_stage = growth_timeline.get('current_stage')
        next_stage = growth_timeline.get('next_stage')
        days_to_next = growth_timeline.get('estimated_days_to_next', 0)
        
        if next_stage and next_stage != "Harvest Complete" and days_to_next <= 14:
            # Prepare for next growth stage
            next_stage_requirements = self._get_stage_requirements(next_stage)
            
            actions.append({
                "type": "preparation",
                "category": "growth_stage",
                "priority": 3,
                "action": f"Prepare for {next_stage} stage",
                "details": f"Expected transition in {days_to_next} days. {next_stage_requirements}",
                "timeline": f"Next {min(days_to_next, 7)} days",
                "parameter": "growth_progression"
            })
        
        # Fertilizer recommendations based on growth stage
        fertilizer_rec = self._get_fertilizer_recommendation(current_stage, descriptive_results['overall_stress'])
        if fertilizer_rec:
            actions.append({
                "type": "preparation",
                "category": "fertilization",
                "priority": 3,
                "action": fertilizer_rec['action'],
                "details": fertilizer_rec['details'],
                "timeline": fertilizer_rec['timeline'],
                "parameter": "fertilization"
            })
        
        return actions
    
    def _calculate_lime_requirement(self, current_ph: float, soil_type: str) -> float:
        """Calculate lime requirement based on pH and soil type"""
        lime_table = self.growth_matrix.get('lime_requirements_by_ph', {})
        
        if current_ph <= 4.4:
            ph_range = "4.0-4.4"
        elif current_ph <= 4.9:
            ph_range = "4.5-4.9"
        elif current_ph <= 5.3:
            ph_range = "5.0-5.3"
        else:
            return 0
        
        soil_key_mapping = {
            'sandy': 'sandy',
            'sandy loam': 'sandy_loam', 
            'loam': 'loam',
            'silt loam': 'silt_clay_loam',
            'clay loam': 'silt_clay_loam',
            'clay': 'clay'
        }
        
        soil_key = soil_key_mapping.get(soil_type.lower(), 'loam')
        return lime_table.get(ph_range, {}).get(soil_key, 2.0)
    
    def _get_stage_requirements(self, stage: str) -> str:
        """Get requirements for upcoming growth stage"""
        stage_info = {
            "V2-V4": "Increase nitrogen application, ensure adequate moisture",
            "V5-VT": "Monitor for pests, maintain consistent moisture",
            "R1-R3": "Critical moisture period, increase irrigation frequency",
            "R4-R5": "Reduce nitrogen, maintain moisture for grain filling",
            "R6": "Prepare for harvest, reduce irrigation gradually"
        }
        return stage_info.get(stage, "Monitor plant development closely")
    
    def _get_fertilizer_recommendation(self, current_stage: str, stress_level: str) -> Optional[Dict]:
        """Get fertilizer recommendations based on growth stage"""
        if stress_level == 'severe':
            return None  # Focus on immediate stress relief first
        
        fertilizer_schedule = {
            "VE": {"action": "Apply starter fertilizer", "details": "NPK 14-14-14 at 2 bags/ha", "timeline": "This week"},
            "V2-V4": {"action": "Side-dress with nitrogen", "details": "Urea 46-0-0 at 1 bag/ha", "timeline": "Next week"},
            "V5-VT": {"action": "Apply complete fertilizer", "details": "NPK 16-16-16 at 2 bags/ha", "timeline": "Next 2 weeks"},
            "R1-R3": {"action": "Final nitrogen application", "details": "Urea 46-0-0 at 0.5 bag/ha", "timeline": "This week"},
        }
        
        return fertilizer_schedule.get(current_stage)
    
    def _prioritize_recommendations(self, recommendations: List[Dict]) -> List[Dict]:
        """Prioritize recommendations by urgency and impact"""
        # Sort by priority (1 = highest priority)
        sorted_recommendations = sorted(recommendations, key=lambda x: (x['priority'], x['type']))
        
        # Add priority labels
        for i, rec in enumerate(sorted_recommendations):
            if rec['priority'] == 1:
                rec['urgency'] = "URGENT"
            elif rec['priority'] == 2:
                rec['urgency'] = "HIGH"
            else:
                rec['urgency'] = "MEDIUM"
        
        return sorted_recommendations
    
    def _calculate_priority_score(self, descriptive_results: Dict, predictive_results: Dict) -> int:
        """Calculate overall priority score for the day"""
        score = 0
        
        # Add points for severe stress
        severe_count = sum(1 for param in descriptive_results['stress_analysis'].values() 
                          if param.get('stress_level') == 'severe')
        score += severe_count * 30
        
        # Add points for moderate stress
        moderate_count = sum(1 for param in descriptive_results['stress_analysis'].values() 
                            if param.get('stress_level') == 'moderate')
        score += moderate_count * 20
        
        # Add points for high risks
        risk_assessment = predictive_results['risk_assessment']
        high_risks = sum(1 for risk in risk_assessment.values() 
                        if isinstance(risk, dict) and risk.get('level') == 'high')
        score += high_risks * 25
        
        # Add points for overall risk level
        overall_risk = risk_assessment.get('overall_risk_level', 'low')
        risk_points = {'low': 5, 'medium': 15, 'high': 25}
        score += risk_points.get(overall_risk, 5)
        
        return min(score, 100)  # Cap at 100
    
    def _save_recommendations(self, results: Dict):
        """Save recommendations to database"""
        try:
            recommendation_doc = DailyRecommendation.create_document(
                farmer_id=results['farmer_id'],
                date=results['recommendation_date'],
                recommendations=results['recommendations'],
                priority_score=results['priority_score']
            )
            
            # Add extra fields
            recommendation_doc.update({
                "total_recommendations": results['total_recommendations'],
                "forecast_period": results['forecast_period'],
                "overall_risk": results['overall_risk']
            })
            
            # Upsert
            self.recommendations_collection.update_one(
                {
                    "farmer_id": results['farmer_id'],
                    "date": results['recommendation_date']
                },
                {"$set": recommendation_doc},
                upsert=True
            )
            
            logger.info("Recommendations saved to database")
            
        except Exception as e:
            logger.error(f"Failed to save recommendations: {e}")

# Global instance
prescriptive_analytics = PrescriptiveAnalytics()