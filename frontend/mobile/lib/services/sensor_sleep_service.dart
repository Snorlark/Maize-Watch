import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class SensorSleepService {
  static final SensorSleepService _instance = SensorSleepService._internal();
  factory SensorSleepService() => _instance;
  SensorSleepService._internal();

  final ApiService _apiService = ApiService();
  final NotificationService _notificationService = NotificationService();
  
  // Timer for checking sensor status
  Timer? _checkTimer;
  
  // Current sensor status
  Map<String, bool> _currentSensorStatus = {
    'ldr': false,
    'ph': false,
    'dht': false,
    'soil': false,
  };
  
  // Previous sensor status for comparison
  Map<String, bool> _previousSensorStatus = {
    'ldr': false,
    'ph': false,
    'dht': false,
    'soil': false,
  };

  // Sensor names for display
  final Map<String, String> _sensorNames = {
    'ldr': 'Light Sensor',
    'ph': 'pH Sensor',
    'dht': 'Temperature & Humidity Sensor',
    'soil': 'Soil Moisture Sensor',
  };

  // Initialize the service
  void initialize() {
    if (_checkTimer != null) return; // Already initialized
    
    // Load previous status from storage
    _loadPreviousStatus();
    
    // Start checking sensor status every 30 seconds
    _checkTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _checkSensorStatus();
    });
  }

  // Load previous sensor status from storage
  Future<void> _loadPreviousStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusJson = prefs.getString('sensor_sleep_status');
      if (statusJson != null) {
        final status = json.decode(statusJson) as Map<String, dynamic>;
        _previousSensorStatus = Map<String, bool>.from(status);
        _currentSensorStatus = Map<String, bool>.from(status);
      }
    } catch (e) {
      print('Error loading sensor status: $e');
    }
  }

  // Save current sensor status to storage
  Future<void> _saveCurrentStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('sensor_sleep_status', json.encode(_currentSensorStatus));
    } catch (e) {
      print('Error saving sensor status: $e');
    }
  }

  // Check sensor status from API
  Future<void> _checkSensorStatus() async {
    try {
      // Get latest sensor readings
      final readings = await _apiService.getLatestReadings();
      if (readings.isEmpty) {
        print('No sensor readings available');
        return;
      }

      final latestReading = readings.first;
      
      // Update current status based on ThingSpeak data
      _currentSensorStatus = {
        'ldr': latestReading.lightIntensity > 0,
        'ph': latestReading.soilPh > 0,
        'dht': latestReading.temperature > 0,
        'soil': latestReading.soilMoisture > 0,
      };

      // Check for status changes and send notifications
      await _checkStatusChanges();
      
      // Save current status
      await _saveCurrentStatus();
      
    } catch (e) {
      print('Error checking sensor status: $e');
    }
  }

  // Check for status changes and send notifications
  Future<void> _checkStatusChanges() async {
    final changedSensors = <String>[];
    final inactiveSensors = <String>[];
    final activeSensors = <String>[];

    for (final entry in _currentSensorStatus.entries) {
      final sensorKey = entry.key;
      final currentStatus = entry.value;
      final previousStatus = _previousSensorStatus[sensorKey] ?? false;

      if (currentStatus != previousStatus) {
        changedSensors.add(sensorKey);
        
        if (currentStatus) {
          activeSensors.add(_sensorNames[sensorKey] ?? sensorKey);
        } else {
          inactiveSensors.add(_sensorNames[sensorKey] ?? sensorKey);
        }
      }
    }

    // Send notifications for status changes
    if (changedSensors.isNotEmpty) {
      print('🔔 Sensor status changes detected: $changedSensors');
      
      // Send individual notifications for each changed sensor
      for (final sensorKey in changedSensors) {
        final isActive = _currentSensorStatus[sensorKey]!;
        final sensorName = _sensorNames[sensorKey] ?? sensorKey;
        
        await _notificationService.showSensorStatusNotification(
          sensorName: sensorName,
          isActive: isActive,
        );
        
        // Add delay between notifications
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Also send a summary notification if multiple sensors changed
      if (changedSensors.length > 1) {
        await _notificationService.showMultipleSensorsStatusNotification(
          inactiveSensors: inactiveSensors,
          activeSensors: activeSensors,
        );
      }
    }

    // Update previous status
    _previousSensorStatus = Map<String, bool>.from(_currentSensorStatus);
  }

  // Get current sensor status
  Map<String, bool> get currentSensorStatus => Map<String, bool>.from(_currentSensorStatus);

  // Check if a specific sensor is active
  bool isSensorActive(String sensorKey) {
    return _currentSensorStatus[sensorKey] ?? false;
  }

  // Get sensor status for display
  Map<String, Map<String, dynamic>> getSensorStatusForDisplay() {
    return _currentSensorStatus.map((key, value) {
      return MapEntry(key, {
        'name': _sensorNames[key] ?? key,
        'isActive': value,
        'status': value ? 'Active' : 'Inactive',
      });
    });
  }

  // Force refresh sensor status
  Future<void> refreshSensorStatus() async {
    await _checkSensorStatus();
  }

  // Dispose resources
  void dispose() {
    _checkTimer?.cancel();
    _checkTimer = null;
  }

  // Add a public method to check sensor status
  Future<void> checkSensorStatus() async {
    await _checkSensorStatus();
  }
} 