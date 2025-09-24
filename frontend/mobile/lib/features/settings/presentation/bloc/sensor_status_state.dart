part of 'sensor_status_bloc.dart';

enum SensorStatusStatus {
  initial,
  loading,
  success,
  failure,
}

final class SensorStatusState extends Equatable {
  const SensorStatusState({
    this.status = SensorStatusStatus.initial,
    this.sensorStatus,
    this.message,
  });

  final SensorStatusStatus status;
  final Map<String, dynamic>? sensorStatus;
  final String? message;

  SensorStatusState copyWith({
    SensorStatusStatus? status,
    Map<String, dynamic>? sensorStatus,
    String? message,
  }) {
    return SensorStatusState(
      status: status ?? this.status,
      sensorStatus: sensorStatus ?? this.sensorStatus,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, sensorStatus, message];
}
