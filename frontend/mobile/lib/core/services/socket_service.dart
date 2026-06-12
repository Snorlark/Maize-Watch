import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:mobile/features/live_monitoring/domain/entities/analytics_entities.dart';
import 'package:mobile/core/services/cache_service.dart';

class SocketService {
  static SocketService? _instance;
  IO.Socket? socket;
  final StreamController<AnalyticsData> _analyticsController = StreamController<AnalyticsData>.broadcast();
  final StreamController<List<PrescriptionModel>> _prescriptionsController = StreamController<List<PrescriptionModel>>.broadcast();
  final StreamController<CropConditionModel> _cropConditionController = StreamController<CropConditionModel>.broadcast();
  
  String? _farmId;
  String? _userId;

  SocketService._();

  static SocketService get instance {
    _instance ??= SocketService._();
    return _instance!;
  }

  // Getters for streams
  Stream<AnalyticsData> get analyticsStream => _analyticsController.stream;
  Stream<List<PrescriptionModel>> get prescriptionsStream => _prescriptionsController.stream;
  Stream<CropConditionModel> get cropConditionStream => _cropConditionController.stream;

  Future<void> connect(String serverUrl, String userId, String farmId) async {
    if (socket?.connected == true) {
      return;
    }

    _userId = userId;
    _farmId = farmId;

    try {
      socket = IO.io(serverUrl, IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': 'your-auth-token'}) // Replace with actual auth token
          .enableAutoConnect()
          .build());

      socket!.onConnect((_) {
        print('Socket connected');
        _subscribeToFarmUpdates();
      });

      socket!.onDisconnect((_) {
        print('Socket disconnected');
      });

      socket!.onError((error) {
        print('Socket error: $error');
      });

      // Listen for analytics updates
      socket!.on('analytics:update', (data) {
        _handleAnalyticsUpdate(data);
      });

      // Listen for prescription updates
      socket!.on('prescription:update', (data) {
        _handlePrescriptionUpdate(data);
      });

      // Listen for crop condition updates
      socket!.on('crop:condition:update', (data) {
        _handleCropConditionUpdate(data);
      });

      // Listen for sensor data updates
      socket!.on('sensor:data:update', (data) {
        _handleSensorDataUpdate(data);
      });

    } catch (e) {
      print('Error connecting to socket: $e');
    }
  }

  void _subscribeToFarmUpdates() {
    if (_farmId != null) {
      socket?.emit('farm:subscribe', {'farmId': _farmId});
    }
  }

  void _handleAnalyticsUpdate(dynamic data) async {
    try {
      final analyticsData = AnalyticsData.fromJson(data);
      
      // Update cache
      await CacheService.cacheAnalytics(analyticsData);
      
      // Emit to stream
      _analyticsController.add(analyticsData);
    } catch (e) {
      print('Error handling analytics update: $e');
    }
  }

  void _handlePrescriptionUpdate(dynamic data) async {
    try {
      if (data is List) {
        final prescriptions = data.map((item) => PrescriptionModel.fromJson(item)).toList();
        
        // Update cache
        await CacheService.cachePrescriptions(prescriptions);
        
        // Emit to stream
        _prescriptionsController.add(prescriptions);
      } else if (data is Map<String, dynamic>) {
        // Single prescription update
        final prescription = PrescriptionModel.fromJson(data);
        
        // Update cache
        await CacheService.updatePrescription(prescription);
        
        // Get updated list and emit
        final prescriptions = await CacheService.getCachedPrescriptions();
        _prescriptionsController.add(prescriptions);
      }
    } catch (e) {
      print('Error handling prescription update: $e');
    }
  }

  void _handleCropConditionUpdate(dynamic data) async {
    try {
      final cropCondition = CropConditionModel.fromJson(data);
      
      // Update cache
      await CacheService.cacheCropCondition(cropCondition);
      
      // Emit to stream
      _cropConditionController.add(cropCondition);
    } catch (e) {
      print('Error handling crop condition update: $e');
    }
  }

  void _handleSensorDataUpdate(dynamic data) async {
    try {
      // Sensor data updates might trigger analytics recalculation
      // For now, we'll just log it
      print('Sensor data updated: $data');
      
      // In a real implementation, you might want to:
      // 1. Update local sensor readings cache
      // 2. Trigger analytics recalculation
      // 3. Update UI with new sensor values
    } catch (e) {
      print('Error handling sensor data update: $e');
    }
  }

  void emitPrescriptionAction(String prescriptionId, String action) {
    socket?.emit('prescription:action', {
      'prescriptionId': prescriptionId,
      'action': action,
      'farmId': _farmId,
    });
  }

  void emitPrescriptionComplete(String prescriptionId) {
    socket?.emit('prescription:complete', {
      'prescriptionId': prescriptionId,
      'farmId': _farmId,
    });
  }

  void requestAnalyticsUpdate() {
    socket?.emit('analytics:request', {
      'farmId': _farmId,
    });
  }

  void requestPrescriptionsUpdate() {
    socket?.emit('prescriptions:request', {
      'farmId': _farmId,
    });
  }

  void disconnect() {
    socket?.disconnect();
    socket = null;
  }

  void dispose() {
    _analyticsController.close();
    _prescriptionsController.close();
    _cropConditionController.close();
    disconnect();
  }

  bool get isConnected => socket?.connected ?? false;
}