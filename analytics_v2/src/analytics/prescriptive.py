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
        
    def generate_recommendations(self, descriptive_results: Dict, predictive_results: Dict) -> Optional[Dict]:
        """
        Main function: Generate daily recommendations
        
        Args:
            descriptive_results: Output from descriptive analytics
            predictive_results: Output from predictive analytics
            
        Returns:
            Complete recommendations with priorities
        """
        try:
            farmer_id = descriptive_results['farmer_id']
            
            logger.info(f"Generating recommendations for {farmer_id}")
            
            # Step 1: Analyze current stress conditions
            immediate_actions = self._generate_immediate_actions(descriptive_results)
            
            # Step 2: Generate preventive measures based on predictions
            preventive_actions = self._generate_preventive_actions(
                descriptive_results, predictive_results
            )
            
            # Step 3: Generate growth stage preparations
            growth_preparations = self._generate_growth_preparations(
                descriptive_results, predictive_results
            )
            
            # Step 4: Prioritize all recommendations
            all_recommendations = immediate_actions + preventive_actions + growth_preparations
            prioritized_recommendations = self._prioritize_recommendations(all_recommendations)
            
            # Step 5: Calculate priority score
            priority_score = self._calculate_priority_score(descriptive_results, predictive_results)
            
            results = {
                "farmer_id": farmer_id,
                "date": descriptive_results['date'],
                "recommendation_date": datetime.combine(datetime.now(pytz.timezone(self.config['system']['timezone'])).date(), datetime.min.time()),
                "total_recommendations": len(prioritized_recommendations),
                "priority_score": priority_score,
                "recommendations": prioritized_recommendations,
                "forecast_period": predictive_results['forecast_period_days'],
                "overall_risk": predictive_results['risk_assessment']['overall_risk_level'],
                "created_timestamp": datetime.utcnow()
            }

            #  target_date = datetime.combine(target_date, datetime.min.time())
            
            # Step 6: Save recommendations
            self._save_recommendations(results)
            
            logger.info(f"Generated {len(prioritized_recommendations)} recommendations with priority {priority_score}")
            return results
            
        except Exception as e:
            logger.error(f"Failed to generate recommendations: {e}")
            return None
    
    # def _generate_immediate_actions(self, descriptive_results: Dict) -> List[Dict]:
    #     """Generate immediate actions for current stress conditions"""
    #     actions = []
    #     stress_analysis = descriptive_results['stress_analysis']
    #     growth_stage = descriptive_results['growth_stage']
        
    #     # Soil moisture actions
    #     if 'soil_moisture' in stress_analysis:
    #         moisture_stress = stress_analysis['soil_moisture']
    #         if moisture_stress['stress_level'] in ['severe', 'moderate']:
    #             actions.append({
    #                 "type": "immediate",
    #                 "category": "irrigation",
    #                 "priority": 1 if moisture_stress['stress_level'] == 'severe' else 2,
    #                 "action": "Irrigate immediately",
    #                 "details": f"Soil moisture at {moisture_stress['actual_value']}%, needs {moisture_stress['optimal_range'][0]}-{moisture_stress['optimal_range'][1]}%",
    #                 "timeline": "Today",
    #                 "parameter": "soil_moisture"
    #             })
    #         elif moisture_stress['stress_level'] == 'mild':
    #             actions.append({
    #                 "type": "immediate",
    #                 "category": "irrigation",
    #                 "priority": 3,
    #                 "action": "Monitor soil moisture closely",
    #                 "details": "Prepare irrigation system for use",
    #                 "timeline": "Today",
    #                 "parameter": "soil_moisture"
    #             })
        
    #     # Soil pH actions
    #     if 'soil_ph' in stress_analysis:
    #         ph_stress = stress_analysis['soil_ph']
    #         if ph_stress['stress_level'] in ['severe', 'moderate']:
    #             lime_amount = self._calculate_lime_requirement(
    #                 ph_stress['actual_value'], 
    #                 descriptive_results.get('soil_type', 'loam')
    #             )
    #             actions.append({
    #                 "type": "immediate",
    #                 "category": "soil_treatment",
    #                 "priority": 2,
    #                 "action": f"Apply lime: {lime_amount} mt/ha",
    #                 "details": f"Current pH {ph_stress['actual_value']}, target {ph_stress['optimal_range'][0]}-{ph_stress['optimal_range'][1]}",
    #                 "timeline": "This week",
    #                 "parameter": "soil_ph"
    #             })
        
    #     # Temperature stress actions
    #     if 'temperature' in stress_analysis:
    #         temp_stress = stress_analysis['temperature']
    #         if temp_stress['stress_level'] in ['severe', 'moderate']:
    #             if temp_stress['actual_value'] > temp_stress['optimal_range'][1]:
    #                 actions.append({
    #                     "type": "immediate",
    #                     "category": "temperature_management",
    #                     "priority": 2,
    #                     "action": "Provide shade or increase irrigation frequency",
    #                     "details": f"Temperature at {temp_stress['actual_value']}°C, above optimal {temp_stress['optimal_range'][1]}°C",
    #                     "timeline": "Today",
    #                     "parameter": "temperature"
    #                 })
    #             else:
    #                 actions.append({
    #                     "type": "immediate",
    #                     "category": "temperature_management",
    #                     "priority": 3,
    #                     "action": "Protect from cold",
    #                     "details": f"Temperature at {temp_stress['actual_value']}°C, below optimal {temp_stress['optimal_range'][0]}°C",
    #                     "timeline": "Today",
    #                     "parameter": "temperature"
    #                 })
        
    #     # Light intensity actions
    #     if 'light_intensity' in stress_analysis:
    #         light_stress = stress_analysis['light_intensity']
    #         if light_stress['stress_level'] in ['severe', 'moderate']:
    #             if light_stress['actual_value'] < light_stress['optimal_range'][0]:
    #                 actions.append({
    #                     "type": "immediate",
    #                     "category": "light_management",
    #                     "priority": 3,
    #                     "action": "Adjust plant spacing for better light penetration",
    #                     "details": f"Light intensity at {light_stress['actual_value']} lux, below optimal {light_stress['optimal_range'][0]} lux",
    #                     "timeline": "This week",
    #                     "parameter": "light_intensity"
    #                 })
        
    #     return actions

    def _generate_immediate_actions(self, descriptive_results: Dict) -> List[Dict]:
        """Generate immediate actions using condition-based recommendation mapping"""
        actions = []
        stress_analysis = descriptive_results['stress_analysis']
        soil_type = descriptive_results.get('soil_type', 'loam')

        def generate_parameter_recommendation(param, condition):
            """Map param+condition to actionable recommendation"""
            recommendations = {
                'temperature': {
                    'low': "Increase temperature: Use greenhouse heating or row covers.",
                    'high': "Reduce temperature: Apply shade cloth and misting.",
                    'critically_low': "URGENT: Increase temperature immediately using heating or row covers.",
                    'critically_high': "URGENT: Reduce temperature immediately using shade cloth and misting."
                },
                'humidity': {
                    'low': "Increase humidity: Apply regular misting or adjust irrigation schedule.",
                    'high': "Reduce humidity: Improve ventilation to prevent disease conditions.",
                    'critically_low': "URGENT: Increase humidity immediately through misting and reduced ventilation.",
                    'critically_high': "URGENT: Reduce humidity immediately by improving ventilation."
                },
                'soil_moisture': {
                    'low': "Increase soil moisture: Begin evening irrigation or use drip irrigation.",
                    'high': "Reduce soil moisture: Improve drainage and reduce irrigation frequency.",
                    'critically_low': "URGENT: Increase soil moisture immediately through irrigation.",
                    'critically_high': "URGENT: Reduce soil moisture immediately by improving drainage."
                },
                'soil_ph': {
                    'low': f"Increase pH: Apply lime or biofertilizer. Recommended: {self._calculate_lime_requirement(stress['actual_value'], soil_type)} mt/ha lime.",
                    'high': "Reduce pH: Apply sulfur or acidifying amendments for better nutrient uptake.",
                    'critically_low': f"URGENT: Increase pH immediately using lime application. Recommended: {self._calculate_lime_requirement(stress['actual_value'], soil_type)} mt/ha lime.",
                    'critically_high': "URGENT: Reduce pH immediately using sulfur application."
                },
                'light_intensity': {
                    'low': "Increase light: Supplement with grow lights for optimal growth.",
                    'high': "Reduce light: Provide partial shade during peak hours.",
                    'critically_low': "URGENT: Increase light immediately using supplemental lighting.",
                    'critically_high': "URGENT: Reduce light exposure immediately using shade cloth."
                }
            }
            return recommendations.get(param, {}).get(condition, None)

        # Loop through stress params
        for param, stress in stress_analysis.items():
            value, optimal = stress['actual_value'], stress['optimal_range']
            low, high = optimal[0], optimal[1]

            # Decide condition
            if value < low:
                condition = 'critically_low' if value < (low - (0.1 * low)) else 'low'
            elif value > high:
                condition = 'critically_high' if value > (high + (0.1 * high)) else 'high'
            else:
                condition = None  # inside optimal, skip

            if condition:
                rec_text = generate_parameter_recommendation(param, condition)
                if rec_text:
                    urgency = "URGENT" if "URGENT" in rec_text else ("HIGH" if "Reduce" in rec_text or "Increase" in rec_text else "MEDIUM")
                    priority = 1 if "URGENT" in rec_text else (2 if urgency == "HIGH" else 3)

                    actions.append({
                        "type": "immediate",
                        "category": param,
                        "priority": priority,
                        "urgency": urgency,
                        "action": rec_text.split(":")[0],   # Short action title
                        "details": rec_text,
                        "timeline": "Today" if urgency == "URGENT" else ("Next 1-2 days" if urgency == "HIGH" else "This week"),
                        "parameter": param
                    })

        return actions

    
    def _generate_preventive_actions(self, descriptive_results: Dict, predictive_results: Dict) -> List[Dict]:
        """Generate preventive actions based on predictions"""
        actions = []
        risk_assessment = predictive_results['risk_assessment']
        weather_forecast = predictive_results['weather_forecast']
        
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
    
    def _generate_growth_preparations(self, descriptive_results: Dict, predictive_results: Dict) -> List[Dict]:
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