// This file is deprecated - use background_notification_service.dart instead
// Kept for backward compatibility but all functionality moved to BackgroundNotificationService

class BackgroundTaskService {
  static Future<void> initialize() async {
    print("🔄 BackgroundTaskService: Deprecated - use BackgroundNotificationService instead");
  }
}
// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:workmanager/workmanager.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile/core/config/environment.dart';
// import 'package:mobile/core/services/notification_service.dart';
// import 'package:mobile/core/storage/secure_storage.dart';

// class BackgroundTaskService {
//   static const String prescriptionCheckTask = "prescriptionCheckTask";
//   static const String sensorStatusTask = "sensorStatusTask";
//   static const String sleepModeTask = "sleepModeTask";
  
//   // Task intervals (in minutes)
//   static const int prescriptionCheckInterval = 15; // Check every 15 minutes
//   static const int sensorStatusInterval = 30; // Check every 30 minutes
//   static const int sleepModeCheckInterval = 60; // Check every hour

//   static Future<void> initialize() async {
//     print("🔄 BackgroundTaskService: Initializing WorkManager");
    
//     await Workmanager().initialize(
//       callbackDispatcher,
//       isInDebugMode: kDebugMode,
//     );

//     // Register periodic tasks
//     await _registerPrescriptionCheckTask();
//     await _registerSensorStatusTask();
//     await _registerSleepModeTask();
    
//     print("🔄 BackgroundTaskService: All tasks registered successfully");
//   }

//   static Future<void> _registerPrescriptionCheckTask() async {
//     await Workmanager().registerPeriodicTask(
//       prescriptionCheckTask,
//       prescriptionCheckTask,
//       frequency: Duration(minutes: prescriptionCheckInterval),
//       constraints: Constraints(
//         networkType: NetworkType.connected,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresDeviceIdle: false,
//         requiresStorageNotLow: false,
//       ),
//     );
//     print("🔄 BackgroundTaskService: Prescription check task registered");
//   }

//   static Future<void> _registerSensorStatusTask() async {
//     await Workmanager().registerPeriodicTask(
//       sensorStatusTask,
//       sensorStatusTask,
//       frequency: Duration(minutes: sensorStatusInterval),
//       constraints: Constraints(
//         networkType: NetworkType.connected,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresDeviceIdle: false,
//         requiresStorageNotLow: false,
//       ),
//     );
//     print("🔄 BackgroundTaskService: Sensor status task registered");
//   }

//   static Future<void> _registerSleepModeTask() async {
//     await Workmanager().registerPeriodicTask(
//       sleepModeTask,
//       sleepModeTask,
//       frequency: Duration(minutes: sleepModeCheckInterval),
//       constraints: Constraints(
//         networkType: NetworkType.connected,
//         requiresBatteryNotLow: false,
//         requiresCharging: false,
//         requiresDeviceIdle: false,
//         requiresStorageNotLow: false,
//       ),
//     );
//     print("🔄 BackgroundTaskService: Sleep mode task registered");
//   }

//   static Future<void> startAllTasks() async {
//     print("🔄 BackgroundTaskService: Starting all background tasks");
//     await _registerPrescriptionCheckTask();
//     await _registerSensorStatusTask();
//     await _registerSleepModeTask();
//   }

//   static Future<void> stopAllTasks() async {
//     print("🔄 BackgroundTaskService: Stopping all background tasks");
//     await Workmanager().cancelAll();
//   }

//   // Test method to manually trigger a background task (for testing)
//   static Future<void> testBackgroundTask() async {
//     print("🔄 BackgroundTaskService: Testing background task manually");
//     await _checkPrescriptions();
//   }

//   static Future<void> cancelTask(String taskName) async {
//     await Workmanager().cancelByUniqueName(taskName);
//     print("🔄 BackgroundTaskService: Cancelled task: $taskName");
//   }
// }

// // This function must be a top-level function
// @pragma('vm:entry-point')
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     print("🔄 BackgroundTaskService: Executing task: $task");
    
//     try {
//       switch (task) {
//         case BackgroundTaskService.prescriptionCheckTask:
//           await _checkPrescriptions();
//           break;
//         case BackgroundTaskService.sensorStatusTask:
//           await _checkSensorStatus();
//           break;
//         case BackgroundTaskService.sleepModeTask:
//           await _checkSleepMode();
//           break;
//         default:
//           print("🔄 BackgroundTaskService: Unknown task: $task");
//       }
      
//       return Future.value(true);
//     } catch (e) {
//       print("🔄 BackgroundTaskService: Task $task failed: $e");
//       return Future.value(false);
//     }
//   });
// }

// Future<void> _checkPrescriptions() async {
//   print("🔄 BackgroundTaskService: Checking for new prescriptions");
  
//   try {
//     // Get stored user data
//     final userData = await SecureStorage.getUserData();
//     if (userData == null) {
//       print("🔄 BackgroundTaskService: No user data found, skipping prescription check");
//       return;
//     }

//     final user = jsonDecode(userData);
//     final userId = user['id'];
    
//     if (userId == null) {
//       print("🔄 BackgroundTaskService: No user ID found, skipping prescription check");
//       return;
//     }

//     // Check if notifications are enabled
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
//     if (!notificationsEnabled) {
//       print("🔄 BackgroundTaskService: Notifications disabled, skipping prescription check");
//       return;
//     }

//     // Get access token
//     final token = await SecureStorage.getToken();
//     if (token == null) {
//       print("🔄 BackgroundTaskService: No access token found, skipping prescription check");
//       return;
//     }

