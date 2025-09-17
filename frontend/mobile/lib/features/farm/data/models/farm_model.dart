import '../../domain/entities/farm.dart';

class FarmModel extends Farm {
  const FarmModel({
    super.id,
    required super.userId,
    required super.farmName,
    required super.location,
    required super.fields,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FarmModel.fromJson(Map<String, dynamic> json) {
    // Handle userId - it can be either a string or an object with _id
    String userIdValue = '';
    if (json['userId'] is String) {
      userIdValue = json['userId'];
    } else if (json['userId'] is Map<String, dynamic>) {
      userIdValue = json['userId']['_id'] ?? '';
    }

    return FarmModel(
      id: json['_id'] ?? json['id'],
      userId: userIdValue,
      farmName: json['farmName'] ?? '',
      location: json['location'] ?? '',
      fields: (json['fields'] as List<dynamic>? ?? [])
          .map((fieldJson) => Field.fromJson(fieldJson))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'userId': userId,
      'farmName': farmName,
      'fields': fields.map((field) => field.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Convert to JSON for API requests (excludes timestamps and userId)
  Map<String, dynamic> toApiJson() {
    return {
      'farmName': farmName,
      'location': location,
      'fields': fields.map((field) => field.toJson()).toList(),
    };
  }

  factory FarmModel.fromEntity(Farm farm) {
    return FarmModel(
      id: farm.id,
      userId: farm.userId,
      farmName: farm.farmName,
      location: farm.location,
      fields: farm.fields,
      createdAt: farm.createdAt,
      updatedAt: farm.updatedAt,
    );
  }
}
