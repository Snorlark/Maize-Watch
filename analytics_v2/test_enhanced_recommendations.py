#!/usr/bin/env python3
"""
Test script for enhanced agricultural recommendations
Demonstrates the comprehensive step-by-step instructions for farmers
"""

import sys
import json
from datetime import datetime

# Add src to path
sys.path.append('src')

from src.analytics.prescriptive import prescriptive_analytics
from src.knowledge.agricultural_guidelines import agricultural_guidelines

def test_enhanced_recommendations():
    """Test the enhanced recommendation system with sample data"""
    
    print("🌽 Enhanced Agricultural Recommendation System Test")
    print("=" * 60)
    print("Based on Department of Agriculture Philippines Guidelines")
    print("=" * 60)
    
    # Sample descriptive results with stress conditions
    sample_descriptive = {
        "farmer_id": "test_farmer_123",
        "date": datetime.now().strftime("%Y-%m-%d"),
        "growth_stage": "R1",
        "daysSincePlanting": 45,
        "overall_stress": "moderate",
        "stress_analysis": {
            "Temperature": {
                "actual_value": 35.5,
                "optimal_range": [24, 32],
                "stress_level": "high",
                "status": "HIGH"
            },
            "Humidity": {
                "actual_value": 45,
                "optimal_range": [65, 80],
                "stress_level": "moderate",
                "status": "LOW"
            },
            "Soil Moisture": {
                "actual_value": 25,
                "optimal_range": [80, 90],
                "stress_level": "severe",
                "status": "LOW"
            },
            "Soil pH": {
                "actual_value": 5.2,
                "optimal_range": [6.0, 7.0],
                "stress_level": "moderate",
                "status": "LOW"
            },
            "Light Intensity": {
                "actual_value": 45000,
                "optimal_range": [50000, 65000],
                "stress_level": "mild",
                "status": "LOW"
            }
        }
    }
    
    # Sample predictive results
    sample_predictive = {
        "forecast_period_days": 7,
        "risk_assessment": {
            "drought_risk": {"level": "high", "probability": 75},
            "excess_moisture_risk": {"level": "low", "probability": 10},
            "temperature_stress_risk": {"level": "high", "probability": 80},
            "overall_risk_level": "high"
        },
        "weather_forecast": {
            "temperature_forecast": {"min_temp": 28, "max_temp": 38},
            "humidity_forecast": 40,
            "rainfall_probability": {"light_rain_probability": 20, "heavy_rain_probability": 5}
        },
        "growth_timeline": {
            "current_stage": "R1",
            "next_stage": "R2",
            "estimated_days_to_next": 7,
            "progression_status": "normal"
        }
    }
    
    # Sample field data
    sample_field_data = {
        "field_id": "field_123",
        "field_name": "North Field",
        "soil_type": "loam",
        "growth_stage": "R1",
        "area": 2.5,
        "crop_type": "corn"
    }
    
    print(f"\n📊 Sample Field Data:")
    print(f"Field: {sample_field_data['field_name']}")
    print(f"Soil Type: {sample_field_data['soil_type']}")
    print(f"Growth Stage: {sample_field_data['growth_stage']}")
    print(f"Area: {sample_field_data['area']} hectares")
    
    print(f"\n🌡️ Current Conditions:")
    for param, data in sample_descriptive['stress_analysis'].items():
        print(f"{param}: {data['actual_value']} (Optimal: {data['optimal_range'][0]}-{data['optimal_range'][1]}) - {data['stress_level'].upper()}")
    
    print(f"\n🔮 Risk Assessment:")
    for risk, data in sample_predictive['risk_assessment'].items():
        if isinstance(data, dict):
            print(f"{risk.replace('_', ' ').title()}: {data['level'].upper()} ({data.get('probability', 'N/A')}%)")
    
    print(f"\n📋 Generating Enhanced Recommendations...")
    print("=" * 60)
    
    # Generate recommendations
    recommendations = prescriptive_analytics.generate_recommendations(
        sample_descriptive, 
        sample_predictive, 
        sample_field_data['field_id']
    )
    
    if recommendations:
        print(f"\n✅ Generated {recommendations['total_recommendations']} recommendations")
        print(f"Priority Score: {recommendations['priority_score']}/100")
        print(f"Overall Risk: {recommendations['overall_risk'].upper()}")
        
        print(f"\n📝 DETAILED FARMER INSTRUCTIONS:")
        print("=" * 60)
        
        for i, rec in enumerate(recommendations['recommendations'], 1):
            urgency_icon = "🔴" if rec['urgency'] == 'URGENT' else "🟠" if rec['urgency'] == 'HIGH' else "🟡"
            
            print(f"\n{urgency_icon} {i}. {rec['action']}")
            print(f"   Category: {rec['category'].replace('_', ' ').title()}")
            print(f"   Timeline: {rec['timeline']}")
            print(f"   Details: {rec['details']}")
            print(f"   Reference: {rec['reference']}")
            
            if 'instructions' in rec:
                print(f"   Step-by-step Instructions:")
                for instruction in rec['instructions']:
                    print(f"     {instruction}")
            
            print("-" * 40)
        
        # Show agricultural guidelines for this growth stage
        print(f"\n📚 GROWTH STAGE GUIDELINES:")
        print("=" * 60)
        
        stage_guidelines = agricultural_guidelines.get_growth_stage_guidelines("R1")
        print(f"Stage: {stage_guidelines['name']}")
        print(f"Duration: {stage_guidelines['duration_days']} days")
        
        print(f"\nCritical Requirements:")
        for param, req in stage_guidelines['critical_requirements'].items():
            print(f"  {param}: {req['min']}-{req['max']} (Optimal: {req['optimal'][0]}-{req['optimal'][1]})")
        
        print(f"\nManagement Practices:")
        for i, practice in enumerate(stage_guidelines['management_practices'], 1):
            print(f"  {i}. {practice}")
        
        print(f"\nFertilizer Requirements:")
        fertilizer = stage_guidelines['fertilizer_requirements']
        print(f"  Starter: {fertilizer['starter_fertilizer']}")
        print(f"  Method: {fertilizer['application_method']}")
        print(f"  Timing: {fertilizer['timing']}")
        
        print(f"\nPest Management:")
        for i, pest in enumerate(stage_guidelines['pest_management'], 1):
            print(f"  {i}. {pest}")
        
        print(f"\nDisease Prevention:")
        for i, disease in enumerate(stage_guidelines['disease_prevention'], 1):
            print(f"  {i}. {disease}")
        
        # Show references
        print(f"\n📖 REFERENCES:")
        print("=" * 60)
        references = agricultural_guidelines.get_references()
        
        print(f"Department of Agriculture Philippines:")
        for pub in references['da_philippines']['publications']:
            print(f"  • {pub}")
        print(f"  Website: {references['da_philippines']['website']}")
        
        print(f"\nInternational Standards:")
        for source in references['international_standards']['sources']:
            print(f"  • {source}")
        
        print(f"\nLocal Research Institutions:")
        for institution in references['local_research']['institutions']:
            print(f"  • {institution}")
        
    else:
        print("❌ Failed to generate recommendations")
    
    print(f"\n" + "=" * 60)
    print("Test completed successfully!")
    print("=" * 60)

if __name__ == "__main__":
    test_enhanced_recommendations()
