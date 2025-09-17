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
  final String parameter;
  final String value;
  final String recommendation;
  @JsonKey(name: 'status')
  final String statusString;
  @JsonKey(name: 'createdAt')
  final String createdAt;
  @JsonKey(name: 'isCompleted')
  final bool isCompleted;
  @JsonKey(name: 'fieldId')
  final String fieldId;
  @JsonKey(name: 'growthStage')
  final String growthStage;
  @JsonKey(name: 'impactScore')
  final double impactScore;

  const PrescriptionModel({
    required this.id,
    required this.parameter,
    required this.value,
    required this.recommendation,
    required this.statusString,
    required this.createdAt,
    required this.isCompleted,
    required this.fieldId,
    required this.growthStage,
    required this.impactScore,
  });

  // Convert JSON to PrescriptionModel
  factory PrescriptionModel.fromJson(Map<String, dynamic> json) =>
      _$PrescriptionModelFromJson(json);

  // Convert PrescriptionModel to JSON
  Map<String, dynamic> toJson() => _$PrescriptionModelToJson(this);

  // Convert to entity
  Prescription toEntity() {
    return Prescription(
      id: id,
      parameter: parameter,
      value: value,
      recommendation: recommendation,
      status: _mapStatusStringToEnum(statusString),
      timestamp: DateTime.parse(createdAt),
      isCompleted: isCompleted,
      fieldId: fieldId,
      growthStage: growthStage,
      impactScore: impactScore,
    );
  }

  // Convert from entity
  factory PrescriptionModel.fromEntity(Prescription entity) {
    return PrescriptionModel(
      id: entity.id,
      parameter: entity.parameter,
      value: entity.value,
      recommendation: entity.recommendation,
      statusString: _mapStatusEnumToString(entity.status),
      createdAt: entity.timestamp.toIso8601String(),
      isCompleted: entity.isCompleted,
      fieldId: entity.fieldId,
      growthStage: entity.growthStage,
      impactScore: entity.impactScore,
    );
  }

  static PrescriptionStatus _mapStatusStringToEnum(String status) {
    switch (status.toLowerCase()) {
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
        return 'high';
      case PrescriptionStatus.medium:
        return 'medium';
      case PrescriptionStatus.low:
        return 'low';
    }
  }

  @override
  List<Object?> get props => [
        id,
        parameter,
        value,
        recommendation,
        statusString,
        createdAt,
        isCompleted,
        fieldId,
        growthStage,
        impactScore,
      ];
      
  @override
  String toString() => 'PrescriptionModel(${toJson()})';
}
