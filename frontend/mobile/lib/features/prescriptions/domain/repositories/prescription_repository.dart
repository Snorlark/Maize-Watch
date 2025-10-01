import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failures.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionRepository {
  // Get all prescriptions
  Future<Either<Failure, List<Prescription>>> getPrescriptions();
  
  // Get prescriptions for a specific farm
  Future<Either<Failure, List<Prescription>>> getPrescriptionsForFarm(String farmId);
  
  // Get a single prescription by ID
  Future<Either<Failure, Prescription>> getPrescription(String id);
  
  // Update prescription status
  Future<Either<Failure, void>> updatePrescriptionStatus({
    required String fieldId,
    required String prescriptionId,
    required bool isCompleted,
  });
  
  // Delete a prescription
  Future<Either<Failure, void>> deletePrescription(String id);
  
  // Mark all prescriptions as completed
  Future<Either<Failure, void>> markAllAsCompleted(bool isCompleted);
  
  // Delete all completed prescriptions
  Future<Either<Failure, void>> deleteCompletedPrescriptions();
  
  // Delete all prescriptions
  Future<Either<Failure, void>> deleteAllPrescriptions();
  
  // Check for new prescriptions
  Future<Either<Failure, Map<String, dynamic>>> checkForNewPrescriptions();
  
  // Listen to prescription updates
  Stream<List<Prescription>> get prescriptionUpdates;
  
  // Sync analytics prescriptions with backend
  Future<Either<Failure, Map<String, dynamic>>> syncAnalyticsPrescriptions(
    String farmId,
    List<Map<String, dynamic>> prescriptions,
  );
}
