import 'package:equatable/equatable.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

class PrescriptionState extends Equatable {
  final List<Prescription> prescriptions;
  final bool isLoading;
  final String? errorMessage;
  final bool hasNewPrescriptions;
  final int newPrescriptionsCount;

  const PrescriptionState({
    this.prescriptions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.hasNewPrescriptions = false,
    this.newPrescriptionsCount = 0,
  });

  PrescriptionState copyWith({
    List<Prescription>? prescriptions,
    bool? isLoading,
    String? errorMessage,
    bool? hasNewPrescriptions,
    int? newPrescriptionsCount,
  }) {
    return PrescriptionState(
      prescriptions: prescriptions ?? this.prescriptions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      hasNewPrescriptions: hasNewPrescriptions ?? this.hasNewPrescriptions,
      newPrescriptionsCount: newPrescriptionsCount ?? this.newPrescriptionsCount,
    );
  }

  @override
  List<Object?> get props => [
        prescriptions,
        isLoading,
        errorMessage,
        hasNewPrescriptions,
        newPrescriptionsCount,
      ];
}

class PrescriptionInitial extends PrescriptionState {
  const PrescriptionInitial() : super();
}

class PrescriptionLoading extends PrescriptionState {
  const PrescriptionLoading() : super(isLoading: true);
}

class PrescriptionLoaded extends PrescriptionState {
  final List<Prescription> loadedPrescriptions;
  final bool hasNew;
  final int count;

  const PrescriptionLoaded({
    required this.loadedPrescriptions,
    this.hasNew = false,
    this.count = 0,
  }) : super(
          prescriptions: loadedPrescriptions,
          hasNewPrescriptions: hasNew,
          newPrescriptionsCount: count,
        );
}

class PrescriptionError extends PrescriptionState {
  final String message;

  const PrescriptionError(this.message) : super(errorMessage: message);
}
