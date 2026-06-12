import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/cache_service.dart';

class CompletionStatusManager {
  static final Map<String, Map<String, bool>> _completionStatus = {}; // userId -> prescriptionId -> isCompleted
  static bool _initialized = false;
  static String? _currentUserId;
  
  // Initialize completion status from SharedPreferences
  static Future<void> _initialize() async {
    if (_initialized) return;
    
    try {
      // Get current user ID
      _currentUserId = await CacheService.getCurrentUserId();
      print('🔧 CompletionStatusManager: Current user ID from CacheService: $_currentUserId');
      
      if (_currentUserId == null) {
        print('🔧 CompletionStatusManager: No current user ID from CacheService, trying to get from SharedPreferences directly');
        // Try to get user ID from SharedPreferences directly
        final prefs = await SharedPreferences.getInstance();
        _currentUserId = prefs.getString('current_user_id');
        print('🔧 CompletionStatusManager: Current user ID from SharedPreferences: $_currentUserId');
        
        // Debug: Check all SharedPreferences keys
        final allKeys = prefs.getKeys();
        print('🔧 CompletionStatusManager: All SharedPreferences keys: $allKeys');
        
        // Try alternative user ID keys
        _currentUserId = prefs.getString('user_id') ?? prefs.getString('userId') ?? prefs.getString('currentUserId');
        print('🔧 CompletionStatusManager: Current user ID from alternative keys: $_currentUserId');
      }
      
      if (_currentUserId == null) {
        print('🔧 CompletionStatusManager: No current user ID found, skipping initialization');
        _initialized = true;
        return;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Initialize user-specific completion status
      _completionStatus[_currentUserId!] = {};
      
      for (final key in keys) {
        if (key.startsWith('prescription_completed_${_currentUserId}_')) {
          final prescriptionId = key.replaceFirst('prescription_completed_${_currentUserId}_', '');
          final isCompleted = prefs.getBool(key) ?? false;
          _completionStatus[_currentUserId!]![prescriptionId] = isCompleted;
        }
      }
      
      _initialized = true;
      print('🔧 Initialized completion status manager for user $_currentUserId with ${_completionStatus[_currentUserId!]?.length ?? 0} prescriptions');
    } catch (e) {
      print('🔧 Error initializing completion status manager: $e');
      _initialized = true;
    }
  }
  
  static Future<void> updateCompletionStatus(String prescriptionId, bool isCompleted) async {
    await _initialize();
    
    print('🔧 CompletionStatusManager: updateCompletionStatus called for $prescriptionId to $isCompleted');
    print('🔧 CompletionStatusManager: Current user ID: $_currentUserId');
    print('🔧 CompletionStatusManager: Current status map before update: $_completionStatus');
    
    if (_currentUserId == null) {
      print('🔧 No current user ID, cannot update completion status');
      return;
    }
    
    // Initialize user's completion status map if it doesn't exist
    _completionStatus[_currentUserId!] ??= {};
    _completionStatus[_currentUserId!]![prescriptionId] = isCompleted;
    
    print('🔧 CompletionStatusManager: Updated in-memory status: $_completionStatus');
    
    // Persist to SharedPreferences with user-specific key
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prescription_completed_${_currentUserId}_$prescriptionId', isCompleted);
      print('🔧 Updated completion status for user $_currentUserId, prescription $prescriptionId: $isCompleted');
      
      // Verify it was saved
      final saved = prefs.getBool('prescription_completed_${_currentUserId}_$prescriptionId');
      print('🔧 CompletionStatusManager: Verified saved to SharedPreferences: $saved');
    } catch (e) {
      print('🔧 Error saving completion status: $e');
    }
  }
  
  static Future<bool> getCompletionStatus(String prescriptionId) async {
    await _initialize();
    
    print('🔧 CompletionStatusManager: getCompletionStatus called for $prescriptionId');
    print('🔧 CompletionStatusManager: Current user ID: $_currentUserId');
    print('🔧 CompletionStatusManager: Current status map: $_completionStatus');
    
    if (_currentUserId == null) {
      print('🔧 CompletionStatusManager: No current user ID, returning false for completion status');
      return false;
    }
    
    final result = _completionStatus[_currentUserId!]?[prescriptionId] ?? false;
    print('🔧 CompletionStatusManager: getCompletionStatus for $prescriptionId (user: $_currentUserId): $result');
    return result;
  }
  
  static bool _loggedMissingUserId = false;
  
  static Future<void> clearAll() async {
    await _initialize();
    
    if (_currentUserId == null) {
      print('🔧 No current user ID, cannot clear completion status');
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      // Clear user-specific completion status
      for (final key in keys) {
        if (key.startsWith('prescription_completed_${_currentUserId}_')) {
          await prefs.remove(key);
        }
      }
      
      _completionStatus[_currentUserId!]?.clear();
      print('🔧 Cleared completion status for user $_currentUserId');
    } catch (e) {
      print('🔧 Error clearing completion status: $e');
    }
  }
  
  // Method to switch users (clear current user's data and load new user's data)
  static Future<void> switchUser(String newUserId) async {
    print('🔧 CompletionStatusManager: Switching to user: $newUserId');
    _initialized = false;
    _currentUserId = newUserId;
    _loggedMissingUserId = false; // Reset logging flag
    await _initialize();
  }
  
  // Method to force re-initialization (useful when user ID might have changed)
  static Future<void> forceReinitialize() async {
    print('🔧 CompletionStatusManager: Force re-initializing...');
    _initialized = false;
    _currentUserId = null;
    _loggedMissingUserId = false;
    await _initialize();
  }
  
  // Method to manually set user ID (fallback when automatic retrieval fails)
  static Future<void> setUserId(String userId) async {
    print('🔧 CompletionStatusManager: Manually setting user ID: $userId');
    _currentUserId = userId;
    _initialized = false;
    await _initialize();
  }
  
  // Method to get current user ID
  static Future<String?> getCurrentUserId() async {
    if (!_initialized) {
      await _initialize();
    }
    return _currentUserId;
  }
}
