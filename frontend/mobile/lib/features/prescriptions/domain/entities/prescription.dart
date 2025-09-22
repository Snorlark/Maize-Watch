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
  
  // Additional fields for detailed view
  final String? title;
  final String? category;
  final String? priority;
  final DateTime? dueDate;
  final String? estimatedDuration;
  final List<String>? materials;
  final List<String>? instructions;
  final String? urgency;
  final String? timeline;
  final String? fieldName;
  final String? soilType;

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
    this.title,
    this.category,
    this.priority,
    this.dueDate,
    this.estimatedDuration,
    this.materials,
    this.instructions,
    this.urgency,
    this.timeline,
    this.fieldName,
    this.soilType,
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
        title,
        category,
        priority,
        dueDate,
        estimatedDuration,
        materials,
        instructions,
        urgency,
        timeline,
        fieldName,
        soilType,
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
    String? title,
    String? category,
    String? priority,
    DateTime? dueDate,
    String? estimatedDuration,
    List<String>? materials,
    List<String>? instructions,
    String? urgency,
    String? timeline,
    String? fieldName,
    String? soilType,
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
      title: title ?? this.title,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      materials: materials ?? this.materials,
      instructions: instructions ?? this.instructions,
      urgency: urgency ?? this.urgency,
      timeline: timeline ?? this.timeline,
      fieldName: fieldName ?? this.fieldName,
      soilType: soilType ?? this.soilType,
    );
  }
}