//     // Make API call to check for new prescriptions
//     final response = await http.get(
//       Uri.parse('${AppConfig.baseUrl}/api/analytics/farm/$userId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     ).timeout(Duration(seconds: 30));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['success'] == true && data['data'] != null) {
//         final analytics = data['data'];
//         final prescriptions = analytics['prescriptive']?['recommendations'] as List? ?? [];
        
//         // Check if there are new prescriptions since last check
//         final lastCheckKey = 'last_prescription_check_$userId';
//         final lastCheckTime = prefs.getInt(lastCheckKey) ?? 0;
//         final currentTime = DateTime.now().millisecondsSinceEpoch;
        
//         bool hasNewPrescriptions = false;
//         for (final prescription in prescriptions) {
//           final createdAt = prescription['created_timestamp'] as String?;
//           if (createdAt != null) {
//             final prescriptionTime = DateTime.parse(createdAt).millisecondsSinceEpoch;
//             if (prescriptionTime > lastCheckTime) {
//               hasNewPrescriptions = true;
//               break;
//             }
//           }
//         }
        
//         if (hasNewPrescriptions) {
//           print("🔄 BackgroundTaskService: New prescriptions found, showing notification");
          
//           // Initialize notification service
//           final notificationService = NotificationService();
//           await notificationService.initialize();
          
//           // Show notification
//           await notificationService.showPrescriptionAlertNotification(
//             title: 'New Farm Prescriptions',
//             message: 'You have ${prescriptions.length} new farm tasks to complete',
//             priority: 'high',
//             notificationId: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//           );
//         }
        
//         // Update last check time
//         await prefs.setInt(lastCheckKey, currentTime);
//       }
//     } else {
//       print("🔄 BackgroundTaskService: Failed to fetch prescriptions: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("🔄 BackgroundTaskService: Error checking prescriptions: $e");
//   }
// }

// Future<void> _checkSensorStatus() async {
//   print("🔄 BackgroundTaskService: Checking sensor status");
  
//   try {
//     // Get stored user data
//     final userData = await SecureStorage.getUserData();
//     if (userData == null) {
//       print("🔄 BackgroundTaskService: No user data found, skipping sensor check");
//       return;
//     }

//     final user = jsonDecode(userData);
//     final userId = user['id'];
    
//     if (userId == null) {
//       print("🔄 BackgroundTaskService: No user ID found, skipping sensor check");
//       return;
//     }

//     // Check if notifications are enabled
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
//     if (!notificationsEnabled) {
//       print("🔄 BackgroundTaskService: Notifications disabled, skipping sensor check");
//       return;
//     }

//     // Get access token
//     final token = await SecureStorage.getToken();
//     if (token == null) {
//       print("🔄 BackgroundTaskService: No access token found, skipping sensor check");
//       return;
//     }

//     // Make API call to check sensor status
//     final response = await http.get(
//       Uri.parse('${AppConfig.baseUrl}/api/sensors/status/$userId'),
//       headers: {
//         'Authorization': 'Bearer $token',
//         'Content-Type': 'application/json',
//       },
//     ).timeout(Duration(seconds: 30));

//     if (response.statusCode == 200) {
//       final data = jsonDecode(response.body);
//       if (data['success'] == true && data['data'] != null) {
//         final sensors = data['data'] as List;
        
//         // Check for offline sensors
//         for (final sensor in sensors) {
//           final sensorName = sensor['name'] as String? ?? 'Unknown Sensor';
//           final isOnline = sensor['isOnline'] as bool? ?? false;
//           final lastSeen = sensor['lastSeen'] as String?;
          
//           if (!isOnline && lastSeen != null) {
//             final lastSeenTime = DateTime.parse(lastSeen);
//             final timeDiff = DateTime.now().difference(lastSeenTime);
            
//             // If sensor has been offline for more than 30 minutes
//             if (timeDiff.inMinutes > 30) {
//               print("🔄 BackgroundTaskService: Sensor $sensorName is offline");
              
//               // Initialize notification service
//               final notificationService = NotificationService();
//               await notificationService.initialize();
              
//               // Show notification
//               await notificationService.showSensorOfflineNotification(sensorName);
//             }
//           }
//         }
//       }
//     } else {
//       print("🔄 BackgroundTaskService: Failed to fetch sensor status: ${response.statusCode}");
//     }
//   } catch (e) {
//     print("🔄 BackgroundTaskService: Error checking sensor status: $e");
//   }
// }

// Future<void> _checkSleepMode() async {
//   print("🔄 BackgroundTaskService: Checking sleep mode");
  
//   try {
//     // Check if notifications are enabled
//     final prefs = await SharedPreferences.getInstance();
//     final notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    
//     if (!notificationsEnabled) {
//       print("🔄 BackgroundTaskService: Notifications disabled, skipping sleep mode check");
//       return;
//     }

//     // Get current time in Philippines timezone
//     final now = DateTime.now();
//     final hour = now.hour;
    
//     // Check if it's sleep mode time (8 PM to 3 AM PH time)
//     final isSleepMode = hour >= 20 || hour < 3;
    
//     // Check if we've already notified about sleep mode today
//     final lastSleepModeNotification = prefs.getString('last_sleep_mode_notification');
//     final today = now.toIso8601String().split('T')[0];
    
//     if (isSleepMode && lastSleepModeNotification != today) {
//       print("🔄 BackgroundTaskService: Sensors entering sleep mode");
      
//       // Initialize notification service
//       final notificationService = NotificationService();
//       await notificationService.initialize();
      
//       // Show notification
//       await notificationService.showSensorSleepModeNotification();
      
//       // Update last notification date
//       await prefs.setString('last_sleep_mode_notification', today);
//     }
//   } catch (e) {
//     print("🔄 BackgroundTaskService: Error checking sleep mode: $e");
//   }
// }
