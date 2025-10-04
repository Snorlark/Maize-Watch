import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/features/farm/presentation/widgets/field_registration_progress_indicator.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/widgets/custom_snackbar.dart';
import '../../../../core/services/prototype_service.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/farm.dart';
import '../bloc/farm_bloc.dart';
import '../widgets/field_registration_app_bar.dart';
import '../widgets/field_registration_form_pages.dart';
import '../widgets/farm_data_summary_modal.dart';
import '../../../authentication/presentation/bloc/authentication_bloc.dart';
import 'farm_registration_success_screen.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/services/completion_status_manager.dart';
import '../../../../core/services/home_screen_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../live_monitoring/presentation/bloc/monitoring_bloc.dart';

class FarmRegistrationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  final bool fromRegistration;

  const FarmRegistrationScreen({
    super.key,
    required this.userData,
    this.fromRegistration = true,
  });

  @override
  State<FarmRegistrationScreen> createState() => _FarmRegistrationScreenState();
}

class _FarmRegistrationScreenState extends State<FarmRegistrationScreen> {
  final PageController _pageController = PageController();
  final _formControllers = FarmRegistrationControllers();
  int currentPage = 0;

  int _currentStep = 1;
  static const int _totalSteps =
      3; // Field name, planting date, device registration

  @override
  void initState() {
    super.initState();
    _deriveLocationFromUserData();
  }

