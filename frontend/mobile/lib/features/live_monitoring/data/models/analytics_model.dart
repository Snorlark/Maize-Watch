import 'package:equatable/equatable.dart';

class CropConditionModel extends Equatable {
  final String status;
  final String message;
  final String color;
  final String icon;

  const CropConditionModel({
    required this.status,
    required this.message,
    required this.color,
    required this.icon,
  });

  factory CropConditionModel.fromJson(Map<String, dynamic> json) {
    // Map status to appropriate display values
    String status = json['status'] ?? 'NORMAL';
    String message;
    String color;
    String icon;

    switch (status.toUpperCase()) {
      case 'EXCELLENT':
        message = 'Your corn is in excellent condition!';
        color = '#4CAF50'; // Green
        icon = 'excellent';
        break;
      case 'GOOD':
        message = 'Your corn is growing well with good conditions.';
        color = '#8BC34A'; // Light Green
        icon = 'good';
        break;
      case 'NORMAL':
        message = 'Your corn is in normal condition.';
        color = '#FFC107'; // Amber
        icon = 'normal';
        break;
      case 'WARNING':
        message = 'Your corn needs attention. Check soil moisture and nutrients.';
        color = '#FF9800'; // Orange
        icon = 'warning';
        break;
      case 'CRITICAL':
        message = 'Your corn is in critical condition. Immediate action required.';
        color = '#F44336'; // Red
        icon = 'critical';
        break;
      default:
        message = 'Unable to determine crop condition.';
        color = '#9E9E9E'; // Grey
        icon = 'unknown';
    }

    return CropConditionModel(
      status: status,
      message: message,
      color: color,
      icon: icon,
    );
  }

  @override
  List<Object?> get props => [status, message, color, icon];
}

class MetricsModel extends Equatable {
  final double soilPh;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final DateTime timestamp;

  const MetricsModel({
    required this.soilPh,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    required this.timestamp,
  });

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    return MetricsModel(
      soilPh: (json['soilPh'] ?? json['soil_ph'] ?? 6.5).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? json['soil_moisture'] ?? 50.0).toDouble(),
      temperature: (json['temperature'] ?? 25.0).toDouble(),
      humidity: (json['humidity'] ?? 60.0).toDouble(),
      lightIntensity: (json['lightIntensity'] ?? json['light_intensity'] ?? 500.0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [soilPh, soilMoisture, temperature, humidity, lightIntensity, timestamp];
}

class WeeklyDataModel extends Equatable {
  final List<DailyMetricsModel> dailyData;
  final Map<String, dynamic> summary;

  const WeeklyDataModel({
    required this.dailyData,
    required this.summary,
  });

  factory WeeklyDataModel.fromJson(Map<String, dynamic> json) {
    final dailyDataJson = json['dailyData'] as List<dynamic>? ?? [];
    final dailyData = dailyDataJson.map((dayJson) => DailyMetricsModel.fromJson(dayJson)).toList();

    return WeeklyDataModel(
      dailyData: dailyData,
      summary: json['summary'] as Map<String, dynamic>? ?? {},
    );
  }

  @override
  List<Object?> get props => [dailyData, summary];
}

class DailyMetricsModel extends Equatable {
  final DateTime date;
  final double soilPh;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double lightIntensity;

  const DailyMetricsModel({
    required this.date,
    required this.soilPh,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
  });

