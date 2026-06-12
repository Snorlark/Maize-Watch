import 'package:equatable/equatable.dart';

class Field extends Equatable {
  final String? id;
  final String farmId;
  final String fieldName;
  final String soilType;
  final DateTime plantingDate;
  final String growthStage;
  final List<Map<String, dynamic>>? devices;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Field({
    this.id,
    required this.farmId,
    required this.fieldName,
    required this.soilType,
    required this.plantingDate,
    required this.growthStage,
    this.devices,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate days since planting
  int get daysSincePlanting {
    final now = DateTime.now();
    return now.difference(plantingDate).inDays;
  }

  // Auto-calculate growth stage based on planting date
  String get calculatedGrowthStage {
    final days = daysSincePlanting;
    if (days <= 7) return 'VE'; // Emergence (0-7 days)
    if (days <= 21) return 'V3'; // 3rd leaf (8-21 days)
    if (days <= 42) return 'V8'; // 8th leaf (22-42 days)
    if (days <= 65) return 'VT'; // Tasseling (43-65 days)
    if (days <= 85) return 'R1'; // Silking (66-85 days)
    return 'R6'; // Maturity (86+ days)
  }

  // Get growth stage description
  String get growthStageDescription {
    switch (growthStage) {
      case 'VE':
        return 'Emergence Stage';
      case 'V3':
        return 'Third Leaf Stage';
      case 'V8':
        return 'Eighth Leaf Stage';
      case 'VT':
        return 'Tasseling Stage';
      case 'R1':
        return 'Silking Stage';
      case 'R6':
        return 'Maturity Stage';
      default:
        return 'Unknown Stage';
    }
  }

  // Check if field has devices
  bool get hasDevices => devices != null && devices!.isNotEmpty;

  Field copyWith({
    String? id,
    String? farmId,
    String? fieldName,
    String? soilType,
    DateTime? plantingDate,
    String? growthStage,
    List<Map<String, dynamic>>? devices,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Field(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      fieldName: fieldName ?? this.fieldName,
      soilType: soilType ?? this.soilType,
      plantingDate: plantingDate ?? this.plantingDate,
      growthStage: growthStage ?? this.growthStage,
      devices: devices ?? this.devices,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'fieldName': fieldName,
      'soilType': soilType,
      'plantingDate': plantingDate.toIso8601String(),
      'growthStage': growthStage,
      'devices': devices,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Field.fromJson(Map<String, dynamic> json) {
    // Handle the actual backend response structure
    // Backend returns 'sensors' but we expect 'devices'
    List<Map<String, dynamic>>? devices;
    if (json['sensors'] != null) {
      devices = List<Map<String, dynamic>>.from(json['sensors']);
    } else if (json['devices'] != null) {
      devices = List<Map<String, dynamic>>.from(json['devices']);
    }

    // Get soilType from the first sensor if available, otherwise use default
    String soilType = 'loamy'; // default
    if (devices != null && devices.isNotEmpty) {
      soilType = devices.first['soilType'] ?? 'loamy';
    }

    return Field(
      id: json['id'] ?? json['_id'],
      farmId: json['farmId'] ?? '', // This will be set by the parent Farm
      fieldName: json['fieldName'] ?? '',
      soilType: soilType,
      plantingDate: DateTime.parse(json['plantingDate']),
      growthStage: json['growthStage'] ?? 'VE',
      devices: devices,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    farmId,
    fieldName,
    soilType,
    plantingDate,
    growthStage,
    devices,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'Field('
        'id: $id, '
        'farmId: $farmId, '
        'fieldName: $fieldName, '
        'soilType: $soilType, '
        'plantingDate: $plantingDate, '
        'growthStage: $growthStage, '
        'devices: ${devices?.length ?? 0} devices, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }
}
