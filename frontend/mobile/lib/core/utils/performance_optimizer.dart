import 'dart:async';
import 'package:flutter/foundation.dart';

/// Performance optimization utilities to reduce memory usage and improve FPS
class PerformanceOptimizer {
  static final Map<String, Timer> _timers = {};
  static final Map<String, StreamSubscription> _subscriptions = {};
  
  /// Create a debounced timer to prevent excessive calls
  static void debounce(String key, Duration delay, VoidCallback callback) {
    _timers[key]?.cancel();
    _timers[key] = Timer(delay, callback);
  }
  
  /// Create a throttled timer to limit execution frequency
  static void throttle(String key, Duration interval, VoidCallback callback) {
    if (!_timers.containsKey(key)) {
      _timers[key] = Timer.periodic(interval, (_) => callback());
    }
  }
  
  /// Cancel a specific timer
  static void cancelTimer(String key) {
    _timers[key]?.cancel();
    _timers.remove(key);
  }
  
  /// Cancel all timers
  static void cancelAllTimers() {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
  
  /// Track and cancel subscriptions
  static void trackSubscription(String key, StreamSubscription subscription) {
    _subscriptions[key] = subscription;
  }
  
  /// Cancel a specific subscription
  static void cancelSubscription(String key) {
    _subscriptions[key]?.cancel();
    _subscriptions.remove(key);
  }
  
  /// Cancel all subscriptions
  static void cancelAllSubscriptions() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
  }
  
  /// Clean up all resources
  static void cleanup() {
    cancelAllTimers();
    cancelAllSubscriptions();
  }
  
  /// Check if running in debug mode and reduce performance impact
  static bool shouldOptimizeForPerformance() {
    return !kDebugMode; // Only optimize in release mode
  }
  
  /// Get memory usage warning threshold
  static int getMemoryWarningThreshold() {
    return shouldOptimizeForPerformance() ? 200 : 400; // MB
  }
  
  /// Get FPS warning threshold
  static int getFPSWarningThreshold() {
    return shouldOptimizeForPerformance() ? 45 : 30; // FPS
  }
}