  factory DailyMetricsModel.fromJson(Map<String, dynamic> json) {
    return DailyMetricsModel(
      date: DateTime.parse(json['date']),
      soilPh: (json['soilPh'] ?? 0.0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 0.0).toDouble(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      lightIntensity: (json['lightIntensity'] ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [date, soilPh, soilMoisture, temperature, humidity, lightIntensity];
}

class GrowthStageAnalysisModel extends Equatable {
  final String currentStage;
  final String stageDescription;
  final int progressPercentage;
  final DateTime expectedHarvest;
  final List<GrowthStageInfo> stageInfo;
  final Map<String, dynamic> recommendations;

  const GrowthStageAnalysisModel({
    required this.currentStage,
    required this.stageDescription,
    required this.progressPercentage,
    required this.expectedHarvest,
    required this.stageInfo,
    required this.recommendations,
  });

  factory GrowthStageAnalysisModel.fromJson(Map<String, dynamic> json) {
    final currentStage = json['currentStage'] ?? 'VE';
    final stageInfo = _getGrowthStageInfo();
    
    return GrowthStageAnalysisModel(
      currentStage: currentStage,
      stageDescription: _getStageDescription(currentStage),
      progressPercentage: _getProgressPercentage(currentStage),
      expectedHarvest: _calculateExpectedHarvest(currentStage),
      stageInfo: stageInfo,
      recommendations: json['recommendations'] as Map<String, dynamic>? ?? {},
    );
  }

  static String _getStageDescription(String stage) {
    switch (stage) {
      case 'VE':
        return 'Emergence stage: Monitor soil moisture closely as seedlings are establishing roots.';
      case 'V1':
      case 'V2':
      case 'V3':
        return 'Early vegetative stage: Plants are developing their root system. Monitor for pest activity.';
      case 'V4':
      case 'V5':
      case 'V6':
        return 'Mid vegetative stage: Rapid growth period. Monitor nutrient levels and watch for stress.';
      case 'V7':
      case 'V8':
      case 'V9':
      case 'V10':
      case 'V11':
      case 'V12':
        return 'Late vegetative stage: Plants are preparing for reproductive phase.';
      case 'VT':
        return 'Tasseling stage: Critical period for pollination. Monitor weather conditions.';
      case 'R1':
        return 'Silking stage: Pollination is occurring. Monitor for successful kernel development.';
      case 'R2':
        return 'Blister stage: Kernels are developing. Monitor for proper kernel fill.';
      case 'R3':
        return 'Milk stage: Kernels contain milky fluid. Monitor for proper kernel development.';
      case 'R4':
        return 'Dough stage: Kernels are filling with starch. Monitor for proper grain development.';
      case 'R5':
        return 'Dent stage: Kernels are nearly mature. Monitor for proper drying.';
      case 'R6':
        return 'Maturity stage: Plants are ready for harvest. Monitor for optimal harvest timing.';
      default:
        return 'Monitor field conditions regularly and adjust management practices.';
    }
  }

  static int _getProgressPercentage(String stage) {
    final progressMap = {
      'VE': 5, 'V1': 8, 'V2': 12, 'V3': 18, 'V4': 25, 'V5': 32, 'V6': 40,
      'V7': 48, 'V8': 55, 'V9': 62, 'V10': 68, 'V11': 72, 'V12': 75,
      'VT': 80, 'R1': 85, 'R2': 88, 'R3': 90, 'R4': 92, 'R5': 94, 'R6': 100,
    };
    return progressMap[stage] ?? 5;
  }

  static DateTime _calculateExpectedHarvest(String currentStage) {
    final daysToHarvest = {
      'VE': 105, 'V1': 100, 'V2': 95, 'V3': 90, 'V4': 85, 'V5': 80, 'V6': 75,
      'V7': 70, 'V8': 65, 'V9': 60, 'V10': 55, 'V11': 50, 'V12': 45,
      'VT': 40, 'R1': 35, 'R2': 30, 'R3': 25, 'R4': 20, 'R5': 15, 'R6': 0,
    };
    return DateTime.now().add(Duration(days: daysToHarvest[currentStage] ?? 105));
  }

  static List<GrowthStageInfo> _getGrowthStageInfo() {
    return [
      GrowthStageInfo(stage: 'VE', name: 'Emergence', description: 'Seedling emergence', days: 5),
      GrowthStageInfo(stage: 'V1-V3', name: 'Early Vegetative', description: 'Leaf development', days: 15),
      GrowthStageInfo(stage: 'V4-V6', name: 'Mid Vegetative', description: 'Rapid growth', days: 20),
      GrowthStageInfo(stage: 'V7-V12', name: 'Late Vegetative', description: 'Pre-reproductive', days: 25),
      GrowthStageInfo(stage: 'VT', name: 'Tasseling', description: 'Tassel emergence', days: 5),
      GrowthStageInfo(stage: 'R1', name: 'Silking', description: 'Silk emergence', days: 3),
      GrowthStageInfo(stage: 'R2-R3', name: 'Kernel Development', description: 'Kernel formation', days: 15),
      GrowthStageInfo(stage: 'R4-R5', name: 'Grain Fill', description: 'Starch accumulation', days: 20),
      GrowthStageInfo(stage: 'R6', name: 'Maturity', description: 'Ready for harvest', days: 0),
    ];
  }

  @override
  List<Object?> get props => [currentStage, stageDescription, progressPercentage, expectedHarvest, stageInfo, recommendations];
}

class GrowthStageInfo extends Equatable {
  final String stage;
  final String name;
  final String description;
  final int days;

  const GrowthStageInfo({
    required this.stage,
    required this.name,
    required this.description,
    required this.days,
  });

  @override
  List<Object?> get props => [stage, name, description, days];
}
