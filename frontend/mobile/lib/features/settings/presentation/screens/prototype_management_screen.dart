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
      print('🔧 PrototypeManagement: Token available: ${token != null}');
      
      if (token == null) {
        print('🔧 PrototypeManagement: No token available');
        setState(() {
          _errorMessage = S.of(context).authentication_required;
          _isLoading = false;
        });
        return;
      }

      print('🔧 PrototypeManagement: Calling getUserPrototypes API...');
      final result = await PrototypeService.getUserPrototypes(token);
      print('🔧 PrototypeManagement: API response: $result');
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (result['success'] == true) {
            // Backend returns data in 'prototypes' field, not 'data'
            _prototypes = List<Map<String, dynamic>>.from(result['prototypes'] ?? []);
            print('🔧 PrototypeManagement: Loaded ${_prototypes.length} prototypes');
            for (var prototype in _prototypes) {
              print('🔧 PrototypeManagement: Prototype: ${prototype['prototype_id']} - Channel: ${prototype['channel_id']}');
            }
          } else {
            _errorMessage = result['message'] ?? S.of(context).failed_to_load_prototypes;
            print('🔧 PrototypeManagement: API error: $_errorMessage');
          }
        });
      }
    } catch (e) {
      print('🔧 PrototypeManagement: Exception: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = S.of(context).error_loading_prototypes(e.toString());
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
          message: S.of(context).authentication_required,
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
            message: result['message'] ?? S.of(context).failed_to_unsync_prototype,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        ErrorDialog.show(
          context,
          title: S.of(context).error,
          message: S.of(context).error_unsyncing_prototype(e.toString()),
        );
      }
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildPrototypeMenuItem({
    required String prototypeId,
    required String channelId,
    required String registeredAt,
    required bool isActive,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(kAppMediumPadding),
      margin: EdgeInsets.only(bottom: kAppSmallGap),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Icon(
              Icons.device_hub,
              color: isActive ? Colors.green : Colors.red,
              size: 20.sp,
            ),
          ),
          SizedBox(width: kAppSmallGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      S.of(context).prototype_id,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MAIZE_ACCENT.withOpacity(0.8),
                
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: 3.h),
                Text(
                  prototypeId,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  S.of(context).channel_id,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: MAIZE_ACCENT.withOpacity(0.8),
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  channelId,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (registeredAt.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    S.of(context).registered,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: MAIZE_ACCENT.withOpacity(0.8),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    _formatDate(registeredAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isActive ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.link_off, color: Colors.red),
            onPressed: () => _unsyncPrototype(prototypeId, channelId, 'Prototype $prototypeId'),
            tooltip: S.of(context).unsync_prototype,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(
        backgroundColor: MAIZE_PRIMARY_LIGHT,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: MAIZE_ACCENT),
          onPressed: () => Navigator.of(context).pop(),
        ),        
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: MAIZE_ACCENT),
            onPressed: _loadPrototypes,
            tooltip: S.of(context).refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _isLoading ? _buildLoadingSection() : _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Expanded(
      child: Center(
        child: CircularProgressIndicator(
          color: MAIZE_ACCENT,
        ),
      ),
    );
  }

  Widget _buildContentSection() {
    final textTheme = Theme.of(context).textTheme;
    
    if (_errorMessage != null) {
      return Expanded(
        child: Center(
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
                child: Text(S.of(context).retry),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_prototypes.isEmpty) {
      return Expanded(
        child: Center(
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
        ),
      );
    }
    
    return Expanded(
      child: Padding(
        padding: EdgeInsets.all(kAppMediumPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              S.of(context).prototype_management,
              style: textTheme.headlineMedium,
            ),
            verticalSpace(5.h),
            Text(
              S.of(context).manage_your_registered_prototypes,
              style: textTheme.bodySmall,
            ),
            verticalSpace(kAppLargeGap),
            Expanded(
              child: ListView.builder(
                itemCount: _prototypes.length,
                itemBuilder: (context, index) {
                  final prototype = _prototypes[index];
                  final prototypeId = prototype['prototype_id'] ?? '';
                  final channelId = prototype['channel_id'] ?? '';
                  final registeredAt = prototype['registeredAt'] ?? '';
                  final isActive = prototype['isActive'] ?? true;

                  return _buildPrototypeMenuItem(
                    prototypeId: prototypeId,
                    channelId: channelId,
                    registeredAt: registeredAt,
                    isActive: isActive,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}