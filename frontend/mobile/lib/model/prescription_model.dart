import 'package:flutter/material.dart';

class Prescription {
  final String id;
  final DateTime timestamp;
  final String parameter;
  final String value;
  final String status;
  final String recommendation;
  final int priority;
  final double impactScore;
  bool isCompleted;
  final String fieldId;
  final String growthStage;

  Prescription({
    required this.id,
    required this.timestamp,
    required this.parameter,
    required this.value,
    required this.status,
    required this.recommendation,
    required this.priority,
    required this.impactScore,
    required this.isCompleted,
    required this.fieldId,
    required this.growthStage,
  });

  // Factory method to create from JSON
  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      timestamp: json['timestamp'] is String 
          ? DateTime.parse(json['timestamp'])
          : DateTime.fromMillisecondsSinceEpoch(json['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      parameter: json['parameter'] ?? '',
      value: json['value']?.toString() ?? '',
      status: json['status'] ?? 'unknown',
      recommendation: json['recommendation'] ?? '',
      priority: json['priority'] is int
          ? json['priority']
          : (json['priority'] is String ? int.tryParse(json['priority']) ?? 2 : 2),
      impactScore: json['impactScore'] is num ? (json['impactScore'] as num).toDouble() : 0.0,
      isCompleted: json['isCompleted'] ?? false,
      fieldId: json['fieldId'] ?? '',
      growthStage: json['growthStage']?.toString() ?? 'Unknown',
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'parameter': parameter,
      'value': value,
      'status': status,
      'recommendation': recommendation,
      'priority': priority,
      'impactScore': impactScore,
      'isCompleted': isCompleted,
      'fieldId': fieldId,
      'growthStage': growthStage,
    };
  }

  // Get the color for the prescription based on priority
  Color getPriorityColor() {
    switch (priority) {
      case 1:
        return Colors.red.shade700; // High priority
      case 2:
        return Colors.orange.shade700; // Medium priority
      case 3:
        return Colors.green.shade700; // Low priority
      default:
        return Colors.blue.shade700; // Default
    }
  }

  // Get a simple priority text
  String getPriorityText() {
    switch (priority) {
      case 1:
        return 'High';
      case 2:
        return 'Medium';
      case 3:
        return 'Low';
      default:
        return 'Normal';
    }
  }

  // Helper method to get parameter icon
  IconData getParameterIcon() {
    switch (parameter.toLowerCase()) {
      case 'soil_ph':
        return Icons.science;
      case 'soil_moisture':
        return Icons.water_drop;
      case 'temperature':
        return Icons.thermostat;
      case 'humidity':
        return Icons.water;
      case 'light_intensity':
        return Icons.light_mode;
      default:
        return Icons.recommend;
    }
  }
}