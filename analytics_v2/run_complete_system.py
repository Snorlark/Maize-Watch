#!/usr/bin/env python3
"""
Complete Corn Monitoring System - All Analytics Combined
"""

import sys
from datetime import datetime

sys.path.append('src')

from src.utils.logger import setup_logger
from src.analytics.descriptive import descriptive_analytics
from src.analytics.predictive import predictive_analytics
from src.analytics.prescriptive import prescriptive_analytics

def run_complete_system(farmer_id: str, field_id: str = None):
    """Run the complete analytics system"""
    
    logger = setup_logger()
    
    print("Corn Growth Monitoring System - Complete Analytics")
    print("=" * 60)
    print(f"Farmer ID: {farmer_id}")
    if field_id:
        print(f"Field ID: {field_id}")
    print(f"Analysis Date: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print("=" * 60)
    
    # Step 1: Descriptive Analytics
    print("\nStep 1: Analyzing today's performance...")
    descriptive_results = descriptive_analytics.analyze_daily_performance(farmer_id, use_today=True)
    
    if not descriptive_results:
        print("FAILED: Could not complete descriptive analysis")
        return None
    
    print(f"COMPLETED: Overall condition is {descriptive_results['overall_stress'].upper()}")
    
    # Step 2: Predictive Analytics
    print("\nStep 2: Generating forecasts and risk assessment...")
    predictive_results = predictive_analytics.analyze_predictions(descriptive_results)
    
    if not predictive_results:
        print("FAILED: Could not complete predictive analysis")
        return {"descriptive": descriptive_results}
    
    print(f"COMPLETED: {predictive_results['forecast_period_days']}-day forecast, overall risk is {predictive_results['risk_assessment']['overall_risk_level'].upper()}")
    
    # Step 3: Prescriptive Analytics
    print("\nStep 3: Generating actionable recommendations...")
    prescriptive_results = prescriptive_analytics.generate_recommendations(
        descriptive_results, predictive_results, field_id
    )
    
    if not prescriptive_results:
        print("FAILED: Could not generate recommendations")
        return {"descriptive": descriptive_results, "predictive": predictive_results}
    
    print(f"COMPLETED: {prescriptive_results['total_recommendations']} recommendations generated with priority score {prescriptive_results['priority_score']}")
    
    # Step 4: Display Final Report
    print_final_report(descriptive_results, predictive_results, prescriptive_results)
    
    return {
        "descriptive": descriptive_results,
        "predictive": predictive_results,
        "prescriptive": prescriptive_results
    }

def print_final_report(descriptive: dict, predictive: dict, prescriptive: dict):
    """Print comprehensive final report"""
    
    print("\n" + "="*60)
    print("DAILY CORN MONITORING REPORT")
    print("="*60)
    
    # Header Info
    print(f"Date: {descriptive['date']}")
    print(f"Growth Stage: {descriptive['growth_stage']}")
    print(f"Overall Condition: {descriptive['overall_stress'].upper()}")
    print(f"Priority Score: {prescriptive['priority_score']}/100")
    
    # Current Conditions
    print(f"\nYESTERDAY'S CONDITIONS:")
    for param, analysis in descriptive['stress_analysis'].items():
        status_icon = analysis['status']
        print(f"{status_icon} {param.replace('_', ' ').title()}: {analysis['stress_level'].upper()}")
        print(f"   Value: {analysis['actual_value']}, Optimal: {analysis['optimal_range'][0]}-{analysis['optimal_range'][1]}")
    
    # Weather Forecast
    weather = predictive.get('weather_forecast', {})
    forecast_days = predictive.get('forecast_period_days', 3)  # Default to 3 days if not specified
    print(f"\n{forecast_days}-DAY WEATHER FORECAST:")
    
    # Safely get temperature forecast
    temp_forecast = weather.get('temperature_forecast', {})
    if temp_forecast and 'min_temp' in temp_forecast and 'max_temp' in temp_forecast:
        print(f"Temperature: {temp_forecast['min_temp']}-{temp_forecast['max_temp']}°C")
    else:
        print("Temperature: Data not available")
    
    # Safely get humidity forecast
    humidity = weather.get('humidity_forecast', 'N/A')
    print(f"Humidity: {humidity}%")
    
    # Safely get rain probability
    rain_prob = weather.get('rainfall_probability', {})
    if rain_prob and 'light_rain_probability' in rain_prob:
        print(f"Rain Probability: {rain_prob['light_rain_probability']}%")
    else:
        print("Rain Probability: Data not available")
    
    # Risk Assessment
    risks = predictive.get('risk_assessment', {})
    print(f"\nRISK ASSESSMENT:")
    
    # Safely get and print drought risk
    drought = risks.get('drought_risk', {})
    print(f"Drought: {drought.get('level', 'UNKNOWN').upper()} ({drought.get('probability', 'N/A')}%)")
    
    # Safely get and print excess moisture risk
    moisture = risks.get('excess_moisture_risk', {})
    print(f"Excess Moisture: {moisture.get('level', 'UNKNOWN').upper()} ({moisture.get('probability', 'N/A')}%)")
    
    # Safely get and print temperature stress risk
    temp_stress = risks.get('temperature_stress_risk', {})
    print(f"Temperature Stress: {temp_stress.get('level', 'UNKNOWN').upper()} ({temp_stress.get('probability', 'N/A')}%)")
    
    # Safely get and print overall risk
    print(f"Overall Risk Level: {risks.get('overall_risk_level', 'UNKNOWN').upper()}")
    
    # Growth Timeline
    growth = predictive.get('growth_timeline', {})
    print(f"\nGROWTH PROGRESSION:")
    
    # Safely get and print current stage
    current_stage = growth.get('current_stage', 'UNKNOWN')
    print(f"Current Stage: {current_stage}")
    
    # Safely get and print next stage info
    next_stage = growth.get('next_stage', 'UNKNOWN')
    days_to_next = growth.get('estimated_days_to_next', 'N/A')
    print(f"Next Stage: {next_stage} (estimated {days_to_next} days)")
    
    # Safely get and print status
    status = growth.get('progression_status', 'UNKNOWN')
    if isinstance(status, str):
        print(f"Status: {status.upper()}")
    else:
        print("Status: UNKNOWN")
    
    # Daily Recommendations
    print(f"\nTODAY'S ACTION PLAN >>")
    recommendations = prescriptive['recommendations']
    
    urgent_actions = [r for r in recommendations if r['urgency'] == 'URGENT']
    high_actions = [r for r in recommendations if r['urgency'] == 'HIGH']
    medium_actions = [r for r in recommendations if r['urgency'] == 'MEDIUM']
    
    if urgent_actions:
        print(f"\nURGENT ACTIONS:")
        for i, rec in enumerate(urgent_actions, 1):
            print(f"{i}. {rec['details']}")
            # print(f"   {rec['details']}")
            print(f"   Timeline: {rec['timeline']}")
    
    if high_actions:
        print(f"\nHIGH PRIORITY:")
        for i, rec in enumerate(high_actions, 1):
            print(f"{i}. {rec['details']}")
          #  print(f"   {rec['details']}")
            print(f"   Timeline: {rec['timeline']}")
    
    if medium_actions:
        print(f"\nMEDIUM PRIORITY:")
        for i, rec in enumerate(medium_actions, 1):
            print(f"{i}. {rec['action']}")
            print(f"   Timeline: {rec['timeline']}")
    
    print("\n" + "="*60)
    print("Report generated successfully. Data saved to database.")
    print("="*60)

if __name__ == "__main__":
    import sys
    farmer_id = sys.argv[1] if len(sys.argv) > 1 else "FARMER001"
    field_id = sys.argv[2] if len(sys.argv) > 2 else None
    results = run_complete_system(farmer_id, field_id)