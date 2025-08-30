import 'package:equatable/equatable.dart';

class Farm extends Equatable {
  final String? id;
  final String userId;
  final String fieldName;
  final String location;
  final String soilType;
  final DateTime plantingDate;
  final String growthStage;
  final String? deviceId;
  final String? deviceMacAddress;
  final DateTime? deviceRegisteredAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Farm({
    this.id,
    required this.userId,
    required this.fieldName,
    required this.location,
    required this.soilType,
    required this.plantingDate,
    required this.growthStage,
    this.deviceId,
    this.deviceMacAddress,
    this.deviceRegisteredAt,
    required this.createdAt,
    required this.updatedAt,
  });

  Farm copyWith({
    String? id,
    String? userId,
    String? fieldName,
    String? location,
    String? soilType,
    DateTime? plantingDate,
    String? growthStage,
    String? deviceId,
    String? deviceMacAddress,
    DateTime? deviceRegisteredAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Farm(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fieldName: fieldName ?? this.fieldName,
      location: location ?? this.location,
      soilType: soilType ?? this.soilType,
      plantingDate: plantingDate ?? this.plantingDate,
      growthStage: growthStage ?? this.growthStage,
      deviceId: deviceId ?? this.deviceId,
      deviceMacAddress: deviceMacAddress ?? this.deviceMacAddress,
      deviceRegisteredAt: deviceRegisteredAt ?? this.deviceRegisteredAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        fieldName,
        location,
        soilType,
        plantingDate,
        growthStage,
        deviceId,
        deviceMacAddress,
        deviceRegisteredAt,
        createdAt,
        updatedAt,
      ];
}