  void _deriveLocationFromUserData() {
    print("🌍 User data received: ${widget.userData}");
    final address = widget.userData['address'];
    String derivedLocation = S.current.location_not_specified;

    print("🌍 Address data: $address (type: ${address.runtimeType})");

    if (address is String && address.trim().isNotEmpty) {
      derivedLocation = address;
      print("🌍 Using string address: $derivedLocation");
    } else if (address is Map) {
      final barangay = address['barangay'];
      final municipality = address['municipality'];
      final province = address['province'];
      final region = address['region'];

      print(
        "🌍 Address components - Barangay: $barangay, Municipality: $municipality, Province: $province, Region: $region",
      );

      final parts = <String>[];
      if (barangay is String && barangay.trim().isNotEmpty) {
        parts.add(barangay);
      }
      if (municipality is String && municipality.trim().isNotEmpty) {
        parts.add(municipality);
      }
      if (province is String && province.trim().isNotEmpty) {
        parts.add(province);
      }
      if (region is String && region.trim().isNotEmpty) {
        parts.add(region);
      }

      if (parts.isNotEmpty) {
        derivedLocation = parts.join(', ');
      }
      print("🌍 Constructed location from parts: $derivedLocation");
    }

    print("🌍 Final farm location: $derivedLocation");
    _formControllers.location = derivedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmBloc, FarmState>(
      listener: (context, state) async {
        if (state is FarmCreated) {
          // Register prototype IDs after successful farm creation
          _registerPrototypeIds();
          
          // Clear all cached data for the new user to ensure fresh data loads
          await _clearUserCacheAndRefreshData();
          
          // Navigate to congratulatory screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder:
                  (context) => FarmRegistrationSuccessScreen(
                    farmName: _formControllers.farmName,
                    fieldName: _formControllers.fieldName,
                    onContinue: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
            ),
          );
        } else if (state is FarmError) {
          // Check if it's an authentication error
          if (state.message.contains('Authentication expired') ||
              state.message.contains('Please log in again')) {
            // Show error and navigate to login
            CustomSnackbar.showError(context, state.message);
            // Navigate to login screen and clear the stack
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/landing', (route) => false);
          } else {
            CustomSnackbar.showError(context, state.message);
          }
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          if (_currentStep > 1) {
            _goToPreviousPage();
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: CornRegistrationAppBar(
            onBackPressed: _currentStep > 1 ? _goToPreviousPage : null,
            showBackButton: !widget.fromRegistration,
          ),
          body: Container(
            decoration: const BoxDecoration(color: MAIZE_BOTTOM_OVERLAY),
            padding: EdgeInsets.symmetric(horizontal: kAppMediumPadding),
            child: Column(
              children: [
                FieldRegistrationProgressIndicator(
                  currentStep: _currentStep,
                  totalSteps: _totalSteps,
                ),
                SizedBox(height: 25.h),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index + 1;
                      });
                    },
                    children: [
                      FieldNameFormPage(controllers: _formControllers),
                      PlantingDateFormPage(controllers: _formControllers),
                      DeviceRegistrationFormPage(controllers: _formControllers),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<FarmBloc, FarmState>(
      builder: (context, state) {
        final isLoading = state is FarmLoading;
        final isCompletionStep =
            _currentStep >
            _totalSteps; // Only show done button after submission

        if (isCompletionStep) {
          return Container(
            padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed:
                    () => Navigator.pushReplacementNamed(context, '/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MAIZE_PRIMARY,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  S.of(context).done,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
          child: Row(
            children: [
              if (_currentStep > 1) ...[
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 56.h,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _goToPreviousPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: MAIZE_PRIMARY,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        S.of(context).back,
                        style: TextStyle(
                          color: MAIZE_PRIMARY,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _handleNextOrSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MAIZE_PRIMARY,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      elevation: 0,
                    ),
                    child:
                        isLoading
                            ? SizedBox(
                              height: 24.h,
                              width: 24.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                            : Text(
                              _currentStep == _totalSteps ? S.current.submit : S.current.next,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _goToPreviousPage() {
    if (_currentStep > 1) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextOrSubmit() {
    if (!_validateCurrentStep()) return;

    if (_currentStep == _totalSteps) {
      // Show summary modal on device registration page (step 4)
      _showFarmSummaryModal();
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 1:
        if (_formControllers.fieldName.trim().isEmpty) {
          CustomSnackbar.showError(context, S.current.please_enter_field_name);
          return false;
        }
        break;
      case 2:
        if (_formControllers.plantingDate == null) {
          CustomSnackbar.showError(context, S.current.please_select_planting_date);
          return false;
        }
        break;
      case 3:
        // Require at least one device
        if (!_formControllers.hasDevices) {
          CustomSnackbar.showError(
            context,
            S.current.please_register_device,
          );
          return false;
        }
        if (!_formControllers.areAllDevicesValid) {
          CustomSnackbar.showError(
            context,
            S.current.please_complete_device_info,
          );
          return false;
        }
        break;
    }
    return true;
  }

  void _showFarmSummaryModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => FarmDataSummaryModal(
            controllers: _formControllers,
            onConfirm: () {
              Navigator.of(context).pop(); // Close modal
              _submitFarmData(); // Submit the data
            },
            onEdit: () {
              Navigator.of(context).pop(); // Close modal
              // User can edit by navigating back through the steps
            },
          ),
    );
  }

  Future<void> _clearUserCacheAndRefreshData() async {
    try {
      print('🧹 Clearing user cache and refreshing data after farm registration...');
      
      // Get current user ID
      final authState = context.read<AuthenticationBloc>().state;
      if (authState.user != null) {
        final userId = authState.user!.id;
        
        // Clear all user-specific cache
        await CacheService.clearCache(userId: userId);
        await CompletionStatusManager.clearAll();
        await HomeScreenService.clearUserCache();
        
        // Clear user notifications to prevent cross-user notification leakage
        final notificationService = NotificationService();
        await notificationService.clearAllUserNotifications();
        
        print('🧹 Cache cleared for user: $userId');
        
        // Force refresh farms data for the new user
        context.read<FarmBloc>().add(GetUserFarmsEvent(userId: userId));
        
        // Force refresh monitoring data
        context.read<MonitoringBloc>().add(LoadLatestReadingsEvent());
        
        // Load field-specific analytics for the newly registered field
        _loadFieldSpecificAnalyticsForNewField();
        
        print('🧹 Data refresh triggered for new user');
      }
    } catch (e) {
      print('❌ Error clearing cache and refreshing data: $e');
    }
  }

  /// Load field-specific analytics for the newly registered field
  void _loadFieldSpecificAnalyticsForNewField() async {
    try {
      print('🌽 FieldRegistration: Loading field-specific analytics for newly registered field');
      
      // Get the farm ID from the form data
      final farmId = _formControllers.farmName; // This should be the farm ID
      
      if (farmId.isNotEmpty) {
        // Load field-specific analytics for the new field
        context.read<MonitoringBloc>().add(
          LoadWeeklyDataEvent(
            farmId: farmId,
            fieldId: _formControllers.fieldName,
            weekOffset: 0
          )
        );
        
        print('🌽 FieldRegistration: Triggered field-specific analytics load for field: ${_formControllers.fieldName}');
      }
    } catch (e) {
      print('❌ Error loading field-specific analytics for new field: $e');
    }
  }

  void _submitFarmData() async {
    if (!_validateCurrentStep()) return;

    // Get authentication state without forcing refresh first
    final authBloc = context.read<AuthenticationBloc>();
    final currentAuthState = authBloc.state;

    print(
      '🔐 Current auth state before submission: ${currentAuthState.status}',
    );
    print('🔐 User data: ${currentAuthState.user?.username}');

    // Only check if we have basic authentication
    if (currentAuthState.status != AuthenticationStatus.authenticated ||
        currentAuthState.user == null) {
      print('🔐 No authentication found, redirecting to login');
      CustomSnackbar.showError(context, S.current.please_log_in_continue);
      Navigator.pushNamedAndRemoveUntil(context, '/landing', (route) => false);
      return;
    }

    final authState = authBloc.state;

    final userId = authState.user!.id;
    final now = DateTime.now();

    // Prepare farm data with fields array according to new structure
    final sensors =
        _formControllers.devices
            .map(
              (device) => {
                'deviceID': device.deviceId,
                'sensorName':
                    device.deviceName.isNotEmpty ? device.deviceName : 'Sensor',
                'description':
                    device.description.isNotEmpty
                        ? device.description
                        : 'Field monitoring sensor',
                'soilType':
                    device.soilType.isNotEmpty ? device.soilType : 'loamy',
                'readings': {
                  'soilMoisture': 0,
                  'temperature': 0,
                  'humidity': 0,
                  'lightIntensity': 0,
                  'soilPh': 0,
                },
                'prototypeId': device.prototypeId,
                'prototypeChannelId': device.prototypeChannelId,
                'prototypeApiKey': device.prototypeApiKey,
              },
            )
            .toList();

    final fields = [
      {
        'fieldName': _formControllers.fieldName,
        'plantingDate':
            (_formControllers.plantingDate ?? DateTime.now()).toIso8601String(),
        'growthStage': 'VE', // Initial growth stage
        'sensors': sensors,
      },
    ];

    final farmPayload = {
      'farmName':
          '${widget.userData['fullName']?.split(' ').first ?? 'User'}\'s Farm',
      'fields': fields,
    };

    print('🚀 Submitting farm data with new structure:');
    print('🚀 Farm: ${farmPayload['farmName']}');
    print('🚀 Fields: ${fields.length}');
    print('🚀 Field Name: ${_formControllers.fieldName}');
    print('🚀 Sensors: ${sensors.length}');
    print('🚀 Planting Date: ${_formControllers.plantingDate}');

    // Create farm with embedded fields structure
    final farmFields =
        fields
            .map(
              (fieldJson) => Field(
                fieldName: fieldJson['fieldName'] as String,
                soilType: 'loamy', // Default soil type for field
                plantingDate: DateTime.parse(
                  fieldJson['plantingDate'] as String,
                ),
                growthStage: fieldJson['growthStage'] as String,
                sensors:
                    (fieldJson['sensors'] as List)
                        .map(
                          (sensorJson) => Sensor(
                            deviceID: sensorJson['deviceID'] as String,
                            sensorName: sensorJson['sensorName'] as String,
                            description: sensorJson['description'] as String,
                            soilType: sensorJson['soilType'] as String,
                            readings: SensorReadings.fromJson(
                              sensorJson['readings'] as Map<String, dynamic>,
                            ),
                            prototypeId: sensorJson['prototypeId'] as String?,
                            prototypeChannelId: sensorJson['prototypeChannelId'] as String?,
                            prototypeApiKey: sensorJson['prototypeApiKey'] as String?,
                          ),
                        )
                        .toList(),
              ),
            )
            .toList();

    // Get user's address as location
    String userLocation = '';
    if (widget.userData['address'] != null) {
      final address = widget.userData['address'];
      if (address is String) {
        userLocation = address;
      } else if (address is Map) {
        // Construct location from address components
        final parts = <String>[];
        if (address['barangay']?.toString().isNotEmpty == true)
          parts.add(address['barangay']);
        if (address['municipality']?.toString().isNotEmpty == true)
          parts.add(address['municipality']);
        if (address['province']?.toString().isNotEmpty == true)
          parts.add(address['province']);
        if (address['region']?.toString().isNotEmpty == true)
          parts.add(address['region']);
        userLocation = parts.join(', ');
      }
    }

    // Fallback to a default location if empty
    if (userLocation.isEmpty) {
      userLocation = 'Philippines';
    }

    final farmData = Farm(
      userId: userId,
      farmName: farmPayload['farmName'] as String,
      location: userLocation,
      fields: farmFields,
      createdAt: now,
      updatedAt: now,
    );

    // Use the new farm structure
    context.read<FarmBloc>().add(CreateFarmEvent(farm: farmData));
  }

  Future<void> _registerPrototypeIds() async {
    try {
      print('🔧 Registering prototype IDs...');
      
      // Get the access token from secure storage
      final token = await SecureStorage.getToken();
      if (token == null) {
        print('❌ No access token found, skipping prototype registration');
        return;
      }
      
      for (final device in _formControllers.devices) {
        if (device.prototypeId.isNotEmpty && device.isPrototypeValid) {
          print('🔧 Registering prototype ID: ${device.prototypeId}');
          
          final result = await PrototypeService.registerPrototype(
            device.prototypeId, 
            token
          );
          
          if (result['success'] == true) {
            print('✅ Successfully registered prototype ID: ${device.prototypeId}');
          } else {
            print('❌ Failed to register prototype ID: ${device.prototypeId} - ${result['message']}');
          }
        }
      }
      
      print('🔧 Prototype ID registration completed');
    } catch (e) {
      print('❌ Error registering prototype IDs: $e');
      // Don't show error to user as farm creation was successful
      // Prototype registration is not critical for farm creation
    }
  }

  @override
  void dispose() {
    _formControllers.dispose();
    _pageController.dispose();
    super.dispose();
  }
}

class FarmRegistrationControllers {
  String fieldName = '';
  String location = '';
  DateTime? plantingDate;
  String soilType = '';
  List<DeviceInfo> devices = [];

  String get farmName => "${fieldName}'s Farm";

  void dispose() {
    // Add any controller disposal if needed
  }

  void addDevice() {
    devices.add(DeviceInfo());
  }

  void removeDevice(int index) {
    if (index >= 0 && index < devices.length) {
      devices.removeAt(index);
    }
  }

  bool get hasDevices => devices.isNotEmpty;

  bool get areAllDevicesValid {
    if (devices.isEmpty) return false;
    return devices.every((device) => device.isValid);
  }
}

class DeviceInfo {
  String deviceId = '';
  String deviceName = '';
  String deviceMacAddress = '';
  String deviceType = 'Multi_Sensor'; // Default sensor type
  String description = '';
  String soilType = 'loamy'; // Default soil type
  String prototypeId = ''; // Prototype ID for validation
  bool isPrototypeValid = false; // Validation status
  String? prototypeValidationError; // Error message if validation fails
  String? prototypeChannelId; // Channel ID from prototype validation
  String? prototypeApiKey; // API key from prototype validation

  bool get isValid =>
      deviceId.trim().isNotEmpty && 
      deviceName.trim().isNotEmpty && 
      prototypeId.trim().isNotEmpty && 
      isPrototypeValid;

  Map<String, dynamic> toJson() {
    return {
      'sensorId': deviceId,
      'name': deviceName,
      'type': deviceType,
      'deviceMacAddress': deviceMacAddress.isEmpty ? null : deviceMacAddress,
      'location': {
        'coordinates': [121.0244, 14.5995], // Default Manila coordinates
        'description': 'Farm sensor location',
      },
      'specifications': {
        'model': 'MaizeWatch-${deviceType}',
        'manufacturer': 'MaizeWatch',
      },
      'status': 'active',
      'isActive': true,
    };
  }

  Map<String, dynamic> toJsonWithFarm(String farmId) {
    final json = toJson();
    json['farm'] = farmId;
    return json;
  }
}
