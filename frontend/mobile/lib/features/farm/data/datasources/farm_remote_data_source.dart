import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/error/exceptions.dart';
import '../../../../core/config/environment.dart';
import '../models/farm_model.dart';

abstract class FarmRemoteDataSource {
  Future<FarmModel> createFarm(FarmModel farm);
  Future<List<FarmModel>> getUserFarms(String userId);
  Future<FarmModel> getFarmById(String farmId);
  Future<FarmModel> updateFarm(FarmModel farm);
  Future<void> deleteFarm(String farmId);
  Future<FarmModel> linkDevice(
    String farmId,
    String deviceId,
    String? macAddress,
  );
  Future<FarmModel> unlinkDevice(String farmId);
}

class FarmRemoteDataSourceImpl implements FarmRemoteDataSource {
  final http.Client client;

  FarmRemoteDataSourceImpl({required this.client});

  @override
  Future<FarmModel> createFarm(FarmModel farm) async {
    final response = await client.post(
      Uri.parse('${AppConfig.baseUrl}/api/farms'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
      body: json.encode(farm.toJson()),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to create farm');
    }
  }

  @override
  Future<List<FarmModel>> getUserFarms(String userId) async {
    final response = await client.get(
      Uri.parse('${AppConfig.baseUrl}/api/farms?userId=$userId'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final List<dynamic> farmsJson = responseData['data']['farms'];
      return farmsJson.map((json) => FarmModel.fromJson(json)).toList();
    } else {
      throw ServerException('Failed to create farm');
    }
  }

  @override
  Future<FarmModel> getFarmById(String farmId) async {
    final response = await client.get(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to create farm');
    }
  }

  @override
  Future<FarmModel> updateFarm(FarmModel farm) async {
    final response = await client.put(
      Uri.parse('${AppConfig.baseUrl}/api/farms/${farm.id}'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
      body: json.encode(farm.toJson()),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to create farm');
    }
  }

  @override
  Future<void> deleteFarm(String farmId) async {
    final response = await client.delete(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
    );

    if (response.statusCode != 200) {
      throw ServerException('Failed to create farm');
    }
  }

  @override
  Future<FarmModel> linkDevice(
    String farmId,
    String deviceId,
    String? macAddress,
  ) async {
    final response = await client.post(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId/device'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
      body: json.encode({
        'deviceId': deviceId,
        if (macAddress != null) 'macAddress': macAddress,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to create farm');
    }
  }

  @override
  Future<FarmModel> unlinkDevice(String farmId) async {
    final response = await client.delete(
      Uri.parse('${AppConfig.baseUrl}/api/farms/$farmId/device'),
      headers: {
        'Content-Type': 'application/json',
        // Add auth token when available
      },
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return FarmModel.fromJson(responseData['data']['farm']);
    } else {
      throw ServerException('Failed to create farm');
    }
  }
}
