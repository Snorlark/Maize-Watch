part of 'farm_bloc.dart';

abstract class FarmEvent extends Equatable {
  const FarmEvent();

  @override
  List<Object> get props => [];
}

class CreateFarmEvent extends FarmEvent {
  final Farm farm;

  const CreateFarmEvent({required this.farm});

  @override
  List<Object> get props => [farm];
}

class GetUserFarmsEvent extends FarmEvent {
  final String userId;

  const GetUserFarmsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UpdateFarmEvent extends FarmEvent {
  final Farm farm;

  const UpdateFarmEvent({required this.farm});

  @override
  List<Object> get props => [farm];
}

class DeleteFarmEvent extends FarmEvent {
  final String farmId;

  const DeleteFarmEvent({required this.farmId});

  @override
  List<Object> get props => [farmId];
}

class LinkDeviceEvent extends FarmEvent {
  final String farmId;
  final String deviceId;
  final String? macAddress;

  const LinkDeviceEvent({
    required this.farmId,
    required this.deviceId,
    this.macAddress,
  });

  @override
  List<Object> get props => [
    farmId,
    deviceId,
    if (macAddress != null) macAddress!,
  ];
}

class UnlinkDeviceEvent extends FarmEvent {
  final String farmId;

  const UnlinkDeviceEvent({required this.farmId});

  @override
  List<Object> get props => [farmId];
}

class CreateSensorEvent extends FarmEvent {
  final String farmId;
  final Map<String, dynamic> sensorData;

  const CreateSensorEvent({required this.farmId, required this.sensorData});

  @override
  List<Object> get props => [farmId, sensorData];
}

class CreateFarmWithFieldEvent extends FarmEvent {
  final Farm farm;
  final Map<String, dynamic> fieldData;

  const CreateFarmWithFieldEvent({required this.farm, required this.fieldData});

  @override
  List<Object> get props => [farm, fieldData];
}
