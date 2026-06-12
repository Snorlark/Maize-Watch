part of 'sensor_status_bloc.dart';

sealed class SensorStatusEvent extends Equatable {
  const SensorStatusEvent();

  @override
  List<Object> get props => [];
}

final class GetSensorStatusEvent extends SensorStatusEvent {
  const GetSensorStatusEvent();
}
