#!/usr/bin/env python3
"""
Standalone test for enhanced agricultural recommendations
Demonstrates the comprehensive step-by-step instructions for farmers
"""

import sys
import json
from datetime import datetime

# Add src to path
sys.path.append('src')

from src.knowledge.agricultural_guidelines import agricultural_guidelines

def test_agricultural_guidelines():
    """Test the agricultural guidelines knowledge base"""
    
    print("🌽 Enhanced Agricultural Knowledge Base Test")
    print("=" * 60)
    print("Based on Department of Agriculture Philippines Guidelines")
    print("=" * 60)
    
    # Test different growth stages
    growth_stages = ['VE', 'V2-V4', 'V5-VT', 'R1-R3', 'R4-R5', 'R6']
    
    for stage in growth_stages:
        print(f"\n📊 GROWTH STAGE: {stage}")
        print("-" * 40)
        
        guidelines = agricultural_guidelines.get_growth_stage_guidelines(stage)
        
        if guidelines:
            print(f"Name: {guidelines['name']}")
            print(f"Duration: {guidelines['duration_days']} days")
            
            print(f"\nCritical Requirements:")
            for param, req in guidelines['critical_requirements'].items():
                print(f"  {param}: {req['min']}-{req['max']} (Optimal: {req['optimal'][0]}-{req['optimal'][1]})")
            
            print(f"\nManagement Practices:")
            for i, practice in enumerate(guidelines['management_practices'], 1):
                print(f"  {i}. {practice}")
            
            print(f"\nFertilizer Requirements:")
            fertilizer = guidelines.get('fertilizer_requirements', {})
            if fertilizer:
                print(f"  Starter: {fertilizer.get('starter_fertilizer', 'N/A')}")
                print(f"  Method: {fertilizer.get('application_method', 'N/A')}")
                print(f"  Timing: {fertilizer.get('timing', 'N/A')}")
            else:
                print(f"  No specific fertilizer requirements for this stage")
            
            print(f"\nPest Management:")
            pest_management = guidelines.get('pest_management', [])
            if pest_management:
                for i, pest in enumerate(pest_management, 1):
                    print(f"  {i}. {pest}")
            else:
                print(f"  No specific pest management for this stage")
            
            print(f"\nDisease Prevention:")
            disease_prevention = guidelines.get('disease_prevention', [])
            if disease_prevention:
                for i, disease in enumerate(disease_prevention, 1):
                    print(f"  {i}. {disease}")
            else:
                print(f"  No specific disease prevention for this stage")
    
    # Test soil management guidelines
    print(f"\n🌱 SOIL MANAGEMENT GUIDELINES")
    print("=" * 60)
    
    soil_types = ['sandy', 'loam', 'clay']
    
    for soil_type in soil_types:
        print(f"\nSoil Type: {soil_type.title()}")
        print("-" * 30)
        
        soil_guidelines = agricultural_guidelines.get_soil_management_guidelines(soil_type)
        
        if soil_guidelines:
            print(f"Characteristics: {soil_guidelines['characteristics']}")
            
            print(f"\nManagement Practices:")
            for i, practice in enumerate(soil_guidelines['management'], 1):
                print(f"  {i}. {practice}")
            
            print(f"\npH Adjustment:")
            ph_adj = soil_guidelines['ph_adjustment']
            print(f"  Lime requirement: {ph_adj['lime_requirement']}")
            print(f"  Sulfur requirement: {ph_adj['sulfur_requirement']}")
    
    # Test fertilizer recommendations
    print(f"\n🌾 FERTILIZER RECOMMENDATIONS")
    print("=" * 60)
    
    fertilizer_rec = agricultural_guidelines.get_fertilizer_recommendations('R1-R3', 'loam')
    
    if fertilizer_rec:
        print(f"Growth Stage Requirements:")
        stage_req = fertilizer_rec['growth_stage']
        if stage_req:
            print(f"  Starter: {stage_req.get('starter_fertilizer', 'N/A')}")
            print(f"  Method: {stage_req.get('application_method', 'N/A')}")
            print(f"  Timing: {stage_req.get('timing', 'N/A')}")
        
        print(f"\nGeneral Requirements:")
        general_req = fertilizer_rec['general_requirements']
        for nutrient, req in general_req['nutrient_requirements'].items():
            print(f"  {nutrient.title()}: {req['total_requirement']}")
            print(f"    Schedule: {', '.join(req['application_schedule'])}")
            print(f"    Sources: {', '.join(req['sources'])}")
    
    # Test irrigation guidelines
    print(f"\n💧 IRRIGATION GUIDELINES")
    print("=" * 60)
    
    irrigation_guidelines = agricultural_guidelines.get_irrigation_guidelines('R1-R3')
    
    if irrigation_guidelines:
        print(f"Critical Periods:")
        for period in irrigation_guidelines['general_guidelines']['critical_periods']:
            print(f"  • {period}")
        
        print(f"\nIrrigation Scheduling:")
        scheduling = irrigation_guidelines['general_guidelines']['irrigation_scheduling']
        for stage, schedule in scheduling.items():
            print(f"  {stage}: {schedule}")
        
        print(f"\nWater Quality Requirements:")
        water_quality = irrigation_guidelines['general_guidelines']['water_quality']
        for param, value in water_quality.items():
            print(f"  {param}: {value}")
    
    # Test pest management
    print(f"\n🐛 PEST MANAGEMENT")
    print("=" * 60)
    
    pest_plan = agricultural_guidelines.get_pest_management_plan('R1-R3')
    
    if pest_plan:
        print(f"Pest Management Plan for R1-R3 Stage:")
        for i, practice in enumerate(pest_plan, 1):
            print(f"  {i}. {practice}")
    
    # Test disease prevention
    print(f"\n🦠 DISEASE PREVENTION")
    print("=" * 60)
    
    disease_plan = agricultural_guidelines.get_disease_prevention_plan('R1-R3')
    
    if disease_plan:
        print(f"Disease Prevention Plan for R1-R3 Stage:")
        for i, practice in enumerate(disease_plan, 1):
            print(f"  {i}. {practice}")
    
    # Test harvest guidelines
    print(f"\n🌾 HARVEST GUIDELINES")
    print("=" * 60)
    
    harvest_guidelines = agricultural_guidelines.get_harvest_guidelines()
    
    if harvest_guidelines:
        print(f"Harvest Timing Indicators:")
        for indicator in harvest_guidelines['harvest_timing']['maturity_indicators']:
            print(f"  • {indicator}")
        
        print(f"\nOptimal Moisture: {harvest_guidelines['harvest_timing']['optimal_moisture']}")
        
        print(f"\nHarvest Methods:")
        methods = harvest_guidelines['harvest_methods']
        for method, details in methods.items():
            print(f"  {method.title()}:")
            print(f"    Advantages: {details['advantages']}")
            print(f"    Disadvantages: {details['disadvantages']}")
            print(f"    Suitable for: {details['suitable_for']}")
        
        print(f"\nPost-Harvest:")
        post_harvest = harvest_guidelines['post_harvest']
        for process, details in post_harvest.items():
            print(f"  {process.title()}:")
            if isinstance(details, dict):
                for key, value in details.items():
                    print(f"    {key}: {value}")
            else:
                print(f"    {details}")
    
    # Show references
    print(f"\n📖 REFERENCES")
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
    
    print(f"\n" + "=" * 60)
    print("✅ Agricultural Knowledge Base Test Completed Successfully!")
    print("=" * 60)

