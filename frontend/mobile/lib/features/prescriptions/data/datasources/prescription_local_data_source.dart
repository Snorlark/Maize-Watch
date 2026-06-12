import 'dart:convert';

import 'package:mobile/core/error/exceptions.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/features/prescriptions/data/models/prescription_model.dart';
import 'package:mobile/features/prescriptions/domain/entities/prescription.dart';

abstract class PrescriptionLocalDataSource {
  Future<List<Prescription>> getCachedPrescriptions();
  Future<void> cachePrescriptions(List<Prescription> prescriptions);
  Future<void> cachePrescription(Prescription prescription);
  Future<void> deleteCachedPrescription(String id);
  Future<void> deleteAllCachedPrescriptions();
  Future<void> updateCachedPrescriptionStatus(String id, bool isCompleted);
}

class PrescriptionLocalDataSourceImpl implements PrescriptionLocalDataSource {
  final String _prescriptionsKey = 'cached_prescriptions';

  PrescriptionLocalDataSourceImpl();

  @override
  Future<List<Prescription>> getCachedPrescriptions() async {
    try {
      final jsonString = await SecureStorage.read(key: _prescriptionsKey);
      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }
      
      try {
        // Parse the JSON string to a list of Prescription objects
        final List<dynamic> jsonList = json.decode(jsonString) as List;
        if (jsonList.isEmpty) return [];
        
        return jsonList
            .map((json) {
              try {
                return PrescriptionModel.fromJson(json as Map<String, dynamic>).toEntity();
              } catch (e) {
                throw CacheException('Failed to parse cached prescription: $e');
              }
            })
            .whereType<Prescription>()
            .toList();
      } on FormatException {
        // If JSON is corrupted, clear the cache and return empty list
        await SecureStorage.write(key: _prescriptionsKey, value: '');
        return [];
      }
    } catch (e) {
      throw CacheException('Failed to get cached prescriptions: ${e.toString()}');
    }
  }

  @override
  Future<void> cachePrescriptions(List<Prescription> prescriptions) async {
    try {
      final jsonList = prescriptions
          .map((p) => PrescriptionModel.fromEntity(p).toJson())
          .toList();
      await SecureStorage.write(
        key: _prescriptionsKey,
        value: json.encode(jsonList),
      );
    } catch (e) {
      throw CacheException('Failed to cache prescriptions: ${e.toString()}');
    }
  }

  @override
  Future<void> cachePrescription(Prescription prescription) async {
    try {
      final prescriptions = await getCachedPrescriptions();
      final index = prescriptions.indexWhere((p) => p.id == prescription.id);
      if (index != -1) {
        prescriptions[index] = prescription;
      } else {
        prescriptions.add(prescription);
      }
      await cachePrescriptions(prescriptions);
    } catch (e) {
      throw CacheException('Failed to cache prescription: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteCachedPrescription(String id) async {
    try {
      final prescriptions = await getCachedPrescriptions();
      final initialLength = prescriptions.length;
      prescriptions.removeWhere((p) => p.id == id);
      
      if (prescriptions.length != initialLength) {
        await cachePrescriptions(prescriptions);
      }
    } catch (e) {
      throw CacheException('Failed to delete cached prescription: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAllCachedPrescriptions() async {
    try {
      await SecureStorage.write(key: _prescriptionsKey, value: '');
    } catch (e) {
      throw CacheException('Failed to delete all cached prescriptions: ${e.toString()}');
    }
  }

  @override
  Future<void> updateCachedPrescriptionStatus(String id, bool isCompleted) async {
    try {
      final prescriptions = await getCachedPrescriptions();
      final index = prescriptions.indexWhere((p) => p.id == id);
      if (index != -1) {
        final updatedPrescription = prescriptions[index].copyWith(
          isCompleted: isCompleted,
        );
        prescriptions[index] = updatedPrescription;
        await cachePrescriptions(prescriptions);
      }
    } catch (e) {
      throw CacheException('Failed to update prescription status: ${e.toString()}');
    }
  }
}
