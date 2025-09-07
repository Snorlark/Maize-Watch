part of 'farm_bloc.dart';

abstract class FarmState extends Equatable {
  const FarmState();

  @override
  List<Object> get props => [];
}

class FarmInitial extends FarmState {}

class FarmLoading extends FarmState {}

class FarmCreated extends FarmState {
  final Farm farm;

  const FarmCreated({required this.farm});

  @override
  List<Object> get props => [farm];
}

class FarmsLoaded extends FarmState {
  final List<Farm> farms;

  const FarmsLoaded({required this.farms});

  @override
  List<Object> get props => [farms];
}

class FarmUpdated extends FarmState {
  final Farm farm;

  const FarmUpdated({required this.farm});

  @override
  List<Object> get props => [farm];
}

class FarmDeleted extends FarmState {}

class DeviceLinked extends FarmState {
  final Farm farm;

  const DeviceLinked({required this.farm});

  @override
  List<Object> get props => [farm];
}

class DeviceUnlinked extends FarmState {
  final Farm farm;

  const DeviceUnlinked({required this.farm});

  @override
  List<Object> get props => [farm];
}

class SensorCreated extends FarmState {}

class FarmError extends FarmState {
  final String message;

  const FarmError({required this.message});

  @override
  List<Object> get props => [message];
}
