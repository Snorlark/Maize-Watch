import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maize_watch/model/sensor_data_model.dart';

class CornGrowthService {
  // Singleton instance
  static final CornGrowthService _instance = CornGrowthService._internal();
  factory CornGrowthService() => _instance;
  CornGrowthService._internal();

  // Streams for broadcasting growth stage updates
  final _growthStageController = StreamController<int>.broadcast();
  final _growthProgressController = StreamController<double>.broadcast();

  // Calculated corn growth stage and progress
  int _currentStageIndex = 0;
  double _currentProgress = 0.0;

  // Define growth stages
  final List<Map<String, dynamic>> cornStages = [
    {
      "stage": "VE: Emergence",
      "description": "Just sprouting from soil",
      "progress": 0.17,
      "minSensorAvg": 0,
    },
    {
      "stage": "V3: Early Growth",
      "description": "3-5 leaves developed",
      "progress": 0.25,
      "minSensorAvg": 25,
    },
    {
      "stage": "V8: Mid Growth",
      "description": "8-10 leaves, growing taller",
      "progress": 0.45,
      "minSensorAvg": 40,
    },
    {
      "stage": "VT: Tasseling",
      "description": "Tassels appearing at top",
      "progress": 0.55,
      "minSensorAvg": 55,
    },
    {
      "stage": "R1: Silking",
      "description": "Silks emerging from ears",
      "progress": 0.60,
      "minSensorAvg": 70,
    },
    {
      "stage": "R6: Mature",
      "description": "Fully developed corn",
      "progress": 1.0,
      "minSensorAvg": 85,
    },
  ];

  // Getters for streams
  Stream<int> get growthStage => _growthStageController.stream;
  Stream<double> get growthProgress => _growthProgressController.stream;

  // Getters for current values
  int get currentStageIndex => _currentStageIndex;
  double get currentProgress => _currentProgress;
  Map<String, dynamic> get currentStage => cornStages[_currentStageIndex];

  // Process sensor data to determine corn growth stage
  void processSensorData(SensorReading? sensorData) {
    if (sensorData == null) return;

    final temp = sensorData.temperature;
    final moisture = sensorData.soilMoisture;
    final humidity = sensorData.humidity;
    final light = sensorData.lightIntensity;
    
    double avgReading = (temp + moisture + humidity + light) / 4;
    
    // Determine growth stage based on average sensor reading
    int newStageIndex = 0;
    for (int i = cornStages.length - 1; i >= 0; i--) {
      if (avgReading >= cornStages[i]["minSensorAvg"]) {
        newStageIndex = i;
        break;
      }
    }
    
    // Calculate progress within the current stage
    double newProgress = cornStages[newStageIndex]["progress"];
    
    // Only update if there's a change
    if (_currentStageIndex != newStageIndex) {
      _currentStageIndex = newStageIndex;
      _growthStageController.add(newStageIndex);
    }
    
    if (_currentProgress != newProgress) {
      _currentProgress = newProgress;
      _growthProgressController.add(newProgress);
    }
  }

  // Calculate crop condition based on sensor data
  Map<String, dynamic> calculateCropCondition(SensorReading? sensorData) {
    String messageKey = "no_data";
    IconData icon = Icons.help_outline;
    Color color = Colors.grey;
    
    if (sensorData != null) {
      final temp = sensorData.temperature;
      final moisture = sensorData.soilMoisture;
      final humidity = sensorData.humidity;
      final light = sensorData.lightIntensity;
      
      double avg = (temp + moisture + humidity + light) / 4;
      
      if (avg >= 70) {
        messageKey = "crop_excellent";
        icon = Icons.sentiment_very_satisfied;
        color = Colors.green;
      } else if (avg >= 40) {
        messageKey = "crop_okay";
        icon = Icons.sentiment_neutral;
        color = Colors.orange;
      } else {
        messageKey = "crop_risk";
        icon = Icons.sentiment_very_dissatisfied;
        color = Colors.red;
      }
    }
    
    return {
      "messageKey": messageKey,
      "icon": icon,
      "color": color,
    };
  }

  // Analyze historical data to predict future growth
  Map<String, dynamic> analyzeTrendData(List<SensorReading>? historicalData) {
    // Default values
    double growthRate = 0.0;
    int daysToNextStage = -1;
    String trend = "stable";
    
    if (historicalData == null || historicalData.isEmpty) {
      return {
        "growthRate": growthRate,
        "daysToNextStage": daysToNextStage,
        "trend": trend,
      };
    }
    
    // Calculate growth trends based on historical data
    // This is a simplified placeholder implementation
    if (historicalData.length > 1) {
      // Calculate average increase in readings over time
      double sumOfChanges = 0.0;
      for (int i = 1; i < historicalData.length; i++) {
        final prevReading = historicalData[i-1];
        final currReading = historicalData[i];
        
        final prevAvg = (prevReading.temperature + 
                        prevReading.soilMoisture + 
                        prevReading.humidity + 
                        prevReading.lightIntensity) / 4;
        
        final currAvg = (currReading.temperature + 
                        currReading.soilMoisture + 
                        currReading.humidity + 
                        currReading.lightIntensity) / 4;
        
        sumOfChanges += (currAvg - prevAvg);
      }
      
      double averageChange = sumOfChanges / (historicalData.length - 1);
      
      // Set trend based on average change
      if (averageChange > 2.0) {
        trend = "rapid_growth";
        growthRate = 0.05; // 5% daily growth
      } else if (averageChange > 0.5) {
        trend = "healthy_growth";
        growthRate = 0.03; // 3% daily growth
      } else if (averageChange > -0.5) {
        trend = "stable";
        growthRate = 0.01; // 1% daily growth
      } else {
        trend = "declining";
        growthRate = -0.01; // -1% daily change
      }
      
      // Estimate days to next stage
      if (_currentStageIndex < cornStages.length - 1 && growthRate > 0) {
        double currentProgress = cornStages[_currentStageIndex]["progress"];
        double nextProgress = cornStages[_currentStageIndex + 1]["progress"];
        double progressNeeded = nextProgress - currentProgress;
        
        daysToNextStage = (progressNeeded / growthRate).ceil();
      }
    }
    
    return {
      "growthRate": growthRate,
      "daysToNextStage": daysToNextStage,
      "trend": trend,
    };
  }

  // Dispose resources
  void dispose() {
    _growthStageController.close();
    _growthProgressController.close();
  }
}