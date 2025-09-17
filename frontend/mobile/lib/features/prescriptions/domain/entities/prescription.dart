import 'package:equatable/equatable.dart';

enum PrescriptionStatus { low, medium, high }

class Prescription extends Equatable {
  final String id;
  final String parameter;
  final String value;
  final String recommendation;
  final PrescriptionStatus status;
  final DateTime timestamp;
  final bool isCompleted;
  final String fieldId;
  final String growthStage;
  final double impactScore;

  const Prescription({
    required this.id,
    required this.parameter,
    required this.value,
    required this.recommendation,
    required this.status,
    required this.timestamp,
    this.isCompleted = false,
    required this.fieldId,
    required this.growthStage,
    this.impactScore = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        parameter,
        value,
        recommendation,
        status,
        timestamp,
        isCompleted,
        fieldId,
        growthStage,
        impactScore,
      ];

  Prescription copyWith({
    String? id,
    String? parameter,
    String? value,
    String? recommendation,
    PrescriptionStatus? status,
    DateTime? timestamp,
    bool? isCompleted,
    String? fieldId,
    String? growthStage,
    double? impactScore,
  }) {
    return Prescription(
      id: id ?? this.id,
      parameter: parameter ?? this.parameter,
      value: value ?? this.value,
      recommendation: recommendation ?? this.recommendation,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      isCompleted: isCompleted ?? this.isCompleted,
      fieldId: fieldId ?? this.fieldId,
      growthStage: growthStage ?? this.growthStage,
      impactScore: impactScore ?? this.impactScore,
    );
  }
}
