import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.preprocessing import LabelEncoder

class CornPredictiveModel:
    def __init__(self):
        """Initialize the predictive model without requiring historical data"""
        self.stress_model = None
        self.feature_columns = ["temperature", "humidity", "soil_moisture", "ph", "light"]
        self.stress_encoder = LabelEncoder()
        # Define stress levels
        self.stress_levels = ["None", "Mild", "Moderate", "Severe"]
        self.stress_encoder.fit(self.stress_levels)
        
    def generate_synthetic_data(self):
        """
        Generate synthetic data for training the model based on domain knowledge
        of optimal ranges for corn growth parameters
        """
        # Define optimal ranges per corn growth stage from descriptive.py
        stage_ranges = {
            "Emergence (VE)": {
                "temperature": (25, 30, "°C"),
                "humidity": (70, 85, "%"),
                "soil_moisture": (60, 80, "%"),
                "ph": (5.5, 7.5, "pH"),
                "light": (15000, 25000, "lux")
            },
            "Early Vegetative (V2–V4)": {
                "temperature": (26, 33, "°C"),
                "humidity": (65, 80, "%"),
                "soil_moisture": (60, 80, "%"),
                "ph": (5.5, 7.5, "pH"),
                "light": (30000, 45000, "lux")
            },
            "Mid Vegetative (V5–VT)": {
                "temperature": (27, 33, "°C"),
                "humidity": (60, 80, "%"),
                "soil_moisture": (60, 80, "%"),
                "ph": (5.5, 7.5, "pH"),
                "light": (40000, 50000, "lux")
            },
            "Reproductive (R1–R3)": {
                "temperature": (27, 35, "°C"),
                "humidity": (65, 80, "%"),
                "soil_moisture": (80, 100, "%"),
                "ph": (5.5, 7.5, "pH"),
                "light": (50000, 70000, "lux")
            },
            "Maturing (R4–R5)": {
                "temperature": (25, 32, "°C"),
                "humidity": (55, 75, "%"),
                "soil_moisture": (60, 80, "%"),
                "ph": (5.5, 7.5, "pH"),
                "light": (35000, 50000, "lux")
            },
            "Maturity/Harvest (R6)": {
                "temperature": (25, 30, "°C"),
                "humidity": (50, 70, "%"),
                "soil_moisture": (60, 75, "%"),
                "ph": (5.5, 7.5, "pH"),
                "light": (0, 99999, "lux")
            }
        }
        
        # How many synthetic samples to generate per stage
        samples_per_stage = 50
        stages = list(stage_ranges.keys())
        total_samples = len(stages) * samples_per_stage
        
        # Initialize data structure
        data = {
            "temperature": np.zeros(total_samples),
            "humidity": np.zeros(total_samples),
            "soil_moisture": np.zeros(total_samples),
            "ph": np.zeros(total_samples),
            "light": np.zeros(total_samples),
            "corn_stage": np.array([None] * total_samples),
            "stress_level": np.array([None] * total_samples)
        }
        
        # Generate data for each growth stage
        idx = 0
        for stage in stages:
            for _ in range(samples_per_stage):
                # Get optimal ranges for this stage
                ranges = stage_ranges[stage]
                
                # Sample generation strategy:
                # - 40% of samples are within optimal range (no stress)
                # - 30% slightly outside optimal range (mild stress)
                # - 20% moderately outside optimal range (moderate stress)
                # - 10% far outside optimal range (severe stress)
                
                stress_category = np.random.choice(
                    ["None", "Mild", "Moderate", "Severe"], 
                    p=[0.4, 0.3, 0.2, 0.1]
                )
                
                # Save the corn stage and stress level
                data["corn_stage"][idx] = stage
                data["stress_level"][idx] = stress_category

                # Generate values for each parameter based on stress category
                for param in self.feature_columns:
                    if param in ranges:
                        min_val, max_val, _ = ranges[param]
                        range_width = max_val - min_val
                        
                        if stress_category == "None":
                            # Within optimal range
                            data[param][idx] = np.random.uniform(min_val, max_val)
                        elif stress_category == "Mild":
                            # Slightly outside optimal range (10-20% deviation)
                            if np.random.random() > 0.5:  # higher than max
                                data[param][idx] = np.random.uniform(
                                    max_val, 
                                    max_val + 0.2 * range_width
                                )
                            else:  # lower than min
                                data[param][idx] = np.random.uniform(
                                    min_val - 0.2 * range_width,
                                    min_val
                                )
                        elif stress_category == "Moderate":
                            # Moderately outside optimal range (20-50% deviation)
                            if np.random.random() > 0.5:  # higher than max
                                data[param][idx] = np.random.uniform(
                                    max_val + 0.2 * range_width,
                                    max_val + 0.5 * range_width
                                )
                            else:  # lower than min
                                data[param][idx] = np.random.uniform(
                                    min_val - 0.5 * range_width,
                                    min_val - 0.2 * range_width
                                )
                        else:  # Severe
                            # Far outside optimal range (50-100% deviation)
                            if np.random.random() > 0.5:  # higher than max
                                data[param][idx] = np.random.uniform(
                                    max_val + 0.5 * range_width,
                                    max_val + range_width
                                )
                            else:  # lower than min
                                data[param][idx] = np.random.uniform(
                                    min_val - range_width,
                                    min_val - 0.5 * range_width
                                )
                idx += 1
        
        # Convert to DataFrame
        return pd.DataFrame(data)
    
    def train(self):
        """Train the model using synthetic data"""
        # Generate synthetic training data
        synthetic_data = self.generate_synthetic_data()
        
        # Extract features and target
        X = synthetic_data[self.feature_columns]
        
        # Add corn_stage as a categorical feature
        stage_dummies = pd.get_dummies(synthetic_data["corn_stage"], prefix="stage")
        X = pd.concat([X, stage_dummies], axis=1)
        
        # Encode and extract stress level target
        y_stress = self.stress_encoder.transform(synthetic_data["stress_level"])
        
        # Train stress level model
        self.stress_model = RandomForestClassifier(n_estimators=100, random_state=42)
        self.stress_model.fit(X, y_stress)
        
        # Save feature names for later use
        self.feature_names = X.columns.tolist()
        
    def predict(self, data_row):
        """
        Make predictions for a single row of data.
        
        Args:
            data_row: Series or dict containing current measurements
            
        Returns:
            dict with predictions and feature importance
        """
        # Train model if not already trained
        if self.stress_model is None:
            self.train()
            
        # Create feature vector for prediction
        X = pd.DataFrame({col: [data_row[col] if col in data_row else 0] 
                         for col in self.feature_columns})
        
        # Add corn_stage features
        stage_features = pd.DataFrame(columns=[col for col in self.feature_names 
                                              if col.startswith('stage_')])
        stage_features = stage_features.fillna(0)
        
        # One-hot encode the corn stage
        if "corn_stage" in data_row:
            stage_col = f"stage_{data_row['corn_stage']}"
            if stage_col in stage_features.columns:
                stage_features[stage_col] = 1
                
        # Combine all features
        X_complete = pd.concat([X, stage_features], axis=1)
        
        # Make sure all expected columns are present
        for col in self.feature_names:
            if col not in X_complete.columns:
                X_complete[col] = 0
                
        # Ensure columns are in the same order as during training
        X_complete = X_complete[self.feature_names]
        
        results = {}
        
        # Predict stress level 
        stress_pred = self.stress_model.predict(X_complete)[0]
        stress_proba = self.stress_model.predict_proba(X_complete)[0]
        results["stress_level"] = {
            "prediction": self.stress_encoder.inverse_transform([stress_pred])[0],
            "confidence": round(max(stress_proba) * 100, 1)
        }
        
        # Calculate feature importance
        results["parameter_importance"] = self._calculate_parameter_importance()
        
        return results
    
    def _calculate_parameter_importance(self):
        """
        Calculate parameter importance based on the model's feature importances.
        """
        if not self.stress_model:
            return {}
            
        # Get feature importance values
        importance = {}
        for i, feature in enumerate(self.feature_names):
            if not feature.startswith("stage_") and i < len(self.stress_model.feature_importances_):
                importance[feature] = self.stress_model.feature_importances_[i]
        
        # Sort by importance
        sorted_importance = {k: v for k, v in sorted(
            importance.items(), 
            key=lambda item: item[1], 
            reverse=True
        )}
        
        # Use an importance threshold instead of fixed number of parameters
        # Include all parameters with an importance score of at least 10% of the max score
        threshold = 0.1 * max(sorted_importance.values()) if sorted_importance else 0
        top_parameters = [k for k, v in sorted_importance.items() if v >= threshold]
        
        # Make sure all five core parameters are included if they have any importance
        for param in self.feature_columns:
            if param in sorted_importance and param not in top_parameters:
                top_parameters.append(param)
        
        return {
            "top_parameters": top_parameters,
            "importance_scores": {k: round(v, 3) for k, v in sorted_importance.items()}
        }

def get_feature_issue_importance(data_row, parameter_importance):
    """
    Identify which issues are most important based on parameter importance.
    
    Args:
        data_row: Current data measurements
        parameter_importance: Dict with importance information from model
        
    Returns:
        List of important issues sorted by importance
    """
    if not parameter_importance or "top_parameters" not in parameter_importance:
        return []
    
    important_issues = []
    
    # Get optimal ranges for the corn stage
    from descriptive import evaluate_corn_health
    health_analysis = evaluate_corn_health(data_row)
    
    # For each important parameter, check if it's an issue
    for param in parameter_importance["top_parameters"]:
        if param in health_analysis["issues"]:
            issue_info = health_analysis["issues"][param]
            importance_score = parameter_importance["importance_scores"].get(param, 0)
            
            important_issues.append({
                "parameter": param,
                "condition": issue_info["condition"],
                "value": issue_info["value"],
                "optimal_range": issue_info["optimal_range"],
                "unit": issue_info["unit"],
                "importance_score": importance_score
            })
    
    # Sort by importance score
    important_issues.sort(key=lambda x: x["importance_score"], reverse=True)
    
    return important_issues