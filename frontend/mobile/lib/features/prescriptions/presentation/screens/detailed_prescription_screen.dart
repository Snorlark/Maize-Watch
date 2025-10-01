import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/services/completion_status_manager.dart';
import '../../../../core/services/prescription_id_mapper.dart';
import '../../../../features/prescriptions/presentation/bloc/prescription_bloc.dart';
import '../../../../features/prescriptions/presentation/bloc/prescription_event.dart';
import '../../../../features/authentication/presentation/bloc/authentication_bloc.dart';
import '../../../../generated/l10n.dart';

class DetailedPrescriptionScreen extends StatefulWidget {
  const DetailedPrescriptionScreen({super.key});

  @override
  State<DetailedPrescriptionScreen> createState() => _DetailedPrescriptionScreenState();
}

class _DetailedPrescriptionScreenState extends State<DetailedPrescriptionScreen> {
  bool _isCompleted = false;
  bool _isInitialized = false;
  Map<String, bool> _expandedInstructions = {}; // Track which instructions are expanded
  
  @override
  void initState() {
    super.initState();
    // Load completion status when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prescriptionData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
      final prescriptionId = prescriptionData['id'] as String? ?? '';
      if (prescriptionId.isNotEmpty) {
        _loadCompletionStatus(prescriptionId);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh completion status when screen becomes visible
    final prescriptionData = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final prescriptionId = prescriptionData['id'] as String? ?? '';
    if (prescriptionId.isNotEmpty) {
      _loadCompletionStatus(prescriptionId);
    }
  }

  // Store completion status for a prescription
  Future<void> _storeCompletionStatus(String prescriptionId, bool isCompleted) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('prescription_completed_$prescriptionId', isCompleted);
      print('🔧 Stored completion status for $prescriptionId: $isCompleted');
    } catch (e) {
      print('🔧 Error storing completion status: $e');
    }
  }

  // Retrieve completion status for a prescription
  Future<bool> _getCompletionStatus(String prescriptionId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('prescription_completed_$prescriptionId') ?? false;
    } catch (e) {
      print('🔧 Error retrieving completion status: $e');
      return false;
    }
  }

  // Load completion status and update UI
  Future<void> _loadCompletionStatus(String prescriptionId) async {
    try {
      // Check both completion status sources
      final staticStatus = await CompletionStatusManager.getCompletionStatus(prescriptionId);
      final storedStatus = await _getCompletionStatus(prescriptionId);
      
      // Use the most recent status (prefer static status as it's more current)
      final finalStatus = staticStatus || storedStatus;
      
      print('🔧 Loading completion status for $prescriptionId: static=$staticStatus, stored=$storedStatus, final=$finalStatus, current=$_isCompleted');
      
      if (finalStatus != _isCompleted) {
        setState(() {
          _isCompleted = finalStatus;
        });
        print('🔧 Updated completion status to: $finalStatus');
      }
    } catch (e) {
      print('🔧 Error loading completion status: $e');
    }
  }

  // Notify that completion status has changed
  void _notifyCompletionStatusChanged() {
    // This could be used to trigger a refresh in parent screens
    // For now, we'll just print a debug message
    print('🔧 Completion status changed for prescription, parent screens should refresh');
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> prescriptionData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    print('🔧 Prescription Data Received:');
    print('🔧 Full prescriptionData: $prescriptionData');
    print('🔧 ID: ${prescriptionData['id']}');
    print('🔧 Field ID: ${prescriptionData['fieldId']}');
    print('🔧 Is Completed: ${prescriptionData['isCompleted']}');

    final String title = prescriptionData['title'] ?? S.of(context).farm_prescription;
    final String description = prescriptionData['description'] ?? S.of(context).no_details_available;
    final String fieldName = prescriptionData['fieldName'] ?? S.of(context).unknown_field;
    final String soilType = prescriptionData['soilType'] ?? S.of(context).unknown;
    final String growthStage = prescriptionData['growthStage'] ?? S.of(context).unknown;
    final String urgency = prescriptionData['urgency'] ?? 'MEDIUM';
    final String timeline = prescriptionData['timeline'] ?? S.of(context).today;
    final String? createdAtString = prescriptionData['createdAt'] as String?;
    final DateTime? createdAt = createdAtString != null ? DateTime.tryParse(createdAtString) : null;
    final bool isCompleted = prescriptionData['isCompleted'] as bool? ?? false;

    // Initialize completion state from prescription data only once
    if (!_isInitialized) {
      print('🔧 Initializing completion state: $isCompleted');
      _isCompleted = isCompleted;
      _isInitialized = true;
      
      // Check for stored completion status
      final prescriptionId = prescriptionData['id'] as String? ?? '';
      if (prescriptionId.isNotEmpty) {
        // Load completion status and update UI
        _loadCompletionStatus(prescriptionId);
      }
    } else {
      print('🔧 State already initialized, current _isCompleted: $_isCompleted');
    }

    // Calculate send time and deadline
    final sendTime = _formatSendTime(createdAt);
    final deadline = _calculateDeadline(timeline, urgency);
    final urgencyColor = _getUrgencyColor(urgency);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      appBar: AppBar(
        backgroundColor: urgencyColor.withOpacity(0.7),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, color: MAIZE_ACCENT),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
              fieldName, 
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,            
                  color: _isCompleted ? Colors.green[700] : null,
                ),
              ),
            ),
          ],
        ),
        
        actions: [
          // Mark as completed toggle in header
          TextButton(
              onPressed: () async {
                final Map<String, dynamic> prescriptionData =
                    ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
                final prescriptionId = prescriptionData['id'] as String? ?? '';
                final fieldId = prescriptionData['fieldId'] as String? ?? '';
                
                print('🔧 Mark Complete Button Pressed (Header)');
                print('🔧 Current _isCompleted: $_isCompleted');
                print('🔧 Prescription ID: $prescriptionId');
                print('🔧 Field ID: $fieldId');
                
                if (prescriptionId.isNotEmpty && fieldId.isNotEmpty) {
                  // Update local state first for immediate UI feedback
                  setState(() {
                    _isCompleted = !_isCompleted;
                  });
                  
                  print('🔧 Updated _isCompleted to: $_isCompleted');
                  
                  // Store completion status locally
                  _storeCompletionStatus(prescriptionId, _isCompleted);
                  // Update completion status directly in SharedPreferences
                  print('🔧 DETAILED SCREEN: About to update completion status for $prescriptionId to $_isCompleted');
                  final prefs = await SharedPreferences.getInstance();
                  // Get user ID from authentication context
                  final authState = context.read<AuthenticationBloc>().state;
                  final userId = authState.user?.id ?? 'unknown';
                  final completionKey = 'completion_${userId}_$prescriptionId';
                  print('🔧 DETAILED SCREEN: Saving completion status with key: $completionKey, value: $_isCompleted');
                  await prefs.setBool(completionKey, _isCompleted);
                  print('🔧 DETAILED SCREEN: Completion status updated successfully with key: $completionKey');
                  
                  // Debug: Verify the save worked
                  final savedValue = prefs.getBool(completionKey);
                  print('🔧 DETAILED SCREEN: Verification - saved value for $completionKey: $savedValue');
                  
                  // Verify the status was saved
                  final savedStatus = prefs.getBool(completionKey) ?? false;
                  print('🔧 DETAILED SCREEN: Verified saved status for $prescriptionId: $savedStatus');
                  
                  // Get MongoDB prescription ID for backend update
                  final mongoId = await PrescriptionIdMapper.getMongoId(prescriptionId);
                  final backendPrescriptionId = mongoId ?? prescriptionId;
                  
                  // Then update backend
                  context.read<PrescriptionBloc>().add(
                    UpdatePrescriptionStatus(
                      fieldId: fieldId,
                      prescriptionId: backendPrescriptionId,
                      isCompleted: _isCompleted,
                    ),
                  );
                  
                  // Notify that completion status has changed
                  _notifyCompletionStatusChanged();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isCompleted ? S.current.marked_as_completed : S.current.marked_as_pending),
                    backgroundColor: _isCompleted ? Colors.green : Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.current.unable_to_update_prescription_status),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: Text(_isCompleted ? S.current.undo_complete : S.current.mark_complete, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildPrescriptionSection(prescriptionData, title, description, fieldName, soilType, growthStage, urgency, timeline, deadline, sendTime, urgencyColor),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionSection(Map<String, dynamic> prescriptionData, String title, String description, String fieldName, String soilType, String growthStage, String urgency, String timeline, String deadline, String sendTime, Color urgencyColor) {
    return Expanded(
      child: Container(
        color: MAIZE_PRIMARY_LIGHT,
      padding: EdgeInsets.all(kAppMediumPadding),
        child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Completion status indicator
          if (_isCompleted) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[600], size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'This prescription has been completed successfully!',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Text(
            title, 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              decoration: _isCompleted ? TextDecoration.lineThrough : null,
              color: _isCompleted ? Colors.green[700] : null,
            ),
          ),
          verticalSpace(kAppSmallGap),
              Row(children: [
                 Container(
                  padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding, vertical: kAppSmallPadding),
                  decoration: BoxDecoration(
                    color: MAIZE_ACCENT.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
            children: [
                      Icon(Icons.timelapse, color: MAIZE_ACCENT, size: 12.sp),
              SizedBox(width: kAppSmallGap),
                      Text(S.current.deadline_colon(deadline), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                SizedBox(width: kAppSmallGap),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding, vertical: kAppSmallPadding),
                decoration: BoxDecoration(
                    color: MAIZE_ACCENT.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.send, color: MAIZE_ACCENT, size: 12.sp),
                      SizedBox(width: kAppSmallGap),
                      Text(sendTime, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),               
                
               

              ],),
              verticalSpace(kAppMediumGap),
                           
              
              // Description
              _buildMenuItem(
                title: 'Description',
                subtitle: description,
                icon: Icons.description,
                isFullWidth: true,
              ),
              verticalSpace(kAppSmallGap),
                            
              
              // Field information
              Row(
                children: [
                  Expanded(
                    child: _buildMenuItem(
                      title: 'Growth Stage',
                      subtitle: growthStage,
                      icon: Icons.trending_up,
                    ),
                  ),
                  SizedBox(width: kAppSmallGap),
                  Expanded(
                    child: _buildMenuItem(
                      title: 'Soil Type',
                      subtitle: soilType,
                      icon: Icons.eco,
                    ),
                  ),
                ],
              ),
       verticalSpace(kAppSmallGap),

      // Detailed Instructions Dropdown
              if (prescriptionData['instructions'] != null && (prescriptionData['instructions'] as List).isNotEmpty) ...[
                _buildInstructionsDropdown(prescriptionData, urgencyColor),
                verticalSpace(kAppSmallGap),
              ],     
        ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionsDropdown(Map<String, dynamic> prescriptionData, Color urgencyColor) {
    final prescriptionId = prescriptionData['id'] as String? ?? '';
    final instructions = prescriptionData['instructions'] as List<dynamic>? ?? [];
    final isExpanded = _expandedInstructions[prescriptionId] ?? false;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedInstructions[prescriptionId] = !isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        splashColor: Colors.black.withOpacity(0.1),
        highlightColor: Colors.black.withOpacity(0.05),
        child: Container(
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Dropdown header
          InkWell(
            onTap: () {
              setState(() {
                _expandedInstructions[prescriptionId] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
            children: [
                  Icon(Icons.list_alt, color: MAIZE_ACCENT, size: 20.sp),
                  SizedBox(width: 8.w),
              Text(
                    'Step-by-Step Instructions (${instructions.length} steps)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MAIZE_ACCENT,
                  fontWeight: FontWeight.bold,
                ),
              ),
                  Spacer(),
              Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: MAIZE_ACCENT,
                size: 20.sp,
              ),
                ],
              ),
            ),
          ),
          // Dropdown content
          if (isExpanded) ...[
            Divider(height: 1, color: MAIZE_ACCENT),
            Container(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                  ...instructions.asMap().entries.map((entry) => 
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24.w,
                            height: 24.w,
                    decoration: BoxDecoration(
                              color: MAIZE_ACCENT,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                                '${entry.key + 1}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                          SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                              entry.value.toString(),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: MAIZE_ACCENT,
                        height: 1.4,
                                decoration: _isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),
                    ),
                  ).toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    )));
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isFullWidth = false,
    Widget? trailing,
  }) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding, vertical: kAppMediumPadding),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white),
      ),
      child: Row(
        mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: MAIZE_ACCENT.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30.r),
            ),
            child: Icon(
              icon,
              color: MAIZE_ACCENT,
                size: 20.sp,
              ),
          ),
          SizedBox(width: kAppSmallGap),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: MAIZE_ACCENT.withOpacity(0.8)),
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: kAppSmallGap),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: MAIZE_PRIMARY_LIGHT,
      padding: EdgeInsets.all(kAppMediumPadding),
      child: Row(
      children: [
          Expanded(
            child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: kAppMediumPadding),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
              ),
                side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text(
                'Back',
              style: TextStyle(
                  color: Colors.grey[600],
                fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: kAppSmallGap),
          Expanded(
            child: ElevatedButton(
                    onPressed: () async {
                      final Map<String, dynamic> prescriptionData =
                          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
                      final prescriptionId = prescriptionData['id'] as String? ?? '';
                      final fieldId = prescriptionData['fieldId'] as String? ?? '';
                      
                      print('🔧 Mark Complete Button Pressed (Bottom)');
                      print('🔧 Current _isCompleted: $_isCompleted');
                      print('🔧 Prescription ID: $prescriptionId');
                      print('🔧 Field ID: $fieldId');
                      
                      if (prescriptionId.isNotEmpty && fieldId.isNotEmpty) {
                        // Update local state first for immediate UI feedback
                        setState(() {
                          _isCompleted = !_isCompleted;
                        });
                        
                        print('🔧 Updated _isCompleted to: $_isCompleted');
                        
                        // Store completion status locally
                        _storeCompletionStatus(prescriptionId, _isCompleted);
                        // Update completion status directly in SharedPreferences
                        print('🔧 DETAILED SCREEN (BOTTOM): About to update completion status for $prescriptionId to $_isCompleted');
                        final prefs = await SharedPreferences.getInstance();
                        // Get user ID from authentication context
                        final authState = context.read<AuthenticationBloc>().state;
                        final userId = authState.user?.id ?? 'unknown';
                        final completionKey = 'completion_${userId}_$prescriptionId';
                        print('🔧 DETAILED SCREEN (BOTTOM): Saving completion status with key: $completionKey, value: $_isCompleted');
                        await prefs.setBool(completionKey, _isCompleted);
                        print('🔧 DETAILED SCREEN (BOTTOM): Completion status updated successfully with key: $completionKey');
                        
                        // Debug: Verify the save worked
                        final savedValue = prefs.getBool(completionKey);
                        print('🔧 DETAILED SCREEN (BOTTOM): Verification - saved value for $completionKey: $savedValue');
                        
                        // Verify the status was saved
                        final savedStatus = prefs.getBool(completionKey) ?? false;
                        print('🔧 DETAILED SCREEN (BOTTOM): Verified saved status for $prescriptionId: $savedStatus');
                        
                        // Get MongoDB prescription ID for backend update
                        final mongoId = await PrescriptionIdMapper.getMongoId(prescriptionId);
                        final backendPrescriptionId = mongoId ?? prescriptionId;
                        
                        // Then update backend
                        context.read<PrescriptionBloc>().add(
                          UpdatePrescriptionStatus(
                            fieldId: fieldId,
                            prescriptionId: backendPrescriptionId,
                            isCompleted: _isCompleted,
                          ),
                        );
                        
                        // Notify that completion status has changed
                        _notifyCompletionStatusChanged();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isCompleted ? S.current.marked_as_completed : S.current.marked_as_pending),
                    backgroundColor: _isCompleted ? Colors.green : Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(S.current.unable_to_update_prescription_status),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isCompleted ? Colors.green : MAIZE_PRIMARY,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: kAppMediumPadding),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isCompleted ? Icons.check_circle : Icons.check_circle_outline,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _isCompleted ? 'Completed' : 'Mark Complete',
              style: TextStyle(
                fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to format send time
  String _formatSendTime(DateTime? timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final now = DateTime.now();
      final difference = now.difference(timestamp);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${timestamp.day}/${timestamp.month}';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  // Helper method to calculate deadline
  String _calculateDeadline(String timeline, String urgency) {
    final now = DateTime.now();
    
    // Parse timeline to determine deadline
    final lowerTimeline = timeline.toLowerCase();
    
    if (lowerTimeline == 'today') {
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59);
      final hoursLeft = endOfDay.difference(now).inHours;
      if (hoursLeft <= 0) return 'Overdue';
      return '${hoursLeft}h left';
    } else if (lowerTimeline.contains('this week')) {
      final endOfWeek = now.add(Duration(days: 7 - now.weekday));
      final daysLeft = endOfWeek.difference(now).inDays;
      if (daysLeft <= 0) return 'Overdue';
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('next') && lowerTimeline.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final days = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(days: days));
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) return 'Overdue';
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('week')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final weeks = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(days: weeks * 7));
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) return 'Overdue';
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final hours = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(hours: hours));
      final hoursLeft = deadline.difference(now).inHours;
      if (hoursLeft <= 0) return 'Overdue';
      return '${hoursLeft}h left';
    }
    
    // Default fallback
    return timeline;
  }


  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return Colors.red[600]!;
      case 'HIGH':
        return Colors.orange[600]!;
      case 'MEDIUM':
        return MAIZE_PRIMARY;
      case 'LOW':
        return Colors.green[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}
