def generate_recommendations(health_analysis):
    """
    Generate specific recommendations based on the health analysis.
    """
    recommendations = []
    
    # If healthy, just maintain current conditions
    if health_analysis["health_status"] == "Healthy":
        base_rec = "All parameters are within optimal ranges. Maintain current conditions."
        
        # Add yield prediction if available
        if "predictions" in health_analysis and "yield_class" in health_analysis["predictions"]:
            yield_class = health_analysis["predictions"]["yield_class"]["prediction"]
            confidence = health_analysis["predictions"]["yield_class"]["confidence"]
            
            if yield_class == "high":
                base_rec += f" Current practices are optimal for high yield (confidence: {confidence}%)."
            elif yield_class == "medium":
                base_rec += f" Consider minor adjustments for optimal yield potential (confidence: {confidence}%)."
            elif yield_class == "low":
                base_rec += f" Despite healthy parameters, yield prediction is lower than optimal (confidence: {confidence}%). Consider nutrient supplementation."
        
        recommendations.append(base_rec)
        return recommendations

    # Focus on important issues identified by ML if available
    if "important_issues" in health_analysis and health_analysis["important_issues"]:
        recommendations.append("Priority issues based on predictive analysis:")
        
        for issue in health_analysis["important_issues"]:
            param = issue["parameter"]
            condition = issue["condition"]
            importance = round(issue["importance_score"] * 100, 1)
            
            # Generate recommendation based on parameter and condition
            rec = generate_parameter_recommendation(param, condition, importance)
            if rec:
                recommendations.append(rec)
    else:
        # If no ML-based important issues, generate standard recommendations for all issues
        for param, details in health_analysis["issues"].items():
            condition = details["condition"]
            rec = generate_parameter_recommendation(param, condition)
            if rec:
                recommendations.append(rec)
    
    # Add stress level specific recommendations
    if "stress_level" in health_analysis:
        stress_level = health_analysis["stress_level"]
        
        if stress_level == "Severe":
            recommendations.append("URGENT: Immediate intervention required to prevent crop loss.")
        elif stress_level == "Moderate":
            recommendations.append("IMPORTANT: Address issues within 48 hours to prevent significant yield impact.")
        elif stress_level == "Mild":
            recommendations.append("MONITOR: Address issues during regular maintenance to optimize yield.")
    
    # Add a stage-specific recommendation
    stage = health_analysis["corn_stage"]
    stage_rec = generate_stage_recommendation(stage)
    if stage_rec:
        recommendations.append(stage_rec)
        
    return recommendations

def generate_parameter_recommendation(param, condition, importance=None):
    """Generate a recommendation for a specific parameter and condition."""
    recommendations = {
        'temperature': {
            'low': "Increase temperature: Use greenhouse heating or row covers to maintain warmth.",
            'high': "Reduce temperature: Apply shade cloth and consider misting to cool the crop.",
            'critically_low': "URGENT: Increase temperature immediately using greenhouse heating or row covers.",
            'critically_high': "URGENT: Reduce temperature immediately using shade cloth and misting."
        },
        'humidity': {
            'low': "Increase humidity: Apply regular misting or adjust irrigation schedule.",
            'high': "Reduce humidity: Improve ventilation to prevent disease conditions.",
            'critically_low': "URGENT: Increase humidity immediately through misting and reduced ventilation.",
            'critically_high': "URGENT: Reduce humidity immediately by improving ventilation."
        },
        'soil_moisture': {
            'low': "Increase soil moisture: Begin evening irrigation daily or use drip irrigation.",
            'high': "Reduce soil moisture: Improve drainage and reduce irrigation frequency.",
            'critically_low': "URGENT: Increase soil moisture immediately through irrigation.",
            'critically_high': "URGENT: Reduce soil moisture immediately by improving drainage."
        },
        'soil_ph': {
            'low': "Increase pH: Apply lime or pH-balancing biofertilizer.",
            'high': "Reduce pH: Apply sulfur or acidifying amendments for better nutrient uptake.",
            'critically_low': "URGENT: Increase pH immediately using lime application.",
            'critically_high': "URGENT: Reduce pH immediately using sulfur application."
        },
        'light_intensity': {
            'low': "Increase light: Supplement with grow lights for optimal growth.",
            'high': "Reduce light exposure: Provide partial shade during peak hours.",
            'critically_low': "URGENT: Increase light immediately using supplemental lighting.",
            'critically_high': "URGENT: Reduce light exposure immediately using shade cloth."
        }
    }
    
    if param in recommendations and condition in recommendations[param]:
        rec = recommendations[param][condition]
        if importance is not None:
            rec = f"{rec} (impact score: {importance}%)"
        return rec
    return None

def generate_stage_recommendation(stage):
    """Generate a stage-specific recommendation."""
    stage_recommendations = {
        "Emergence (VE)": "Stage note: Ensure soil is warm and moist for proper emergence.",
        "Early Vegetative (V2–V4)": "Stage note: Focus on nutrient application for root and leaf development.",
        "Mid Vegetative (V5–VT)": "Stage note: Maintain optimal growth conditions for tasseling.",
        "Reproductive (R1–R3)": "Stage note: Ensure adequate water and nutrients for kernel formation.",
        "Maturing (R4–R5)": "Stage note: Monitor kernel development and prevent water stress.",
        "Maturity/Harvest (R6)": "Stage note: Prepare for harvest and maintain dry conditions."
    }
    return stage_recommendations.get(stage)