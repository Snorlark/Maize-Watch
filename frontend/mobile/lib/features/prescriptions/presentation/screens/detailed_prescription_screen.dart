import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/theme/colors.dart';

class DetailedPrescriptionScreen extends StatefulWidget {
  const DetailedPrescriptionScreen({super.key});

  @override
  State<DetailedPrescriptionScreen> createState() => _DetailedPrescriptionScreenState();
}

class _DetailedPrescriptionScreenState extends State<DetailedPrescriptionScreen> {
  bool _isCompleted = false;
  Map<String, bool> _expandedInstructions = {}; // Track which instructions are expanded

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> prescriptionData =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};

    final String title = prescriptionData['title'] ?? 'Farm Prescription';
    final String description = prescriptionData['description'] ?? 'No details available';
    final String fieldName = prescriptionData['fieldName'] ?? 'Unknown Field';
    final String soilType = prescriptionData['soilType'] ?? 'Unknown';
    final String growthStage = prescriptionData['growthStage'] ?? 'Unknown';
    final String urgency = prescriptionData['urgency'] ?? 'MEDIUM';
    final String timeline = prescriptionData['timeline'] ?? 'Today';
    final DateTime? createdAt = prescriptionData['createdAt'] as DateTime?;

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
        title: Text(fieldName, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
        
        actions: [
          // Mark as completed toggle in header
          TextButton(
            onPressed: () {
              setState(() {
                _isCompleted = !_isCompleted;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isCompleted ? 'Marked as completed!' : 'Marked as pending'),
                  backgroundColor: _isCompleted ? Colors.green : Colors.orange,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              );
            },
            child: Text(_isCompleted ? 'Undo Complete' : 'Mark Complete', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
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
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
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
                      Text('Deadline: $deadline', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
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
            onPressed: () {
                setState(() {
                  _isCompleted = !_isCompleted;
                });
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isCompleted ? 'Marked as completed!' : 'Marked as pending'),
                    backgroundColor: _isCompleted ? Colors.green : Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                );
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