def demonstrate_sample_recommendations():
    """Demonstrate sample recommendations with detailed instructions"""
    
    print(f"\n📋 SAMPLE FARMER INSTRUCTIONS")
    print("=" * 60)
    
    # Sample stress conditions
    sample_conditions = {
        "field_name": "North Field",
        "soil_type": "loam",
        "growth_stage": "R1",
        "temperature": 35.5,
        "humidity": 45,
        "soil_moisture": 25,
        "soil_ph": 5.2
    }
    
    print(f"Field: {sample_conditions['field_name']}")
    print(f"Soil Type: {sample_conditions['soil_type']}")
    print(f"Growth Stage: {sample_conditions['growth_stage']}")
    print(f"Temperature: {sample_conditions['temperature']}°C")
    print(f"Humidity: {sample_conditions['humidity']}%")
    print(f"Soil Moisture: {sample_conditions['soil_moisture']}%")
    print(f"Soil pH: {sample_conditions['soil_ph']}")
    
    print(f"\n🔴 URGENT ACTIONS REQUIRED:")
    print("-" * 40)
    
    # Temperature stress
    print(f"\n1. Manage High Temperature Stress")
    print(f"   Details: Temperature at 35.5°C, above optimal 32°C for R1 stage")
    print(f"   Instructions:")
    print(f"   1. Increase irrigation frequency to 2-3 times daily")
    print(f"   2. Apply mulch around plants to reduce soil temperature")
    print(f"   3. Consider temporary shade structures if temperature exceeds 35°C")
    print(f"   4. Monitor soil moisture closely - high temperatures increase water demand")
    print(f"   5. Avoid fertilizer application during peak heat hours (10 AM - 3 PM)")
    print(f"   6. Check for heat stress symptoms: wilting, leaf curling, stunted growth")
    print(f"   Timeline: Today - Immediate action required")
    print(f"   Reference: DA Philippines Corn Production Guide - Temperature Management")
    
    # Soil moisture stress
    print(f"\n2. URGENT: Irrigate immediately")
    print(f"   Details: Soil moisture at 25%, below optimal 80% for loam soil in R1 stage")
    print(f"   Instructions:")
    print(f"   1. IMMEDIATE: Apply 25-30 mm of water using sprinkler or flood irrigation")
    print(f"   2. Check soil moisture at 15-20 cm depth after irrigation")
    print(f"   3. For loam soil: Irrigate every 3-4 days with 25-30 mm")
    print(f"   4. Monitor plant wilting - if present, increase irrigation frequency")
    print(f"   5. Apply mulch to conserve soil moisture")
    print(f"   6. Check irrigation system for proper coverage and efficiency")
    print(f"   Timeline: Today - CRITICAL for plant survival")
    print(f"   Reference: DA Philippines Corn Production Guide - Irrigation Management")
    
    # Soil pH adjustment
    print(f"\n3. Apply lime to increase soil pH")
    print(f"   Details: Soil pH at 5.2, below optimal 6.0. Apply 2.0 mt/ha lime for loam soil")
    print(f"   Instructions:")
    print(f"   1. Apply 2.0 metric tons per hectare of agricultural lime")
    print(f"   2. Broadcast lime evenly across the field using spreader")
    print(f"   3. Incorporate lime into soil to 15-20 cm depth using disc harrow")
    print(f"   4. Apply 3-6 months before next planting season for best results")
    print(f"   5. Water the field lightly after application to activate lime")
    print(f"   6. Monitor pH changes - retest soil after 3 months")
    print(f"   Timeline: This week - Plan for next season")
    print(f"   Reference: DA Philippines Corn Production Guide - Soil pH Management")
    
    # Reproductive stage management
    print(f"\n4. CRITICAL: Reproductive stage management")
    print(f"   Details: Most critical period - ensure optimal conditions for pollination")
    print(f"   Instructions:")
    print(f"   1. CRITICAL: Maintain consistent soil moisture (80-90%) - most important factor")
    print(f"   2. Increase irrigation frequency to every 2-3 days with 30-40 mm water")
    print(f"   3. Monitor pollination success - check for proper silking and pollen shed")
    print(f"   4. Avoid water stress during silking - can reduce yield by 50%")
    print(f"   5. Monitor kernel development and ear formation")
    print(f"   6. Apply final nitrogen application if not done earlier")
    print(f"   7. Monitor for corn earworm and corn borer in ears")
    print(f"   8. Check for lodging and provide support if needed")
    print(f"   Timeline: This week - CRITICAL for yield")
    print(f"   Reference: DA Philippines Corn Production Guide - Reproductive Stage")
    
    print(f"\n" + "=" * 60)
    print("✅ Sample Recommendations Demonstrated Successfully!")
    print("=" * 60)

if __name__ == "__main__":
    test_agricultural_guidelines()
    demonstrate_sample_recommendations()
