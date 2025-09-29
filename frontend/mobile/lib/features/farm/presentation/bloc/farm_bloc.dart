import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/farm.dart';
import '../../domain/usecases/create_farm.dart';
import '../../domain/usecases/get_user_farms.dart';
import '../../domain/usecases/create_sensor.dart';

part 'farm_event.dart';
part 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final CreateFarm createFarm;
  final GetUserFarms getUserFarms;
  final CreateSensor createSensor;

  FarmBloc({
    required this.createFarm, 
    required this.getUserFarms,
    required this.createSensor,
  }) : super(FarmInitial()) {
    on<CreateFarmEvent>(_onCreateFarm);
    on<CreateFarmWithFieldEvent>(_onCreateFarmWithField);
    on<GetUserFarmsEvent>(_onGetUserFarms);
    on<CreateSensorEvent>(_onCreateSensor);
  }

  Future<void> _onCreateFarm(
    CreateFarmEvent event,
    Emitter<FarmState> emit,
  ) async {
    emit(FarmLoading());

    final result = await createFarm(CreateFarmParams(farm: event.farm));

    result.fold(
      (failure) => emit(FarmError(message: _mapFailureToMessage(failure))),
      (farm) => emit(FarmCreated(farm: farm)),
    );
  }

  Future<void> _onCreateFarmWithField(
    CreateFarmWithFieldEvent event,
    Emitter<FarmState> emit,
  ) async {
    emit(FarmLoading());

    // Use the createFarm use case but pass the field data as well
    final result = await createFarm(CreateFarmParams(
      farm: event.farm,
      fieldData: event.fieldData,
    ));

    result.fold(
      (failure) => emit(FarmError(message: _mapFailureToMessage(failure))),
      (farm) => emit(FarmCreated(farm: farm)),
    );
  }

  Future<void> _onGetUserFarms(
    GetUserFarmsEvent event,
    Emitter<FarmState> emit,
  ) async {
    print('🌽 FarmBloc: Loading user farms for userId: ${event.userId}');
    emit(FarmLoading());

    final result = await getUserFarms(GetUserFarmsParams(userId: event.userId));

    result.fold(
      (failure) {
        print('🌽 FarmBloc: Error loading farms: ${_mapFailureToMessage(failure)}');
        emit(FarmError(message: _mapFailureToMessage(failure)));
      },
      (farms) {
        print('🌽 FarmBloc: Successfully loaded ${farms.length} farms');
        for (int i = 0; i < farms.length; i++) {
          final farm = farms[i];
          print('🌽 FarmBloc: Farm $i - Name: ${farm.farmName}, Fields: ${farm.fields.length}');
          for (int j = 0; j < farm.fields.length; j++) {
            final field = farm.fields[j];
            print('🌽 FarmBloc: Field $j - Name: ${field.fieldName}, GrowthStage: ${field.growthStage}');
          }
        }
        emit(FarmsLoaded(farms: farms));
      },
    );
  }

  Future<void> _onCreateSensor(
    CreateSensorEvent event,
    Emitter<FarmState> emit,
  ) async {
    final result = await createSensor(CreateSensorParams(
      farmId: event.farmId,
      sensorData: event.sensorData,
    ));

    result.fold(
      (failure) => emit(FarmError(message: _mapFailureToMessage(failure))),
      (_) => emit(SensorCreated()),
    );
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        final serverFailure = failure as ServerFailure;
        // Check if it's an authentication error
        if (serverFailure.message.contains('Authentication expired') ||
            serverFailure.message.contains('Please log in again')) {
          return serverFailure.message;
        }
        return serverFailure.message.isNotEmpty ? serverFailure.message : 'Server error occurred';
      case NetworkFailure:
        return 'Network connection failed';
      default:
        return 'An unexpected error occurred';
    }
  }
}
