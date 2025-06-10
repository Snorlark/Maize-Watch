import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'prescription_service.dart';
import 'sensor_sleep_service.dart';
import 'notification_service.dart';

class BackgroundService {
  static final BackgroundService _instance = BackgroundService._internal();
  factory BackgroundService() => _instance;
  BackgroundService._internal();

  final PrescriptionService _prescriptionService = PrescriptionService();
  final SensorSleepService _sensorSleepService = SensorSleepService();
  final NotificationService _notificationService = NotificationService();

  Timer? _prescriptionCheckTimer;
  Timer? _sensorCheckTimer;
  bool _isInitialized = false;

  // Initialize background services
  void initialize() {
    if (_isInitialized) return;
    
    _isInitialized = true;
    
    // Initialize services
    _sensorSleepService.initialize();
    _notificationService.initialize();
    
    // Start periodic checks
    _startPrescriptionChecks();
    _startSensorChecks();
    
    print('🔄 Background services initialized');
  }

  // Start periodic prescription checks
  void _startPrescriptionChecks() {
    // Check for new prescriptions every 5 minutes
    _prescriptionCheckTimer = Timer.periodic(const Duration(minutes: 5), (timer) async {
      await _checkForNewPrescriptions();
    });
  }

  // Start periodic sensor checks
  void _startSensorChecks() {
    // Check sensor status every 30 seconds (handled by SensorSleepService)
    // This is just for additional monitoring
    _sensorCheckTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      await _checkSensorStatus();
    });
  }

  // Check for new prescriptions
  Future<void> _checkForNewPrescriptions() async {
    try {
      // Check if notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      
      if (!notificationsEnabled) {
        return;
      }

      print('🔍 Background: Checking for new prescriptions...');
      
      // Create a dummy context for the prescription service
      final result = await _prescriptionService.checkForNewPrescriptions(
        // We'll need to handle this differently since we don't have a context
        // For now, we'll create a simple check
        _createDummyContext(),
      );
      
      if (result['success'] == true && result['hasNewPrescriptions'] == true) {
        print('✅ Background: New prescriptions found and notifications sent');
      } else {
        print('ℹ️ Background: No new prescriptions found');
      }
    } catch (e) {
      print('❌ Background: Error checking for prescriptions: $e');
    }
  }

  // Check sensor status
  Future<void> _checkSensorStatus() async {
    try {
      // Check if notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
      
      if (!notificationsEnabled) {
        return;
      }

      // The sensor sleep service handles its own checks
      // This is just for additional monitoring
      await _sensorSleepService.refreshSensorStatus();
    } catch (e) {
      print('❌ Background: Error checking sensor status: $e');
    }
  }

  // Create a dummy context for services that need it
  BuildContext _createDummyContext() {
    // This is a workaround for services that require a BuildContext
    // In a real implementation, you might want to pass the context from the UI
    throw UnimplementedError('Context required for prescription service');
  }

  // Stop background services
  void stop() {
    _prescriptionCheckTimer?.cancel();
    _sensorCheckTimer?.cancel();
    _sensorSleepService.dispose();
    _isInitialized = false;
    print('🛑 Background services stopped');
  }

  // Check if services are running
  bool get isRunning => _isInitialized;

  // Force check for new prescriptions (called from UI)
  Future<void> forceCheckPrescriptions(BuildContext context) async {
    await _checkForNewPrescriptions();
  }

  // Force check sensor status (called from UI)
  Future<void> forceCheckSensorStatus() async {
    await _checkSensorStatus();
  }
} 