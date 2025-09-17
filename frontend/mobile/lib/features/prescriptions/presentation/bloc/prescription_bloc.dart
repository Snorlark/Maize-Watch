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
    _prescriptionSubscription = getPrescriptions(NoParams()).asStream().listen((
      failureOrPrescriptions,
    ) {
      failureOrPrescriptions.fold(
        (failure) => add(_mapFailureToEvent(failure)),
        (prescriptions) => add(_prescriptionsUpdated(prescriptions)),
      );
    });
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

  PrescriptionEvent _prescriptionsUpdated(List<Prescription> prescriptions) {
    return _PrescriptionsUpdated(prescriptions);
  }

  PrescriptionEvent _mapFailureToEvent(Failure failure) {
    return _PrescriptionsError(_mapFailureToMessage(failure));
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

// Private events for internal use
class _PrescriptionsUpdated extends PrescriptionEvent {
  final List<Prescription> prescriptions;

  const _PrescriptionsUpdated(this.prescriptions);

  @override
  List<Object> get props => [prescriptions];
}

class _PrescriptionsError extends PrescriptionEvent {
  final String message;

  const _PrescriptionsError(this.message);

  @override
  List<Object> get props => [message];
}
