import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'package:http/http.dart' as http;
import '../model/prescription_model.dart';

class PrescriptionService {
  final ApiService apiService = ApiService();
  final NotificationService notificationService = NotificationService();
  
  // Keys for storing data in SharedPreferences
  static const String _lastCheckKey = 'last_prescription_check';
  static const String _prescriptionsStorageKey = 'prescriptions';
  static const String _lastErrorKey = 'last_prescription_error';
  static const String _lastNotificationKey = 'last_prescription_notification';

  // Maximum number of retries for failed requests
  static const int _maxRetries = 3;
  
  // Check for new prescriptions with improved error handling
  Future<Map<String, dynamic>> checkForNewPrescriptions(
      BuildContext context) async {
    try {
      print('🔄 Checking for new prescriptions...');
      
      // Get current user data
      final userData = await apiService.getUserData();
      if (userData == null) {
        print('❌ User not logged in');
        return {'success': false, 'message': 'User not logged in'};
      }
      
      // Get the field ID from crop data
      final cropData = await apiService.getCropData(context);
      if (cropData == null || cropData['fieldName'] == null) {
        print('❌ Field ID not found in crop data');
        return {'success': false, 'message': 'Field ID not found'};
      }

      final fieldId = 'maize_field_1'; // Use the field ID from analytics
      print('📊 Using field ID: $fieldId');

      // Get last check timestamp
      final prefs = await SharedPreferences.getInstance();
      int lastCheck = 0;

      if (prefs.containsKey('last_prescription_check')) {
        final storedValue = prefs.get('last_prescription_check');
        if (storedValue is int) {
          lastCheck = storedValue;
        } else if (storedValue is String) {
          try {
            final dateTime = DateTime.parse(storedValue);
            lastCheck = dateTime.millisecondsSinceEpoch;
          } catch (e) {
            print('⚠️ Could not parse stored timestamp: $storedValue, using 0');
            lastCheck = 0;
          }
        }
      }

      print('⏰ Last check: ${DateTime.fromMillisecondsSinceEpoch(lastCheck)}');

      // Make API request
      final token = await _getToken();
      if (token == null) {
        print('❌ No authentication token found');
        return {'success': false, 'message': 'Not authenticated'};
      }

      final response = await apiService.getClient().get(
        Uri.parse(
            '${apiService.baseUrl}/api/analytics/latest/field/$fieldId?realtime=true'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
      );
        
      print('📡 Response status: ${response.statusCode}');
      print('📦 Response body: ${response.body}');
        
        if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // Handle both success wrapper and direct data
        dynamic analysisData;
        if (data['success'] == true && data['data'] != null) {
          analysisData = data['data'];
        } else if (data.containsKey('measurements')) {
          // Direct analysis data without wrapper
          analysisData = data;
        }

        if (analysisData != null) {
          print('✅ Found analysis data');

          final prescriptions = _formatSingleAnalysis(analysisData);
          print('📋 Generated ${prescriptions.length} prescriptions');

          if (prescriptions.isNotEmpty) {
            // Check if these are new prescriptions that need notification
            await _checkAndNotifyNewPrescriptions(prescriptions, prefs);
            
            // Save prescriptions
            await _savePrescriptionsToLocal(prescriptions);
            print('💾 Saved prescriptions: ${prescriptions.length}');

            // Update last check timestamp
            await prefs.setInt('last_prescription_check',
                DateTime.now().millisecondsSinceEpoch);
            
            return {
              'success': true,
              'hasNewPrescriptions': true,
              'prescriptions': prescriptions.map((p) => p.toJson()).toList(),
              'message': 'New prescriptions found',
            };
          }
        }
      }

      print('ℹ️ No new prescriptions found');
      return {
        'success': true,
        'hasNewPrescriptions': false,
        'prescriptions': [],
        'message': 'No new prescriptions found'
      };
    } catch (e) {
      print('❌ Error checking for prescriptions: $e');
          return {
            'success': false,
        'message': 'Error checking for prescriptions: $e'
      };
    }
  }

