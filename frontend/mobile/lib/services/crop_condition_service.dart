import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:maize_watch/model/sensor_data_model.dart';
import 'package:maize_watch/services/api_service.dart';
import 'package:maize_watch/services/prescription_service.dart';

class CropConditionService {
  // Singleton pattern
  static final CropConditionService _instance = CropConditionService._internal();
  factory CropConditionService() => _instance;
  CropConditionService._internal();

  // Services
  final ApiService _apiService = ApiService();
  final PrescriptionService _prescriptionService = PrescriptionService();
  
  // ValueNotifier to broadcast condition data changes
  final ValueNotifier<SensorReading?> currentDataNotifier = ValueNotifier(null);
  
  // Timer for refreshing data
  Timer? _dataRefreshTimer;
  bool _isUpdating = false;

  // Status tracking
  bool get isUpdating => _isUpdating;
  
  // Initialize the service
  void initialize() {
    if (_dataRefreshTimer != null) return; // Already initialized
    
    // Load initial data
    _loadLatestData();
    
    // Start polling for updates
    _dataRefreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _loadLatestData();
    });
  }

  // Load latest sensor data
  Future<void> _loadLatestData() async {
    if (_isUpdating) return;
    
    _isUpdating = true;
    
    try {
      final latestReadings = await _apiService.getLatestReadings();
      if (latestReadings.isNotEmpty) {
        currentDataNotifier.value = latestReadings.first;
      }
    } catch (e) {
      print('Error loading latest crop condition data: $e');
    } finally {
      _isUpdating = false;
    }
  }

  // Force refresh data
  Future<void> refreshData() async {
    await _loadLatestData();
  }

  // Calculate crop health status
  String getCropHealthStatus(SensorReading? data) {
    if (data == null) return 'Unknown';
    
    final soilMoisture = data.soilMoisture;
    final temperature = data.temperature;
    final humidity = data.humidity;
    final lightLevel = data.lightIntensity;
    
    // Define ideal ranges for corn
    final bool moistureGood = soilMoisture >= 40 && soilMoisture <= 70;
    final bool temperatureGood = temperature >= 15 && temperature <= 30;
    final bool humidityGood = humidity >= 40 && humidity <= 80;
    final bool lightGood = lightLevel >= 30;
    
    // Count how many parameters are in good range
    int goodCount = 0;
    if (moistureGood) goodCount++;
    if (temperatureGood) goodCount++;
    if (humidityGood) goodCount++;
    if (lightGood) goodCount++;
    
    // Determine status based on good parameter count
    if (goodCount == 4) {
      return 'Excellent';
    } else if (goodCount == 3) {
      return 'Good';
    } else if (goodCount == 2) {
      return 'Fair';
    } else if (goodCount == 1) {
      return 'Poor';
    } else {
      return 'Critical';
    }
  }
  
  // Get specific issue descriptions based on sensor readings
  List<String> getCropIssues(SensorReading? data) {
    if (data == null) return ['No data available'];
    
    final List<String> issues = [];
    final soilMoisture = data.soilMoisture;
    final temperature = data.temperature;
    final humidity = data.humidity;
    final lightLevel = data.lightIntensity;
    
    // Check each parameter and add issues if outside ideal ranges
    if (soilMoisture < 40) {
      issues.add('Soil too dry - needs irrigation');
    } else if (soilMoisture > 70) {
      issues.add('Soil too wet - possible waterlogging');
    }
    
    if (temperature < 15) {
      issues.add('Temperature too low for optimal growth');
    } else if (temperature > 30) {
      issues.add('Temperature too high - heat stress risk');
    }
    
    if (humidity < 40) {
      issues.add('Low humidity may stress plants');
    } else if (humidity > 80) {
      issues.add('High humidity - disease risk increased');
    }
    
    if (lightLevel < 30) {
      issues.add('Insufficient light for optimal photosynthesis');
    }
    
    return issues.isEmpty ? ['No issues detected'] : issues;
  }

  // Get color representing crop health
  Color getCropHealthColor(SensorReading? data) {
    String status = getCropHealthStatus(data);
    
    switch (status) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.lightGreen;
      case 'Fair':
        return Colors.amber;
      case 'Poor':
        return Colors.orange;
      case 'Critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Get overall status from analytics
  Future<String> getOverallStatus(BuildContext context) async {
    try {
      final userData = await _apiService.getUserData();
      if (userData == null) return 'Unknown';
      
      final userId = userData['id'] ?? userData['_id'];
      if (userId == null) return 'Unknown';
      
      final result = await _prescriptionService.checkForNewPrescriptions(context);
      if (result['success'] == true && result['hasNewPrescriptions'] == true) {
        final prescriptions = result['prescriptions'] as List<Map<String, dynamic>>;
        if (prescriptions.isNotEmpty) {
          // Get the highest priority prescription's severity
          final highestPriority = prescriptions.reduce((a, b) {
            int aPriority = a['priority'] is int ? a['priority'] : (a['priority'] is String ? int.tryParse(a['priority']) ?? 2 : 2);
            int bPriority = b['priority'] is int ? b['priority'] : (b['priority'] is String ? int.tryParse(b['priority']) ?? 2 : 2);
            return aPriority < bPriority ? a : b;
          });
          return (highestPriority['priority'] is int ? highestPriority['priority'] : int.tryParse(highestPriority['priority'].toString()) ?? 2) == 1 ? 'CRITICAL' : 'WARNING';
        }
      }
      return 'NORMAL';
    } catch (e) {
      print('Error getting overall status: $e');
      return 'NORMAL';
    }
  }

  // Get color for overall status
  Color getOverallStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'CRITICAL':
        return Colors.red;
      case 'WARNING':
        return Colors.orange;
      case 'NORMAL':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Properly dispose of resources
  void dispose() {
    _dataRefreshTimer?.cancel();
    _dataRefreshTimer = null;
  }
}