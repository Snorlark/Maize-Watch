// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prescription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrescriptionModel _$PrescriptionModelFromJson(Map<String, dynamic> json) =>
    PrescriptionModel(
      id: json['id'] as String,
      parameter: json['parameter'] as String,
      value: json['value'] as String,
      recommendation: json['recommendation'] as String,
      statusString: json['status'] as String,
      createdAt: json['createdAt'] as String,
      isCompleted: json['isCompleted'] as bool,
      fieldId: json['fieldId'] as String,
      growthStage: json['growthStage'] as String,
      impactScore: (json['impactScore'] as num).toDouble(),
    );

Map<String, dynamic> _$PrescriptionModelToJson(PrescriptionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'parameter': instance.parameter,
      'value': instance.value,
      'recommendation': instance.recommendation,
      'status': instance.statusString,
      'createdAt': instance.createdAt,
      'isCompleted': instance.isCompleted,
      'fieldId': instance.fieldId,
      'growthStage': instance.growthStage,
      'impactScore': instance.impactScore,
    };
