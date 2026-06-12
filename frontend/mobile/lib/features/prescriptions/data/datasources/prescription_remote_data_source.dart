import 'package:dio/dio.dart';
import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/features/prescriptions/data/models/prescription_model.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionRemoteDataSource {
  Future<List<Prescription>> getPrescriptions();
  Future<List<Prescription>> getPrescriptionsForFarm(String farmId);
  Future<Prescription> getPrescription(String id);
  Future<void> updatePrescriptionStatus({
    required String fieldId,
    required String prescriptionId,
    required bool isCompleted,
  });
  Future<void> deletePrescription(String id);
  Future<void> markAllAsCompleted(bool isCompleted);
  Future<void> deleteCompletedPrescriptions();
  Future<void> deleteAllPrescriptions();
  Future<Map<String, dynamic>> checkForNewPrescriptions();
  Future<Map<String, dynamic>> syncAnalyticsPrescriptions(
    String farmId,
    List<Map<String, dynamic>> prescriptions,
  );
}

class PrescriptionRemoteDataSourceImpl implements PrescriptionRemoteDataSource {
  final Dio httpClient;

  PrescriptionRemoteDataSourceImpl({required this.httpClient});

  @override
  Future<List<Prescription>> getPrescriptions() async {
    // This method is deprecated - use getPrescriptionsForFarm() instead
    throw UnimplementedError('getPrescriptions() requires farmId parameter - use getPrescriptionsForFarm() instead');
  }

  @override
  Future<List<Prescription>> getPrescriptionsForFarm(String farmId) async {
    try {
      final response = await httpClient.get('/prescriptions/farm/$farmId');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data
            .map((json) => PrescriptionModel.fromJson(json).toEntity())
            .toList();
      } else {
        throw ServerException('Failed to load prescriptions: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('An unknown error occurred: ${e.message}');
      }
    } catch (e) {
      throw ServerException('Unexpected error: $e');
    }
  }

  @override
  Future<Prescription> getPrescription(String id) async {
    if (id.isEmpty) {
      throw ServerException('Invalid prescription ID');
    }
    
    try {
      final response = await httpClient.get('/prescriptions/$id');
      
      if (response.statusCode == 200) {
        return PrescriptionModel.fromJson(response.data['data']).toEntity();
      } else {
        throw ServerException('Failed to fetch prescription: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw NotFoundException();
      } else {
        throw ServerException('Failed to fetch prescription: ${e.message} (${e.response?.statusCode})');
      }
    }
  }

  @override
  Future<void> updatePrescriptionStatus({
    required String fieldId,
    required String prescriptionId,
    required bool isCompleted,
  }) async {
    try {
      final response = await httpClient.patch(
        '/fields/$fieldId/prescriptions/$prescriptionId',
        data: {'isCompleted': isCompleted},
      );
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update prescription status: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error while updating prescription status: ${e.message}');
    }
  }

  @override
  Future<void> deletePrescription(String id) async {
    try {
      final response = await httpClient.delete('/prescriptions/$id');
      
      if (response.statusCode != 204) {
        throw ServerException('Failed to delete prescription: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error while deleting prescription: ${e.message}');
    }
  }

  @override
  Future<void> markAllAsCompleted(bool isCompleted) async {
    try {
      final response = await httpClient.patch(
        '/prescriptions/update-status',
        data: {'isCompleted': isCompleted},
      );
      
      if (response.statusCode != 200) {
        throw ServerException('Failed to update all prescriptions status: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error while updating all prescriptions: ${e.message}');
    }
  }

  @override
  Future<void> deleteCompletedPrescriptions() async {
    try {
      final response = await httpClient.delete('/prescriptions/completed');
      
      if (response.statusCode != 204) {
        throw ServerException('Failed to delete completed prescriptions: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error while deleting completed prescriptions: ${e.message}');
    }
  }

  @override
  Future<void> deleteAllPrescriptions() async {
    try {
      final response = await httpClient.delete('/prescriptions');
      
      if (response.statusCode != 204) {
        throw ServerException('Failed to delete all prescriptions: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      throw ServerException('Network error while deleting all prescriptions: ${e.message}');
    }
  }

  @override
  Future<Map<String, dynamic>> checkForNewPrescriptions() async {
    try {
      final response = await httpClient.get('/prescriptions/check-updates');
      
      if (response.statusCode == 200) {
        return {
          'hasNewPrescriptions': response.data['hasNewPrescriptions'] ?? false,
          'count': response.data['count'] ?? 0,
        };
      } else {
        throw ServerException('Failed to check for new prescriptions: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('Network error while checking for new prescriptions: ${e.message} (${e.response?.statusCode})');
      }
    }
  }

  @override
  Future<Map<String, dynamic>> syncAnalyticsPrescriptions(
    String farmId,
    List<Map<String, dynamic>> prescriptions,
  ) async {
    try {
      final response = await httpClient.post(
        '/prescriptions/sync-analytics',
        data: {
          'farmId': farmId,
          'prescriptions': prescriptions,
        },
      );
      
      if (response.statusCode == 200) {
        return response.data['data'] ?? {};
      } else {
        throw ServerException('Failed to sync analytics prescriptions: ${response.statusCode} - ${response.statusMessage}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw ConnectionTimeoutException();
      } else {
        throw ServerException('Network error while syncing analytics prescriptions: ${e.message} (${e.response?.statusCode})');
      }
    }
  }
}
