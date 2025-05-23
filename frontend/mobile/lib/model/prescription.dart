class Prescription {
  final String id;
  final DateTime timestamp;
  final String fieldId;
  final String userId;
  final String cornGrowthStage;
  final Map<String, double> measurements;
  final List<String> alerts;
  final List<String> recommendations;
  final String severityLevel;
  final Map<String, double> importanceScores;

  Prescription({
    required this.id,
    required this.timestamp,
    required this.fieldId,
    required this.userId,
    required this.cornGrowthStage,
    required this.measurements,
    required this.alerts,
    required this.recommendations,
    required this.severityLevel,
    required this.importanceScores,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    // Convert measurements to double
    final measurements = Map<String, double>.from(
      json['measurements']?.map((key, value) => MapEntry(key, value.toDouble())) ?? {}
    );

    // Convert importance scores to double
    final importanceScores = Map<String, double>.from(
      json['importance_scores']?.map((key, value) => MapEntry(key, value.toDouble())) ?? {}
    );

    return Prescription(
      id: json['_id'].toString(),
      timestamp: DateTime.parse(json['timestamp']),
      fieldId: json['field_id'] ?? '',
      userId: json['user_id'] ?? '',
      cornGrowthStage: json['corn_growth_stage'] ?? '',
      measurements: measurements,
      alerts: List<String>.from(json['alerts'] ?? []),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      severityLevel: json['severity_level'] ?? 'NORMAL',
      importanceScores: importanceScores,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'timestamp': timestamp.toIso8601String(),
      'field_id': fieldId,
      'user_id': userId,
      'corn_growth_stage': cornGrowthStage,
      'measurements': measurements,
      'alerts': alerts,
      'recommendations': recommendations,
      'severity_level': severityLevel,
      'importance_scores': importanceScores,
    };
  }
} 