  // Check for new prescriptions and send notifications
  Future<void> _checkAndNotifyNewPrescriptions(
    List<Prescription> prescriptions, 
    SharedPreferences prefs
  ) async {
    try {
      // Get the last notification timestamp
      int lastNotificationTime = prefs.getInt(_lastNotificationKey) ?? 0;
      
      // Filter prescriptions that are newer than the last notification
      final newPrescriptions = prescriptions.where((prescription) {
        return prescription.timestamp.millisecondsSinceEpoch > lastNotificationTime;
      }).toList();

      if (newPrescriptions.isNotEmpty) {
        print('🔔 Found ${newPrescriptions.length} new prescriptions to notify about');
        
        // Send notification for each new prescription
        for (final prescription in newPrescriptions) {
          await notificationService.showPrescriptionNotification(
            title: 'New Crop Recommendation',
            body: '${prescription.parameter}: ${prescription.recommendation}',
            prescriptionId: prescription.id,
          );
          
          // Add a small delay between notifications
          await Future.delayed(const Duration(milliseconds: 500));
        }
        
        // Update last notification timestamp
        await prefs.setInt(_lastNotificationKey, DateTime.now().millisecondsSinceEpoch);
        
        print('✅ Sent notifications for ${newPrescriptions.length} new prescriptions');
      } else {
        print('ℹ️ No new prescriptions to notify about');
      }
    } catch (e) {
      print('❌ Error sending prescription notifications: $e');
    }
  }

  // FIXED: Format single analysis - create prescriptions for ALL non-normal conditions
  List<Prescription> _formatSingleAnalysis(Map<String, dynamic> analysis) {
    List<Prescription> prescriptions = [];
    Set<String> processedParameters = {};

    print('🔍 Formatting analysis: ${analysis.keys}');

    // Extract data from analysis
    final measurements = analysis['measurements'] ?? {};
    final parameterStatuses = analysis['parameter_status'] ?? {};
    final recommendations =
        List<String>.from(analysis['recommendations'] ?? []);
    final alerts = List<String>.from(analysis['alerts'] ?? []);

    print('📊 Processing analysis with ${measurements.length} measurements');
    print('📊 Parameter statuses: $parameterStatuses');

    // Process each parameter measurement
    measurements.forEach((param, value) {
      final statusInfo = parameterStatuses[param];
      if (statusInfo == null) {
        print('⚠️ No status info for parameter: $param');
        return;
      }

      final condition = statusInfo['condition'] ?? 'unknown';
      final severity = statusInfo['severity'] ?? 'NORMAL';

      print(
          '📊 Processing parameter: $param, Value: $value, Condition: $condition, Severity: $severity');

      // Create prescription for ANY non-normal condition
      if (condition != 'normal' && !processedParameters.contains(param)) {
        processedParameters.add(param);

        String recommendation =
            _findRecommendationForParameter(param, recommendations, alerts);
        // Remove impact score from recommendation text
        recommendation = recommendation.replaceAll(RegExp(r'\(impact score: \d+\.?\d*%\)'), '').trim();
        double impactScore =
            _calculateImpactScore(severity); // Use severity-based impact score instead

        // FIXED: Parse timestamp with proper timezone handling
        DateTime timestamp;
        try {
          if (analysis['timestamp'] != null) {
            String timestampStr = analysis['timestamp'].toString();
            // Handle various timestamp formats
            if (timestampStr.contains('T')) {
              timestamp = DateTime.parse(timestampStr).toLocal();
            } else {
              // If it's just a date, assume current time
              timestamp = DateTime.now();
            }
          } else {
            timestamp = DateTime.now();
          }
        } catch (e) {
          print(
              '⚠️ Error parsing timestamp: ${analysis['timestamp']}, using current time');
          timestamp = DateTime.now();
        }

        final prescription = Prescription(
          id: '${analysis['_id'] ?? timestamp.millisecondsSinceEpoch}_$param',
          timestamp: timestamp,
          parameter: param,
          value: value.toString(),
          status: condition,
          recommendation: recommendation,
          priority: _calculatePriority(severity),
          impactScore: impactScore,
          isCompleted: false,
          fieldId: analysis['field_id'] ?? 'maize_field_1',
          growthStage: analysis['corn_growth_stage']?.toString() ?? 'Unknown',
        );

        prescriptions.add(prescription);
        print(
            '✅ Created prescription for $param: $recommendation (Impact: ${(impactScore * 100).toStringAsFixed(1)}%)');
      }
    });

    return prescriptions;
  }

