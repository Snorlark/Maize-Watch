import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/farm.dart';

abstract class FarmRepository {
  Future<Either<Failure, Farm>> createFarm(Farm farm);
  Future<Either<Failure, Farm>> createFarmWithField(Farm farm, Map<String, dynamic> fieldData);
  Future<Either<Failure, List<Farm>>> getUserFarms(String userId);
  Future<Either<Failure, Farm>> getFarmById(String farmId);
  Future<Either<Failure, Farm>> updateFarm(Farm farm);
  Future<Either<Failure, void>> deleteFarm(String farmId);
  Future<Either<Failure, Farm>> linkDevice(String farmId, String deviceId, String? macAddress);
  Future<Either<Failure, Farm>> unlinkDevice(String farmId);
  Future<Either<Failure, void>> createSensor(String farmId, Map<String, dynamic> sensorData);
  Future<Either<Failure, Map<String, dynamic>>> getFarmAnalytics(String farmId);
}
