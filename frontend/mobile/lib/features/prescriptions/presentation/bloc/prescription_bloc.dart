import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';
import 'package:mobile/features/prescriptions/domain/usecases/delete_all_prescriptions.dart'
    as usecase;
import 'package:mobile/features/prescriptions/domain/usecases/delete_completed_prescriptions.dart'
    as usecase;
import 'package:mobile/features/prescriptions/domain/usecases/delete_prescription.dart'
    as usecase;
import 'package:mobile/features/prescriptions/domain/usecases/get_prescriptions.dart';
import 'package:mobile/features/prescriptions/domain/usecases/mark_all_as_completed.dart'
    as usecase;
import 'package:mobile/features/prescriptions/domain/usecases/update_prescription_status.dart'
    as usecase;
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_event.dart';
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_state.dart';

import '../../../../core/usecases/usecase.dart';

class PrescriptionBloc extends Bloc<PrescriptionEvent, PrescriptionState> {
  final GetPrescriptions getPrescriptions;
  final usecase.UpdatePrescriptionStatus updatePrescriptionStatus;
  final usecase.DeletePrescription deletePrescription;
  final usecase.MarkAllAsCompleted markAllAsCompleted;
  final usecase.DeleteCompletedPrescriptions deleteCompletedPrescriptions;
  final usecase.DeleteAllPrescriptions deleteAllPrescriptions;

  StreamSubscription<Either<Failure, List<Prescription>>>?
  _prescriptionSubscription;
  PrescriptionBloc({
    required this.getPrescriptions,
    required this.updatePrescriptionStatus,
    required this.deletePrescription,
    required this.markAllAsCompleted,
    required this.deleteCompletedPrescriptions,
    required this.deleteAllPrescriptions,
  }) : super(const PrescriptionInitial()) {
    on<LoadPrescriptions>(_onLoadPrescriptions);
    on<UpdatePrescriptionStatus>(_onUpdatePrescriptionStatus);
    on<DeletePrescription>(_onDeletePrescription);
    on<MarkAllAsCompleted>(_onMarkAllAsCompleted);
    on<DeleteCompletedPrescriptions>(_onDeleteCompletedPrescriptions);
    on<DeleteAllPrescriptions>(_onDeleteAllPrescriptions);
    on<CheckForNewPrescriptions>(_onCheckForNewPrescriptions);
  }

  void _onLoadPrescriptions(
    LoadPrescriptions event,
    Emitter<PrescriptionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    _prescriptionSubscription?.cancel();
    
    try {
      final failureOrPrescriptions = await getPrescriptions(NoParams());
      
      failureOrPrescriptions.fold(
        (failure) {
          emit(state.copyWith(
            isLoading: false,
            errorMessage: _mapFailureToMessage(failure),
          ));
        },
        (prescriptions) {
          emit(state.copyWith(
            prescriptions: prescriptions,
            isLoading: false,
            errorMessage: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load prescriptions: $e',
      ));
    }
  }

  void _onUpdatePrescriptionStatus(
    UpdatePrescriptionStatus event,
    Emitter<PrescriptionState> emit,
  ) async {
    final result = await updatePrescriptionStatus(
      usecase.UpdatePrescriptionStatusParams(
        fieldId: event.fieldId,
        prescriptionId: event.prescriptionId,
        isCompleted: event.isCompleted,
      ),
    );

    result.fold(
      (failure) => emit(PrescriptionError(_mapFailureToMessage(failure))),
      (_) {
        // State will be updated via the stream
      },
    );
  }

  void _onDeletePrescription(
    DeletePrescription event,
    Emitter<PrescriptionState> emit,
  ) async {
    final result = await deletePrescription(event.id);
    result.fold(
      (failure) => emit(PrescriptionError(_mapFailureToMessage(failure))),
      (_) {
        // State will be updated via the stream
      },
    );
  }

  void _onMarkAllAsCompleted(
    MarkAllAsCompleted event,
    Emitter<PrescriptionState> emit,
  ) async {
    final result = await markAllAsCompleted(event.isCompleted);
    result.fold(
      (failure) => emit(PrescriptionError(_mapFailureToMessage(failure))),
      (_) {
        // State will be updated via the stream
      },
    );
  }

  void _onDeleteCompletedPrescriptions(
    DeleteCompletedPrescriptions event,
    Emitter<PrescriptionState> emit,
  ) async {
    final result = await deleteCompletedPrescriptions(NoParams());
    result.fold(
      (failure) => emit(PrescriptionError(_mapFailureToMessage(failure))),
      (_) {
        // State will be updated via the stream
      },
    );
  }

  void _onDeleteAllPrescriptions(
    DeleteAllPrescriptions event,
    Emitter<PrescriptionState> emit,
  ) async {
    final result = await deleteAllPrescriptions(NoParams());
    result.fold(
      (failure) => emit(PrescriptionError(_mapFailureToMessage(failure))),
      (_) {
        // State will be updated via the stream
      },
    );
  }

  void _onCheckForNewPrescriptions(
    CheckForNewPrescriptions event,
    Emitter<PrescriptionState> emit,
  ) async {
    if (state is PrescriptionLoaded) {
      final currentState = state as PrescriptionLoaded;
      emit(
        currentState.copyWith(
          hasNewPrescriptions: false,
          newPrescriptionsCount: 0,
        ),
      );
    }
  }


  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error';
      case CacheFailure:
        return 'Cache error';
      case ConnectionFailure:
        return 'Connection error';
      case NotFoundFailure:
        return 'Not found';
      default:
        return 'Unexpected error';
    }
  }


  @override
  Future<void> close() {
    _prescriptionSubscription?.cancel();
    return super.close();
  }
}
