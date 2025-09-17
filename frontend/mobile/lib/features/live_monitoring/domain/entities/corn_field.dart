import 'package:equatable/equatable.dart';

class CornField extends Equatable {
  final String id;
  final String fieldName;
  final String farmId;
  final String cornVariety;
  final String growthStage;
  final DateTime plantingDate;
  final String soilType;
  final String? location;
  final Map<String, dynamic>? metadata;

  const CornField({
    required this.id,
    required this.farmId,
    required this.fieldName,
    required this.cornVariety,
    required this.growthStage,
    required this.plantingDate,
    required this.soilType,
    this.location,
    this.metadata,
    required String growthStageDescription,
    required int daysFromPlanting,
  });

  @override
  List<Object?> get props => [
    id,
    fieldName,
    cornVariety,
    growthStage,
    plantingDate,
    soilType,
    location,
    metadata,
  ];

  CornField copyWith({
    String? id,
    String? farmId,
    String? fieldName,
    String? cornVariety,
    String? growthStage,
    DateTime? plantingDate,
    String? soilType,
    String? location,
    Map<String, dynamic>? metadata,
  }) {
    return CornField(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      fieldName: fieldName ?? this.fieldName,
      cornVariety: cornVariety ?? this.cornVariety,
      growthStage: growthStage ?? this.growthStage,
      plantingDate: plantingDate ?? this.plantingDate,
      soilType: soilType ?? this.soilType,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
      growthStageDescription: '',
      daysFromPlanting: 0,
    );
  }

  int get daysFromPlanting {
    return DateTime.now().difference(plantingDate).inDays;
  }

  String get growthStageDescription {
    switch (growthStage.toUpperCase()) {
      case 'VE':
        return 'Emergence';
      case 'V3':
        return 'Third Leaf';
      case 'V6':
        return 'Sixth Leaf';
      case 'VT':
        return 'Tasseling';
      case 'R1':
        return 'Silking';
      case 'R2':
        return 'Blister';
      case 'R3':
        return 'Milk';
      case 'R4':
        return 'Dough';
      case 'R5':
        return 'Dent';
      case 'R6':
        return 'Physiological Maturity';
      default:
        return growthStage;
    }
  }
}
