import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/core/network/network_info.dart';
import 'package:mobile/features/prescriptions/data/datasources/prescription_local_data_source.dart';
import 'package:mobile/features/prescriptions/data/datasources/prescription_remote_data_source.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart'
    show Prescription;
import 'package:mobile/features/prescriptions/domain/repositories/prescription_repository.dart';
import 'package:mobile/features/prescriptions/data/models/prescription_model.dart';
import 'package:mobile/core/services/socket_service.dart';

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final PrescriptionRemoteDataSource remoteDataSource;
  final PrescriptionLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  final SocketService socketService;
  final _controller = StreamController<List<Prescription>>.broadcast();

  PrescriptionRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
    required this.socketService,
  }) {
    // Initialize socket listeners in the next microtask to ensure proper initialization
    Future.microtask(_setupSocketListeners);
  }

  void _setupSocketListeners() {
    final socket = socketService.socket;
    if (socket == null) return;

    // Remove previous listener (if any) and register a new one.
    // This uses typical socket.io dart API where on returns void and off removes listeners.
    try {
      socket.off('prescription:update');
    } catch (_) {
      // ignore if off fails or is not implemented
    }

    socket.on('prescription:update', (dynamic rawData) async {
      try {
        // Some socket implementations send a Map, some send a JSON string — handle common cases.
        Map<String, dynamic>? dataMap;

        if (rawData is Map) {
          // Ensure it's a Map<String, dynamic>
          try {
            dataMap = Map<String, dynamic>.from(rawData as Map);
          } catch (_) {
            // Fallback: map entries may not be String keys; ignore
            dataMap = null;
          }
        } else if (rawData is String) {
          // If the socket gives a JSON string, attempt to decode it.
          try {
            // Use dart:convert only here to decode if necessary
            // (import dart:convert above if you need this branch)
            // dataMap = json.decode(rawData) as Map<String, dynamic>;
          } catch (_) {
            dataMap = null;
          }
        }

        if (dataMap == null) return;

        // Update local cache and notify listeners
        final prescriptions = await localDataSource.getCachedPrescriptions();
        final index = prescriptions.indexWhere((p) => p.id == dataMap!['id']);
        if (index != -1) {
          final updatedModel = PrescriptionModel.fromJson(dataMap);
          final updated = updatedModel.toEntity();

          await localDataSource.cachePrescription(updated);
          final updatedList = await localDataSource.getCachedPrescriptions();
          _controller.add(updatedList);
        }
      } catch (e) {
        // swallow errors from socket handler; consider logging
      }
    });
  }

  @override
  Future<Either<Failure, List<Prescription>>> getPrescriptions() async {
    try {
      if (await networkInfo.isConnected) {
        try {
          final remotePrescriptions = await remoteDataSource.getPrescriptions();
          await localDataSource.cachePrescriptions(remotePrescriptions);
          return Right(remotePrescriptions);
        } on ServerException catch (e) {
          // Try to return cached data if available
          try {
            final localPrescriptions =
                await localDataSource.getCachedPrescriptions();
            if (localPrescriptions.isNotEmpty) {
              return Right(localPrescriptions);
            }
            return Left(ServerFailure(e.message));
          } on CacheException {
            return Left(ServerFailure(e.message));
          }
        } on ConnectionTimeoutException {
          return Left(const ConnectionFailure());
        }
      }

      // If offline, return cached data
      try {
        final localPrescriptions =
            await localDataSource.getCachedPrescriptions();
        return Right(localPrescriptions);
      } on CacheException {
        return const Left(CacheFailure('No cached prescriptions available'));
      }
    } catch (e) {
      return Left(ServerFailure('An unexpected error occurred'));
    }
  }

  @override
  Future<Either<Failure, Prescription>> getPrescription(String id) async {
    if (id.isEmpty) {
      return const Left(ServerFailure('Invalid prescription ID'));
    }

    try {
      if (await networkInfo.isConnected) {
        try {
          final prescription = await remoteDataSource.getPrescription(id);
          await localDataSource.cachePrescription(prescription);
          return Right(prescription);
        } on ServerException catch (e) {
          // Try to get from cache if remote fetch fails
          try {
            final allPrescriptions =
                await localDataSource.getCachedPrescriptions();
            final localPrescription = allPrescriptions.firstWhere(
              (p) => p.id == id,
              orElse:
                  () =>
                      throw const CacheException(
                        'Prescription not found in cache',
                      ),
            );
            return Right(localPrescription);
          } on CacheException {
            return Left(ServerFailure(e.message));
          }
        } on NotFoundException {
          return const Left(NotFoundFailure());
        } on ConnectionTimeoutException {
          return const Left(ConnectionFailure());
        }
      }

      // If offline, try to get from cache
      try {
        final allPrescriptions = await localDataSource.getCachedPrescriptions();
        final localPrescription = allPrescriptions.firstWhere(
          (p) => p.id == id,
          orElse:
              () =>
                  throw const CacheException('Prescription not found in cache'),
        );
        return Right(localPrescription);
      } on CacheException {
        return const Left(
          CacheFailure('Prescription not found in local cache'),
        );
      }
    } catch (e) {
      return Left(
        ServerFailure('An unexpected error occurred: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updatePrescriptionStatus({
    required String fieldId,
    required String prescriptionId,
    required bool isCompleted,
  }) async {
    if (prescriptionId.isEmpty) {
      return const Left(ServerFailure('Invalid prescription ID'));
    }
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.updatePrescriptionStatus(
          fieldId: fieldId,
          prescriptionId: prescriptionId,
          isCompleted: isCompleted,
        );
      }

      // Update local cache regardless of connectivity
      await localDataSource.updateCachedPrescriptionStatus(
        prescriptionId,
        isCompleted,
      );

      // Notify listeners
      final updatedList = await localDataSource.getCachedPrescriptions();
      _controller.add(updatedList);

      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure('Prescription not found in local cache'));
    } on ConnectionTimeoutException {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deletePrescription(String id) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deletePrescription(id);
      }

      await localDataSource.deleteCachedPrescription(id);

      // Notify listeners
      final updatedList = await localDataSource.getCachedPrescriptions();
      _controller.add(updatedList);

      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure('Prescription not found in local cache'));
    } on ConnectionTimeoutException {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsCompleted(bool isCompleted) async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.markAllAsCompleted(isCompleted);
      }

      // Update local cache
      final prescriptions = await localDataSource.getCachedPrescriptions();
      for (var prescription in prescriptions) {
        await localDataSource.updateCachedPrescriptionStatus(
          prescription.id,
          isCompleted,
        );
      }

      // Notify listeners
      final updatedList = await localDataSource.getCachedPrescriptions();
      _controller.add(updatedList);

      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure('Prescription not found in local cache'));
    } on ConnectionTimeoutException {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteCompletedPrescriptions() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteCompletedPrescriptions();
      }

      // Update local cache
      final prescriptions = await localDataSource.getCachedPrescriptions();
      final completedIds =
          prescriptions.where((p) => p.isCompleted).map((p) => p.id).toList();

      for (var id in completedIds) {
        await localDataSource.deleteCachedPrescription(id);
      }

      // Notify listeners
      final updatedList = await localDataSource.getCachedPrescriptions();
      _controller.add(updatedList);

      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure('Prescription not found in local cache'));
    } on ConnectionTimeoutException {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllPrescriptions() async {
    try {
      if (await networkInfo.isConnected) {
        await remoteDataSource.deleteAllPrescriptions();
      }

      await localDataSource.deleteAllCachedPrescriptions();

      // Notify listeners with empty list
      _controller.add([]);

      return const Right(null);
    } on ServerException {
      return Left(ServerFailure());
    } on CacheException {
      return const Left(CacheFailure('Prescription not found in local cache'));
    } on ConnectionTimeoutException {
      return const Left(ConnectionFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>>
  checkForNewPrescriptions() async {
    if (await networkInfo.isConnected) {
      try {
        final result = await remoteDataSource.checkForNewPrescriptions();
        return Right(result);
      } on ServerException {
        return Left(ServerFailure());
      } on ConnectionTimeoutException {
        return const Left(ConnectionFailure());
      }
    } else {
      return const Right({'hasNewPrescriptions': false, 'count': 0});
    }
  }

  @override
  Stream<List<Prescription>> get prescriptionUpdates async* {
    // First emit the current cached data
    try {
      final cachedPrescriptions =
          await localDataSource.getCachedPrescriptions();
      yield cachedPrescriptions;
    } catch (e) {
      yield [];
    }

    // Then emit updates from the stream
    yield* _controller.stream;
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> syncAnalyticsPrescriptions(
    String farmId,
    List<Map<String, dynamic>> prescriptions,
  ) async {
    try {
      if (await networkInfo.isConnected) {
        final result = await remoteDataSource.syncAnalyticsPrescriptions(farmId, prescriptions);
        return Right(result);
      } else {
        return const Left(NetworkFailure('No internet connection'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  // Clean up resources
  void dispose() {
    try {
      socketService.socket?.off('prescription:update');
    } catch (_) {
      // ignore
    }
    _controller.close();
  }
}
