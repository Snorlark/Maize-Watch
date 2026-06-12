part of 'sensor_bloc.dart';

/// Base class for all sensor-related events
abstract class SensorEvent extends Equatable {
  const SensorEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load the latest sensor readings for a specific farm
class LoadLatestSensorReadingsEvent extends SensorEvent {
  /// The ID of the farm to load sensor readings for
  final String farmId;

  /// Creates a [LoadLatestSensorReadingsEvent]
  const LoadLatestSensorReadingsEvent({required this.farmId});

  @override
  List<Object> get props => [farmId];
  
  @override
  String toString() => 'LoadLatestSensorReadingsEvent(farmId: $farmId)';
}

/// Event to load historical sensor readings for a specific farm within a date range
class LoadHistoricalSensorReadingsEvent extends SensorEvent {
  /// The ID of the farm to load historical data for
  final String farmId;
  
  /// The start date for the historical data range (optional)
  final DateTime? startDate;
  
  /// The end date for the historical data range (optional)
  final DateTime? endDate;
  
  /// Maximum number of readings to return (optional)
  final int? limit;

  /// Creates a [LoadHistoricalSensorReadingsEvent]
  const LoadHistoricalSensorReadingsEvent({
    required this.farmId,
    this.startDate,
    this.endDate,
    this.limit,
  });

  @override
  List<Object?> get props => [farmId, startDate, endDate, limit];
  
  @override
  String toString() => 'LoadHistoricalSensorReadingsEvent(' 
      'farmId: $farmId, startDate: $startDate, endDate: $endDate, limit: $limit';
}

/// Event to load corn field data for a specific farm
class LoadCornFieldDataEvent extends SensorEvent {
  /// The ID of the farm to load corn field data for
  final String farmId;

  /// Creates a [LoadCornFieldDataEvent]
  const LoadCornFieldDataEvent({required this.farmId});

  @override
  List<Object> get props => [farmId];
  
  @override
  String toString() => 'LoadCornFieldDataEvent(farmId: $farmId)';
}

/// Event to load crop status for a specific farm
class LoadCropStatusEvent extends SensorEvent {
  /// The ID of the farm to load crop status for
  final String farmId;

  /// Creates a [LoadCropStatusEvent]
  const LoadCropStatusEvent({required this.farmId});

  @override
  List<Object> get props => [farmId];
  
  @override
  String toString() => 'LoadCropStatusEvent(farmId: $farmId)';
}

/// Event to refresh all sensor data for a specific farm
class RefreshSensorDataEvent extends SensorEvent {
  /// The ID of the farm to refresh sensor data for
  final String farmId;

  /// Creates a [RefreshSensorDataEvent]
  const RefreshSensorDataEvent({required this.farmId});

  @override
  List<Object> get props => [farmId];
  
  @override
  String toString() => 'RefreshSensorDataEvent(farmId: $farmId)';
}
