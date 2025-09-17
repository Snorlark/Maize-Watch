import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import '../../../farm/presentation/bloc/farm_bloc.dart';

class DebugDataView extends StatefulWidget {
  const DebugDataView({super.key});

  @override
  _DebugDataViewState createState() => _DebugDataViewState();
}

class _DebugDataViewState extends State<DebugDataView> {
  @override
  void initState() {
    super.initState();
    // Fetch user farms when screen loads
    final authState = context.read<AuthenticationBloc>().state;
    if (authState.status == AuthenticationStatus.authenticated &&
        authState.user != null) {
      context.read<FarmBloc>().add(
        GetUserFarmsEvent(userId: authState.user!.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Data View'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Authentication Data Section
            _buildSectionTitle('🔐 Authentication Data'),
            BlocBuilder<AuthenticationBloc, AuthenticationState>(
              builder: (context, authState) {
                return _buildDataCard([
                  'Status: ${authState.status}',
                  'User ID: ${authState.user?.id ?? 'null'}',
                  'Username: ${authState.user?.username ?? 'null'}',
                  'Full Name: ${authState.user?.fullName ?? 'null'}',
                  'Contact: ${authState.user?.contactNumber ?? 'null'}',
                  'Role: ${authState.user?.role ?? 'null'}',
                  'Address: ${authState.user?.address ?? 'null'}',
                ]);
              },
            ),

            const SizedBox(height: 20),

            // Farm Data Section
            _buildSectionTitle('🌽 Farm Data'),
            BlocBuilder<FarmBloc, FarmState>(
              builder: (context, farmState) {
                if (farmState is FarmInitial) {
                  return _buildDataCard([
                    'State: Initial - No data loaded yet',
                  ]);
                } else if (farmState is FarmLoading) {
                  return _buildDataCard(['State: Loading farms...']);
                } else if (farmState is FarmsLoaded) {
                  final farms = farmState.farms;
                  List<String> farmData = [
                    'State: FarmsLoaded',
                    'Number of farms: ${farms.length}',
                    '',
                  ];

                  for (int i = 0; i < farms.length; i++) {
                    final farm = farms[i];
                    farmData.addAll([
                      '--- Farm ${i + 1} ---',
                      'ID: ${farm.id}',
                      'Name: ${farm.farmName}',
                      'User ID: ${farm.userId}',
                      'Created: ${farm.createdAt}',
                      'Updated: ${farm.updatedAt}',
                      'Fields Count: ${farm.fields.length}',
                      '',
                    ]);

                    // Display fields data
                    if (farm.fields.isNotEmpty) {
                      for (int j = 0; j < farm.fields.length; j++) {
                        final field = farm.fields[j];
                        farmData.addAll([
                          '  --- Field ${j + 1} ---',
                          '  Field Name: ${field.fieldName}',
                          '  Planting Date: ${field.plantingDate}',
                          '  Growth Stage: ${field.growthStage}',
                          '  Sensors Count: ${field.sensors.length}',
                          '',
                        ]);

                        // Display sensors data
                        if (field.sensors.isNotEmpty) {
                          for (int k = 0; k < field.sensors.length; k++) {
                            final sensor = field.sensors[k];
                            farmData.addAll([
                              '    --- Sensor ${k + 1} ---',
                              '    Device ID: ${sensor.deviceID}',
                              '    Name: ${sensor.sensorName}',
                              '    Description: ${sensor.description}',
                              '    Soil Type: ${sensor.soilType}',
                              '',
                            ]);

                            // Display sensor readings
                            farmData.addAll([
                              '      Current Readings:',
                              '      Temperature: ${sensor.readings.temperature}°C',
                              '      Humidity: ${sensor.readings.humidity}%',
                              '      Soil Moisture: ${sensor.readings.soilMoisture}%',
                              '      Soil pH: ${sensor.readings.soilPh}',
                              '      Light Intensity: ${sensor.readings.lightIntensity} lux',
                              '',
                            ]);
                          }
                        }
                      }
                    }
                  }

                  return _buildDataCard(farmData);
                } else if (farmState is FarmError) {
                  return _buildDataCard([
                    'State: Error',
                    'Error Message: ${farmState.message}',
                  ]);
                } else if (farmState is FarmCreated) {
                  return _buildDataCard([
                    'State: Farm Created',
                    'Farm ID: ${farmState.farm.id}',
                    'Farm Name: ${farmState.farm.farmName}',
                  ]);
                } else {
                  return _buildDataCard(['State: ${farmState.runtimeType}']);
                }
              },
            ),

            const SizedBox(height: 20),

            // Action Buttons
            _buildSectionTitle('🔄 Actions'),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final authState =
                          context.read<AuthenticationBloc>().state;
                      if (authState.user != null) {
                        context.read<FarmBloc>().add(
                          GetUserFarmsEvent(userId: authState.user!.id),
                        );
                      }
                    },
                    child: const Text('Refresh Farm Data'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<AuthenticationBloc>().add(
                        CheckAuthStatusEvent(),
                      );
                    },
                    child: const Text('Refresh Auth'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.green,
        ),
      ),
    );
  }

  Widget _buildDataCard(List<String> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              data
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color:
                              item.startsWith('---')
                                  ? Colors.blue
                                  : Colors.black87,
                          fontWeight:
                              item.startsWith('---')
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
