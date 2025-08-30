import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/farm.dart';
import '../../domain/usecases/create_farm.dart';
import '../../domain/usecases/get_user_farms.dart';

part 'farm_event.dart';
part 'farm_state.dart';

class FarmBloc extends Bloc<FarmEvent, FarmState> {
  final CreateFarm createFarm;
  final GetUserFarms getUserFarms;

  FarmBloc({required this.createFarm, required this.getUserFarms})
    : super(FarmInitial()) {
    on<CreateFarmEvent>(_onCreateFarm);
    on<GetUserFarmsEvent>(_onGetUserFarms);
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

  Future<void> _onGetUserFarms(
    GetUserFarmsEvent event,
    Emitter<FarmState> emit,
  ) async {
    emit(FarmLoading());

    final result = await getUserFarms(GetUserFarmsParams(userId: event.userId));

    result.fold(
      (failure) => emit(FarmError(message: _mapFailureToMessage(failure))),
      (farms) => emit(FarmsLoaded(farms: farms)),
    );
  }

  String _mapFailureToMessage(failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case NetworkFailure:
        return 'Network connection failed';
      default:
        return 'An unexpected error occurred';
    }
  }
}
