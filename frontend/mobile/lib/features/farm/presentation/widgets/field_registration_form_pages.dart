import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/prototype_service.dart';
import '../../../../generated/l10n.dart';
import '../screens/field_registration_screen.dart';

// Field Name Input Page
class FieldNameFormPage extends StatefulWidget {
  final FarmRegistrationControllers controllers;

  const FieldNameFormPage({super.key, required this.controllers});

  @override
  State<FieldNameFormPage> createState() => _FieldNameFormPageState();
}

class _FieldNameFormPageState extends State<FieldNameFormPage> {
  final _fieldNameController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _fieldNameController.text = widget.controllers.fieldName;
    _fieldNameController.addListener(() {
      widget.controllers.fieldName = _fieldNameController.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).name_your_field,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28.sp,
              height: 1.2,
              letterSpacing: 0,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            S.of(context).give_field_unique_name,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: MAIZE_ACCENT.withOpacity(0.8),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 30.h),

          // Field Name Input using consistent styling
          _buildInputField(
            S.of(context).field_name,
            S.of(context).field_name_hint,
            _fieldNameController,
          ),
          SizedBox(height: 20.h),

          // Info card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    S.of(context).multiple_fields_info,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyLarge?.copyWith(fontSize: 16.sp)),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          focusNode: _focusNode,
          style: textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white.withOpacity(0.8),
            hintStyle: TextStyle(
              color: const Color.fromARGB(122, 43, 70, 37),
              fontSize: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fieldNameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

// Planting Date Selection Page
class PlantingDateFormPage extends StatefulWidget {
  final FarmRegistrationControllers controllers;

  const PlantingDateFormPage({super.key, required this.controllers});

  @override
  State<PlantingDateFormPage> createState() => _PlantingDateFormPageState();
}

class _PlantingDateFormPageState extends State<PlantingDateFormPage> {
  int? get daysSincePlanting {
    if (widget.controllers.plantingDate == null) return null;
    return DateTime.now().difference(widget.controllers.plantingDate!).inDays;
  }

  String get growthStageText {
    final days = daysSincePlanting;
    if (days == null) return '';

    if (days <= 7) return S.of(context).emergence_stage(days);
    if (days <= 21) return S.of(context).third_leaf_stage(days);
    if (days <= 42) return S.of(context).eighth_leaf_stage(days);
    if (days <= 65) return S.of(context).tasseling_stage(days);
    if (days <= 85) return S.of(context).silking_stage(days);
    return S.of(context).maturity_stage(days);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            S.of(context).planting_date,
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28.sp,
              height: 1.2,
              letterSpacing: 0,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            S.of(context).when_did_you_plant,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: MAIZE_ACCENT.withOpacity(0.8),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 30.h),

          // Date picker card
          GestureDetector(
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate:
                    widget.controllers.plantingDate ??
                    DateTime.now().subtract(const Duration(days: 30)),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: MAIZE_ACCENT,
                        onPrimary: Colors.white,
                      ),
                      textTheme: Theme.of(context).textTheme.copyWith(
                        bodyLarge: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.normal),
                        bodyMedium: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.normal),
                        labelLarge: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(fontWeight: FontWeight.normal),
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  widget.controllers.plantingDate = pickedDate;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color:
                      widget.controllers.plantingDate != null
                          ? MAIZE_ACCENT
                          : Colors.grey.shade300,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: MAIZE_ACCENT, size: 20.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      widget.controllers.plantingDate != null
                          ? '${widget.controllers.plantingDate!.day}/${widget.controllers.plantingDate!.month}/${widget.controllers.plantingDate!.year}'
                          : S.of(context).select_planting_date,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color:
                            widget.controllers.plantingDate != null
                                ? MAIZE_ACCENT
                                : const Color.fromARGB(122, 43, 70, 37),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
            ),
          ),

          if (widget.controllers.plantingDate != null) ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: MAIZE_PRIMARY_LIGHT,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.timeline, color: MAIZE_ACCENT, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        S.of(context).estimated_growth_stage,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: MAIZE_ACCENT,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    growthStageText,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),

          // Info card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Colors.blue.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    S.of(context).growth_stage_calculated,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.blue.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Device Registration Page
class DeviceRegistrationFormPage extends StatefulWidget {
  final FarmRegistrationControllers controllers;

