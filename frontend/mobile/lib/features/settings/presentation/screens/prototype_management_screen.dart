import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/widgets/error_dialog.dart';
import 'package:mobile/core/services/prototype_service.dart';
import 'package:mobile/core/storage/secure_storage.dart';
import 'package:mobile/generated/l10n.dart';

class PrototypeManagementScreen extends StatefulWidget {
  const PrototypeManagementScreen({super.key});

  @override
  State<PrototypeManagementScreen> createState() => _PrototypeManagementScreenState();
}

class _PrototypeManagementScreenState extends State<PrototypeManagementScreen> {
  List<Map<String, dynamic>> _prototypes = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPrototypes();
  }

  Future<void> _loadPrototypes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        setState(() {
          _errorMessage = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      final result = await PrototypeService.getUserPrototypes(token);
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success'] == true) {
            _prototypes = List<Map<String, dynamic>>.from(result['data'] ?? []);
          } else {
            _errorMessage = result['message'] ?? 'Failed to load prototypes';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading prototypes: $e';
        });
      }
    }
  }

  Future<void> _unsyncPrototype(String prototypeId, String fieldId, String fieldName) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(S.of(context).unsync_prototype),
        content: Text(S.of(context).unsync_prototype_confirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.of(context).cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(S.of(context).confirm_unsync),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final token = await SecureStorage.getToken();
      if (token == null) {
        Navigator.of(context).pop(); // Close loading dialog
        ErrorDialog.show(
          context,
          title: S.of(context).error,
          message: 'Authentication required',
        );
        return;
      }

      final result = await PrototypeService.unsyncPrototype(prototypeId, fieldId, token);
      
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(S.of(context).prototype_unsynced),
              backgroundColor: Colors.green,
            ),
          );
          // Reload prototypes
          _loadPrototypes();
        } else {
          ErrorDialog.show(
            context,
            title: S.of(context).error,
            message: result['message'] ?? 'Failed to unsync prototype',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ErrorDialog.show(
          context,
          title: S.of(context).error,
          message: 'Error unsyncing prototype: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: MAIZE_BACKGROUND,
      appBar: AppBar(
        backgroundColor: MAIZE_BACKGROUND,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MAIZE_ACCENT),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          S.of(context).unsync_prototype,
          style: textTheme.headlineSmall?.copyWith(
            color: MAIZE_ACCENT,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.sp,
                        color: Colors.red,
                      ),
                      SizedBox(height: kAppMediumPadding.h),
                      Text(
                        _errorMessage!,
                        style: textTheme.bodyLarge?.copyWith(
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: kAppMediumPadding.h),
                      ElevatedButton(
                        onPressed: _loadPrototypes,
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                )
              : _prototypes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.device_hub_outlined,
                            size: 64.sp,
                            color: MAIZE_ACCENT.withOpacity(0.5),
                          ),
                          SizedBox(height: kAppMediumPadding.h),
                          Text(
                            S.of(context).no_prototypes_found,
                            style: textTheme.headlineSmall?.copyWith(
                              color: MAIZE_ACCENT.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: kAppSmallPadding.h),
                          Text(
                            S.of(context).no_prototypes_registered,
                            style: textTheme.bodyMedium?.copyWith(
                              color: MAIZE_ACCENT.withOpacity(0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(kAppMediumPadding.w),
                      itemCount: _prototypes.length,
                      itemBuilder: (context, index) {
                        final prototype = _prototypes[index];
                        final prototypeId = prototype['prototype_id'] ?? '';
                        final fieldId = prototype['field_id'] ?? '';
                        final fieldName = prototype['field_name'] ?? 'Unknown Field';
                        final isActive = prototype['is_active'] ?? false;

                        return Card(
                          margin: EdgeInsets.only(bottom: kAppMediumPadding.h),
                          child: ListTile(
                            leading: Container(
                              padding: EdgeInsets.all(kAppSmallPadding.w),
                              decoration: BoxDecoration(
                                color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(
                                Icons.device_hub,
                                color: isActive ? Colors.green : Colors.red,
                                size: 24.sp,
                              ),
                            ),
                            title: Text(
                              '${S.of(context).prototype_id} $prototypeId',
                              style: textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${S.of(context).field_colon} $fieldName'),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      isActive ? Icons.check_circle : Icons.cancel,
                                      size: 16.sp,
                                      color: isActive ? Colors.green : Colors.red,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      isActive ? S.of(context).active : S.of(context).inactive,
                                      style: textTheme.bodySmall?.copyWith(
                                        color: isActive ? Colors.green : Colors.red,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.link_off, color: Colors.red),
                              onPressed: () => _unsyncPrototype(prototypeId, fieldId, fieldName),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
