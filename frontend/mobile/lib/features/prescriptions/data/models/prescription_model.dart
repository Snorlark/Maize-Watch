import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

part 'prescription_model.g.dart';

@JsonSerializable(
  explicitToJson: true,
  includeIfNull: false,
  fieldRename: FieldRename.snake,
  createToJson: true,
  createFactory: true,
)
class PrescriptionModel extends Equatable {
  final String id;
  final String farmId;
  final String title;
  final String description;
  final String priority;
  final String status;
  final String dueDate;
  final String createdAt;
  final String updatedAt;
  final String category;
  final String estimatedDuration;
  final List<String> materials;
  final List<String> instructions;

  const PrescriptionModel({
    required this.id,
    required this.farmId,
    required this.title,
    required this.description,
    required this.priority,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    required this.updatedAt,
    required this.category,
    required this.estimatedDuration,
    required this.materials,
    required this.instructions,
  });

  // Convert JSON to PrescriptionModel
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id']?.toString() ?? '',
      farmId: json['farmId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      priority: json['priority']?.toString() ?? 'low',
      status: json['status']?.toString() ?? 'pending',
      dueDate: json['dueDate']?.toString() ?? DateTime.now().toIso8601String(),
      createdAt: json['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
      updatedAt: json['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
      category: json['category']?.toString() ?? 'general',
      estimatedDuration: json['estimatedDuration']?.toString() ?? '1 hour',
      materials: (json['materials'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      instructions: (json['instructions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  // Convert PrescriptionModel to JSON
  Map<String, dynamic> toJson() => _$PrescriptionModelToJson(this);

  // Convert to entity
  Prescription toEntity() {
    return Prescription(
      id: id,
      parameter: _mapCategoryToParameter(category),
      value: _mapPriorityToValue(priority),
      recommendation: description,
      status: _mapStatusStringToEnum(status),
      timestamp: DateTime.tryParse(createdAt) ?? DateTime.now(),
      isCompleted: status == 'completed',
      fieldId: farmId, // Using farmId as fieldId for now
      growthStage: 'V8', // Default growth stage
      impactScore: _mapPriorityToImpactScore(priority),
      // Additional fields for detailed view
      title: title,
      category: category,
      priority: priority,
      dueDate: DateTime.tryParse(dueDate) ?? DateTime.now(),
      estimatedDuration: estimatedDuration,
      materials: materials,
      instructions: instructions,
      urgency: _mapPriorityToUrgency(priority),
      timeline: _mapPriorityToTimeline(priority),
      fieldName: _getFieldName(),
      soilType: _getSoilType(),
    );
  }

  // Convert from entity
  factory PrescriptionModel.fromEntity(Prescription entity) {
    return PrescriptionModel(
      id: entity.id,
      farmId: entity.fieldId,
      title: entity.recommendation,
      description: entity.recommendation,
      priority: entity.value,
      status: _mapStatusEnumToString(entity.status),
      dueDate: entity.timestamp.add(const Duration(days: 1)).toIso8601String(),
      createdAt: entity.timestamp.toIso8601String(),
      updatedAt: entity.timestamp.toIso8601String(),
      category: entity.parameter,
      estimatedDuration: '2 hours',
      materials: ['Materials needed'],
      instructions: ['Follow instructions'],
    );
  }

  static PrescriptionStatus _mapStatusStringToEnum(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return PrescriptionStatus.high;
      case 'completed':
        return PrescriptionStatus.low;
      case 'high':
        return PrescriptionStatus.high;
      case 'medium':
        return PrescriptionStatus.medium;
      case 'low':
      default:
        return PrescriptionStatus.low;
    }
  }

  static String _mapStatusEnumToString(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.high:
        return 'pending';
      case PrescriptionStatus.medium:
        return 'pending';
      case PrescriptionStatus.low:
        return 'completed';
    }
  }

  static double _mapPriorityToImpactScore(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 0.9;
      case 'medium':
        return 0.6;
      case 'low':
      default:
        return 0.3;
    }
  }

  String _mapCategoryToParameter(String category) {
    switch (category.toLowerCase()) {
      case 'irrigation':
        return 'SOIL MOISTURE';
      case 'soil_management':
        return 'SOIL PH';
      case 'pest_management':
        return 'PEST CONTROL';
      case 'fertilization':
        return 'NUTRIENTS';
      case 'temperature_control':
        return 'TEMPERATURE';
      case 'lighting':
        return 'LIGHT INTENSITY';
      default:
        return category.toUpperCase();
    }
  }

  String _mapPriorityToValue(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return '31.1 (high)';
      case 'medium':
        return '0 (critically_low)';
      case 'low':
        return '3809 (low)';
      default:
        return 'normal';
    }
  }

  String _mapPriorityToUrgency(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'URGENT';
      case 'medium':
        return 'HIGH';
      case 'low':
        return 'MEDIUM';
      default:
        return 'MEDIUM';
    }
  }

  String _mapPriorityToTimeline(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return 'Today';
      case 'medium':
        return 'This week';
      case 'low':
        return 'Next week';
      default:
        return 'This week';
    }
  }

  String _getFieldName() {
    // This would ideally come from the backend, but for now use a default
    return 'Main Field';
  }

  String _getSoilType() {
    // This would ideally come from the backend, but for now use a default
    return 'Loam';
  }

  @override
  List<Object?> get props => [
        id,
        farmId,
        title,
        description,
        priority,
        status,
        dueDate,
        createdAt,
        updatedAt,
        category,
        estimatedDuration,
        materials,
        instructions,
      ];
      
  @override
  String toString() => 'PrescriptionModel(${toJson()})';
}
