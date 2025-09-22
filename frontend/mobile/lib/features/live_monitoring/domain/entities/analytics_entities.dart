class CropConditionModel {
  final String status;
  final String message;
  final String color;
  final String icon;

  CropConditionModel({
    required this.status,
    required this.message,
    required this.color,
    required this.icon,
  });

  factory CropConditionModel.fromJson(Map<String, dynamic> json) {
    return CropConditionModel(
      status: json['status'] ?? 'NORMAL',
      message: json['message'] ?? 'No data available',
      color: json['color'] ?? '#9E9E9E',
      icon: json['icon'] ?? 'unknown',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'color': color,
      'icon': icon,
    };
  }
}

class MetricsModel {
  final double soilPh;
  final double soilMoisture;
  final double temperature;
  final double humidity;
  final double lightIntensity;
  final DateTime? timestamp;

  MetricsModel({
    required this.soilPh,
    required this.soilMoisture,
    required this.temperature,
    required this.humidity,
    required this.lightIntensity,
    this.timestamp,
  });

  factory MetricsModel.fromJson(Map<String, dynamic> json) {
    return MetricsModel(
      soilPh: (json['soilPh'] ?? 6.5).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 50.0).toDouble(),
      temperature: (json['temperature'] ?? 25.0).toDouble(),
      humidity: (json['humidity'] ?? 60.0).toDouble(),
      lightIntensity: (json['lightIntensity'] ?? 500.0).toDouble(),
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soilPh': soilPh,
      'soilMoisture': soilMoisture,
      'temperature': temperature,
      'humidity': humidity,
      'lightIntensity': lightIntensity,
      'timestamp': timestamp?.toIso8601String(),
    };
  }
}

class DailyDataModel {
  final DateTime date;
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double soilPh;
  final double lightIntensity;

  DailyDataModel({
    required this.date,
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.soilPh,
    required this.lightIntensity,
  });

  factory DailyDataModel.fromJson(Map<String, dynamic> json) {
    return DailyDataModel(
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      temperature: (json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['humidity'] ?? 0.0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? 0.0).toDouble(),
      soilPh: (json['soilPh'] ?? 0.0).toDouble(),
      lightIntensity: (json['lightIntensity'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'soilPh': soilPh,
      'lightIntensity': lightIntensity,
    };
  }
}

class WeeklyDataModel {
  final List<DailyDataModel> dailyData;
  final Map<String, dynamic> summary;

  WeeklyDataModel({
    required this.dailyData,
    required this.summary,
  });

  factory WeeklyDataModel.fromJson(Map<String, dynamic> json) {
    return WeeklyDataModel(
      dailyData: (json['dailyData'] as List<dynamic>?)
          ?.map((item) => DailyDataModel.fromJson(item))
          .toList() ?? [],
      summary: json['summary'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyData': dailyData.map((item) => item.toJson()).toList(),
      'summary': summary,
    };
  }
}

class GrowthStageInfo {
  final String stage;
  final String name;
  final String description;
  final int days;

  GrowthStageInfo({
    required this.stage,
    required this.name,
    required this.description,
    required this.days,
  });

  factory GrowthStageInfo.fromJson(Map<String, dynamic> json) {
    return GrowthStageInfo(
      stage: json['stage'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      days: json['days'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'name': name,
      'description': description,
      'days': days,
    };
  }
}

class GrowthStageAnalysisModel {
  final String currentStage;
  final int progressPercentage;
  final String stageDescription;
  final List<GrowthStageInfo> stageInfo;
  final DateTime expectedHarvest;

  GrowthStageAnalysisModel({
    required this.currentStage,
    required this.progressPercentage,
    required this.stageDescription,
    required this.stageInfo,
    required this.expectedHarvest,
  });

  factory GrowthStageAnalysisModel.fromJson(Map<String, dynamic> json) {
    return GrowthStageAnalysisModel(
      currentStage: json['currentStage'] ?? 'Unknown',
      progressPercentage: json['progressPercentage'] ?? 0,
      stageDescription: json['stageDescription'] ?? '',
      stageInfo: (json['stageInfo'] as List<dynamic>?)
          ?.map((item) => GrowthStageInfo.fromJson(item))
          .toList() ?? [],
      expectedHarvest: DateTime.parse(json['expectedHarvest'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStage': currentStage,
      'progressPercentage': progressPercentage,
      'stageDescription': stageDescription,
      'stageInfo': stageInfo.map((item) => item.toJson()).toList(),
      'expectedHarvest': expectedHarvest.toIso8601String(),
    };
  }
}

class PrescriptionModel {
  final String id;
  final String action;
  final String details;
  final String urgency;
  final String timeline;
  final String category;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? completedAt;

  PrescriptionModel({
    required this.id,
    required this.action,
    required this.details,
    required this.urgency,
    required this.timeline,
    required this.category,
    this.isCompleted = false,
    required this.createdAt,
    this.completedAt,
  });

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] ?? '',
      action: json['action'] ?? '',
      details: json['details'] ?? '',
      urgency: json['urgency'] ?? 'MEDIUM',
      timeline: json['timeline'] ?? '',
      category: json['category'] ?? 'general',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completedAt'] != null 
          ? DateTime.parse(json['completedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'action': action,
      'details': details,
      'urgency': urgency,
      'timeline': timeline,
      'category': category,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  PrescriptionModel copyWith({
    String? id,
    String? action,
    String? details,
    String? urgency,
    String? timeline,
    String? category,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? completedAt,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      action: action ?? this.action,
      details: details ?? this.details,
      urgency: urgency ?? this.urgency,
      timeline: timeline ?? this.timeline,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class AnalyticsData {
  final CropConditionModel? cropCondition;
  final MetricsModel? currentMetrics;
  final WeeklyDataModel? weeklyData;
  final GrowthStageAnalysisModel? growthStageAnalysis;
  final List<PrescriptionModel> prescriptions;

  AnalyticsData({
    this.cropCondition,
    this.currentMetrics,
    this.weeklyData,
    this.growthStageAnalysis,
    this.prescriptions = const [],
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      cropCondition: json['cropCondition'] != null 
          ? CropConditionModel.fromJson(json['cropCondition']) 
          : null,
      currentMetrics: json['currentMetrics'] != null 
          ? MetricsModel.fromJson(json['currentMetrics']) 
          : null,
      weeklyData: json['weeklyData'] != null 
          ? WeeklyDataModel.fromJson(json['weeklyData']) 
          : null,
      growthStageAnalysis: json['growthStageAnalysis'] != null 
          ? GrowthStageAnalysisModel.fromJson(json['growthStageAnalysis']) 
          : null,
      prescriptions: (json['prescriptions'] as List<dynamic>?)
          ?.map((item) => PrescriptionModel.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cropCondition': cropCondition?.toJson(),
      'currentMetrics': currentMetrics?.toJson(),
      'weeklyData': weeklyData?.toJson(),
      'growthStageAnalysis': growthStageAnalysis?.toJson(),
      'prescriptions': prescriptions.map((item) => item.toJson()).toList(),
    };
  }
}