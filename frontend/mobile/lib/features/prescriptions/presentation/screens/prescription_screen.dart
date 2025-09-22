import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/features/prescriptions/presentation/widgets/prescription_filter_chip.dart';
import 'package:mobile/features/live_monitoring/presentation/bloc/monitoring_bloc.dart';
import 'package:mobile/features/farm/presentation/bloc/farm_bloc.dart';

import '../../../../generated/l10n.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  String _selectedFilter = 'all';
  final _scrollController = ScrollController();
  bool _showScrollToTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load analytics data instead of prescription API
    _loadAnalyticsData();
  }

  void _loadAnalyticsData() {
    final farmState = context.read<FarmBloc>().state;
    if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
      final farmId = farmState.farms.first.id ?? '';
      context.read<MonitoringBloc>().add(LoadFarmAnalyticsEvent(farmId: farmId));
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 200) {
      if (!_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = true);
      }
    } else {
      if (_showScrollToTopButton) {
        setState(() => _showScrollToTopButton = false);
      }
    }
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _onRefresh() {
    _loadAnalyticsData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = S.of(context);

    return Scaffold(
      backgroundColor: MAIZE_PRIMARY_LIGHT,
      extendBodyBehindAppBar: true,

      body: BlocBuilder<MonitoringBloc, MonitoringState>(
        builder: (context, monitoringState) {
          if (monitoringState.isLoading && monitoringState.farmAnalytics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: MAIZE_ACCENT),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading farm tasks...',
                    style: theme.textTheme.bodyLarge?.copyWith(color: MAIZE_ACCENT),
          ),
        ],
      ),
            );
          }

          // Convert analytics data to prescription format
          final prescriptions = _convertAnalyticsToPrescriptions(monitoringState.farmAnalytics);
          final filteredPrescriptions = _filterPrescriptions(prescriptions, _selectedFilter);

          return RefreshIndicator(
            onRefresh: () async => _onRefresh(),
            color: MAIZE_ACCENT,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Header section with user info and filters
                  _buildHeaderSection(theme, l10n, filteredPrescriptions.length, context),

                  verticalSpace(kAppSmallGap),
                  // Main content area
                  Container(

                    margin: EdgeInsets.only(top: kAppSmallPadding),
                    padding: EdgeInsets.only(
                      left: kAppMediumPadding, 
                      right: kAppMediumPadding, 
                      top: kAppMediumPadding, 
                      bottom: kAppLargePadding,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Filter chips
                        _buildFilterChips(theme),
                        SizedBox(height: kAppLargeGap),
                        
                        // Prescription cards
                        if (filteredPrescriptions.isNotEmpty)
                          _buildPrescriptionCards(context, filteredPrescriptions)
                        else
                          _buildEmptyState(theme, l10n),
                      ],
                    ),
                  ),
              ],
              ),
            ),
          );
        },
      ),
      floatingActionButton:
          _showScrollToTopButton
              ? FloatingActionButton(
                onPressed: () {
                  _scrollController.animateTo(
                    0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
                child: const Icon(Icons.arrow_upward),
              )
              : null,
    );
  }

  Widget _buildHeaderSection(
    ThemeData theme,
    S l10n,
    int prescriptionCount,
    BuildContext context,
  ) {
    return Container(
      height: 240.h,
      padding: EdgeInsets.all(kAppMediumPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.r),
          bottomRight: Radius.circular(20.r),
        ),
        image: const DecorationImage(
          image: AssetImage('assets/images/background-prescription.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Spacer(),
          // Title and task count
          Text(
            'Farm Tasks & Recommendations',
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),

          verticalSpace(5.h),
          Text(
            l10n.prescriptions_subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
          ),
                    SizedBox(height: 16.h),
          
          // Task summary cards
          _buildTaskSummaryCards(theme, prescriptionCount),
        ],
      ),
    );
  }


  Widget _buildTaskSummaryCards(ThemeData theme, int prescriptionCount) {
    return Row(
      children: [
        _buildSummaryCard(
          'Total Tasks',
          '$prescriptionCount',
          Icons.assignment,
          MAIZE_ACCENT,
        ),
        SizedBox(width: kAppSmallGap),
        _buildSummaryCard(
          'Urgent',
          '${_getUrgentCount()}',
          Icons.priority_high,
          Colors.red,
        ),
        SizedBox(width: kAppSmallGap),
        _buildSummaryCard(
          'Today',
          '${_getTodayCount()}',
          Icons.today,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: MAIZE_ACCENT.withOpacity(0.4),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MAIZE_PRIMARY_LIGHT.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20.sp),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25.r),
      ),
              child: Row(
                children: [
          Expanded(
            child: PrescriptionFilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'all',
                    onSelected: () => _onFilterChanged('all'),
                  ),
          ),
          Expanded(
            child: PrescriptionFilterChip(
              label: 'Pending',
              isSelected: _selectedFilter == 'pending',
              onSelected: () => _onFilterChanged('pending'),
            ),
          ),
          Expanded(
            child: PrescriptionFilterChip(
              label: 'Urgent',
              isSelected: _selectedFilter == 'urgent',
              onSelected: () => _onFilterChanged('urgent'),
            ),
                  ),
                ],
              ),
    );
  }

  Widget _buildPrescriptionCards(BuildContext context, List<Map<String, dynamic>> prescriptions) {
    return Column(
      children: prescriptions.map((prescription) => 
        Padding(
          padding: EdgeInsets.only(bottom: kAppSmallGap),
          child: _buildModernPrescriptionCard(context, prescription, prescriptions.indexOf(prescription)),
        ),
      ).toList(),
    );
  }

  Widget _buildEmptyState(ThemeData theme, S l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64.sp,
            color: theme.hintColor,
          ),
          SizedBox(height: 16.h),
          Text(
            _getEmptyStateMessage(_selectedFilter, l10n),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getUrgentCount() {
    // This would be calculated from the actual prescriptions
    return 0; // Placeholder
  }

  int _getTodayCount() {
    // This would be calculated from the actual prescriptions
    return 0; // Placeholder
  }


  String _getEmptyStateMessage(String filter, S l10n) {
    switch (filter) {
      case 'pending':
        return 'No pending tasks found';
      case 'urgent':
        return 'No urgent tasks found';
      case 'all':
      default:
        return 'No farm tasks available';
    }
  }


  // Convert analytics data to prescription format
  List<Map<String, dynamic>> _convertAnalyticsToPrescriptions(Map<String, dynamic>? analyticsData) {
    if (analyticsData == null || analyticsData['prescriptive'] == null) {
      return [];
    }

    final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
    final recommendations = prescriptive['recommendations'] as List<dynamic>? ?? [];
    
    return recommendations.map((rec) {
      final recMap = rec as Map<String, dynamic>;
      return {
        'id': 'analytics_${DateTime.now().millisecondsSinceEpoch}_${recommendations.indexOf(rec)}',
        'title': recMap['action'] ?? 'Farm Task',
        'description': recMap['details'] ?? 'Follow recommended actions',
        'category': recMap['category'] ?? 'general',
        'urgency': recMap['urgency'] ?? 'MEDIUM',
        'timeline': recMap['timeline'] ?? 'Today',
        'parameter': recMap['parameter'] ?? 'general',
        'fieldName': 'Main Field', // Will be updated with real field data
        'soilType': 'Loam', // Will be updated with real soil data
        'growthStage': 'V8', // Will be updated with real growth stage
        'priority': _mapUrgencyToPriority(recMap['urgency'] ?? 'MEDIUM'),
        'status': 'pending',
        'dueDate': _calculateDueDate(recMap['timeline'] ?? 'Today'),
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      };
    }).toList();
  }

  String _mapUrgencyToPriority(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return 'high';
      case 'HIGH':
        return 'high';
      case 'MEDIUM':
        return 'medium';
      case 'LOW':
        return 'low';
      default:
        return 'medium';
    }
  }

  DateTime _calculateDueDate(String timeline) {
    final now = DateTime.now();
    switch (timeline.toLowerCase()) {
      case 'today':
        return now.add(const Duration(hours: 2));
      case 'this week':
        return now.add(const Duration(days: 3));
      case 'next week':
        return now.add(const Duration(days: 7));
      default:
        return now.add(const Duration(days: 1));
    }
  }

  List<Map<String, dynamic>> _filterPrescriptions(
    List<Map<String, dynamic>> prescriptions,
    String filter,
  ) {
    switch (filter) {
      case 'pending':
        return prescriptions.where((p) => p['status'] == 'pending').toList();
      case 'completed':
        return prescriptions.where((p) => p['status'] == 'completed').toList();
      case 'urgent':
        return prescriptions.where((p) => p['urgency'] == 'URGENT' || p['urgency'] == 'HIGH').toList();
      default:
        return prescriptions;
    }
  }

  // Simple prescription card - farmer-friendly design
  Widget _buildModernPrescriptionCard(BuildContext context, Map<String, dynamic> prescription, int index) {
    final urgency = prescription['urgency'] as String;
    final category = prescription['category'] as String;
    final urgencyColor = _getUrgencyColor(urgency);
    final isCompleted = prescription['isCompleted'] as bool? ?? false;
    
    return GestureDetector(
      onTap: () => _navigateToDetailScreen(context, prescription),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.green[50] 
              : urgencyColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted 
                ? Colors.green[300]! 
                : urgencyColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: urgencyColor.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Functional checkbox
            GestureDetector(
              onTap: () => _togglePrescriptionCompletion(prescription),
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isCompleted ? Colors.green : urgencyColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                  color: isCompleted ? Colors.green : Colors.transparent,
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16.sp,
                      )
                    : null,
              ),
            ),
            SizedBox(width: 16.w),
            // Main content with better spacing
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title with urgency badge
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          prescription['title'] as String,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: isCompleted ? Colors.green[700] : Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      // Urgency badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: urgencyColor,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          urgency,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Description
                  Text(
                    prescription['description'] as String,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isCompleted ? Colors.grey[500] : Colors.grey[600],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  // Category and timeline
                  Row(
                    children: [
                      Icon(
                        _getCategoryIcon(category),
                        size: 14.sp,
                        color: _getCategoryColor(category),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _getCategoryColor(category),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.schedule,
                        size: 14.sp,
                        color: MAIZE_ACCENT,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        prescription['timeline'] as String? ?? 'Today',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: MAIZE_ACCENT,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            // Pressable indicator - arrow
            Icon(
              Icons.arrow_forward_ios,
              color: urgencyColor,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _togglePrescriptionCompletion(Map<String, dynamic> prescription) {
    setState(() {
      prescription['isCompleted'] = !(prescription['isCompleted'] as bool? ?? false);
      prescription['status'] = prescription['isCompleted'] ? 'completed' : 'pending';
    });
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

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'irrigation':
        return Colors.blue[600]!;
      case 'fertilization':
        return Colors.green[600]!;
      case 'weather':
        return Colors.cyan[600]!;
      case 'monitoring':
        return Colors.purple[600]!;
      case 'humidity_control':
        return Colors.teal[600]!;
      case 'temperature_control':
        return Colors.red[400]!;
      case 'general':
        return MAIZE_ACCENT;
      default:
        return Colors.orange[600]!;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'irrigation':
        return Icons.water_drop;
      case 'fertilization':
        return Icons.eco;
      case 'weather':
        return Icons.wb_sunny;
      case 'monitoring':
        return Icons.monitor;
      case 'humidity_control':
        return Icons.opacity;
      case 'temperature_control':
        return Icons.thermostat;
      case 'general':
        return Icons.assignment;
      default:
        return Icons.agriculture;
    }
  }

  void _navigateToDetailScreen(BuildContext context, Map<String, dynamic> prescription) {
    Navigator.pushNamed(
      context,
      '/detailed-prescription',
      arguments: prescription,
    );
  }
}
