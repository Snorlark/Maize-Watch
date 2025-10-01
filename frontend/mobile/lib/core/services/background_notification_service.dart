import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile/core/services/notification_service.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/core/services/offline_cache_service.dart';
import 'package:mobile/core/services/home_screen_service.dart';
import 'package:mobile/generated/l10n.dart';

class BackgroundNotificationService {
  static Timer? _prescriptionCheckTask;
  static Timer? _sensorStatusTask;
  static Timer? _sleepModeTask;

  // Task intervals
  static const Duration prescriptionCheckInterval = Duration(minutes: 15);
  static const Duration sensorStatusInterval = Duration(minutes: 30);
  static const Duration sleepModeCheckInterval = Duration(hours: 1);

  // Notification tracking to prevent duplicates
  static final Set<String> _notifiedPrescriptions = <String>{};
  static final Set<String> _notifiedSensors = <String>{};
  static DateTime? _lastNotificationTime;
  
  // Service state tracking
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      print('🔄 BackgroundNotificationService: Already initialized, skipping...');
      return;
    }
    
    print('🔄 BackgroundNotificationService: Initializing...');
    
    // Stop any existing timers
    stopAllTimers();
    
    // Start background tasks
    _startPrescriptionCheck();
    _startSensorStatusCheck();
    _startSleepModeCheck();
    
    _isInitialized = true;
    print('✅ BackgroundNotificationService: Initialized successfully');
  }

  static void stopAllTimers() {
    _prescriptionCheckTask?.cancel();
    _sensorStatusTask?.cancel();
    _sleepModeTask?.cancel();
    
    _prescriptionCheckTask = null;
    _sensorStatusTask = null;
    _sleepModeTask = null;
    
    print('🔄 BackgroundNotificationService: All timers stopped');
  }

  static void stopAllTasks() {
    stopAllTimers();
    _isInitialized = false;
    print('🔄 BackgroundNotificationService: All tasks stopped');
  }

  static void _startPrescriptionCheck() {
    _prescriptionCheckTask = Timer.periodic(prescriptionCheckInterval, (timer) {
      _checkPrescriptions();
    });
    print('🔄 BackgroundNotificationService: Prescription check timer started');
  }

  static void _startSensorStatusCheck() {
    _sensorStatusTask = Timer.periodic(sensorStatusInterval, (timer) {
      _checkSensorStatus();
    });
    print('🔄 BackgroundNotificationService: Sensor status check timer started');
  }

  static void _startSleepModeCheck() {
    _sleepModeTask = Timer.periodic(sleepModeCheckInterval, (timer) {
      _checkSleepMode();
    });
    print('🔄 BackgroundNotificationService: Sleep mode check timer started');
  }

  static Future<void> _checkPrescriptions() async {
    try {
      print('🔄 BackgroundNotificationService: Checking prescriptions...');
      
      // Check if notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      if (!notificationsEnabled) {
        print('🔄 BackgroundNotificationService: Notifications disabled, skipping prescription check');
        return;
      }

      // Get user data
      final userDataString = await SecureStorage.getUserData();
      if (userDataString == null) {
        print('🔄 BackgroundNotificationService: No user data, skipping prescription check');
        return;
      }

      final userData = json.decode(userDataString);
      final userId = userData['_id'];
      if (userId == null) {
        print('🔄 BackgroundNotificationService: No user ID, skipping prescription check');
        return;
      }

      // Get token
      final token = await SecureStorage.getToken();
      if (token == null) {
        print('🔄 BackgroundNotificationService: No token, skipping prescription check');
        return;
      }

      // Make API call to get prescriptions
      final response = await http.get(
        Uri.parse('https://maize-watch-app.onrender.com/api/prescriptions'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prescriptions = data['data'] ?? [];
        
        if (prescriptions.isNotEmpty) {
          print('🔄 BackgroundNotificationService: Found ${prescriptions.length} prescriptions');
          
          // Cache prescriptions for offline use
          final prescriptionList = prescriptions.cast<Map<String, dynamic>>();
          await OfflineCacheService.cachePrescriptions(prescriptionList);
          
          // Check if notifications are enabled before showing
          final notificationService = NotificationService();
          final notificationsEnabled = await notificationService.areNotificationsEnabled();
          
          if (notificationsEnabled) {
            // Check if we already showed notification recently (within last 30 minutes)
            final now = DateTime.now();
            if (_lastNotificationTime == null || 
                now.difference(_lastNotificationTime!).inMinutes > 30) {
              
              // Show notification for new prescriptions
              await notificationService.showPrescriptionAlertNotification(
                title: 'New Farm Prescriptions', // Will be translated in notification service
                message: 'You have ${prescriptions.length} new farm tasks to complete',
                priority: 'high',
                notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
              );
              
              _lastNotificationTime = now;
              print('🔄 BackgroundNotificationService: Prescription notification shown');
            } else {
              print('🔄 BackgroundNotificationService: Skipping notification - already shown recently');
            }
          } else {
            print('🔄 BackgroundNotificationService: Notifications disabled, skipping prescription notification');
          }
        }
      }
    } catch (e) {
      print('🔄 BackgroundNotificationService: Error checking prescriptions: $e');
    }
  }

  static Future<void> _checkSensorStatus() async {
    try {
      print('🔄 BackgroundNotificationService: Checking sensor status...');
      
      // Check if notifications are enabled
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      
      if (!notificationsEnabled) {
        print('🔄 BackgroundNotificationService: Notifications disabled, skipping sensor check');
        return;
      }

      // Get user data
      final userDataString = await SecureStorage.getUserData();
      if (userDataString == null) {
        print('🔄 BackgroundNotificationService: No user data, skipping sensor check');
        return;
      }

      final userData = json.decode(userDataString);
      final userId = userData['_id'];
      if (userId == null) {
        print('🔄 BackgroundNotificationService: No user ID, skipping sensor check');
        return;
      }

      // Get token
      final token = await SecureStorage.getToken();
      if (token == null) {
        print('🔄 BackgroundNotificationService: No token, skipping sensor check');
        return;
      }

      // Make API call to check sensor status
      final response = await http.get(
        Uri.parse('https://maize-watch-app.onrender.com/api/sensors/status/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final sensors = data['sensors'] ?? [];
        
        // Check if any sensors are offline for more than 30 minutes
        final now = DateTime.now();
        for (final sensor in sensors) {
          final sensorId = sensor['_id']?.toString();
          final sensorName = sensor['name'] ?? S.current.unknown_sensor;
          
          if (sensorId != null && !_notifiedSensors.contains(sensorId)) {
            final lastUpdate = DateTime.tryParse(sensor['lastUpdate'] ?? '');
            if (lastUpdate != null) {
              final timeDiff = now.difference(lastUpdate);
              if (timeDiff.inMinutes > 30) {
                print('🔄 BackgroundNotificationService: Sensor $sensorName is offline');
                
                await NotificationService().showSensorOfflineNotification(sensorName);
                _notifiedSensors.add(sensorId);
              }
            }
          }
        }
      }
    } catch (e) {
      print('🔄 BackgroundNotificationService: Error checking sensor status: $e');
    }
  }

  static Future<void> _checkSleepMode() async {
    try {
      print('🔄 BackgroundNotificationService: Checking sleep mode...');
      
      // Check if notifications are enabled using the notification service
      final notificationService = NotificationService();
      final notificationsEnabled = await notificationService.areNotificationsEnabled();
      
      if (!notificationsEnabled) {
        print('🔄 BackgroundNotificationService: Notifications disabled, skipping sleep mode check');
        return;
      }

      // Check if it's sleep mode time (8 PM - 3 AM PH time)
      final now = DateTime.now();
      final hour = now.hour;
      
      if (hour >= 20 || hour < 3) {
        print('🔄 BackgroundNotificationService: Sleep mode active, showing notification');
        
        await notificationService.showSensorSleepModeNotification();
      }
    } catch (e) {
      print('🔄 BackgroundNotificationService: Error checking sleep mode: $e');
    }
  }

  /// Clear notification tracking (useful for testing or when user logs out)
  static void clearNotificationTracking() {
    _notifiedPrescriptions.clear();
    _notifiedSensors.clear();
    _lastNotificationTime = null;
    print('🔄 BackgroundNotificationService: Notification tracking cleared');
  }

  /// Check if service is currently running
  static bool get isRunning => _isInitialized;
}