import '../../domain/entities/farm.dart';

class FarmModel extends Farm {
  const FarmModel({
    super.id,
    required super.userId,
    required super.fieldName,
    required super.location,
    required super.soilType,
    required super.plantingDate,
    required super.growthStage,
    super.deviceId,
    super.deviceMacAddress,
    super.deviceRegisteredAt,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    return FarmModel(
      id: json['_id'] ?? json['id'],
      userId: json['userId'],
      fieldName: json['fieldName'],
      location: json['location'],
      soilType: json['soilType'],
      plantingDate: DateTime.parse(json['plantingDate']),
      growthStage: json['growthStage'],
      deviceId: json['deviceId'],
      deviceMacAddress: json['deviceMacAddress'],
      deviceRegisteredAt: json['deviceRegisteredAt'] != null
          ? DateTime.parse(json['deviceRegisteredAt'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'fieldName': fieldName,
      'location': location,
      'soilType': soilType,
      'plantingDate': plantingDate.toIso8601String(),
      'growthStage': growthStage,
      if (deviceId != null) 'deviceId': deviceId,
      if (deviceMacAddress != null) 'deviceMacAddress': deviceMacAddress,
      if (deviceRegisteredAt != null)
        'deviceRegisteredAt': deviceRegisteredAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory FarmModel.fromEntity(Farm farm) {
    return FarmModel(
      id: farm.id,
      userId: farm.userId,
      fieldName: farm.fieldName,
      location: farm.location,
      soilType: farm.soilType,
      plantingDate: farm.plantingDate,
      growthStage: farm.growthStage,
      deviceId: farm.deviceId,
      deviceMacAddress: farm.deviceMacAddress,
      deviceRegisteredAt: farm.deviceRegisteredAt,
      createdAt: farm.createdAt,
      updatedAt: farm.updatedAt,
    );
  }
}