  // Helper method to find recommendation for a specific parameter
  String _findRecommendationForParameter(
      String param, List<String> recommendations, List<String> alerts) {
    // First try to find from recommendations
    for (var rec in recommendations) {
      if (_isRecommendationForParameter(param, rec)) {
        return rec;
      }
    }

    // Then try from alerts
    for (var alert in alerts) {
      if (_isRecommendationForParameter(param, alert)) {
        return alert;
      }
    }

    return 'Monitor $param levels and take appropriate action';
  }

  // Helper method to check if recommendation/alert is for specific parameter
  bool _isRecommendationForParameter(String param, String text) {
    final paramLower = param.toLowerCase();
    final textLower = text.toLowerCase();

    switch (paramLower) {
      case 'soil_ph':
        return textLower.contains('ph') ||
            textLower.contains('lime') ||
            textLower.contains('acid');
      case 'soil_moisture':
        return textLower.contains('moisture') ||
            textLower.contains('water') ||
            textLower.contains('irrigation');
      case 'light_intensity':
        return textLower.contains('light') ||
            textLower.contains('grow lights') ||
            textLower.contains('illumination');
      case 'temperature':
        return textLower.contains('temperature') ||
            textLower.contains('heat') ||
            textLower.contains('cooling');
      case 'humidity':
        return textLower.contains('humidity') || textLower.contains('moisture');
      default:
        return textLower.contains(paramLower);
    }
  }

  // FIXED: Extract impact score from recommendation text and convert to proper decimal
  double _extractImpactScoreFromRecommendation(String recommendation) {
    // Try to find impact score in the text
    final regex = RegExp(r'impact[:\s]*(\d+\.?\d*)%?', caseSensitive: false);
    final match = regex.firstMatch(recommendation);
    if (match != null) {
      final scoreString = match.group(1) ?? '0';
      final score = double.tryParse(scoreString) ?? 0.0;
      // If score is > 1, assume it's a percentage and convert to decimal
      return score > 1.0 ? score / 100.0 : score;
    }

    // Fallback based on severity keywords
    final recLower = recommendation.toLowerCase();
    if (recLower.contains('critical') || recLower.contains('urgent')) {
      return 0.85; // 85%
    } else if (recLower.contains('warning') || recLower.contains('attention')) {
      return 0.65; // 65%
    } else if (recLower.contains('moderate') || recLower.contains('monitor')) {
      return 0.45; // 45%
    }

    return 0.25; // Default 25%
  }

  // Extract parameter name from alert text
  String _extractParameterFromAlert(String alert) {
    if (alert.toLowerCase().contains('soil_ph') ||
        alert.toLowerCase().contains('ph')) {
      return 'soil_ph';
    } else if (alert.toLowerCase().contains('light')) {
      return 'light_intensity';
    } else if (alert.toLowerCase().contains('moisture')) {
      return 'soil_moisture';
    } else if (alert.toLowerCase().contains('temperature')) {
      return 'temperature';
    } else if (alert.toLowerCase().contains('humidity')) {
      return 'humidity';
    }
    return 'general';
  }

  // Extract value from alert text
  String _extractValueFromAlert(String alert) {
    final regex = RegExp(r'\((\d+\.?\d*)\)');
    final match = regex.firstMatch(alert);
    return match?.group(1) ?? 'N/A';
  }

  // Find corresponding recommendation for an alert
  String _findCorrespondingRecommendation(
      String alert, List<String> recommendations) {
    final parameter = _extractParameterFromAlert(alert);
    return _findRecommendationForParameter(parameter, recommendations, []);
  }

