// lib/services/prescription_list.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maize_watch/model/prescription_model.dart';

// Default prescription list in case we can't fetch from the API
List<Map<String, dynamic>> PrescriptionList = [
  {
    "id": "1",
    "title": "Apply Nitrogen Fertilizer",
    "value": "150 kg/ha",
    "date": "19/05/2025",
    "time": "08:00 AM",
    "isChecked": false,
    "fieldId": "field1",
    "category": "Nutrition",
    "priority": 1,
    "description": "Soil tests indicate nitrogen deficiency. Apply fertilizer evenly across the field."
  },
  {
    "id": "2",
    "title": "Water Field Section A",
    "value": "25mm",
    "date": "18/05/2025",
    "time": "06:30 AM",
    "isChecked": true,
    "fieldId": "field1",
    "category": "Moisture",
    "priority": 2,
    "description": "Soil moisture levels are dropping. Apply irrigation to maintain optimal growth."
  },
  {
    "id": "3",
    "title": "Apply Lime to Adjust pH",
    "value": "2 tons/ha",
    "date": "15/05/2025",
    "time": "10:00 AM",
    "isChecked": true,
    "fieldId": "field1",
    "category": "Soil pH",
    "priority": 2,
    "description": "Soil pH is too acidic at 5.2. Apply agricultural lime to raise pH to optimal range."
  },
  {
    "id": "4",
    "title": "Scout for Fall Armyworm",
    "value": "Check 20 plants",
    "date": "20/05/2025",
    "time": "09:00 AM",
    "isChecked": false,
    "fieldId": "field1",
    "category": "Pest",
    "priority": 1,
    "description": "Sensor data indicates conditions favorable for Fall Armyworm. Inspect plants for early infestation."
  },
  {
    "id": "5",
    "title": "Apply Phosphorus Fertilizer",
    "value": "80 kg/ha",
    "date": "21/05/2025",
    "time": "07:00 AM",
    "isChecked": false,
    "fieldId": "field1",
    "category": "Nutrition",
    "priority": 3,
    "description": "Soil tests show moderate phosphorus deficiency. Apply during V3 stage for optimal effect."
  },
];

// Function to convert from API response format to Prescription objects
List<Prescription> convertToPrescriptionObjects(List<Map<String, dynamic>> data) {
  return data.map((item) => Prescription.fromJson(item)).toList();
}

// Format the current date using the intl package
String formatCurrentDate() {
  final now = DateTime.now();
  final formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(now);
}

// Format the current time using the intl package
String formatCurrentTime() {
  final now = DateTime.now();
  final formatter = DateFormat('hh:mm a');
  return formatter.format(now);
}