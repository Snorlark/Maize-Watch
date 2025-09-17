import 'package:equatable/equatable.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionEvent extends Equatable {
  const PrescriptionEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrescriptions extends PrescriptionEvent {
  const LoadPrescriptions();
}

class UpdatePrescriptionStatus extends PrescriptionEvent {
  final String fieldId;
  final String prescriptionId;
  final bool isCompleted;

  const UpdatePrescriptionStatus({
    required this.fieldId,
    required this.prescriptionId,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [fieldId, prescriptionId, isCompleted];
}

class DeletePrescription extends PrescriptionEvent {
  final String id;

  const DeletePrescription(this.id);

  @override
  List<Object?> get props => [id];
}

class MarkAllAsCompleted extends PrescriptionEvent {
  final bool isCompleted;

  const MarkAllAsCompleted(this.isCompleted);

  @override
  List<Object?> get props => [isCompleted];
}

class DeleteCompletedPrescriptions extends PrescriptionEvent {
  const DeleteCompletedPrescriptions();
}

class DeleteAllPrescriptions extends PrescriptionEvent {
  const DeleteAllPrescriptions();
}

class CheckForNewPrescriptions extends PrescriptionEvent {
  const CheckForNewPrescriptions();
}
