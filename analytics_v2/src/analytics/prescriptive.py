import json
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional, List
import pytz

from database.mongodb_setup import db_manager
from database.data_models import DailyRecommendation
from knowledge.agricultural_guidelines import agricultural_guidelines

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
        
    def generate_multi_field_recommendations(self, descriptive_results: Dict, predictive_results: Dict) -> Optional[Dict]:
        """
        Generate recommendations for all fields in a farm
        
        Args:
            descriptive_results: Output from multi-field descriptive analytics
            predictive_results: Output from predictive analytics
            
        Returns:
            Complete recommendations with priorities for all fields
        """
        try:
            farmer_id = descriptive_results['farmer_id']
            field_analyses = descriptive_results.get('field_analyses', {})
            
            logger.info(f"Generating multi-field recommendations for {farmer_id} with {len(field_analyses)} fields")
            
            all_recommendations = []
            field_recommendations = {}
            
            # Process each field individually
            for field_name, field_analysis in field_analyses.items():
                logger.info(f"Processing recommendations for field: {field_name}")
                
                # Get field-specific data
                field_data = self._get_field_data(farmer_id, field_name)
                
                # Generate recommendations for this field
                field_recs = self._generate_field_recommendations(field_analysis, predictive_results, field_data, field_name)
                
                if field_recs:
                    field_recommendations[field_name] = field_recs
                    all_recommendations.extend(field_recs)
            
            # Prioritize all recommendations across all fields
            prioritized_recommendations = self._prioritize_recommendations(all_recommendations)
            
            # Calculate overall priority score
            priority_score = self._calculate_priority_score(descriptive_results, predictive_results)
            
            results = {
                "farmer_id": farmer_id,
                "field_id": None,  # Multi-field
                "date": descriptive_results['date'],
                "recommendation_date": datetime.combine(datetime.now(pytz.timezone(self.config['system']['timezone'])).date(), datetime.min.time()),
                "total_recommendations": len(prioritized_recommendations),
                "priority_score": priority_score,
                "recommendations": prioritized_recommendations,
                "field_recommendations": field_recommendations,  # Recommendations by field
                "total_fields": descriptive_results.get('total_fields', 0),
                "fields_processed": descriptive_results.get('fields_processed', 0),
                "forecast_period": predictive_results['forecast_period_days'],
                "overall_risk": predictive_results['risk_assessment']['overall_risk_level'],
                "growth_stage": descriptive_results.get('growth_stage', 'VE'),
                "days_since_planting": descriptive_results.get('daysSincePlanting', 0),
                "created_timestamp": datetime.utcnow()
            }
            
            # Save recommendations
            self._save_recommendations(results)
            
            logger.info(f"Generated {len(prioritized_recommendations)} multi-field recommendations with priority {priority_score}")
            return results
            
        except Exception as e:
            logger.error(f"Failed to generate multi-field recommendations: {e}")
            return None

    def _generate_field_recommendations(self, field_analysis: Dict, predictive_results: Dict, field_data: Dict, field_name: str) -> List[Dict]:
        """Generate recommendations for a specific field"""
        try:
            # Generate immediate actions for this field
            immediate_actions = self._generate_immediate_actions(field_analysis, field_data)
            
            # Generate preventive actions for this field
            preventive_actions = self._generate_preventive_actions(field_analysis, predictive_results, field_data)
            
            # Generate growth preparations for this field
            growth_preparations = self._generate_growth_preparations(field_analysis, predictive_results, field_data)
            
            # Combine all recommendations for this field
            field_recommendations = immediate_actions + preventive_actions + growth_preparations
            
            # Add field information to each recommendation
            for rec in field_recommendations:
                rec['field_id'] = field_name
                rec['field_name'] = field_name  # Use the actual field name, not field_data
            
            logger.info(f"Generated {len(field_recommendations)} recommendations for field {field_name}")
            return field_recommendations
            
        except Exception as e:
            logger.error(f"Failed to generate recommendations for field {field_name}: {e}")
            return []
        
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
            
            # Step 1: Check for recent prescriptions to avoid duplicates
            recent_prescriptions = self._get_recent_prescriptions(farmer_id, field_id)
            
            # Step 2: Analyze current stress conditions
            immediate_actions = self._generate_immediate_actions(descriptive_results, field_data)
            logger.info(f"Generated {len(immediate_actions)} immediate actions")
            
            # Filter out recent prescriptions to avoid duplicates
            immediate_actions = self._filter_recent_prescriptions(immediate_actions, recent_prescriptions)
            logger.info(f"After filtering recent prescriptions: {len(immediate_actions)} immediate actions")
            
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
            
            # Generate crop condition based on stress analysis
            crop_condition = self._generate_crop_condition(descriptive_results, prioritized_recommendations)
            
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
                "crop_condition": crop_condition,
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
                    # Check both _id and fieldName for field_id matching
                    if (str(field.get('_id', '')) == field_id or 
                        str(field.get('fieldName', '')) == field_id):
                        logger.info(f"Found field: {field.get('fieldName', 'Unknown Field')} (ID: {field.get('_id', 'unknown')})")
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
        """Generate immediate actions for current stress conditions with detailed instructions"""
        actions = []
        stress_analysis = descriptive_results.get('stress_analysis', {})
        growth_stage = field_data.get('growth_stage', 'VE') if field_data else descriptive_results.get('growth_stage', 'VE')
        soil_type = field_data.get('soil_type', 'loam') if field_data else 'loam'
        field_name = field_data.get('field_name', 'Unknown Field') if field_data else 'Unknown Field'
        
        logger.info(f"Generating immediate actions for field '{field_name}' (stage: {growth_stage}, soil: {soil_type})")
        logger.info(f"Stress analysis available: {len(stress_analysis)} factors")
        
        # Get agricultural guidelines for this growth stage
        stage_guidelines = agricultural_guidelines.get_growth_stage_guidelines(growth_stage)
        
        # Define stress thresholds - only generate prescriptions for significant stress
        STRESS_THRESHOLDS = {
            'temperature': {'min_severity': 'high', 'min_deviation': 5.0},  # Only if high+ stress or >5°C deviation
            'humidity': {'min_severity': 'high', 'min_deviation': 15.0},    # Only if high+ stress or >15% deviation
            'soil_moisture': {'min_severity': 'high', 'min_deviation': 20.0}, # Only if high+ stress or >20% deviation
            'soil_ph': {'min_severity': 'moderate', 'min_deviation': 1.0},   # pH is more critical
            'light_intensity': {'min_severity': 'high', 'min_deviation': 10000.0} # Only for significant light issues
        }
        
        def _should_generate_prescription(parameter: str, stress_data: Dict) -> bool:
            """Check if prescription should be generated based on severity and deviation thresholds"""
            stress_level = stress_data.get('stress_level', 'low')
            actual_value = stress_data.get('actual_value', 0)
            optimal_range = stress_data.get('optimal_range', [0, 100])
            
            # Check severity threshold
            severity_order = ['low', 'moderate', 'high', 'severe']
            min_severity = STRESS_THRESHOLDS.get(parameter, {}).get('min_severity', 'high')
            min_severity_index = severity_order.index(min_severity)
            current_severity_index = severity_order.index(stress_level) if stress_level in severity_order else 0
            
            if current_severity_index >= min_severity_index:
                return True
            
            # Check deviation threshold
            min_deviation = STRESS_THRESHOLDS.get(parameter, {}).get('min_deviation', 10.0)
            optimal_mid = (optimal_range[0] + optimal_range[1]) / 2
            deviation = abs(actual_value - optimal_mid)
            
            return deviation >= min_deviation
        
        def _get_recent_prescriptions(self, farmer_id: str, field_id: str = None) -> List[Dict]:
            """Get prescriptions from the last 24 hours to avoid duplicates"""
            try:
                from datetime import datetime, timedelta
                from bson import ObjectId
                
                # Convert farmer_id to ObjectId if it's a string
                if isinstance(farmer_id, str):
                    farmer_object_id = ObjectId(farmer_id)
                else:
                    farmer_object_id = farmer_id
                
                # Get prescriptions from last 24 hours
                cutoff_time = datetime.utcnow() - timedelta(hours=24)
                
                query = {
                    "farmer_id": farmer_object_id,
                    "created_timestamp": {"$gte": cutoff_time}
                }
                
                if field_id:
                    query["field_id"] = field_id
                
                recent_prescriptions = list(self.recommendations_collection.find(query))
                logger.info(f"Found {len(recent_prescriptions)} recent prescriptions for farmer {farmer_id}")
                return recent_prescriptions
                
            except Exception as e:
                logger.warning(f"Could not fetch recent prescriptions: {e}")
                return []
        
        def _filter_recent_prescriptions(self, new_actions: List[Dict], recent_prescriptions: List[Dict]) -> List[Dict]:
            """Filter out actions that are similar to recent prescriptions"""
            if not recent_prescriptions:
                return new_actions
            
            filtered_actions = []
            recent_actions = [p.get('action', '') for p in recent_prescriptions]
            
            for action in new_actions:
                action_name = action.get('action', '')
                action_category = action.get('category', '')
                
                # Check if similar action exists in recent prescriptions
                is_duplicate = False
                for recent_action in recent_actions:
                    if (action_name.lower() in recent_action.lower() or 
                        recent_action.lower() in action_name.lower() or
                        action_category in recent_action.lower()):
                        is_duplicate = True
                        break
                
                if not is_duplicate:
                    filtered_actions.append(action)
                else:
                    logger.info(f"Filtered out duplicate prescription: {action_name}")
            
            return filtered_actions
        
        # Use comprehensive stress analysis from descriptive analytics
        if stress_analysis:
            logger.info("Using comprehensive stress analysis for recommendations")
            
            # Temperature stress actions
            if 'Temperature' in stress_analysis:
                temp_stress = stress_analysis['Temperature']
                if _should_generate_prescription('temperature', temp_stress):
                    if temp_stress['status'] == 'HIGH':
                        # Get detailed temperature management guidelines
                        temp_guidelines = stage_guidelines.get('critical_requirements', {}).get('soil_temperature', {})
                        optimal_range = temp_guidelines.get('optimal', [20, 30])
                        max_temp = temp_guidelines.get('max', 35)
                        
                        actions.append({
                            "type": "immediate",
                            "category": "temperature_management",
                            "priority": 2 if temp_stress['stress_level'] == 'high' else 1,
                            "action": "Manage high temperature stress",
                            "details": f"Field '{field_name}': Temperature at {temp_stress['actual_value']}°C, above optimal {optimal_range[1]}°C for {growth_stage} stage",
                            "instructions": [
                                "1. Increase irrigation frequency to 2-3 times daily",
                                "2. Apply mulch around plants to reduce soil temperature",
                                "3. Consider temporary shade structures if temperature exceeds 35°C",
                                "4. Monitor soil moisture closely - high temperatures increase water demand",
                                "5. Avoid fertilizer application during peak heat hours (10 AM - 3 PM)",
                                "6. Check for heat stress symptoms: wilting, leaf curling, stunted growth"
                            ],
                            "timeline": "Today",
                            "parameter": "temperature",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Temperature Management"
                        })
                    else:
                        actions.append({
                            "type": "immediate",
                            "category": "temperature_management",
                            "priority": 3,
                            "action": "Protect from cold stress",
                            "details": f"Field '{field_name}': Temperature at {temp_stress['actual_value']}°C, below optimal {temp_stress['optimal_range'][0]}°C for {growth_stage} stage",
                            "instructions": [
                                "1. Reduce irrigation frequency to prevent waterlogging",
                                "2. Apply organic mulch to insulate soil",
                                "3. Consider row covers or plastic tunnels for protection",
                                "4. Monitor for cold stress symptoms: purple leaves, stunted growth",
                                "5. Avoid planting or transplanting during cold periods",
                                "6. Ensure proper drainage to prevent root damage"
                            ],
                            "timeline": "Today",
                            "parameter": "temperature",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Cold Stress Management"
                        })
            
            # Humidity stress actions
            if 'Humidity' in stress_analysis:
                humidity_stress = stress_analysis['Humidity']
                if _should_generate_prescription('humidity', humidity_stress):
                    if humidity_stress['status'] == 'LOW':
                        actions.append({
                            "type": "immediate",
                            "category": "humidity_management",
                            "priority": 2 if humidity_stress['stress_level'] == 'high' else 3,
                            "action": "Increase humidity for optimal plant growth",
                            "details": f"Field '{field_name}': Humidity at {humidity_stress['actual_value']}%, below optimal {humidity_stress['optimal_range'][0]}% for {growth_stage} stage",
                            "instructions": [
                                "1. Increase irrigation frequency to maintain soil moisture",
                                "2. Apply mulch to reduce soil evaporation",
                                "3. Consider overhead irrigation during early morning hours",
                                "4. Monitor for drought stress symptoms: wilting, leaf rolling",
                                "5. Check soil moisture at 15-20 cm depth",
                                "6. Avoid irrigation during peak heat hours to prevent rapid evaporation"
                            ],
                            "timeline": "Today",
                            "parameter": "humidity",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Humidity Management"
                        })
                    else:
                        actions.append({
                            "type": "immediate",
                            "category": "humidity_management",
                            "priority": 2,
                            "action": "Reduce humidity to prevent disease",
                            "details": f"Field '{field_name}': Humidity at {humidity_stress['actual_value']}%, above optimal {humidity_stress['optimal_range'][1]}% for {growth_stage} stage",
                            "instructions": [
                                "1. Improve field drainage to reduce standing water",
                                "2. Increase plant spacing for better air circulation",
                                "3. Apply fungicide preventively if disease pressure is high",
                                "4. Monitor for fungal diseases: downy mildew, rust, leaf blight",
                                "5. Avoid overhead irrigation during high humidity periods",
                                "6. Remove infected plant debris to prevent disease spread"
                            ],
                            "timeline": "Today",
                            "parameter": "humidity",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Disease Prevention"
                        })
            
            # Soil moisture stress actions
            if 'Soil Moisture' in stress_analysis:
                moisture_stress = stress_analysis['Soil Moisture']
                if _should_generate_prescription('soil_moisture', moisture_stress):
                    if moisture_stress['status'] == 'LOW':
                        # Get irrigation guidelines for this growth stage
                        irrigation_guidelines = agricultural_guidelines.get_irrigation_guidelines(growth_stage)
                        stage_irrigation = irrigation_guidelines.get('stage_specific', {})
                        soil_moisture_optimal = stage_irrigation.get('soil_moisture', {}).get('optimal', [70, 85])
                        
                        actions.append({
                            "type": "immediate",
                            "category": "irrigation",
                            "priority": 1 if moisture_stress['stress_level'] == 'high' else 2,
                            "action": "URGENT: Irrigate immediately" if moisture_stress['stress_level'] == 'high' else "Increase irrigation frequency",
                            "details": f"Field '{field_name}': Soil moisture at {moisture_stress['actual_value']}%, below optimal {soil_moisture_optimal[0]}% for {soil_type} soil in {growth_stage} stage",
                            "instructions": self._get_soil_specific_irrigation_instructions(soil_type, growth_stage, moisture_stress['actual_value']),
                            "timeline": "Today",
                            "parameter": "soil_moisture",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Irrigation Management"
                        })
            else:
                        actions.append({
                            "type": "immediate",
                            "category": "drainage",
                            "priority": 2,
                            "action": "Improve drainage to prevent waterlogging",
                            "details": f"Field '{field_name}': Soil moisture at {moisture_stress['actual_value']}%, above optimal {moisture_stress['optimal_range'][1]}% for {soil_type} soil in {growth_stage} stage",
                            "instructions": self._get_soil_specific_drainage_instructions(soil_type, growth_stage, moisture_stress['actual_value']),
                            "timeline": "Today",
                            "parameter": "soil_moisture",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Drainage Management"
                        })
            
            # Soil pH stress actions
            if 'Soil pH' in stress_analysis:
                ph_stress = stress_analysis['Soil pH']
                if ph_stress['stress_level'] in ['severe', 'moderate', 'high', 'medium']:
                    if ph_stress['status'] == 'LOW':
                        lime_amount = self._calculate_lime_requirement(ph_stress['actual_value'], soil_type)
                        # Get soil management guidelines
                        soil_guidelines = agricultural_guidelines.get_soil_management_guidelines(soil_type)
                        ph_management = agricultural_guidelines.guidelines["soil_management"]["ph_management"]
                        
                        actions.append({
                            "type": "immediate",
                            "category": "soil_treatment",
                            "priority": 2,
                            "action": "Apply lime to increase soil pH",
                            "details": f"Field '{field_name}': Soil pH at {ph_stress['actual_value']}, below optimal {ph_stress['optimal_range'][0]}. Apply {lime_amount} mt/ha lime for {soil_type} soil in {growth_stage} stage",
                            "instructions": [
                                f"1. Apply {lime_amount} metric tons per hectare of agricultural lime",
                                "2. Broadcast lime evenly across the field using spreader",
                                "3. Incorporate lime into soil to 15-20 cm depth using disc harrow",
                                "4. Apply 3-6 months before next planting season for best results",
                                "5. Water the field lightly after application to activate lime",
                                "6. Monitor pH changes - retest soil after 3 months",
                                "7. For immediate effect, use quicklime but handle with care",
                                "8. Consider split application: 50% now, 50% in 3 months"
                            ],
                            "timeline": "This week - Plan for next season",
                            "parameter": "soil_ph",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Soil pH Management"
                        })
                    else:
                        # Get sulfur application guidelines
                        sulfur_guidelines = agricultural_guidelines.guidelines["soil_management"]["ph_management"]["sulfur_application"]
                        
                        actions.append({
                            "type": "immediate",
                            "category": "soil_treatment",
                            "priority": 2,
                            "action": "Apply sulfur to decrease soil pH",
                            "details": f"Field '{field_name}': Soil pH at {ph_stress['actual_value']}, above optimal {ph_stress['optimal_range'][1]}. Apply sulfur for {soil_type} soil in {growth_stage} stage",
                            "instructions": [
                                "1. Apply elemental sulfur at 1-3 tons per hectare based on soil type",
                                "2. For sandy soil: Use 1-2 tons/ha sulfur",
                                "3. For loam soil: Use 2-3 tons/ha sulfur", 
                                "4. For clay soil: Use 3-4 tons/ha sulfur",
                                "5. Broadcast sulfur evenly and incorporate to 15-20 cm depth",
                                "6. Apply 2-3 months before planting for best results",
                                "7. Water field after application to activate sulfur",
                                "8. Monitor pH changes - retest soil after 2 months"
                            ],
                            "timeline": "This week - Plan for next season",
                            "parameter": "soil_ph",
                            "field_id": field_data.get('field_id') if field_data else None,
                            "field_name": field_name,
                            "soil_type": soil_type,
                            "growth_stage": growth_stage,
                            "reference": "DA Philippines Corn Production Guide - Soil pH Management"
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
            
            # Growth stage specific recommendations with detailed management practices
            stage_management = stage_guidelines.get('management_practices', [])
            fertilizer_req = stage_guidelines.get('fertilizer_requirements', {})
            pest_management = agricultural_guidelines.get_pest_management_plan(growth_stage)
            disease_prevention = agricultural_guidelines.get_disease_prevention_plan(growth_stage)
            
            if growth_stage == 'VE':
                actions.append({
                    "type": "preventive",
                    "category": "growth_management",
                    "priority": 3,
                    "action": "Ensure proper emergence and early growth",
                    "details": f"Field '{field_name}': Critical emergence stage - check seed depth and soil conditions for {soil_type} soil",
                    "instructions": [
                        "1. Verify seed depth: 2-3 cm for heavy soils, 3-4 cm for light soils",
                        "2. Check for soil crusting that may prevent emergence",
                        "3. Maintain consistent soil moisture - avoid waterlogging",
                        "4. Protect from birds and rodents using netting or scare devices",
                        "5. Monitor emergence rate - should be 80-90% within 7 days",
                        "6. Apply pre-emergence herbicide if needed for weed control",
                        "7. Check for cutworm damage and apply insecticide if necessary"
                    ],
                    "timeline": "This week - Critical for establishment",
                    "parameter": "growth_stage",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage,
                    "reference": "DA Philippines Corn Production Guide - Emergence Stage"
                })
            elif growth_stage in ['V2', 'V3', 'V4']:
                actions.append({
                    "type": "preventive",
                    "category": "growth_management",
                    "priority": 3,
                    "action": "Early vegetative growth management",
                    "details": f"Field '{field_name}': Critical growth stage - apply side-dressing and manage weeds for {soil_type} soil in {growth_stage} stage",
                    "instructions": [
                        "1. Begin side-dressing with nitrogen fertilizer (Urea 46-0-0 at 1-2 bags/ha)",
                        "2. Apply fertilizer 10-15 cm from plant base using side-dress applicator",
                        "3. Thin plants to recommended spacing (20-25 cm between plants)",
                        "4. Control weeds through cultivation or herbicide application",
                        "5. Monitor plant population density - target 60,000-70,000 plants/ha",
                        "6. Check for nutrient deficiencies: yellowing, stunted growth",
                        "7. Monitor for early pest damage: aphids, leafhoppers, cutworms"
                    ],
                    "timeline": "This week - Critical for yield potential",
                    "parameter": "growth_stage",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage,
                    "reference": "DA Philippines Corn Production Guide - Early Vegetative Stage"
                })
            elif growth_stage in ['R1', 'R2', 'R3']:
                actions.append({
                    "type": "preventive",
                    "category": "growth_management",
                    "priority": 1,  # Highest priority for reproductive stage
                    "action": "CRITICAL: Reproductive stage management",
                    "details": f"Field '{field_name}': Most critical period - ensure optimal conditions for pollination and kernel development in {soil_type} soil",
                    "instructions": [
                        "1. CRITICAL: Maintain consistent soil moisture (80-90%) - this is the most important factor",
                        "2. Increase irrigation frequency to every 2-3 days with 30-40 mm water",
                        "3. Monitor pollination success - check for proper silking and pollen shed",
                        "4. Avoid water stress during silking - can reduce yield by 50%",
                        "5. Monitor kernel development and ear formation",
                        "6. Apply final nitrogen application if not done earlier",
                        "7. Monitor for corn earworm and corn borer in ears",
                        "8. Check for lodging and provide support if needed"
                    ],
                    "timeline": "This week - CRITICAL for yield",
                    "parameter": "growth_stage",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage,
                    "reference": "DA Philippines Corn Production Guide - Reproductive Stage"
                })
            
            # Add pest management recommendations
            if pest_management:
                actions.append({
                    "type": "preventive",
                    "category": "pest_management",
                    "priority": 2,
                    "action": f"Pest monitoring and control for {growth_stage} stage",
                    "details": f"Field '{field_name}': Implement integrated pest management practices for {growth_stage} stage",
                    "instructions": pest_management,
                    "timeline": "This week - Regular monitoring",
                    "parameter": "pest_management",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage,
                    "reference": "DA Philippines Corn Production Guide - Integrated Pest Management"
                })
            
            # Add disease prevention recommendations
            if disease_prevention:
                actions.append({
                    "type": "preventive",
                    "category": "disease_prevention",
                    "priority": 2,
                    "action": f"Disease prevention for {growth_stage} stage",
                    "details": f"Field '{field_name}': Implement disease prevention measures for {growth_stage} stage",
                    "instructions": disease_prevention,
                    "timeline": "This week - Preventive measures",
                    "parameter": "disease_prevention",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage,
                    "reference": "DA Philippines Corn Production Guide - Disease Management"
                })
            
            # Add fertilizer recommendations based on growth stage
            if fertilizer_req:
                fertilizer_instructions = []
                if fertilizer_req.get('starter_fertilizer'):
                    fertilizer_instructions.append(f"1. Apply starter fertilizer: {fertilizer_req['starter_fertilizer']}")
                if fertilizer_req.get('application_method'):
                    fertilizer_instructions.append(f"2. Application method: {fertilizer_req['application_method']}")
                if fertilizer_req.get('timing'):
                    fertilizer_instructions.append(f"3. Timing: {fertilizer_req['timing']}")
                
                if fertilizer_instructions:
                    actions.append({
                        "type": "preventive",
                        "category": "fertilization",
                        "priority": 3,
                        "action": f"Fertilizer application for {growth_stage} stage",
                        "details": f"Field '{field_name}': Apply appropriate fertilizers for {growth_stage} stage in {soil_type} soil",
                        "instructions": fertilizer_instructions,
                        "timeline": fertilizer_req.get('timing', 'This week'),
                        "parameter": "fertilization",
                        "field_id": field_data.get('field_id') if field_data else None,
                        "field_name": field_name,
                        "soil_type": soil_type,
                        "growth_stage": growth_stage,
                        "reference": "DA Philippines Corn Production Guide - Fertilizer Management"
                })
            
            # Default recommendations if no specific issues
            if not actions:
                actions.append({
                    "type": "preventive",
                    "category": "general",
                    "priority": 3,
                    "action": "Continue regular monitoring and maintenance",
                    "details": f"Field '{field_name}': All parameters within normal ranges for {growth_stage} stage, maintain current practices for {soil_type} soil",
                    "instructions": [
                        "1. Continue regular field monitoring",
                        "2. Maintain current irrigation schedule",
                        "3. Monitor for pest and disease symptoms",
                        "4. Check soil moisture levels regularly",
                        "5. Prepare for next growth stage requirements",
                        "6. Keep field records updated"
                    ],
                    "timeline": "Ongoing",
                    "parameter": "general",
                    "field_id": field_data.get('field_id') if field_data else None,
                    "field_name": field_name,
                    "soil_type": soil_type,
                    "growth_stage": growth_stage,
                    "reference": "DA Philippines Corn Production Guide - General Management"
                })
        
        else:
            logger.warning("No stress analysis available, using fallback recommendations")
            # Fallback recommendations when no stress analysis is available
            actions.append({
                "type": "preventive",
                "category": "general",
                "priority": 3,
                "action": "Check sensor connectivity and perform manual monitoring",
                "details": f"Field '{field_name}': Unable to fetch comprehensive analysis, verify sensor connections for {growth_stage} stage",
                "instructions": [
                    "1. Check all sensor connections and power supply",
                    "2. Verify data transmission to monitoring system",
                    "3. Perform manual field inspection for plant health",
                    "4. Check soil moisture by hand (should feel moist but not wet)",
                    "5. Look for visual stress symptoms: wilting, yellowing, stunted growth",
                    "6. Monitor weather conditions and adjust irrigation accordingly",
                    "7. Check for pest damage: holes in leaves, chewed stems",
                    "8. Look for disease symptoms: spots, mold, discoloration",
                    "9. Contact technical support if sensors remain offline",
                    "10. Maintain regular field monitoring until sensors are restored"
                ],
                "timeline": "Today",
                "parameter": "general",
                "field_id": field_data.get('field_id') if field_data else None,
                "field_name": field_name,
                "soil_type": soil_type,
                "growth_stage": growth_stage,
                "reference": "DA Philippines Corn Production Guide - Manual Monitoring"
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
    
    def _get_soil_specific_irrigation_instructions(self, soil_type: str, growth_stage: str, current_moisture: float) -> List[str]:
        """Generate soil-specific irrigation instructions based on actual field data"""
        soil_type_lower = soil_type.lower()
        
        # Get irrigation guidelines for the growth stage
        irrigation_guidelines = agricultural_guidelines.get_irrigation_guidelines(growth_stage)
        stage_irrigation = irrigation_guidelines.get('stage_specific', {})
        soil_moisture_optimal = stage_irrigation.get('soil_moisture', {}).get('optimal', [70, 85])
        
        instructions = [
            "1. IMMEDIATE: Apply water using appropriate irrigation method",
            "2. Check soil moisture at 15-20 cm depth after irrigation",
        ]
        
        # Add soil-specific instructions
        if soil_type_lower == 'sandy':
            instructions.extend([
                "3. SANDY SOIL: Irrigate every 2-3 days with 20-25 mm water",
                "4. Use frequent, light applications to prevent water loss",
                "5. Apply mulch (rice straw, corn stalks) to reduce evaporation",
                "6. Monitor for rapid drainage - water may need to be applied more frequently"
            ])
        elif soil_type_lower == 'loam':
            instructions.extend([
                "3. LOAM SOIL: Irrigate every 3-4 days with 25-30 mm water",
                "4. This soil type has good water retention and drainage",
                "5. Apply mulch to maintain consistent soil moisture",
                "6. Monitor plant response - adjust frequency based on growth stage"
            ])
        elif soil_type_lower == 'clay':
            instructions.extend([
                "3. CLAY SOIL: Irrigate every 4-5 days with 30-35 mm water",
                "4. Clay holds water longer - avoid over-irrigation",
                "5. Use slow, deep watering to prevent runoff",
                "6. Monitor for waterlogging - ensure good drainage"
            ])
        elif soil_type_lower == 'silt':
            instructions.extend([
                "3. SILT SOIL: Irrigate every 3-4 days with 25-30 mm water",
                "4. Similar to loam but more prone to compaction",
                "5. Avoid heavy machinery when soil is wet",
                "6. Apply organic matter to improve structure"
            ])
        else:
            # Default instructions for unknown soil types
            instructions.extend([
                f"3. {soil_type.upper()} SOIL: Adjust irrigation based on soil characteristics",
                "4. Monitor soil moisture regularly",
                "5. Apply mulch to conserve moisture",
                "6. Observe plant response and adjust accordingly"
            ])
        
        # Add growth stage specific instructions
        if growth_stage in ['VE', 'V2', 'V3']:
            instructions.extend([
                "7. Early growth stage: Focus on root development",
                "8. Avoid water stress during critical establishment period"
            ])
        elif growth_stage in ['V4', 'V5', 'V6', 'V7', 'V8']:
            instructions.extend([
                "7. Vegetative stage: Maintain consistent moisture for rapid growth",
                "8. Monitor for nutrient uptake efficiency"
            ])
        elif growth_stage in ['VT', 'R1', 'R2', 'R3']:
            instructions.extend([
                "7. Reproductive stage: Critical for yield - maintain optimal moisture",
                "8. Avoid drought stress during pollination and grain fill"
            ])
        
        # Add monitoring instructions
        instructions.extend([
            "9. Monitor plant wilting - if present, increase irrigation frequency",
            "10. Check irrigation system for proper coverage and efficiency",
            f"11. Target soil moisture: {soil_moisture_optimal[0]}-{soil_moisture_optimal[1]}% (currently {current_moisture}%)"
        ])
        
        return instructions
    
    def _get_soil_specific_drainage_instructions(self, soil_type: str, growth_stage: str, current_moisture: float) -> List[str]:
        """Generate soil-specific drainage instructions based on actual field data"""
        soil_type_lower = soil_type.lower()
        
        instructions = [
            "1. IMMEDIATE: Stop irrigation to prevent further waterlogging",
            "2. Check field drainage - ensure ditches are clear and functional",
        ]
        
        # Add soil-specific drainage instructions
        if soil_type_lower == 'clay':
            instructions.extend([
                "3. CLAY SOIL: High water retention - urgent drainage needed",
                "4. Create deeper drainage ditches (30-40 cm depth)",
                "5. Consider subsoiling to break up clay pan",
                "6. Install tile drains if waterlogging is chronic",
                "7. Avoid field traffic - clay compacts easily when wet"
            ])
        elif soil_type_lower == 'silt':
            instructions.extend([
                "3. SILT SOIL: Prone to compaction - improve drainage carefully",
                "4. Create shallow drainage channels (20-30 cm depth)",
                "5. Add organic matter to improve soil structure",
                "6. Avoid heavy machinery when soil is wet",
                "7. Consider cover crops to improve drainage"
            ])
        elif soil_type_lower == 'loam':
            instructions.extend([
                "3. LOAM SOIL: Good drainage potential - clear existing channels",
                "4. Ensure ditches are 20-25 cm deep and clear",
                "5. Check for blockages in drainage system",
                "6. Monitor soil moisture levels regularly",
                "7. Apply mulch to prevent surface runoff"
            ])
        elif soil_type_lower == 'sandy':
            instructions.extend([
                "3. SANDY SOIL: Usually drains well - check for unusual waterlogging",
                "4. Verify drainage channels are not blocked",
                "5. Check for high water table or seasonal flooding",
                "6. Consider if irrigation was excessive",
                "7. Monitor for signs of nutrient leaching"
            ])
        else:
            # Default instructions for unknown soil types
            instructions.extend([
                f"3. {soil_type.upper()} SOIL: Assess drainage characteristics",
                "4. Create appropriate drainage channels",
                "5. Monitor soil moisture and plant response",
                "6. Adjust drainage strategy based on soil behavior"
            ])
        
        # Add growth stage specific instructions
        if growth_stage in ['VE', 'V2', 'V3']:
            instructions.extend([
                "8. Early growth: Critical period - prevent root damage",
                "9. Young plants are most vulnerable to waterlogging"
            ])
        elif growth_stage in ['V4', 'V5', 'V6', 'V7', 'V8']:
            instructions.extend([
                "8. Vegetative stage: Monitor for nutrient uptake issues",
                "9. Waterlogged roots cannot absorb nutrients effectively"
            ])
        elif growth_stage in ['VT', 'R1', 'R2', 'R3']:
            instructions.extend([
                "8. Reproductive stage: Critical for yield - prevent stress",
                "9. Waterlogging during pollination can severely reduce yield"
            ])
        
        # Add monitoring instructions
        instructions.extend([
            "10. Monitor for root rot symptoms: yellowing leaves, stunted growth",
            "11. Apply fungicide if root rot is suspected",
            "12. Monitor plant health closely for recovery",
            f"13. Current moisture: {current_moisture}% - target below 80%"
        ])
        
        return instructions
    
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
    
    def _generate_crop_condition(self, descriptive_results: Dict, recommendations: List[Dict]) -> Dict:
        """Generate crop condition status based on stress analysis and recommendations"""
        try:
            stress_analysis = descriptive_results.get('stress_analysis', {})
            overall_stress = descriptive_results.get('overall_stress', 'low')
            
            # Count urgent and high priority recommendations
            urgent_count = sum(1 for rec in recommendations if rec.get('urgency') == 'URGENT')
            high_count = sum(1 for rec in recommendations if rec.get('urgency') == 'HIGH')
            
            # Determine crop condition status
            if urgent_count > 0 or overall_stress == 'severe':
                status = 'Critical'
                message = 'Crop requires immediate attention'
                color = '#F44336'  # Red
                icon = 'critical'
            elif high_count > 0 or overall_stress == 'high':
                status = 'Warning'
                message = 'Crop needs attention'
                color = '#FF9800'  # Orange
                icon = 'warning'
            elif overall_stress == 'moderate':
                status = 'Moderate'
                message = 'Crop is growing with some stress'
                color = '#FFC107'  # Amber
                icon = 'moderate'
            elif overall_stress == 'low':
                status = 'Healthy'
                message = 'Crop is growing well'
                color = '#4CAF50'  # Green
                icon = 'good'
            else:
                status = 'Normal'
                message = 'Crop is in normal condition'
                color = '#2196F3'  # Blue
                icon = 'normal'
            
            return {
                "status": status,
                "message": message,
                "color": color,
                "icon": icon,
                "stress_level": overall_stress,
                "urgent_actions": urgent_count,
                "high_priority_actions": high_count
            }
            
        except Exception as e:
            logger.error(f"Failed to generate crop condition: {e}")
            return {
                "status": "Unknown",
                "message": "Unable to determine crop condition",
                "color": "#9E9E9E",
                "icon": "unknown",
                "stress_level": "unknown",
                "urgent_actions": 0,
                "high_priority_actions": 0
            }
    
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