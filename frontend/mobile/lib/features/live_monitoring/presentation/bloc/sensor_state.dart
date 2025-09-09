part of 'sensor_bloc.dart';

enum SensorDataStatus {
  initial,
  loading,
  success,
  failure,
  refreshing,
}

abstract class SensorState extends Equatable {
  final SensorDataStatus status;
  final String? error;
  final DateTime? lastUpdated;

  const SensorState({
    this.status = SensorDataStatus.initial,
    this.error,
    this.lastUpdated,
  });

  @override
  List<Object?> get props => [status, error, lastUpdated];
}

class SensorInitial extends SensorState {
  const SensorInitial() : super(status: SensorDataStatus.initial);
}

class SensorLoading extends SensorState {
  const SensorLoading() : super(status: SensorDataStatus.loading);
}

class SensorLoaded extends SensorState {
  final List<SensorReading> latestReadings;
  final List<SensorReading> historicalReadings;
  final CornField? cornField;
  final String cropStatus;
  final Map<String, dynamic> analytics;
  @override
  final DateTime? lastUpdated;
  @override
  final SensorDataStatus status;
  @override
  final String? error;

  const SensorLoaded({
    required this.latestReadings,
    required this.historicalReadings,
    this.cornField,
    required this.cropStatus,
    required this.analytics,
    this.status = SensorDataStatus.success,
    this.lastUpdated,
    this.error,
  });

  @override
  List<Object?> get props => [
        latestReadings,
        historicalReadings,
        cornField,
        cropStatus,
        analytics,
        status,
        error,
        lastUpdated,
      ];

  SensorLoaded copyWith({
    List<SensorReading>? latestReadings,
    List<SensorReading>? historicalReadings,
    CornField? cornField,
    String? cropStatus,
    Map<String, dynamic>? analytics,
    SensorDataStatus? status,
    String? error,
    DateTime? lastUpdated,
    bool clearError = false,
  }) {
    return SensorLoaded(
      latestReadings: latestReadings ?? this.latestReadings,
      historicalReadings: historicalReadings ?? this.historicalReadings,
      cornField: cornField ?? this.cornField,
      cropStatus: cropStatus ?? this.cropStatus,
      analytics: analytics ?? this.analytics,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class SensorError extends SensorState {
  final String message;
  final SensorLoaded? lastValidState;

  const SensorError({
    required this.message,
    this.lastValidState,
  }) : super(
          status: SensorDataStatus.failure,
          error: message,
        );

  @override
  List<Object?> get props => [message, lastValidState];
}

class SensorRefreshing extends SensorState {
  final SensorLoaded previousState;

  const SensorRefreshing({required this.previousState})
      : super(status: SensorDataStatus.refreshing);

  @override
  List<Object?> get props => [previousState, status];
}
