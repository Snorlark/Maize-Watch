import 'package:flutter/material.dart';

class Prescription {
  final String id;
  final String title;
  final String value;
  final String date;
  final String time;
  bool isChecked;
  final String fieldId;
  final String category; // E.g., "Soil pH", "Moisture", "Temperature", "Nutrition"
  final int priority; // 1 = high, 2 = medium, 3 = low
  final String description; // Additional details about the recommendation

  Prescription({
    required this.id,
    required this.title,
    required this.value,
    required this.date,
    required this.time,
    required this.isChecked,
    required this.fieldId,
    required this.category,
    required this.priority,
    required this.description,
  });

  // Factory method to create from JSON
  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      isChecked: json['isChecked'] ?? false,
      fieldId: json['fieldId'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 2,
      description: json['description'] ?? '',
    );
  }

  // Method to convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'value': value,
      'date': date,
      'time': time,
      'isChecked': isChecked,
      'fieldId': fieldId,
      'category': category,
      'priority': priority,
      'description': description,
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

  // Helper method to get category icon
  IconData getCategoryIcon() {
    switch (category.toLowerCase()) {
      case 'soil ph':
        return Icons.science;
      case 'moisture':
        return Icons.water_drop;
      case 'temperature':
        return Icons.thermostat;
      case 'nutrition':
        return Icons.eco;
      case 'pest':
        return Icons.bug_report;
      case 'disease':
        return Icons.coronavirus;
      default:
        return Icons.recommend;
    }
  }
}