  // Calculate priority based on severity
  int _calculatePriority(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 1;
      case 'warning':
        return 2;
      case 'normal':
        return 3;
      default:
        return 3;
    }
  }

  // Calculate impact score based on severity
  double _calculateImpactScore(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return 0.85; // 85%
      case 'warning':
        return 0.65; // 65%
      case 'normal':
        return 0.25; // 25%
      default:
        return 0.25; // 25%
    }
  }
  
  // Get token from shared preferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('❌ Error retrieving token: $e');
      return null;
    }
  }
  
  // Save the last check timestamp as int (milliseconds)
  Future<void> _saveLastCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastCheckKey, now);
      print(
          '✅ Last check timestamp saved: ${DateTime.fromMillisecondsSinceEpoch(now)}');
    } catch (e) {
      print('❗ Error saving last check timestamp: $e');
    }
  }
  
  // Get the last check timestamp as int
  Future<int> _getLastCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_lastCheckKey) ?? 0;
    } catch (e) {
      print('❗ Error retrieving last check timestamp: $e');
      return 0;
    }
  }

  // Clear all stored prescriptions
  Future<void> clearAllPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prescriptionsStorageKey);
      print('✅ All stored prescriptions cleared');
    } catch (e) {
      print('❗ Error clearing prescriptions: $e');
    }
  }

  // FIXED: Get all prescriptions - avoid duplicates when merging
  Future<List<Prescription>> getAllPrescriptions(BuildContext context) async {
    try {
      print('🔍 Getting all prescriptions (local + remote)...');
      
      // Get the current local prescriptions first
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);
      List<Prescription> storedPrescriptions = [];
      Set<String> existingIds = {};
      
      if (storedData != null) {
        try {
          final List<dynamic> decoded = json.decode(storedData);
          storedPrescriptions = decoded
              .map((item) => Prescription.fromJson(item is String
                  ? jsonDecode(item)
                  : item as Map<String, dynamic>))
              .toList();

          // Track existing prescription IDs
          existingIds = storedPrescriptions.map((p) => p.id).toSet();
          print('📋 Found ${storedPrescriptions.length} stored prescriptions');
        } catch (e) {
          print('❗ Error parsing stored prescriptions: $e');
          storedPrescriptions = [];
        }
      } else {
        print('ℹ️ No stored prescriptions found in SharedPreferences');
      }
      
      // Check for new remote prescriptions
      final remoteResult = await checkForNewPrescriptions(context);

      // If there are new prescriptions, add only the unique ones
      if (remoteResult['success'] == true &&
          remoteResult['hasNewPrescriptions'] == true) {
        final List<dynamic> newPrescriptionsData =
            remoteResult['prescriptions'];
        final newPrescriptions = newPrescriptionsData
            .map((item) => item is Prescription
                ? item
                : Prescription.fromJson(item is String
                    ? jsonDecode(item)
                    : item as Map<String, dynamic>))
            .toList();

        // Filter out duplicates
        final uniqueNewPrescriptions =
            newPrescriptions.where((p) => !existingIds.contains(p.id)).toList();

        if (uniqueNewPrescriptions.isNotEmpty) {
          print(
              '✅ Adding ${uniqueNewPrescriptions.length} new unique prescriptions');
        
        // Add new prescriptions to the front of the list
          storedPrescriptions = [
            ...uniqueNewPrescriptions,
            ...storedPrescriptions
          ];
        
          // Save back to shared preferences as JSON
          await prefs.setString(_prescriptionsStorageKey,
              json.encode(storedPrescriptions.map((p) => p.toJson()).toList()));
        print('💾 Updated prescriptions saved to SharedPreferences');
        } else {
          print('ℹ️ No new unique prescriptions to add');
        }
      } else if (remoteResult['success'] != true) {
        print(
            '⚠️ Failed to get remote prescriptions: ${remoteResult['message']}');
      } else {
        print('ℹ️ No new prescriptions found remotely');
      }
      
      // Debug - Print some sample data
      if (storedPrescriptions.isNotEmpty) {
        print(
            '📋 First prescription parameter: ${storedPrescriptions[0].parameter}');
        print(
            '📋 Total prescriptions to return: ${storedPrescriptions.length}');
      }
      
      return storedPrescriptions;
    } catch (e) {
      print('❗ Error getting all prescriptions: $e');
      return [];
    }
  }
  
  // Helper method to save prescriptions locally
  Future<void> _savePrescriptionsToLocal(
      List<Prescription> prescriptions) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing prescriptions first
      final existingData = prefs.getString(_prescriptionsStorageKey);
      List<Prescription> existingPrescriptions = [];
      Set<String> existingIds = {};

      if (existingData != null) {
        try {
          final List<dynamic> decoded = json.decode(existingData);
          existingPrescriptions = decoded
              .map((item) => Prescription.fromJson(item is String
                  ? jsonDecode(item)
                  : item as Map<String, dynamic>))
              .toList();
          existingIds = existingPrescriptions.map((p) => p.id).toSet();
        } catch (e) {
          print('⚠️ Error parsing existing prescriptions: $e');
        }
      }

      // Filter out duplicates and add new prescriptions to the front
      final newUniquePrescriptions =
          prescriptions.where((p) => !existingIds.contains(p.id)).toList();
      final allPrescriptions = [
        ...newUniquePrescriptions,
        ...existingPrescriptions
      ];

      // Save to SharedPreferences using consistent key
      final prescriptionsJson =
          allPrescriptions.map((p) => p.toJson()).toList();
      await prefs.setString(
          _prescriptionsStorageKey, json.encode(prescriptionsJson));
      print(
          '💾 Saved ${newUniquePrescriptions.length} new prescriptions (${allPrescriptions.length} total)');
    } catch (e) {
      print('❌ Error saving prescriptions to local storage: $e');
    }
  }

  // Add these methods to your PrescriptionService class:

