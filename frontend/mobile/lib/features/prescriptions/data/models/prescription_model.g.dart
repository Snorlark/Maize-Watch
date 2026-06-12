// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrescriptionModel _$PrescriptionModelFromJson(Map<String, dynamic> json) =>
    PrescriptionModel(
      id: json['id'] as String,
      farmId: json['farm_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      status: json['status'] as String,
      dueDate: json['due_date'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      category: json['category'] as String,
      estimatedDuration: json['estimated_duration'] as String,
      materials:
          (json['materials'] as List<dynamic>).map((e) => e as String).toList(),
      instructions:
          (json['instructions'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
    );

Map<String, dynamic> _$PrescriptionModelToJson(PrescriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'farm_id': instance.farmId,
      'title': instance.title,
      'description': instance.description,
      'priority': instance.priority,
      'status': instance.status,
      'due_date': instance.dueDate,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'category': instance.category,
      'estimated_duration': instance.estimatedDuration,
      'materials': instance.materials,
      'instructions': instance.instructions,
    };