  const DeviceRegistrationFormPage({super.key, required this.controllers});

  @override
  State<DeviceRegistrationFormPage> createState() =>
      _DeviceRegistrationFormPageState();
}

class _DeviceRegistrationFormPageState
    extends State<DeviceRegistrationFormPage> {
  @override
  void initState() {
    super.initState();
    // Start with no devices - user can add them if needed
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          S.of(context).device_registration,
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 28.sp,
            height: 1.2,
            letterSpacing: 0,
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          S.of(context).register_monitoring_devices,
          style: textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: MAIZE_ACCENT.withOpacity(0.8),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 20.h),

        // Device count indicator
        if (widget.controllers.devices.isNotEmpty)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: MAIZE_PRIMARY_LIGHT,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: MAIZE_ACCENT.withOpacity(0.2)),
            ),
            child: Text(
              S.of(context).devices_registered(widget.controllers.devices.length),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: MAIZE_ACCENT,
              ),
            ),
          ),

        if (widget.controllers.devices.isNotEmpty) SizedBox(height: 16.h),

        // Devices list or empty state
        Expanded(
          child:
              widget.controllers.devices.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: widget.controllers.devices.length,
                    itemBuilder: (context, index) {
                      return _buildDeviceListItem(index);
                    },
                  ),
        ),

        SizedBox(height: 16.h),

        // Add device button
        SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton.icon(
            onPressed: () => _showDeviceRegistrationModal(),
            icon: Icon(Icons.add, size: 20.sp),
            label: Text(
              widget.controllers.devices.isEmpty
                  ? 'Add Device'
                  : 'Add Another Device',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: MAIZE_ACCENT,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: MAIZE_PRIMARY_LIGHT.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.device_hub_outlined,
              size: 48.sp,
              color: MAIZE_ACCENT.withOpacity(0.6),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No devices registered yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first monitoring device to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: MAIZE_ACCENT.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceListItem(int index) {
    final device = widget.controllers.devices[index];

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color:
              device.isValid
                  ? MAIZE_ACCENT.withOpacity(0.3)
                  : Colors.red.withOpacity(0.3),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: MAIZE_PRIMARY_LIGHT,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.device_hub, size: 24.sp, color: MAIZE_ACCENT),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.deviceName.isNotEmpty
                      ? device.deviceName
                      : 'Unnamed Device',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: MAIZE_ACCENT,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'ID: ${device.deviceId}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: MAIZE_ACCENT.withOpacity(0.7),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prototype: ${device.prototypeId.isNotEmpty ? device.prototypeId : 'Not set'}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: device.isPrototypeValid 
                            ? Colors.green 
                            : device.prototypeValidationError != null 
                                ? Colors.red 
                                : MAIZE_ACCENT.withOpacity(0.7),
                      ),
                    ),
                    if (device.isPrototypeValid && device.prototypeChannelId != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        'Channel: ${device.prototypeChannelId}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green.withOpacity(0.8),
                        ),
                      ),
                      Text(
                        'API: ${device.prototypeApiKey?.substring(0, 8) ?? ''}...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ],
                ),
                if (device.isPrototypeValid) ...[
                  Row(
                    children: [
                      Icon(Icons.check_circle, size: 12.sp, color: Colors.green),
                      SizedBox(width: 4.w),
                      Text(
                        'Validated',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ] else if (device.prototypeValidationError != null) ...[
                  Row(
                    children: [
                      Icon(Icons.error, size: 12.sp, color: Colors.red),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          device.prototypeValidationError!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.red,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _showDeviceRegistrationModal(editIndex: index);
              } else if (value == 'delete') {
                _removeDevice(index);
              }
            },
            itemBuilder:
                (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 18.sp),
                        SizedBox(width: 8.w),
                        Text(S.of(context).edit),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 18.sp, color: Colors.red),
                        SizedBox(width: 8.w),
                        Text(S.of(context).delete, style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
            child: Icon(Icons.more_vert, color: MAIZE_ACCENT.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }

  void _showDeviceRegistrationModal({int? editIndex}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DeviceRegistrationModal(
            controllers: widget.controllers,
            editIndex: editIndex,
            onDeviceAdded: () {
              setState(() {});
            },
          ),
    );
  }

  void _removeDevice(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Delete Device',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this device? This action cannot be undone.',
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  widget.controllers.removeDevice(index);
                });
              },
              child: Text(S.of(context).delete, style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

// Device Registration Modal
class DeviceRegistrationModal extends StatefulWidget {
  final FarmRegistrationControllers controllers;
  final int? editIndex;
  final VoidCallback onDeviceAdded;

  const DeviceRegistrationModal({
    super.key,
    required this.controllers,
    this.editIndex,
    required this.onDeviceAdded,
  });

  @override
  State<DeviceRegistrationModal> createState() =>
      _DeviceRegistrationModalState();
}

class _DeviceRegistrationModalState extends State<DeviceRegistrationModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _deviceNameController;
  late TextEditingController _deviceIdController;

  late TextEditingController _prototypeIdController;
  String _selectedSoilType = 'loamy';
  bool _isValidatingPrototype = false;
  bool _isPrototypeValid = false;
  String? _prototypeValidationError;
  String? _prototypeChannelId;
  String? _prototypeApiKey;

  @override
  void initState() {
    super.initState();

    if (widget.editIndex != null) {
      final device = widget.controllers.devices[widget.editIndex!];
      _deviceNameController = TextEditingController(text: device.deviceName);
      _deviceIdController = TextEditingController(text: device.deviceId);
      _prototypeIdController = TextEditingController(text: device.prototypeId);
      _selectedSoilType = device.soilType;
      _isPrototypeValid = device.isPrototypeValid;
      _prototypeValidationError = device.prototypeValidationError;
      _prototypeChannelId = device.prototypeChannelId;
      _prototypeApiKey = device.prototypeApiKey;
    } else {
      _deviceNameController = TextEditingController();
      _deviceIdController = TextEditingController();
      _prototypeIdController = TextEditingController();
    }
  }

  Future<void> _validatePrototypeId() async {
    if (_prototypeIdController.text.trim().isEmpty) {
      setState(() {
        _isPrototypeValid = false;
        _prototypeValidationError = 'Prototype ID is required';
      });
      return;
    }

    setState(() {
      _isValidatingPrototype = true;
      _prototypeValidationError = null;
    });

    try {
      final result = await PrototypeService.validatePrototype(_prototypeIdController.text.trim());
      
      setState(() {
        _isValidatingPrototype = false;
        _isPrototypeValid = result['success'] == true && result['available'] == true;
        _prototypeValidationError = _isPrototypeValid ? null : result['message'] ?? 'Invalid prototype ID';
        
        // Store prototype details if validation is successful
        if (_isPrototypeValid && result['prototype'] != null) {
          final prototype = result['prototype'];
          _prototypeChannelId = prototype['channel_id'];
          _prototypeApiKey = prototype['api_key'];
        } else {
          _prototypeChannelId = null;
          _prototypeApiKey = null;
        }
      });
    } catch (e) {
      setState(() {
        _isValidatingPrototype = false;
        _isPrototypeValid = false;
        _prototypeValidationError = 'Failed to validate prototype ID: $e';
        _prototypeChannelId = null;
        _prototypeApiKey = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: MAIZE_BOTTOM_OVERLAY,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Modal header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.editIndex != null ? 'Edit Device' : 'Add Device',
                      style: textTheme.headlineSmall?.copyWith(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: MAIZE_ACCENT,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: MAIZE_ACCENT),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Device Name Field
              _buildModalInputField(
                label: 'Device Name *',
                controller: _deviceNameController,
                hintText: 'e.g., Field Sensor 1',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Device name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Device ID Field
              _buildModalInputField(
                label: 'Device ID *',
                controller: _deviceIdController,
                hintText: 'Enter unique device ID',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Device ID is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Prototype ID Field
              _buildPrototypeIdField(),
              SizedBox(height: 16.h),

              

              // Soil Type Selection
              _buildSoilTypeSelection(),
              SizedBox(height: 24.h),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _submitDevice,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_ACCENT,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.editIndex != null ? 'Update Device' : 'Add Device',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModalInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextTheme().bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: MAIZE_ACCENT.withOpacity(0.8),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontWeight: FontWeight.w100, // lighter but not too thin
              color: MAIZE_ACCENT.withOpacity(0.4), // subtle color for hint
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: MAIZE_ACCENT.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: MAIZE_ACCENT.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: MAIZE_ACCENT, width: 2.w),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 12.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrototypeIdField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Prototype ID *',
          style: TextTheme().bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: MAIZE_ACCENT.withOpacity(0.8),
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _prototypeIdController,
                onChanged: (value) {
                  // Clear validation state when user types
                  if (_isPrototypeValid || _prototypeValidationError != null) {
                    setState(() {
                      _isPrototypeValid = false;
                      _prototypeValidationError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'e.g., PROTO_001, SENSOR_001',
                  hintStyle: TextStyle(
                    fontWeight: FontWeight.w100,
                    color: MAIZE_ACCENT.withOpacity(0.4),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: _isPrototypeValid 
                          ? Colors.green.withOpacity(0.5)
                          : _prototypeValidationError != null
                              ? Colors.red.withOpacity(0.5)
                              : MAIZE_ACCENT.withOpacity(0.3),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: _isPrototypeValid 
                          ? Colors.green.withOpacity(0.5)
                          : _prototypeValidationError != null
                              ? Colors.red.withOpacity(0.5)
                              : MAIZE_ACCENT.withOpacity(0.3),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(
                      color: _isPrototypeValid 
                          ? Colors.green
                          : _prototypeValidationError != null
                              ? Colors.red
                              : MAIZE_ACCENT,
                      width: 2.w,
                    ),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  suffixIcon: _isValidatingPrototype
                      ? Padding(
                          padding: EdgeInsets.all(12.w),
                          child: SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(MAIZE_ACCENT),
                            ),
                          ),
                        )
                      : _isPrototypeValid
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20.sp,
                            )
                          : _prototypeValidationError != null
                              ? Icon(
                                  Icons.error,
                                  color: Colors.red,
                                  size: 20.sp,
                                )
                              : null,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Prototype ID is required';
                  }
                  if (!_isPrototypeValid && _prototypeValidationError != null) {
                    return _prototypeValidationError;
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 8.w),
            ElevatedButton(
              onPressed: _isValidatingPrototype ? null : _validatePrototypeId,
              style: ElevatedButton.styleFrom(
                backgroundColor: MAIZE_ACCENT,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              ),
              child: Text(
                'Validate',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        if (_prototypeValidationError != null) ...[
          SizedBox(height: 4.h),
          Text(
            _prototypeValidationError!,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.red,
            ),
          ),
        ],
        if (_isPrototypeValid) ...[
          SizedBox(height: 4.h),
          Text(
            'Prototype ID is valid and available',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.green,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSoilTypeSelection() {
    final soilTypes = [
      {
        'id': 'loamy',
        'name': 'Loamy Soil',
        'icon': Icons.landscape,
        'description': 'Well-balanced soil',
      },
      {
        'id': 'sandy',
        'name': 'Sandy Soil',
        'icon': Icons.grain,
        'description': 'Fast-draining soil',
      },
      {
        'id': 'clay',
        'name': 'Clay Soil',
        'icon': Icons.layers,
        'description': 'Water-retaining soil',
      },
      {
        'id': 'silty',
        'name': 'Silty Soil',
        'icon': Icons.texture,
        'description': 'Smooth textured soil',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Soil Type *',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: MAIZE_ACCENT,
          ),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.9,
          ),
          itemCount: soilTypes.length,
          itemBuilder: (context, index) {
            final soil = soilTypes[index];
            final isSelected = _selectedSoilType == soil['id'];

            return _buildSoilTypeCard(
              isSelected: isSelected,
              title: soil['name'] as String,
              description: soil['description'] as String,
              icon: soil['icon'] as IconData,
              onTap: () {
                setState(() {
                  _selectedSoilType = soil['id'] as String;
                });
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildSoilTypeCard({
    required bool isSelected,
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isSelected ? MAIZE_PRIMARY : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border:
              isSelected ? null : Border.all(color: MAIZE_PRIMARY, width: 1.w),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: isSelected ? MAIZE_PRIMARY_LIGHT : MAIZE_PRIMARY,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isSelected ? MAIZE_PRIMARY_LIGHT : MAIZE_PRIMARY,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 11.sp,
                color:
                    isSelected
                        ? MAIZE_PRIMARY_LIGHT.withOpacity(0.8)
                        : MAIZE_PRIMARY.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _submitDevice() {
    if (_formKey.currentState!.validate()) {
      // Check if prototype ID is valid before submitting
      if (!_isPrototypeValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).please_validate_prototype_id),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (widget.editIndex != null) {
        // Edit existing device
        final device = widget.controllers.devices[widget.editIndex!];
        device.deviceName = _deviceNameController.text.trim();
        device.deviceId = _deviceIdController.text.trim();
        device.deviceType = 'Multi_Sensor'; // Default device type
        device.soilType = _selectedSoilType;
        device.prototypeId = _prototypeIdController.text.trim();
        device.isPrototypeValid = _isPrototypeValid;
        device.prototypeValidationError = _prototypeValidationError;
        device.prototypeChannelId = _prototypeChannelId;
        device.prototypeApiKey = _prototypeApiKey;
      } else {
        // Add new device
        widget.controllers.addDevice();
        final device = widget.controllers.devices.last;
        device.deviceName = _deviceNameController.text.trim();
        device.deviceId = _deviceIdController.text.trim();
        device.deviceType = 'Multi_Sensor'; // Default device type
        device.soilType = _selectedSoilType;
        device.prototypeId = _prototypeIdController.text.trim();
        device.isPrototypeValid = _isPrototypeValid;
        device.prototypeValidationError = _prototypeValidationError;
        device.prototypeChannelId = _prototypeChannelId;
        device.prototypeApiKey = _prototypeApiKey;
      }

      widget.onDeviceAdded();
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _deviceNameController.dispose();
    _deviceIdController.dispose();
    _prototypeIdController.dispose();
    super.dispose();
  }
}

// Farm Data Confirmation Page
class FarmDataConfirmationPage extends StatelessWidget {
  final FarmRegistrationControllers controllers;

  const FarmDataConfirmationPage({super.key, required this.controllers});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confirm Your Farm Data',
            style: textTheme.headlineMedium?.copyWith(
              fontSize: 28.sp,
              height: 1.2,
              letterSpacing: 0,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please review your farm information before submitting',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: MAIZE_ACCENT.withOpacity(0.8),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 20.h),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildInfoCard(
                    title: 'Field Information',
                    icon: Icons.agriculture,
                    children: [
                      _buildInfoRow('Field Name', controllers.fieldName),
                      _buildInfoRow('Location', controllers.location),
                      _buildInfoRow(
                        'Soil Type',
                        _formatSoilType(controllers.soilType),
                      ),
                      _buildInfoRow(
                        'Planting Date',
                        controllers.plantingDate != null
                            ? '${controllers.plantingDate!.day}/${controllers.plantingDate!.month}/${controllers.plantingDate!.year}'
                            : 'Not set',
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  _buildInfoCard(
                    title: 'Registered Devices',
                    icon: Icons.device_hub,
                    children:
                        controllers.devices.isEmpty
                            ? [
                              Container(
                                padding: EdgeInsets.all(16.w),
                                child: Text(
                                  'No devices registered',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: MAIZE_ACCENT.withOpacity(0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ]
                            : controllers.devices
                                .map((device) => _buildDeviceInfo(device))
                                .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: MAIZE_ACCENT.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
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
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: MAIZE_PRIMARY_LIGHT,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, size: 20.sp, color: MAIZE_ACCENT),
              ),
              SizedBox(width: 12.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: MAIZE_ACCENT,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: MAIZE_ACCENT.withOpacity(0.7),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Not specified',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: MAIZE_ACCENT,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceInfo(DeviceInfo device) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY_LIGHT.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: MAIZE_ACCENT.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            device.deviceName.isNotEmpty ? device.deviceName : 'Unnamed Device',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: MAIZE_ACCENT,
            ),
          ),
          SizedBox(height: 6.h),
          _buildInfoRow('Device ID', device.deviceId),
          _buildInfoRow('Device Type', device.deviceType),
        ],
      ),
    );
  }

  String _formatSoilType(String soilType) {
    switch (soilType) {
      case 'loamy':
        return 'Loamy Soil';
      case 'sandy':
        return 'Sandy Soil';
      case 'clay':
        return 'Clay Soil';
      case 'silt':
        return 'Silt Soil';
      default:
        return soilType.isNotEmpty ? soilType : 'Not specified';
    }
  }
}

// Completion Page
class CompletionFormPage extends StatelessWidget {
  final FarmRegistrationControllers controllers;

  const CompletionFormPage({super.key, required this.controllers});

  int get daysSincePlanting {
    if (controllers.plantingDate == null) return 0;
    return DateTime.now().difference(controllers.plantingDate!).inDays;
  }

  String get growthStage {
    final days = daysSincePlanting;
    if (days <= 7) return 'VE - Emergence';
    if (days <= 21) return 'V3 - Third Leaf';
    if (days <= 42) return 'V8 - Eighth Leaf';
    if (days <= 65) return 'VT - Tasseling';
    if (days <= 85) return 'R1 - Silking';
    return 'R6 - Maturity';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        children: [
          SizedBox(height: 40.h),

          // Success icon
          Container(
            width: 100.w,
            height: 100.w,
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 60.sp,
              color: Colors.green.shade600,
            ),
          ),
          SizedBox(height: 24.h),

          Text(
            'Farm Registered Successfully!',
            style: TextStyle(
              fontSize: 24.sp,
              color: MAIZE_ACCENT,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          Text(
            'Your farm has been successfully registered and is ready for monitoring.',
            style: TextStyle(
              fontSize: 16.sp,
              color: MAIZE_ACCENT.withOpacity(0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),

          // Registered devices summary
          if (controllers.hasDevices) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: MAIZE_PRIMARY_LIGHT,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: MAIZE_ACCENT.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sensors, color: MAIZE_ACCENT, size: 20.sp),
                      SizedBox(width: 8.w),
                      Text(
                        'Registered Devices',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: MAIZE_ACCENT,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ...controllers.devices.asMap().entries.map((entry) {
                    final index = entry.key;
                    final device = entry.value;
                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: MAIZE_ACCENT.withOpacity(0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32.w,
                            height: 32.w,
                            decoration: BoxDecoration(
                              color: MAIZE_ACCENT.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: MAIZE_ACCENT,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  device.deviceName,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: MAIZE_ACCENT,
                                  ),
                                ),
                                Text(
                                  'ID: ${device.deviceId}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: MAIZE_ACCENT.withOpacity(0.6),
                                  ),
                                ),
                                Text(
                                  'Type: ${device.deviceType.replaceAll('_', ' ')}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: MAIZE_ACCENT.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],
          SizedBox(height: 32.h),

          // Registration summary
          Expanded(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: MAIZE_PRIMARY_LIGHT),
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
                    'Farm Summary',
                    style: TextStyle(
                      fontSize: 18.sp,
                      color: MAIZE_ACCENT,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),

                  _buildSummaryItem(
                    icon: Icons.agriculture,
                    label: 'Field Name',
                    value:
                        controllers.fieldName.isNotEmpty
                            ? controllers.fieldName
                            : 'Not set',
                  ),

                  _buildSummaryItem(
                    icon: Icons.location_on,
                    label: 'Location',
                    value: controllers.location,
                  ),

                  _buildSummaryItem(
                    icon: Icons.terrain,
                    label: 'Soil Type',
                    value: _formatSoilType(controllers.soilType),
                  ),

                  _buildSummaryItem(
                    icon: Icons.calendar_today,
                    label: 'Planting Date',
                    value:
                        controllers.plantingDate != null
                            ? '${controllers.plantingDate!.day}/${controllers.plantingDate!.month}/${controllers.plantingDate!.year}'
                            : 'Not set',
                  ),

                  _buildSummaryItem(
                    icon: Icons.timeline,
                    label: 'Current Growth Stage',
                    value: '$growthStage ($daysSincePlanting days)',
                  ),

                  if (controllers.hasDevices)
                    _buildSummaryItem(
                      icon: Icons.device_hub,
                      label: 'Devices',
                      value:
                          '${controllers.devices.length} device${controllers.devices.length != 1 ? 's' : ''} registered',
                      isLast: true,
                    )
                  else
                    _buildSummaryItem(
                      icon: Icons.info_outline,
                      label: 'Device Status',
                      value: 'Not connected',
                      isLast: true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: MAIZE_PRIMARY_LIGHT,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: MAIZE_ACCENT, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: MAIZE_ACCENT.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: MAIZE_ACCENT,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatSoilType(String soilType) {
    switch (soilType) {
      case 'loamy':
        return 'Loamy Soil';
      case 'sandy':
        return 'Sandy Soil';
      case 'clay':
        return 'Clay Soil';
      case 'silty':
        return 'Silty Soil';
      default:
        return soilType;
    }
  }
}
