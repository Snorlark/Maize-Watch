class CornField {
  final String id;
  final String fieldName;
  final String location;
  final String cornVariety;
  final String soilType;
  final String growthStage;
  final DateTime plantingDate;
  final String? userId;

  CornField({
    required this.id,
    required this.fieldName,
    required this.location,
    required this.cornVariety,
    required this.soilType,
    required this.growthStage,
    required this.plantingDate,
    this.userId,
  });

  factory CornField.fromJson(Map<String, dynamic> json) {
    return CornField(
      id: json['_id'] ?? json['id'] ?? '',
      fieldName: json['fieldName'] ?? '',
      location: json['location'] ?? '',
      cornVariety: json['cornVariety'] ?? '',
      soilType: json['soilType'] ?? '',
      growthStage: json['growthStage'] ?? 'VE',  // Make sure this is getting the right property
      plantingDate: json['plantingDate'] != null 
          ? DateTime.parse(json['plantingDate']) 
          : DateTime.now(),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fieldName': fieldName,
      'location': location,
      'cornVariety': cornVariety,
      'soilType': soilType,
      'growthStage': growthStage,
      'plantingDate': plantingDate.toIso8601String(),
      'userId': userId,
    };
  }
}