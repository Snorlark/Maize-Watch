def generate_recommendations(health_analysis):
    """
    Generate specific recommendations based on the health analysis.
    """
    recommendations = []
    
    # If healthy, just maintain current conditions
    if health_analysis["health_status"] == "Healthy":
        base_rec = "All parameters are within optimal ranges. Maintain current conditions."
        
        # Add yield prediction if available STILL COOKING FOR THIS PART !
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
            
            # Add importance score(??) to the recommendation
            if param == "temperature":
                if condition == "low":
                    recommendations.append(f"Increase temperature (impact score: {importance}%): Use greenhouse heating or row covers to maintain warmth.")
                else:
                    recommendations.append(f"Reduce temperature (impact score: {importance}%): Apply shade cloth and consider misting to cool the crop.")
            
            elif param == "humidity":
                if condition == "low":
                    recommendations.append(f"Increase humidity (impact score: {importance}%): Apply regular misting or adjust irrigation schedule.")
                else:
                    recommendations.append(f"Reduce humidity (impact score: {importance}%): Improve ventilation to prevent disease conditions.")
            
            elif param == "soil_moisture":
                if condition == "low":
                    recommendations.append(f"Increase soil moisture (impact score: {importance}%): Begin evening irrigation daily or use drip irrigation.")
                else:
                    recommendations.append(f"Reduce soil moisture (impact score: {importance}%): Improve drainage and reduce irrigation frequency.")
            
            elif param == "ph":
                if condition == "low":
                    recommendations.append(f"Increase pH (impact score: {importance}%): Apply lime or pH-balancing biofertilizer.")
                else:
                    recommendations.append(f"Reduce pH (impact score: {importance}%): Apply sulfur or acidifying amendments for better nutrient uptake.")
            
            elif param == "light":
                if condition == "low":
                    recommendations.append(f"Increase light (impact score: {importance}%): Supplement with grow lights for optimal growth.")
                else:
                    recommendations.append(f"Reduce light exposure (impact score: {importance}%): Provide partial shade during peak hours.")
    else:
        # If no ML-based important issues, generate standard recommendations for all issues
        for param, details in health_analysis["issues"].items():
            condition = details["condition"]
            
            if param == "temperature":
                if condition == "low":
                    recommendations.append("Increase greenhouse temperature or use row covers to maintain warmth.")
                else:
                    recommendations.append("Apply shade cloth to reduce thermal stress and consider misting to cool the crop.")
            
            elif param == "humidity":
                if condition == "low":
                    recommendations.append("Increase humidity through regular misting or irrigation.")
                else:
                    recommendations.append("Improve ventilation to reduce excess humidity and prevent disease.")
            
            elif param == "soil_moisture":
                if condition == "low":
                    recommendations.append("Begin evening irrigation daily to maintain optimal soil moisture.")
                else:
                    recommendations.append("Improve drainage and reduce irrigation frequency to avoid waterlogged conditions.")
            
            elif param == "ph":
                if condition == "low":
                    recommendations.append("Apply lime or pH-balancing biofertilizer to increase soil pH.")
                else:
                    recommendations.append("Apply sulfur or acidifying amendments to lower soil pH for better nutrient uptake.")
            
            elif param == "light":
                if condition == "low":
                    recommendations.append("Supplement with grow lights to achieve optimal light intensity for this growth stage.")
                else:
                    recommendations.append("Provide partial shade to reduce excessive light exposure.")
    
    # Add stress level specific recommendations if available
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
    if stage == "Emergence (VE)":
        recommendations.append("Stage note: Ensure soil is warm and moist for proper emergence.")
    elif stage == "Early Vegetative (V2–V4)":
        recommendations.append("Stage note: Focus on nutrient application for root and leaf development.")
    elif stage == "Mid Vegetative (V5–VT)":
        recommendations.append("Stage note: Maintain optimal growth conditions for tasseling.")
    elif stage == "Reproductive (R1–R3)":
        recommendations.append("Stage note: Ensure adequate water and nutrients for kernel formation.")
    elif stage == "Maturing (R4–R5)":
        recommendations.append("Stage note: Monitor kernel development and prevent water stress.")
    elif stage == "Maturity/Harvest (R6)":
        recommendations.append("Stage note: Prepare for harvest and maintain dry conditions.")
        
    return recommendations