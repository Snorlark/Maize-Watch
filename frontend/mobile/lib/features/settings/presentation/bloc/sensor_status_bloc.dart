import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_sensor_status.dart';

part 'sensor_status_event.dart';
part 'sensor_status_state.dart';

class SensorStatusBloc extends Bloc<SensorStatusEvent, SensorStatusState> {
  final GetSensorStatus getSensorStatusUseCase;

  SensorStatusBloc({required this.getSensorStatusUseCase}) : super(const SensorStatusState()) {
    on<GetSensorStatusEvent>(_onGetSensorStatus);
  }

  Future<void> _onGetSensorStatus(
    GetSensorStatusEvent event,
    Emitter<SensorStatusState> emit,
  ) async {
    emit(state.copyWith(status: SensorStatusStatus.loading));

    final result = await getSensorStatusUseCase();

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SensorStatusStatus.failure,
          message: _mapFailureToString(failure),
        ),
      ),
      (sensorStatus) {
        print("🔍 SensorStatusBloc: Sensor status loaded successfully");
        emit(
          state.copyWith(
            status: SensorStatusStatus.success,
            sensorStatus: sensorStatus,
          ),
        );
      },
    );
  }

  String _mapFailureToString(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Server error. Please try again later.';
    } else if (failure is NetworkFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Network connection failed.';
    } else if (failure is CacheFailure) {
      return failure.message.isNotEmpty
          ? failure.message
          : 'Failed due to a caching issue.';
    }
    return 'An unexpected error occurred.';
  }
}
