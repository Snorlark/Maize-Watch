import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../domain/entities/corn_field.dart';
import '../../domain/usecases/get_latest_readings.dart';
import '../../domain/usecases/get_historical_readings.dart';
import '../../domain/repositories/monitoring_repository.dart';

part 'sensor_event.dart';
part 'sensor_state.dart';

class SensorBloc extends Bloc<SensorEvent, SensorState> {
  final GetLatestReadings getLatestReadings;
  final GetHistoricalReadings getHistoricalReadings;
  final MonitoringRepository repository;

  SensorBloc({
    required this.getLatestReadings,
    required this.getHistoricalReadings,
    required this.repository,
  }) : super(SensorInitial()) {
    on<LoadLatestSensorReadingsEvent>(_onLoadLatestSensorReadings);
    on<LoadHistoricalSensorReadingsEvent>(_onLoadHistoricalSensorReadings);
    on<LoadCornFieldDataEvent>(_onLoadCornFieldData);
    on<LoadCropStatusEvent>(_onLoadCropStatus);
    on<RefreshSensorDataEvent>(_onRefreshSensorData);
  }

  Future<void> _onLoadLatestSensorReadings(
    LoadLatestSensorReadingsEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      final currentState = state;

      // Only show loading if we don't have any data yet
      if (currentState is! SensorLoaded) {
        emit(SensorLoading());
      }

      final result = await getLatestReadings();

      await result.fold(
        (failure) async {
          _handleError(emit, failure, 'Failed to load latest readings');
        },
        (readings) async {
          // If we have a previous state, merge with the new readings
          if (currentState is SensorLoaded) {
            emit(
              currentState.copyWith(
                latestReadings: readings,
                status: SensorDataStatus.success,
                lastUpdated: DateTime.now(),
              ),
            );
          } else {
            emit(
              SensorLoaded(
                latestReadings: readings,
                historicalReadings: const [],
                cropStatus: 'NORMAL',
                analytics: const {},
                status: SensorDataStatus.success,
                lastUpdated: DateTime.now(),
              ),
            );
          }
        },
      );
    } catch (e) {
      _handleError(emit, e, 'Failed to load latest sensor readings');
    }
  }

  Future<void> _onLoadHistoricalSensorReadings(
    LoadHistoricalSensorReadingsEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is! SensorLoaded) {
        emit(SensorLoading());
      }

      // Calculate days from start date to now
      final days =
          event.startDate != null
              ? DateTime.now().difference(event.startDate!).inDays
              : 7; // Default to 7 days if no start date provided

      final result = await getHistoricalReadings(event.farmId, days);

      await result.fold(
        (failure) async {
          _handleError(emit, failure, 'Failed to load historical readings');
        },
        (readings) async {
          if (currentState is SensorLoaded) {
            emit(
              currentState.copyWith(
                historicalReadings: readings,
                status: SensorDataStatus.success,
                lastUpdated: DateTime.now(),
              ),
            );
          } else {
            emit(
              SensorLoaded(
                latestReadings: const [],
                historicalReadings: readings,
                cropStatus: 'NORMAL',
                analytics: const {},
                status: SensorDataStatus.success,
                lastUpdated: DateTime.now(),
              ),
            );
          }
        },
      );
    } catch (e) {
      _handleError(emit, e, 'Failed to load historical sensor readings');
    }
  }

  Future<void> _onLoadCornFieldData(
    LoadCornFieldDataEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is! SensorLoaded) {
        emit(SensorLoading());
      }

      if (currentState is SensorLoaded) {
        emit(
          currentState.copyWith(
            status: SensorDataStatus.success,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        emit(
          SensorLoaded(
            latestReadings: const [],
            historicalReadings: const [],
            cropStatus: 'NORMAL',
            analytics: const {},
            status: SensorDataStatus.success,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      _handleError(emit, e, 'Failed to load corn field data');
    }
  }

  Future<void> _onLoadCropStatus(
    LoadCropStatusEvent event,
    Emitter<SensorState> emit,
  ) async {
    try {
      final currentState = state;

      if (currentState is! SensorLoaded) {
        emit(SensorLoading());
      }

      if (currentState is SensorLoaded) {
        emit(
          currentState.copyWith(
            status: SensorDataStatus.success,
            lastUpdated: DateTime.now(),
          ),
        );
      } else {
        emit(
          SensorLoaded(
            latestReadings: const [],
            historicalReadings: const [],
            cropStatus: 'NORMAL',
            analytics: const {},
            status: SensorDataStatus.success,
            lastUpdated: DateTime.now(),
          ),
        );
      }
    } catch (e) {
      _handleError(emit, e, 'Failed to load crop status');
    }
  }

  Future<void> _onRefreshSensorData(
    RefreshSensorDataEvent event,
    Emitter<SensorState> emit,
  ) async {
    final currentState = state;
    final isInitialLoad = currentState is! SensorLoaded;

    // Show refreshing state if we already have data
    if (!isInitialLoad) {
      emit(SensorRefreshing(previousState: currentState));
    }

    try {
      // Get latest readings
      final latestResult = await getLatestReadings();

      return latestResult.fold(
        (failure) {
          _handleError(emit, failure, 'Failed to refresh latest readings');
        },
        (latestReadings) async {
          // Get historical data for the last 7 days by default
          final historicalResult = await getHistoricalReadings(event.farmId, 7);

          return historicalResult.fold(
            (failure) {
              // If we can't get historical data but have latest readings, still proceed
              if (currentState is SensorLoaded) {
                emit(
                  currentState.copyWith(
                    latestReadings: latestReadings,
                    status: SensorDataStatus.success,
                    lastUpdated: DateTime.now(),
                  ),
                );
              } else {
                emit(
                  SensorLoaded(
                    latestReadings: latestReadings,
                    historicalReadings: const [],
                    cropStatus: 'NORMAL',
                    analytics: const {},
                    status: SensorDataStatus.success,
                    lastUpdated: DateTime.now(),
                  ),
                );
              }
            },
            (historicalReadings) {
              // Successfully got both latest and historical data
              emit(
                SensorLoaded(
                  latestReadings: latestReadings,
                  historicalReadings: historicalReadings,
                  cropStatus: 'NORMAL',
                  analytics: const {},
                  status: SensorDataStatus.success,
                  lastUpdated: DateTime.now(),
                ),
              );
            },
          );
        },
      );
    } catch (e) {
      _handleError(emit, e, 'Failed to refresh sensor data');
    }
  }

  // Helper method to handle errors consistently
  void _handleError(Emitter<SensorState> emit, dynamic error, String context) {
    // Log the error for debugging
    print('SensorBloc error in $context: $error');

    // Get the current state
    final currentState = state;
    final errorMessage =
        error is Failure
            ? _mapFailureToMessage(error)
            : 'An unexpected error occurred: $error';

    // Emit appropriate error state
    if (currentState is SensorLoaded) {
      emit(
        currentState.copyWith(
          status: SensorDataStatus.failure,
          error: errorMessage,
        ),
      );
    } else {
      emit(
        SensorError(
          message: errorMessage,
          lastValidState: currentState is SensorLoaded ? currentState : null,
        ),
      );
    }
  }

  // Convert Failure to user-friendly message
  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return 'Server error: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return 'Network error: ${failure.message}. Please check your connection and try again.';
    } else if (failure is CacheFailure) {
      return 'Cache error: ${failure.message}';
    } else if (failure is AuthFailure) {
      return 'Authentication failed: ${failure.message}. Please log in again.';
    } else if (failure is UnauthorizedFailure) {
      return 'You need to log in to access this feature.';
    }
    return 'An unexpected error occurred. Please try again later.';
  }
}
