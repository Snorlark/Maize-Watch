import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:mobile/features/farm/presentation/bloc/farm_bloc.dart';
import 'growth_progress_widget.dart';
import 'historical_tab_widget.dart';
import '../../../farm/domain/entities/farm.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../bloc/monitoring_bloc.dart';
import '../../domain/entities/analytics_entities.dart';

class FarmDetailWidget extends StatefulWidget {
  final Farm farm;
  final List<Sensor> sensors;
  final List<SensorReading> sensorReadings;
  final VoidCallback onBack;
  final Field? selectedField; // Add selected field parameter

  const FarmDetailWidget({
    super.key,
    required this.farm,
    required this.sensorReadings,
    required this.onBack,
    this.selectedField,
    required this.sensors,
  });

  @override
  State<FarmDetailWidget> createState() => _FarmDetailWidgetState();
}

class _FarmDetailWidgetState extends State<FarmDetailWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;

  // Analytics data
  CropConditionModel? _cropCondition;
  MetricsModel? _currentMetrics;
  WeeklyDataModel? _weeklyData;
  GrowthStageAnalysisModel? _growthStageAnalysis;
  Map<String, dynamic>? _stressAnalysis; // Store stress analysis data
  bool _isLoadingAnalytics = false;
  String? _analyticsError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Changed to 3 tabs
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });

    // Load field-specific data when widget initializes
    _loadFieldData();
    // Defer analytics load until after first build so BlocProvider is in the tree
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnalyticsData();
    });
  }

  @override
  void didUpdateWidget(FarmDetailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if the selected field has changed
    if (oldWidget.selectedField?.fieldName != widget.selectedField?.fieldName) {
      print('🔍 Field changed from ${oldWidget.selectedField?.fieldName} to ${widget.selectedField?.fieldName}');
      
      // Clear current metrics to force reload
      setState(() {
        _currentMetrics = null;
        _cropCondition = null;
        _stressAnalysis = null;
      });
      
      // Reload analytics data for the new field
      _loadAnalyticsData();
    }
  }

  void _loadFieldData() {
    // Load sensor readings for the selected field
    if (widget.selectedField != null && widget.farm.id != null) {
      context.read<MonitoringBloc>().add(
        LoadHistoricalReadingsEvent(farmId: widget.farm.id!, days: 7),
      );
    }
  }

  void _loadAnalyticsData() async {
    if (widget.farm.id == null) return;

    // Load analytics data using MonitoringBloc
    context.read<MonitoringBloc>().add(
      LoadFarmAnalyticsEvent(farmId: widget.farm.id!),
    );
  }

  void _parseAnalyticsData(Map<String, dynamic> analyticsData) {
    try {
      print('🔍 Raw analytics data structure: ${analyticsData.keys.toList()}');
      
      // Try to use complete analytics data first (with stress analysis)
      if (analyticsData['descriptive'] != null) {
        final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
        print('🔍 Using complete analytics data with stress analysis');
        
        // Get timestamp from analytics data (actual ThingSpeak timestamp)
        final timestamp = descriptive['date'] != null 
            ? DateTime.parse(descriptive['date'] as String)
            : DateTime.now();
        
        // Store stress analysis data for status indicators
        final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
        if (stressAnalysis != null) {
          _stressAnalysis = stressAnalysis;
          print('🔍 Stored stress analysis data: $_stressAnalysis');
        }
        
        // Extract values from stress analysis (real ThingSpeak data)
        final temperatureData = stressAnalysis?['Temperature'] as Map<String, dynamic>?;
        final humidityData = stressAnalysis?['Humidity'] as Map<String, dynamic>?;
        final soilMoistureData = stressAnalysis?['Soil Moisture'] as Map<String, dynamic>?;
        final soilPhData = stressAnalysis?['Soil pH'] as Map<String, dynamic>?;
        final lightIntensityData = stressAnalysis?['Light Intensity'] as Map<String, dynamic>?;
        
        _currentMetrics = MetricsModel(
          soilPh: (soilPhData?['actual_value'] as num?)?.toDouble() ?? 0.0,
          soilMoisture: (soilMoistureData?['actual_value'] as num?)?.toDouble() ?? 0.0,
          temperature: (temperatureData?['actual_value'] as num?)?.toDouble() ?? 0.0,
          humidity: (humidityData?['actual_value'] as num?)?.toDouble() ?? 0.0,
          lightIntensity: (lightIntensityData?['actual_value'] as num?)?.toDouble() ?? 0.0,
          timestamp: timestamp, // Use actual ThingSpeak timestamp
        );
        print('🔍 Using complete analytics data for metrics: ${_currentMetrics?.temperature}°C at ${_currentMetrics?.timestamp}');
      } else if (analyticsData['data'] != null) {
        // Fallback to raw sensor data if complete analytics not available
        final data = analyticsData['data'] as Map<String, dynamic>;
        final timestamp = data['timestamp'] != null 
            ? DateTime.parse(data['timestamp'] as String)
            : DateTime.now();
        
        _currentMetrics = MetricsModel(
          soilPh: (data['soilPh'] as num?)?.toDouble() ?? 0.0,
          soilMoisture: (data['soilMoisture'] as num?)?.toDouble() ?? 0.0,
          temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
          humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
          lightIntensity: (data['lightIntensity'] as num?)?.toDouble() ?? 0.0,
          timestamp: timestamp,
        );
        print('🔍 Using raw analytics data for metrics: ${_currentMetrics?.temperature}°C at ${_currentMetrics?.timestamp}');
      } else if (widget.sensorReadings.isNotEmpty) {
        // Fallback to sensor readings if analytics data is not available
        final latestReading = widget.sensorReadings.first;
        _currentMetrics = MetricsModel(
          soilPh: latestReading.pH,
          soilMoisture: latestReading.soilMoisture,
          temperature: latestReading.temperature,
          humidity: latestReading.humidity,
          lightIntensity: latestReading.lightIntensity,
          timestamp: latestReading.timestamp,
        );
        print('🔍 Using sensor readings for metrics: ${_currentMetrics?.temperature}°C');
      } else {
        print('🔍 No data available for metrics');
      }

      // Create weekly data from sensor readings
      if (widget.sensorReadings.isNotEmpty) {
        _weeklyData = _createWeeklyDataFromReadings(widget.sensorReadings);
        print('🔍 Created weekly data from ${widget.sensorReadings.length} readings');
      } else {
        print('🔍 No sensor readings available for weekly data');
      }
      
      // If still no weekly data, create a fallback with current metrics
      if (_weeklyData == null && _currentMetrics != null) {
        _weeklyData = _createFallbackWeeklyData(_currentMetrics!);
        print('🔍 Created fallback weekly data from current metrics');
      }

      // Create growth stage from field data
      final selectedField = widget.selectedField ?? 
          (widget.farm.fields.isNotEmpty ? widget.farm.fields.first : null);
      if (selectedField != null) {
        _growthStageAnalysis = _createGrowthStageFromField(selectedField);
        print('🔍 Created growth stage from field: ${selectedField.growthStage}');
      }

      // Try to parse analytics data if available
      if (analyticsData['prescriptive'] != null) {
        final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
        print('🔍 Prescriptive data keys: ${prescriptive.keys.toList()}');
        
        // Try to get crop condition from analytics (new field)
        final cropCondition = prescriptive['crop_condition'] as Map<String, dynamic>?;
        if (cropCondition != null) {
          _cropCondition = CropConditionModel.fromJson(cropCondition);
          print('🔍 Parsed crop condition from analytics: ${_cropCondition?.status}');
        }
      }

      // Try to parse descriptive analytics
      if (analyticsData['descriptive'] != null) {
        final descriptive = analyticsData['descriptive'] as Map<String, dynamic>;
        print('🔍 Descriptive data keys: ${descriptive.keys.toList()}');
        
        // Try to get current metrics from analytics (new field)
        final currentMetrics = descriptive['current_metrics'] as Map<String, dynamic>?;
        if (currentMetrics != null) {
          _currentMetrics = MetricsModel.fromJson(currentMetrics);
          print('🔍 Parsed metrics from analytics: ${_currentMetrics?.temperature}°C');
        }
        
        // Try to get weekly data from analytics (new field)
        final weeklyData = descriptive['weekly_data'] as Map<String, dynamic>?;
        if (weeklyData != null) {
          _weeklyData = WeeklyDataModel.fromJson(weeklyData);
          print('🔍 Parsed weekly data from analytics');
        } else {
          print('🔍 No weekly data from analytics, will use sensor readings if available');
        }
        
        // Try to get growth stage analysis from analytics (new field)
        final growthStageAnalysis = descriptive['growth_stage_analysis'] as Map<String, dynamic>?;
        if (growthStageAnalysis != null) {
          _growthStageAnalysis = GrowthStageAnalysisModel.fromJson(growthStageAnalysis);
          print('🔍 Parsed growth stage from analytics: ${_growthStageAnalysis?.currentStage}');
        }
        
        // Parse field-specific data to create current_metrics (PRIORITY)
        final fieldAnalyses = descriptive['field_analyses'] as Map<String, dynamic>?;
        if (fieldAnalyses != null) {
          // Get the selected field name
          final selectedFieldName = widget.selectedField?.fieldName ?? 
              (widget.farm.fields.isNotEmpty ? widget.farm.fields.first.fieldName : null);
          
          print('🔍 Looking for field-specific data for: $selectedFieldName');
          print('🔍 Available fields in analytics: ${fieldAnalyses.keys.toList()}');
          
          if (selectedFieldName != null && fieldAnalyses.containsKey(selectedFieldName)) {
            final fieldData = fieldAnalyses[selectedFieldName] as Map<String, dynamic>;
            final weatherSummary = fieldData['weather_summary'] as Map<String, dynamic>?;
            
            if (weatherSummary != null) {
              _currentMetrics = MetricsModel(
                soilPh: (weatherSummary['avg_soil_ph'] as num?)?.toDouble() ?? 0.0,
                soilMoisture: (weatherSummary['avg_soil_moisture'] as num?)?.toDouble() ?? 0.0,
                temperature: (weatherSummary['avg_temp'] as num?)?.toDouble() ?? 0.0,
                humidity: (weatherSummary['avg_humidity'] as num?)?.toDouble() ?? 0.0,
                lightIntensity: (weatherSummary['avg_light_intensity'] as num?)?.toDouble() ?? 0.0,
                timestamp: DateTime.now(),
              );
              print('🔍 ✅ Created metrics from field-specific data for $selectedFieldName: ${_currentMetrics?.temperature}°C, ${_currentMetrics?.humidity}%, ${_currentMetrics?.soilMoisture}%');
            } else {
              print('🔍 ❌ No weather summary found for field $selectedFieldName');
            }
          } else {
            print('🔍 ❌ Field $selectedFieldName not found in field analyses');
          }
        } else {
          print('🔍 ❌ No field analyses found in analytics data');
        }
        
        // Fallback to overall stress analysis if field-specific data not available
        if (_currentMetrics == null) {
          final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
          if (stressAnalysis != null) {
            // Store stress analysis data for chart display
            _stressAnalysis = stressAnalysis;
            print('🔍 Stored stress analysis data: $_stressAnalysis');
            
            _currentMetrics = _createMetricsFromStressAnalysis(stressAnalysis);
            print('🔍 Created metrics from stress analysis: ${_currentMetrics?.temperature}°C');
          } else {
            print('🔍 No stress analysis available for metrics');
          }
        }
        
        // Parse field-specific stress analysis for crop condition
        if (_cropCondition == null && fieldAnalyses != null) {
          final selectedFieldName = widget.selectedField?.fieldName ?? 
              (widget.farm.fields.isNotEmpty ? widget.farm.fields.first.fieldName : null);
          
          if (selectedFieldName != null && fieldAnalyses.containsKey(selectedFieldName)) {
            final fieldData = fieldAnalyses[selectedFieldName] as Map<String, dynamic>;
            final fieldStressAnalysis = fieldData['stress_analysis'] as Map<String, dynamic>?;
            
            if (fieldStressAnalysis != null) {
              print('🔍 Using field-specific stress analysis for $selectedFieldName');
              _stressAnalysis = fieldStressAnalysis;
              _cropCondition = _createCropConditionFromStressAnalysis(fieldStressAnalysis);
              print('🔍 Created crop condition from field-specific stress analysis: ${_cropCondition?.status}');
            }
          }
        }
        
        // Fallback: Create crop condition from overall stress analysis if available
        if (_cropCondition == null) {
          final overallStress = descriptive['overall_stress'] as String?;
          print('🔍 Overall stress level: $overallStress');
          if (overallStress != null && overallStress.toLowerCase() != 'unknown') {
            _cropCondition = _createCropConditionFromStress(overallStress);
            print('🔍 Created crop condition from overall stress analysis: ${_cropCondition?.status}');
          } else {
            // If overall_stress is unknown, analyze individual stress levels
            final stressAnalysis = descriptive['stress_analysis'] as Map<String, dynamic>?;
            if (stressAnalysis != null) {
              print('🔍 Analyzing individual stress levels: ${stressAnalysis.keys.toList()}');
              _stressAnalysis = stressAnalysis;
              _cropCondition = _createCropConditionFromStressAnalysis(stressAnalysis);
              print('🔍 Created crop condition from individual stress levels: ${_cropCondition?.status}');
            } else {
              print('🔍 No stress analysis available for crop condition');
            }
          }
        }
      }

      // Create a basic crop condition if none exists
      if (_cropCondition == null && _currentMetrics != null) {
        _cropCondition = _createCropConditionFromMetrics(_currentMetrics!);
        print('🔍 Created crop condition from metrics: ${_cropCondition?.status}');
      }

      print('🔍 Final parsed data - Crop: ${_cropCondition?.status}, Metrics: ${_currentMetrics?.temperature}°C, Growth: ${_growthStageAnalysis?.currentStage}');
    } catch (e) {
      print('🔍 Error parsing analytics data: $e');
        setState(() {
        _analyticsError = 'Failed to parse analytics data: $e';
      });
    }
  }

  GrowthStageAnalysisModel _createGrowthStageFromField(Field field) {
    final growthStage = field.growthStage;
    final plantingDate = field.plantingDate;
    final now = DateTime.now();
    
    // Calculate days since planting
    final daysSincePlanting = now.difference(plantingDate).inDays;
    
    // Calculate progress percentage based on actual days and growth stage
    final progressPercentage = _calculateProgressPercentage(daysSincePlanting, growthStage);
    
    // Calculate expected harvest (roughly 90-120 days from planting)
    final expectedHarvest = plantingDate.add(Duration(days: 100));
    
    return GrowthStageAnalysisModel(
      currentStage: growthStage,
      progressPercentage: progressPercentage,
      stageDescription: _getGrowthStageDescription(growthStage),
      stageInfo: _getGrowthStageInfoList(),
      expectedHarvest: expectedHarvest,
    );
  }

  int _calculateProgressPercentage(int daysSincePlanting, String currentStage) {
    // Corn growth stages with typical day ranges
    final stageRanges = {
      'VE': {'start': 0, 'end': 7, 'base': 0},
      'V2': {'start': 7, 'end': 14, 'base': 5},
      'V3': {'start': 14, 'end': 21, 'base': 15},
      'V4': {'start': 21, 'end': 28, 'base': 25},
      'V5': {'start': 28, 'end': 35, 'base': 35},
      'V6': {'start': 35, 'end': 42, 'base': 45},
      'V7': {'start': 42, 'end': 49, 'base': 55},
      'V8': {'start': 49, 'end': 56, 'base': 65},
      'VT': {'start': 56, 'end': 63, 'base': 75},
      'R1': {'start': 63, 'end': 70, 'base': 80},
      'R2': {'start': 70, 'end': 77, 'base': 85},
      'R3': {'start': 77, 'end': 84, 'base': 90},
      'R4': {'start': 84, 'end': 91, 'base': 92},
      'R5': {'start': 91, 'end': 98, 'base': 95},
      'R6': {'start': 98, 'end': 105, 'base': 100},
    };

    // Find the current stage range
    final stageRange = stageRanges[currentStage];
    if (stageRange == null) {
      // Fallback: calculate based on days since planting
      return (daysSincePlanting / 105 * 100).clamp(0, 100).round();
    }

    // Calculate progress within the current stage
    final stageStart = stageRange['start']!;
    final stageEnd = stageRange['end']!;
    final basePercentage = stageRange['base']!;
    
    if (daysSincePlanting < stageStart) {
      return basePercentage;
    } else if (daysSincePlanting >= stageEnd) {
      // Move to next stage or max out
      final nextStagePercentage = basePercentage + 10;
      return nextStagePercentage.clamp(0, 100);
    } else {
      // Calculate progress within current stage
      final stageProgress = (daysSincePlanting - stageStart) / (stageEnd - stageStart);
      final stageIncrement = 10 * stageProgress; // 10% increment per stage
      return (basePercentage + stageIncrement).clamp(0, 100).round();
    }
  }

  String _getGrowthStageDescription(String stage) {
    switch (stage) {
      case 'VE':
        return 'Seedling emergence - roots developing';
      case 'V2':
      case 'V3':
      case 'V4':
        return 'Early vegetative growth - rapid leaf development';
      case 'V5':
      case 'V6':
      case 'V7':
      case 'V8':
        return 'Mid vegetative growth - stem elongation';
      case 'VT':
        return 'Tasseling - reproductive phase begins';
      case 'R1':
      case 'R2':
      case 'R3':
        return 'Reproductive phase - grain development';
      case 'R4':
      case 'R5':
        return 'Maturing phase - grain filling';
      case 'R6':
        return 'Maturity - ready for harvest';
      default:
        return 'Growth stage unknown';
    }
  }

  List<GrowthStageInfo> _getGrowthStageInfoList() {
    return [
      GrowthStageInfo(stage: 'VE', name: 'Emergence', description: 'Seedling emergence', days: 5),
      GrowthStageInfo(stage: 'V2-V4', name: 'Early Vegetative', description: 'Rapid leaf development', days: 15),
      GrowthStageInfo(stage: 'V5-V8', name: 'Mid Vegetative', description: 'Stem elongation', days: 20),
      GrowthStageInfo(stage: 'VT', name: 'Tasseling', description: 'Reproductive phase begins', days: 10),
      GrowthStageInfo(stage: 'R1-R3', name: 'Reproductive', description: 'Grain development', days: 25),
      GrowthStageInfo(stage: 'R4-R6', name: 'Maturing', description: 'Grain filling to maturity', days: 15),
    ];
  }

  CropConditionModel _createCropConditionFromStress(String stressLevel) {
    switch (stressLevel.toLowerCase()) {
      case 'low':
        return CropConditionModel(
          status: 'Healthy',
          message: 'Crop is growing well with minimal stress',
          color: '#4CAF50', // Green
          icon: 'good',
        );
      case 'medium':
        return CropConditionModel(
          status: 'Moderate',
          message: 'Crop is growing with some stress factors',
          color: '#FFC107', // Amber
          icon: 'moderate',
        );
      case 'high':
        return CropConditionModel(
          status: 'Warning',
          message: 'Crop needs attention due to high stress',
          color: '#FF9800', // Orange
          icon: 'warning',
        );
      case 'severe':
        return CropConditionModel(
          status: 'Critical',
          message: 'Crop requires immediate attention',
          color: '#F44336', // Red
          icon: 'critical',
        );
      default:
        return CropConditionModel(
          status: 'Unknown',
          message: 'Unable to determine crop condition',
          color: '#9E9E9E', // Grey
          icon: 'unknown',
        );
    }
  }

  CropConditionModel _createCropConditionFromStressAnalysis(Map<String, dynamic> stressAnalysis) {
    // Count high stress factors
    int highStressCount = 0;
    int mediumStressCount = 0;
    
    for (final entry in stressAnalysis.entries) {
      final data = entry.value as Map<String, dynamic>?;
      if (data != null) {
        final stressLevel = data['stress_level'] as String? ?? 'low';
        switch (stressLevel.toLowerCase()) {
          case 'high':
            highStressCount++;
            break;
          case 'medium':
            mediumStressCount++;
            break;
        }
      }
    }
    
    // Determine condition based on stress levels
    if (highStressCount >= 3) {
      return CropConditionModel(
        status: 'Critical',
        message: 'Crop requires immediate attention - multiple high stress factors detected',
        color: '#F44336', // Red
        icon: 'critical',
      );
    } else if (highStressCount >= 2) {
      return CropConditionModel(
        status: 'High Stress',
        message: 'Crop needs attention - several high stress factors detected',
        color: '#FF9800', // Orange
        icon: 'warning',
      );
    } else if (highStressCount >= 1 || mediumStressCount >= 2) {
      return CropConditionModel(
        status: 'Moderate Stress',
        message: 'Crop is growing with some stress factors',
        color: '#FFC107', // Amber
        icon: 'moderate',
      );
    } else {
      return CropConditionModel(
        status: 'Healthy',
        message: 'Crop is growing well with minimal stress',
        color: '#4CAF50', // Green
        icon: 'good',
      );
    }
  }

  MetricsModel _createMetricsFromStressAnalysis(Map<String, dynamic> stressAnalysis, {DateTime? timestamp}) {
    // Extract actual values from stress analysis
    final temperatureData = stressAnalysis['Temperature'] as Map<String, dynamic>?;
    final humidityData = stressAnalysis['Humidity'] as Map<String, dynamic>?;
    final soilMoistureData = stressAnalysis['Soil Moisture'] as Map<String, dynamic>?;
    final soilPhData = stressAnalysis['Soil pH'] as Map<String, dynamic>?;
    final lightIntensityData = stressAnalysis['Light Intensity'] as Map<String, dynamic>?;

    return MetricsModel(
      temperature: (temperatureData?['actual_value'] as num?)?.toDouble() ?? 0.0,
      humidity: (humidityData?['actual_value'] as num?)?.toDouble() ?? 0.0,
      soilMoisture: (soilMoistureData?['actual_value'] as num?)?.toDouble() ?? 0.0,
      soilPh: (soilPhData?['actual_value'] as num?)?.toDouble() ?? 0.0,
      lightIntensity: (lightIntensityData?['actual_value'] as num?)?.toDouble() ?? 0.0,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  CropConditionModel _createCropConditionFromMetrics(MetricsModel metrics) {
    // Analyze metrics to determine crop condition
    String status = 'Normal';
    String message = 'Crop is growing normally';
    String color = '#4CAF50'; // Green
    String icon = 'good';

    // Check temperature
    if (metrics.temperature < 15 || metrics.temperature > 35) {
      status = 'Warning';
      message = 'Temperature is outside optimal range (${metrics.temperature.toStringAsFixed(1)}°C)';
      color = '#FF9800'; // Orange
      icon = 'warning';
    }

    // Check soil moisture
    if (metrics.soilMoisture < 30) {
      status = 'Critical';
      message = 'Soil moisture is critically low (${metrics.soilMoisture.toStringAsFixed(1)}%)';
      color = '#F44336'; // Red
      icon = 'critical';
    } else if (metrics.soilMoisture > 80) {
      status = 'Warning';
      message = 'Soil moisture is high (${metrics.soilMoisture.toStringAsFixed(1)}%)';
      color = '#FF9800'; // Orange
      icon = 'warning';
    }

    // Check soil pH
    if (metrics.soilPh < 6.0 || metrics.soilPh > 7.5) {
      status = 'Warning';
      message = 'Soil pH is outside optimal range (${metrics.soilPh.toStringAsFixed(1)})';
      color = '#FF9800'; // Orange
      icon = 'warning';
    }

    // Check humidity
    if (metrics.humidity < 30 || metrics.humidity > 90) {
      status = 'Warning';
      message = 'Humidity is outside optimal range (${metrics.humidity.toStringAsFixed(1)}%)';
      color = '#FF9800'; // Orange
      icon = 'warning';
    }

    return CropConditionModel(
      status: status,
      message: message,
      color: color,
      icon: icon,
    );
  }

  WeeklyDataModel _createWeeklyDataFromReadings(List<SensorReading> readings) {
    print('🔍 Creating weekly data from ${readings.length} readings');
    
    // Group readings by date
    final Map<String, List<SensorReading>> readingsByDate = {};
    
    for (final reading in readings) {
      final dateKey = '${reading.timestamp.year}-${reading.timestamp.month.toString().padLeft(2, '0')}-${reading.timestamp.day.toString().padLeft(2, '0')}';
      readingsByDate[dateKey] ??= [];
      readingsByDate[dateKey]!.add(reading);
    }
    
    print('🔍 Grouped readings by date: ${readingsByDate.keys.toList()}');

    // Create daily data from grouped readings
    final dailyData = <DailyDataModel>[];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      if (readingsByDate.containsKey(dateKey)) {
        final dayReadings = readingsByDate[dateKey]!;
        print('🔍 Found ${dayReadings.length} readings for $dateKey');
        
        // Calculate averages for the day
        final avgTemperature = dayReadings.map((r) => r.temperature).reduce((a, b) => a + b) / dayReadings.length;
        final avgHumidity = dayReadings.map((r) => r.humidity).reduce((a, b) => a + b) / dayReadings.length;
        final avgSoilMoisture = dayReadings.map((r) => r.soilMoisture).reduce((a, b) => a + b) / dayReadings.length;
        final avgSoilPh = dayReadings.map((r) => r.pH).reduce((a, b) => a + b) / dayReadings.length;
        final avgLightIntensity = dayReadings.map((r) => r.lightIntensity).reduce((a, b) => a + b) / dayReadings.length;
        
        dailyData.add(DailyDataModel(
          date: date,
          temperature: avgTemperature,
          humidity: avgHumidity,
          soilMoisture: avgSoilMoisture,
          soilPh: avgSoilPh,
          lightIntensity: avgLightIntensity,
        ));
      } else {
        print('🔍 No readings found for $dateKey, using zeros');
        // No data for this day, use zeros
        dailyData.add(DailyDataModel(
          date: date,
          temperature: 0.0,
          humidity: 0.0,
          soilMoisture: 0.0,
          soilPh: 0.0,
          lightIntensity: 0.0,
        ));
      }
    }
    
    print('🔍 Created ${dailyData.length} daily data points');

    return WeeklyDataModel(
      dailyData: dailyData,
      summary: {
        'totalReadings': readings.length,
        'daysWithData': readingsByDate.length,
        'lastUpdate': now.toIso8601String(),
      },
    );
  }

  WeeklyDataModel _createFallbackWeeklyData(MetricsModel currentMetrics) {
    // Create a fallback weekly data using current metrics for all days
    final dailyData = <DailyDataModel>[];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      
      dailyData.add(DailyDataModel(
        date: date,
        temperature: currentMetrics.temperature,
        humidity: currentMetrics.humidity,
        soilMoisture: currentMetrics.soilMoisture,
        soilPh: currentMetrics.soilPh,
        lightIntensity: currentMetrics.lightIntensity,
      ));
    }
    
    print('🔍 Created fallback weekly data with ${dailyData.length} days');
    
    return WeeklyDataModel(
      dailyData: dailyData,
      summary: {
        'totalReadings': 1,
        'daysWithData': 7,
        'lastUpdate': now.toIso8601String(),
        'note': 'Data based on current sensor readings',
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MonitoringBloc, MonitoringState>(
        listener: (context, state) async {
          if (state.farmAnalytics != null) {
            final analyticsData = state.farmAnalytics!;
            print('🔍 FarmDetailWidget received analytics: $analyticsData');
            
            setState(() {
              _isLoadingAnalytics = false;
              _analyticsError = null;
            });

            // Parse analytics data from MonitoringBloc
            _parseAnalyticsData(analyticsData);
          } else if (state.isLoading) {
            setState(() {
              _isLoadingAnalytics = true;
              _analyticsError = null;
            });
          } else if (state.error != null) {
            setState(() {
              _isLoadingAnalytics = false;
              _analyticsError = state.error;
            });
          }
        },
        child: Scaffold(
          backgroundColor: MAIZE_PRIMARY_LIGHT,
          body: Stack(
            children: [
              // Main scrollable content
              Positioned.fill(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Hero section with growth progress
                      _buildHeroSection(),

                      // Overlaid field details card
                      Transform.translate(
                        offset: Offset(
                          0,
                          -90.h,
                        ), // Adjust this value to control the overlap
                        child: Column(
                          children: [
                            _buildFieldDetailsCard(),

                            verticalSpace(kAppMediumGap),
                            // Tab navigation
                            _buildTabNavigation(),

                            verticalSpace(kAppMediumGap),

                            // Tab content
                            _buildTabContent(),

                            SizedBox(height: 40.h), // Bottom padding
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Header with back button
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: kAppSmallPadding,
                      vertical: 8.h,
                    ),
                    child: Row(
                      children: [
                        _buildCircleIconButton(
                          icon: Icons.arrow_back,
                          onTap: widget.onBack,
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      height: 370.h, // Adjusted height for the growth progress widget
      padding: EdgeInsets.only(bottom: 24.h),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
      ),
      child: Stack(
        children: [
          // Growth progress widget
          Center(
            child: GrowthProgressWidget(
              currentGrowthStage:
                  widget.selectedField?.growthStage ??
                  (widget.farm.fields.isNotEmpty
                      ? widget.farm.fields.first.growthStage
                      : 'VE'),
              plantingDate:
                  widget.selectedField?.plantingDate ??
                  (widget.farm.fields.isNotEmpty
                      ? widget.farm.fields.first.plantingDate
                      : DateTime.now()),
              historicalData: widget.sensorReadings,
              onStageChange: () {
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: MAIZE_ACCENT, size: 20.sp),
      ),
    );
  }

  Widget _buildFieldDetailsCard() {
    final selectedField =
        widget.selectedField ??
        (widget.farm.fields.isNotEmpty ? widget.farm.fields.first : null);

    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, farmState) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(kAppMediumPadding),
          decoration: BoxDecoration(
            color: MAIZE_PRIMARY_LIGHT,
            borderRadius: BorderRadius.circular(16.r), //
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectedField?.fieldName ?? widget.farm.farmName,
                style: TextTheme.of(context).headlineMedium?.copyWith(
                  fontWeight: FontWeight.w300,
                  fontSize: 30.sp,
                ),
              ),

              verticalSpace(5),

              BlocBuilder<AuthenticationBloc, AuthenticationState>(
                builder: (context, state) {
                  return Text(
                    '${state.user?.address['municipality']}, ${state.user?.address['province']}', // Or add a location property to your farm model
                    style: TextTheme.of(
                      context,
                    ).bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.7)),
                  );
                },
              ),

              verticalSpace(12),

              Column(
                children: [
                  Wrap(
                    spacing: 12.w, // horizontal spacing between items
                    runSpacing: 8.h, // vertical spacing when wrapping
                    children: [
                      if (selectedField != null) ...[
                        // Soil type
                        if (selectedField.sensors.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: kAppSmallGap,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: MAIZE_ACCENT.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: MAIZE_ACCENT,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.grass,
                                  color: MAIZE_ACCENT.withOpacity(0.8),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    selectedField.sensors.first.soilType,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: MAIZE_ACCENT.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: kAppSmallGap,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: MAIZE_ACCENT.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: MAIZE_ACCENT, width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.date_range,
                                color: MAIZE_ACCENT.withOpacity(0.8),
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  '${selectedField.plantingDate.day}/${selectedField.plantingDate.month}/${selectedField.plantingDate.year}',
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.copyWith(
                                    color: MAIZE_ACCENT.withOpacity(0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sensor count (if any)
                        if (selectedField.sensors.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: kAppSmallGap,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: MAIZE_ACCENT.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: MAIZE_ACCENT,
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sensors,
                                  color: MAIZE_ACCENT.withOpacity(0.8),
                                  size: 18.sp,
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    'Devices: ${selectedField.sensors.length}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: MAIZE_ACCENT.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ] else if (widget.farm.fields.isNotEmpty) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.sensors,
                              color: MAIZE_PRIMARY,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Text(
                                'Total Sensors: ${widget.farm.fields.fold<int>(0, (sum, field) => sum + field.sensors.length)}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  SizedBox(height: 16.h), // Space between sections
                  // Crop Condition Section
                  if (_isLoadingAnalytics)
                    _buildLoadingIndicator()
                  else if (_analyticsError != null)
                    _buildErrorIndicator()
                  else if (_cropCondition != null)
                    _buildCropConditionCard()
                  else
                    _buildNoDataIndicator(),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20.w,
            height: 20.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
            ),
          ),
          horizontalSpace(12),
          Text(
            'Loading crop condition...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[600], size: 20.sp),
          horizontalSpace(12),
          Expanded(
            child: Text(
              _analyticsError ?? 'Failed to load crop condition',
              style: TextStyle(fontSize: 14.sp, color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataIndicator() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20.sp),
          horizontalSpace(12),
          Text(
            'No analytics data available',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCropConditionCard() {
    if (_cropCondition == null) return SizedBox.shrink();

    final condition = _cropCondition!;
    final color = Color(int.parse(condition.color.replaceFirst('#', '0xFF')));

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
       border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(
                  _getConditionIcon(condition.icon),
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Corn Condition',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      condition.status,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(12),
          Text(
            condition.message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getConditionIcon(String icon) {
    switch (icon) {
      case 'excellent':
        return Icons.eco;
      case 'good':
        return Icons.thumb_up;
      case 'normal':
        return Icons.check_circle;
      case 'warning':
        return Icons.warning;
      case 'critical':
        return Icons.error;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildTabNavigation() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40.r),
      ),
      child: Row(
        children: [
          _buildTabButton('Overview', 0),
          _buildTabButton('Historical', 1),
          _buildTabButton('Growth Stage', 2),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
            _tabController.animateTo(index);
          });
        },
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.w, horizontal: kAppSmallPadding),        
          decoration: BoxDecoration(
                color: isSelected ? MAIZE_PRIMARY : Colors.transparent,
                borderRadius: BorderRadius.circular(40.r),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : MAIZE_ACCENT.withOpacity(0.6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildOverviewTab();
      case 1:
        return _buildHistoricalTab();
      case 2:
        return _buildGrowthStageTab();
      default:
        return _buildOverviewTab();
    }
  }

  Widget _buildOverviewTab() {
    if (_isLoadingAnalytics) {
      return _buildLoadingState();
    }

    if (_analyticsError != null) {
      return _buildErrorState();
    }

    if (_currentMetrics == null) {
      return _buildNoDataState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          verticalSpace(kAppMediumGap),
          // 5 Key Metrics Grid
          _buildKeyMetricsGrid(),

          verticalSpace(16),
          
          // Last Updated Indicator
          _buildLastUpdatedIndicator(),

          verticalSpace(24),
        ],
      ),
    );
  }

  Widget _buildKeyMetricsGrid() {
    final metrics = _currentMetrics!;

    return Column(
      children: [
        // First row - Soil pH and Soil Moisture
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Soil pH',
                '${metrics.soilPh.toStringAsFixed(1)}',
                'pH',
                Icons.science,
                _getSoilPhColor(metrics.soilPh),
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: _buildMetricCard(
                'Soil Moisture',
                '${metrics.soilMoisture.toStringAsFixed(0)}%',
                '',
                Icons.water_drop,
                _getSoilMoistureColor(metrics.soilMoisture),
              ),
            ),
          ],
        ),
        verticalSpace(12),
        // Second row - Temperature and Humidity
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                'Temperature',
                '${metrics.temperature.toStringAsFixed(0)}°C',
                '',
                Icons.thermostat,
                _getTemperatureColor(metrics.temperature),
              ),
            ),
            horizontalSpace(12),
            Expanded(
              child: _buildMetricCard(
                'Humidity',
                '${metrics.humidity.toStringAsFixed(0)}%',
                '',
                Icons.eco,
                _getHumidityColor(metrics.humidity),
              ),
            ),
          ],
        ),
        verticalSpace(12),
        // Third row - Light Intensity (full width)
        _buildMetricCard(
          'Light Intensity',
          '${metrics.lightIntensity.toStringAsFixed(0)} lux',
          '',
          Icons.light_mode,
          _getLightIntensityColor(metrics.lightIntensity),
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color, {
    bool isFullWidth = false,
  }) {
    // Get stress level from analytics data
    final stressLevel = _getStressLevelForMetric(title);
    final statusColor = _getStatusColor(stressLevel);
    final statusText = _getFarmerFriendlyStatus(stressLevel);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator at the top
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          verticalSpace(12),
          
          // Icon with color indicator
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: statusColor, size: 20.sp),
          ),
          verticalSpace(8),
          
          // Title
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          verticalSpace(4),
          
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: MAIZE_ACCENT,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
          ),
          verticalSpace(16),
          Text(
            'Loading metrics...',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: Colors.red, size: 48.sp),
          verticalSpace(16),
          Text(
            'Failed to load metrics',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.red,
            ),
          ),
          verticalSpace(8),
          Text(
            _analyticsError ?? 'Unknown error',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return Container(
      padding: EdgeInsets.all(40.w),
      child: Column(
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 48.sp),
          verticalSpace(16),
          Text(
            'No metrics available',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          verticalSpace(8),
          Text(
            'Analytics data will appear here once available',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoricalTab() {
    final farmId = widget.farm.id!; // Use fallback farm ID
    print('🔍 FarmDetailWidget: Using farm ID: $farmId');
    return HistoricalTabWidget(
      farmId: farmId,
      fieldId: widget.selectedField?.fieldName,
      onBack: () {
        // Handle back navigation if needed
      },
      currentMetrics: _currentMetrics, // Pass current metrics
      analyticsData: _stressAnalysis, // Pass stress analysis data
    );
  }


  Widget _buildWeeklySummary() {
    if (_weeklyData?.summary.isEmpty != false) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Summary',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(12),
          Text(
            'Data collected over the past 7 days',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStageTab() {
    if (_isLoadingAnalytics) {
      return _buildLoadingState();
    }

    if (_analyticsError != null) {
      return _buildErrorState();
    }

    if (_growthStageAnalysis == null) {
      return _buildNoDataState();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // Current growth stage info
          _buildCurrentGrowthStage(),
          verticalSpace(20),
          // Growth stage progress table
          _buildGrowthStageTable(),
          verticalSpace(20),
          // Expected harvest info
          _buildHarvestInfo(),
        ],
      ),
    );
  }

  Widget _buildCurrentGrowthStage() {
    final analysis = _growthStageAnalysis!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: MAIZE_PRIMARY.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.eco, color: MAIZE_PRIMARY, size: 30.sp),
              ),
              horizontalSpace(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Stage',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      analysis.currentStage,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: MAIZE_ACCENT,
                      ),
                    ),
                    Text(
                      '${analysis.progressPercentage}% Complete',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: MAIZE_PRIMARY,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          verticalSpace(16),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: analysis.progressPercentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_PRIMARY),
              minHeight: 8.h,
            ),
          ),
          verticalSpace(16),
          Text(
            analysis.stageDescription,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthStageTable() {
    final analysis = _growthStageAnalysis!;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Stage Progress',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          verticalSpace(16),
          ...analysis.stageInfo.map(
            (stage) => _buildStageRow(stage, analysis.currentStage),
          ),
        ],
      ),
    );
  }

  Widget _buildStageRow(GrowthStageInfo stage, String currentStage) {
    final isCurrentStage =
        stage.stage == currentStage ||
        (stage.stage.contains('-') &&
            stage.stage.split('-').any((s) => s == currentStage));
    final isCompleted = _isStageCompleted(stage.stage, currentStage);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color:
            isCurrentStage
                ? MAIZE_PRIMARY.withOpacity(0.1)
                : isCompleted
                ? Colors.green.withOpacity(0.1)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color:
              isCurrentStage
                  ? MAIZE_PRIMARY
                  : isCompleted
                  ? Colors.green
                  : Colors.grey[300]!,
          width: isCurrentStage || isCompleted ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.h,
            decoration: BoxDecoration(
              color:
                  isCurrentStage
                      ? MAIZE_PRIMARY
                      : isCompleted
                      ? Colors.green
                      : Colors.grey[400],
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCurrentStage
                  ? Icons.play_arrow
                  : isCompleted
                  ? Icons.check
                  : Icons.radio_button_unchecked,
              color: Colors.white,
              size: 16.sp,
            ),
          ),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stage.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color:
                        isCurrentStage || isCompleted
                            ? MAIZE_ACCENT
                            : Colors.grey[600],
                  ),
                ),
                Text(
                  stage.description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (stage.days > 0)
            Text(
              '${stage.days} days',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  bool _isStageCompleted(String stageRange, String currentStage) {
    if (stageRange.contains('-')) {
      final parts = stageRange.split('-');
      if (parts.length == 2) {
        // This is a simplified comparison - in reality you'd need proper stage ordering
        return false; // For now, only show current stage as active
      }
    }
    return false;
  }

  Widget _buildHarvestInfo() {
    final analysis = _growthStageAnalysis!;
    final daysToHarvest =
        analysis.expectedHarvest.difference(DateTime.now()).inDays;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.schedule, color: MAIZE_PRIMARY, size: 24.sp),
              horizontalSpace(12),
              Text(
                'Expected Harvest',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          verticalSpace(12),
          Text(
            '${analysis.expectedHarvest.day}/${analysis.expectedHarvest.month}/${analysis.expectedHarvest.year}',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: MAIZE_PRIMARY,
            ),
          ),
          verticalSpace(8),
          Text(
            daysToHarvest > 0
                ? '$daysToHarvest days remaining'
                : 'Harvest time!',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  // Color helper methods for metrics
  Color _getSoilPhColor(double ph) {
    if (ph < 6.0) return Colors.red;
    if (ph < 6.5) return Colors.orange;
    if (ph <= 7.5) return Colors.green;
    if (ph <= 8.0) return Colors.orange;
    return Colors.red;
  }

  Color _getSoilMoistureColor(double moisture) {
    if (moisture < 30) return Colors.red;
    if (moisture < 50) return Colors.orange;
    if (moisture <= 70) return Colors.green;
    if (moisture <= 85) return Colors.orange;
    return Colors.red;
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 15) return Colors.blue;
    if (temp < 20) return Colors.cyan;
    if (temp <= 30) return Colors.green;
    if (temp <= 35) return Colors.orange;
    return Colors.red;
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < 30) return Colors.red;
    if (humidity < 50) return Colors.orange;
    if (humidity <= 80) return Colors.green;
    if (humidity <= 90) return Colors.orange;
    return Colors.red;
  }

  Color _getLightIntensityColor(double intensity) {
    if (intensity < 200) return Colors.red;
    if (intensity < 400) return Colors.orange;
    if (intensity <= 800) return Colors.green;
    if (intensity <= 1200) return Colors.orange;
    return Colors.red;
  }

  Widget _buildLastUpdatedIndicator() {
    final timestamp = _currentMetrics?.timestamp ?? DateTime.now();
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    String timeAgo;
    if (difference.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (difference.inMinutes < 60) {
      timeAgo = '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      timeAgo = '${difference.inHours}h ago';
    } else {
      timeAgo = '${difference.inDays}d ago';
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.access_time,
            size: 16.sp,
            color: Colors.grey[600],
          ),
          SizedBox(width: 8.w),
          Text(
            'Last updated: $timeAgo',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Get stress level for a specific metric from analytics data
  String _getStressLevelForMetric(String metricTitle) {
    // First try to get from stress analysis if available
    if (_stressAnalysis != null) {
      String metricKey = '';
      switch (metricTitle) {
        case 'Soil pH':
          metricKey = 'Soil pH';
          break;
        case 'Soil Moisture':
          metricKey = 'Soil Moisture';
          break;
        case 'Temperature':
          metricKey = 'Temperature';
          break;
        case 'Humidity':
          metricKey = 'Humidity';
          break;
        case 'Light Intensity':
          metricKey = 'Light Intensity';
          break;
        default:
          break;
      }
      
      final metricData = _stressAnalysis![metricKey] as Map<String, dynamic>?;
      if (metricData != null) {
        final stressLevel = metricData['stress_level'] as String? ?? 'unknown';
        print('🔍 $metricTitle stress level from analytics: $stressLevel');
        return stressLevel;
      }
    }
    
    // Fallback: Calculate stress level based on metric value and optimal ranges
    if (_currentMetrics != null) {
      return _calculateStressLevelFromValue(metricTitle, _currentMetrics!);
    }
    
    return 'unknown';
  }

  // Calculate stress level based on metric value and optimal ranges
  String _calculateStressLevelFromValue(String metricTitle, MetricsModel metrics) {
    switch (metricTitle) {
      case 'Soil pH':
        final ph = metrics.soilPh;
        if (ph < 6.0 || ph > 8.0) return 'critical';
        if (ph < 6.5 || ph > 7.5) return 'high';
        return 'low';
      
      case 'Soil Moisture':
        final moisture = metrics.soilMoisture;
        if (moisture < 30 || moisture > 85) return 'critical';
        if (moisture < 40 || moisture > 70) return 'high';
        return 'low';
      
      case 'Temperature':
        final temp = metrics.temperature;
        if (temp < 15 || temp > 35) return 'critical';
        if (temp < 20 || temp > 30) return 'high';
        return 'low';
      
      case 'Humidity':
        final humidity = metrics.humidity;
        if (humidity < 30 || humidity > 90) return 'critical';
        if (humidity < 50 || humidity > 80) return 'high';
        return 'low';
      
      case 'Light Intensity':
        final light = metrics.lightIntensity;
        if (light < 200 || light > 1200) return 'critical';
        if (light < 400 || light > 800) return 'high';
        return 'low';
      
      default:
        return 'unknown';
    }
  }

  // Get color based on stress level
  Color _getStatusColor(String stressLevel) {
    switch (stressLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'critical':
        return Colors.red[800]!;
      case 'unknown':
        return Colors.grey[600]!;
      default:
        return Colors.grey;
    }
  }

  // Get farmer-friendly status text
  String _getFarmerFriendlyStatus(String stressLevel) {
    switch (stressLevel.toLowerCase()) {
      case 'low':
        return 'GOOD';
      case 'medium':
        return 'WARNING';
      case 'high':
        return 'ATTENTION';
      case 'critical':
        return 'URGENT';
      case 'unknown':
        return 'CHECKING...';
      default:
        return 'UNKNOWN';
    }
  }

}