// Helper method to update local storage after deletion
Future<void> updateLocalStorageAfterDelete(String prescriptionId) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final storedData = prefs.getString(_prescriptionsStorageKey);
    
    if (storedData != null) {
      final List<dynamic> decoded = json.decode(storedData);
      List<Prescription> prescriptions = decoded.map((item) => 
        Prescription.fromJson(item is String ? jsonDecode(item) : item as Map<String, dynamic>)
      ).toList();
      
      // Remove the prescription
      prescriptions.removeWhere((p) => p.id == prescriptionId);
      
      // Save back to shared preferences
      await prefs.setString(_prescriptionsStorageKey, json.encode(prescriptions.map((p) => p.toJson()).toList()));
      print('✅ Updated local storage after deleting prescription: $prescriptionId');
    }
  } catch (e) {
    print('❗ Error updating local storage after delete: $e');
  }
}

// Enhanced method to check for real-time updates
Future<bool> hasNewRealTimeData() async {
  try {
    final token = await _getToken();
    if (token == null) return false;
    
    final response = await apiService.getClient().get(
      Uri.parse('${apiService.baseUrl}/api/analytics/latest/field/maize_field_1?realtime=true&timestamp=${DateTime.now().millisecondsSinceEpoch}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      // Check if there's new data by comparing timestamps
      final prefs = await SharedPreferences.getInstance();
      final lastCheck = prefs.getInt(_lastCheckKey) ?? 0;
      
      dynamic analysisData = data['success'] == true ? data['data'] : data;
      if (analysisData != null && analysisData['timestamp'] != null) {
        final dataTimestamp = DateTime.parse(analysisData['timestamp']).millisecondsSinceEpoch;
        return dataTimestamp > lastCheck;
      }
    }
    
    return false;
  } catch (e) {
    print('❗ Error checking for real-time data: $e');
    return false;
  }
}

// Method to force refresh prescriptions from server
Future<Map<String, dynamic>> forceRefreshPrescriptions(BuildContext context) async {
  try {
    // Clear last check timestamp to force new data fetch
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastCheckKey);
    
    // Get fresh prescriptions
    return await checkForNewPrescriptions(context);
  } catch (e) {
    print('❗ Error force refreshing prescriptions: $e');
    return {'success': false, 'message': 'Error refreshing: $e'};
  }
}

  // Update prescription status (both locally and on server)
  Future<Map<String, dynamic>> updatePrescriptionStatus(
      String analysisId, String prescriptionId, bool isCompleted) async {
    try {
      print(
          '🔄 Updating prescription status - ID: $prescriptionId, Completed: $isCompleted');

      // Update local storage first
      await _updateLocalPrescriptionStatus(
          analysisId, prescriptionId, isCompleted);

      return {
        'success': true,
        'message': 'Prescription status updated successfully'
      };
    } catch (e) {
      print('❗ Error updating prescription status: $e');
      return {
        'success': false,
        'message': 'Error updating prescription status: ${e.toString()}'
      };
    }
  }
  
  // Update a prescription's status in the local storage
  Future<void> _updateLocalPrescriptionStatus(
      String analysisId, String prescriptionId, bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);
      
      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        List<Prescription> prescriptions = decoded
            .map((item) => Prescription.fromJson(item is String
                ? jsonDecode(item)
                : item as Map<String, dynamic>))
            .toList();
        
        // Find and update the prescription
        final index = prescriptions.indexWhere((p) => p.id == prescriptionId);
        
        if (index != -1) {
          prescriptions[index] = Prescription(
            id: prescriptions[index].id,
            timestamp: prescriptions[index].timestamp,
            parameter: prescriptions[index].parameter,
            value: prescriptions[index].value,
            status: prescriptions[index].status,
            recommendation: prescriptions[index].recommendation,
            priority: prescriptions[index].priority,
            impactScore: prescriptions[index].impactScore,
            isCompleted: isCompleted,
            fieldId: prescriptions[index].fieldId,
            growthStage: prescriptions[index].growthStage,
          );
          
          // Save back to shared preferences
          await prefs.setString(_prescriptionsStorageKey,
              json.encode(prescriptions.map((p) => p.toJson()).toList()));
          print(
              '✅ Updated local prescription status - Index: $index, Completed: $isCompleted');
        } else {
          print('⚠️ Prescription not found in local storage for update');
        }
      }
    } catch (e) {
      print('❗ Error updating local prescription status: $e');
    }
  }
  
  // Get prescription by ID
  Future<Prescription?> getPrescriptionById(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);

      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        for (var item in decoded) {
          final prescription = Prescription.fromJson(
              item is String ? jsonDecode(item) : item as Map<String, dynamic>);
          if (prescription.id == id) {
            return prescription;
          }
        }
      }

      return null;
    } catch (e) {
      print('❗ Error getting prescription by ID: $e');
      return null;
    }
  }

  // Get prescriptions by parameter
  Future<List<Prescription>> getPrescriptionsByParameter(
      String parameter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);

      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        return decoded
            .map((item) => Prescription.fromJson(item is String
                ? jsonDecode(item)
                : item as Map<String, dynamic>))
            .where((p) => p.parameter.toLowerCase() == parameter.toLowerCase())
            .toList();
      }

      return [];
    } catch (e) {
      print('❗ Error getting prescriptions by parameter: $e');
      return [];
    }
  }

  // Get prescriptions by status
  Future<List<Prescription>> getPrescriptionsByStatus(String status) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);

      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        return decoded
            .map((item) => Prescription.fromJson(item is String
                ? jsonDecode(item)
                : item as Map<String, dynamic>))
            .where((p) => p.status.toLowerCase() == status.toLowerCase())
            .toList();
      }

      return [];
    } catch (e) {
      print('❗ Error getting prescriptions by status: $e');
      return [];
    }
  }

  // Update all prescriptions status
  Future<void> updateAllPrescriptionsStatus(bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);
      
      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        List<Prescription> prescriptions = decoded.map((item) => 
          Prescription.fromJson(item is String ? jsonDecode(item) : item as Map<String, dynamic>)
        ).toList();
        
        // Update all prescriptions
        prescriptions = prescriptions.map((p) => Prescription(
          id: p.id,
          timestamp: p.timestamp,
          parameter: p.parameter,
          value: p.value,
          status: p.status,
          recommendation: p.recommendation,
          priority: p.priority,
          impactScore: p.impactScore,
          isCompleted: isCompleted,
          fieldId: p.fieldId,
          growthStage: p.growthStage,
        )).toList();
        
        // Save back to shared preferences
        await prefs.setString(_prescriptionsStorageKey, json.encode(prescriptions.map((p) => p.toJson()).toList()));
        print('✅ Updated all prescriptions status to: $isCompleted');
      }
    } catch (e) {
      print('❗ Error updating all prescriptions status: $e');
    }
  }

  // Delete all completed prescriptions
  Future<void> deleteAllCompletedPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);
      
      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        List<Prescription> prescriptions = decoded.map((item) => 
          Prescription.fromJson(item is String ? jsonDecode(item) : item as Map<String, dynamic>)
        ).toList();
        
        // Remove completed prescriptions
        prescriptions = prescriptions.where((p) => !p.isCompleted).toList();
        
        // Save back to shared preferences
        await prefs.setString(_prescriptionsStorageKey, json.encode(prescriptions.map((p) => p.toJson()).toList()));
        print('✅ Deleted all completed prescriptions');
      }
    } catch (e) {
      print('❗ Error deleting all completed prescriptions: $e');
    }
  }

  // Delete all prescriptions
  Future<void> deleteAllPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prescriptionsStorageKey);
      print('✅ Deleted all prescriptions');
    } catch (e) {
      print('❗ Error deleting all prescriptions: $e');
    }
  }
}
