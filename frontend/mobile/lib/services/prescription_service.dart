import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'package:http/http.dart' as http;
import '../model/prescription.dart';  // Import the correct prescription model

class PrescriptionService {
  final ApiService apiService = ApiService();
  
  // Key for storing the last check timestamp in SharedPreferences
  static const String _lastCheckKey = 'last_prescription_check';
  static const String _prescriptionsStorageKey = 'prescriptions';
  
  // Check for new prescriptions
  Future<Map<String, dynamic>> checkForNewPrescriptions() async {
    try {
      print('🔄 Starting check for new prescriptions...');
      
      // Get current user data
      final userData = await apiService.getUserData();
      if (userData == null) {
        print('❌ User not logged in');
        return {'success': false, 'message': 'User not logged in'};
      }
      
      // Get the user ID - handle both 'id' and '_id' formats
      final userId = userData['id'] ?? userData['_id'];
      if (userId == null) {
        print('❌ User ID not found in userData');
        print('🔍 Available userData keys: ${userData.keys.join(", ")}');
        return {'success': false, 'message': 'User ID not found'};
      }
      print('👤 User ID: $userId');
      
      // Get the last check timestamp
      final lastCheck = await _getLastCheckTimestamp();
      print('⏱️ Last prescription check timestamp: ${lastCheck ?? "null (first check)"}');
      
      // Get the authentication token
      final token = await _getToken();
      if (token == null) {
        print('❌ Authentication token not found');
        return {'success': false, 'message': 'Authentication token not found'};
      }
      print('🔑 Auth token retrieved (${token.substring(0, 10)}...)');
      
      // Make API call to check for new prescriptions
      final client = apiService.getClient();
      try {
        // Create proper URL with query parameter for lastCheck
        var uri = Uri.parse('${apiService.baseUrl}/api/analytics/latest/$userId');
        if (lastCheck != null) {
          uri = uri.replace(queryParameters: {'lastCheck': lastCheck});
        }
        
        print('🌐 Requesting: ${uri.toString()}');
        
        final response = await client.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 15));
        
        print('📥 Response status code: ${response.statusCode}');
        
        // Check response status
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          print('📊 Response data: ${_truncateForLog(response.body)}');
          
          // Update the last check timestamp
          await _saveLastCheckTimestamp();
          print('⏱️ Updated last check timestamp to: ${DateTime.now().toIso8601String()}');
          
          // Format the prescription data for the app
          if (responseData['success'] == true && responseData['data'] != null) {
            final analysis = responseData['data'];
            final prescription = Prescription.fromJson(analysis);
            
            // Convert to app format
            final formattedPrescription = _formatPrescription(prescription);
            
            return {
              'success': true,
              'hasNewPrescriptions': true,
              'count': 1,
              'prescriptions': [formattedPrescription]
            };
          }
          
          print('❌ API returned success: false - ${responseData['message']}');
          return {
            'success': false,
            'message': responseData['message'] ?? 'Failed to get prescriptions'
          };
        } else if (response.statusCode == 401) {
          print('🔄 Authentication failed (401) - attempting token refresh');
          // Token may have expired, try refreshing
          final refreshSuccess = await apiService.refreshToken();
          if (refreshSuccess) {
            print('✅ Token refreshed successfully, retrying...');
            // Retry with new token
            return checkForNewPrescriptions();
          } else {
            print('❌ Token refresh failed');
            return {'success': false, 'message': 'Authentication failed'};
          }
        } else {
          print('❌ Server error: ${response.statusCode}');
          print('📝 Response body: ${_truncateForLog(response.body)}');
          return {
            'success': false,
            'message': 'Server error: ${response.statusCode}'
          };
        }
      } finally {
        client.close();
      }
    } catch (e) {
      print('❗ Error checking for prescriptions: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
  
  // Format a prescription from the API to match the app's format
  Map<String, dynamic> _formatPrescription(Prescription prescription) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('HH:mm');
    
    // Convert severity level to priority
    int priority;
    switch (prescription.severityLevel.toUpperCase()) {
      case 'CRITICAL':
        priority = 1;
        break;
      case 'WARNING':
        priority = 2;
        break;
      default:
        priority = 3;
    }
    
    // Create a title from the first alert or recommendation
    String title = prescription.alerts.isNotEmpty 
        ? prescription.alerts.first 
        : (prescription.recommendations.isNotEmpty 
            ? prescription.recommendations.first 
            : 'Corn Analysis Update');
    
    // Create a description from all recommendations
    String description = prescription.recommendations.join('\n');
    
    // Get the most important measurement based on importance scores
    String value = '';
    if (prescription.importanceScores.isNotEmpty) {
      final sortedScores = prescription.importanceScores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final mostImportant = sortedScores.first;
      value = '${mostImportant.key}: ${prescription.measurements[mostImportant.key]}';
    }
    
    return {
      'title': title,
      'value': value,
      'description': description,
      'date': dateFormatter.format(prescription.timestamp),
      'time': timeFormatter.format(prescription.timestamp),
      'isChecked': false,
      'analysisId': prescription.id,
      'prescriptionId': prescription.id,
      'fieldId': prescription.fieldId,
      'priority': priority,
      'category': _getCategoryFromMeasurements(prescription.measurements),
      'measurements': prescription.measurements,
      'alerts': prescription.alerts,
      'recommendations': prescription.recommendations,
      'severityLevel': prescription.severityLevel,
      'importanceScores': prescription.importanceScores,
    };
  }
  
  // Helper to determine category based on measurements
  String _getCategoryFromMeasurements(Map<String, double> measurements) {
    if (measurements.containsKey('soil_ph')) return 'Soil pH';
    if (measurements.containsKey('soil_moisture')) return 'Moisture';
    if (measurements.containsKey('temperature')) return 'Temperature';
    if (measurements.containsKey('humidity')) return 'Humidity';
    if (measurements.containsKey('light_intensity')) return 'Light';
    return 'General';
  }
  
  // Get token from shared preferences
  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('❗ Error retrieving token: $e');
      return null;
    }
  }
  
  // Save the last check timestamp
  Future<void> _saveLastCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().toIso8601String();
      await prefs.setString(_lastCheckKey, now);
      print('✅ Last check timestamp saved: $now');
    } catch (e) {
      print('❗ Error saving last check timestamp: $e');
    }
  }
  
  // Get the last check timestamp
  Future<String?> _getLastCheckTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_lastCheckKey);
    } catch (e) {
      print('❗ Error retrieving last check timestamp: $e');
      return null;
    }
  }
  
  // Get all prescriptions (combining local and remote)
  Future<List<Map<String, dynamic>>> getAllPrescriptions() async {
    try {
      print('🔍 Getting all prescriptions (local + remote)...');
      
      // First check if we have new remote prescriptions
      final remoteResult = await checkForNewPrescriptions();
      
      // Get the current local prescriptions
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);
      List<Map<String, dynamic>> storedPrescriptions = [];
      
      if (storedData != null) {
        try {
          final decoded = json.decode(storedData);
          storedPrescriptions = List<Map<String, dynamic>>.from(
            decoded.map((item) => Map<String, dynamic>.from(item))
          );
          print('📋 Found ${storedPrescriptions.length} stored prescriptions');
        } catch (e) {
          print('❗ Error parsing stored prescriptions: $e');
          // If there's an error parsing, we'll start with an empty list
          storedPrescriptions = [];
        }
      } else {
        print('ℹ️ No stored prescriptions found in SharedPreferences');
      }
      
      // If there are new prescriptions, add them to the local store
      if (remoteResult['success'] == true && remoteResult['hasNewPrescriptions'] == true) {
        final newPrescriptions = List<Map<String, dynamic>>.from(remoteResult['prescriptions']);
        print('✅ Adding ${newPrescriptions.length} new prescriptions to local storage');
        
        // Add new prescriptions to the front of the list
        storedPrescriptions = [...newPrescriptions, ...storedPrescriptions];
        
        // Save back to shared preferences
        await prefs.setString(_prescriptionsStorageKey, json.encode(storedPrescriptions));
        print('💾 Updated prescriptions saved to SharedPreferences');
      } else if (!remoteResult['success']) {
        print('⚠️ Failed to get remote prescriptions: ${remoteResult['message']}');
      } else {
        print('ℹ️ No new prescriptions found remotely');
      }
      
      // Debug - Print some sample data
      if (storedPrescriptions.isNotEmpty) {
        print('📝 First prescription title: ${storedPrescriptions[0]['title']}');
      }
      
      return storedPrescriptions;
    } catch (e) {
      print('❗ Error getting all prescriptions: $e');
      return [];
    }
  }
  
  // Truncate long strings for logging
  String _truncateForLog(String text) {
    if (text.length > 500) {
      return '${text.substring(0, 500)}... (truncated)';
    }
    return text;
  }
  
  // Update a prescription's status in the local storage
  Future<void> _updateLocalPrescriptionStatus(String analysisId, String prescriptionId, bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedData = prefs.getString(_prescriptionsStorageKey);
      
      if (storedData != null) {
        final List<dynamic> decoded = json.decode(storedData);
        List<Map<String, dynamic>> prescriptions = List<Map<String, dynamic>>.from(
          decoded.map((item) => Map<String, dynamic>.from(item))
        );
        
        // Find and update the prescription
        final index = prescriptions.indexWhere((p) => 
          p['analysisId'] == analysisId && p['prescriptionId'] == prescriptionId);
        
        if (index != -1) {
          prescriptions[index]['isChecked'] = isCompleted;
          
          // Save back to shared preferences
          await prefs.setString(_prescriptionsStorageKey, json.encode(prescriptions));
          print('✅ Updated local prescription status - Index: $index, Completed: $isCompleted');
        } else {
          print('⚠️ Prescription not found in local storage for update');
        }
      }
    } catch (e) {
      print('❗ Error updating local prescription status: $e');
    }
  }
  
  // Update prescription status (both locally and on server)
  Future<Map<String, dynamic>> updatePrescriptionStatus(String analysisId, String prescriptionId, bool isCompleted) async {
    try {
      print('🔄 Updating prescription status - ID: $prescriptionId, Completed: $isCompleted');
      
      // Update local storage first
      await _updateLocalPrescriptionStatus(analysisId, prescriptionId, isCompleted);
      
      // Get the authentication token
      final token = await _getToken();
      if (token == null) {
        print('❌ Authentication token not found');
        return {
          'success': false,
          'message': 'Authentication token not found'
        };
      }
      
      // Make API call to update status on server
      final client = apiService.getClient();
      try {
        final response = await client.put(
          Uri.parse('${apiService.baseUrl}/api/analytics/prescription/$prescriptionId/status'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode({
            'is_completed': isCompleted,
            'updated_at': DateTime.now().toIso8601String(),
          }),
        ).timeout(const Duration(seconds: 15));
        
        print('📥 Response status code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          print('✅ Prescription status updated successfully on server');
          return {
            'success': true,
            'message': 'Prescription status updated successfully'
          };
        } else if (response.statusCode == 401) {
          print('🔄 Authentication failed (401) - attempting token refresh');
          // Token may have expired, try refreshing
          final refreshSuccess = await apiService.refreshToken();
          if (refreshSuccess) {
            print('✅ Token refreshed successfully, retrying...');
            // Retry with new token
            return updatePrescriptionStatus(analysisId, prescriptionId, isCompleted);
          }
        }
        
        print('❌ Failed to update prescription status on server: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to update prescription status on server'
        };
      } finally {
        client.close();
      }
    } catch (e) {
      print('❗ Error updating prescription status: $e');
      return {
        'success': false,
        'message': 'Error updating prescription status: ${e.toString()}'
      };
    }
  }
}