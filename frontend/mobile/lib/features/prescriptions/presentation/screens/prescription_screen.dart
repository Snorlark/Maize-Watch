import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/constants/app_spacing.dart';
// import 'package:mobile/core/widgets/offline_indicator.dart';
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
  Map<String, bool> _filterOptions = {
    'urgency_urgent': false,
    'urgency_high': false,
    'urgency_medium': false,
    'urgency_low': false,
    'category_irrigation': false,
    'category_humidity_management': false,
    'category_soil_treatment': false,
    'category_temperature_management': false,
    'category_light_management': false,
    'timeline_today': false,
    'timeline_this_week': false,
    'timeline_next_week': false,
  };
  Map<String, bool> _expandedInstructions = {}; // Track which instructions are expanded

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
          
          return StatefulBuilder(
            builder: (context, setState) {
              // Re-filter prescriptions whenever the widget rebuilds
          final filteredPrescriptions = _filterPrescriptions(prescriptions, _selectedFilter);
              final activeFilters = _getActiveFilters();

              return Column(
                children: [
                  // Fixed header section
                  _buildHeaderSection(theme, l10n, filteredPrescriptions.length, context),
              // Scrollable content area
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(right: kAppMediumPadding, left: kAppMediumPadding, bottom: kAppLargePadding),                 
                    decoration: BoxDecoration(
                      color: MAIZE_PRIMARY_LIGHT,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Filter chips
                        _buildFilterChips(theme, filteredPrescriptions.length, setState),
                        
                        // Filter indicator
                        if (activeFilters.isNotEmpty) _buildFilterIndicator(activeFilters, setState),
                       
                      // Scrollable prescription cards
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async => _onRefresh(),
                          color: MAIZE_ACCENT,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
                            child: filteredPrescriptions.isNotEmpty
                                ? _buildPrescriptionCards(context, filteredPrescriptions)
                                : _buildEmptyState(theme, l10n),
                          ),
                    ),
                  ),
              ],
              ),
            ),
              ),
            ],
          );
            },
          );
        },
      ),
      floatingActionButton:
          _showScrollToTopButton
              ? FloatingActionButton(
                backgroundColor: MAIZE_PRIMARY,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
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
      height: 180.h,
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
          // Title and filter button
          Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
            'Farm Prescriptions',
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          SizedBox(height: 2.h),
          Text(
            'View and complete your farm prescriptions',
            style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
          ),
          ],),
          Spacer(),
          GestureDetector(
            onTap: () => _showFilterOptions(context, setState),
      child: Container(
              padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
              ),
          ],),
          SizedBox(height: kAppSmallGap),
          
           
          ],
      ),
    );
  }

  Widget _buildFilterChips(ThemeData theme, int prescriptionCount, StateSetter setState) {
    // Calculate counts for each filter
    final pendingCount = _getFilteredCount('pending');
    final urgentCount = _getFilteredCount('urgent');
    
    return Container(
      margin: EdgeInsets.symmetric(vertical: kAppSmallGap),
      decoration: BoxDecoration(
        color: MAIZE_PRIMARY.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40.r),
      ),
              child: Row(
                children: [
          Expanded(
            child: PrescriptionFilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'all',
              onSelected: () {
                setState(() {
                  _selectedFilter = 'all';
                });
              },
              badgeCount: prescriptionCount,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: PrescriptionFilterChip(
              label: 'Pending',
              isSelected: _selectedFilter == 'pending',
              onSelected: () {
                setState(() {
                  _selectedFilter = 'pending';
                });
              },
              badgeCount: pendingCount,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: PrescriptionFilterChip(
              label: 'Urgent',
              isSelected: _selectedFilter == 'urgent',
              onSelected: () {
                setState(() {
                  _selectedFilter = 'urgent';
                });
              },
              badgeCount: urgentCount,
            ),
                  ),
                ],
              ),
    );
  }

  int _getFilteredCount(String filter) {
    final monitoringState = context.read<MonitoringBloc>().state;
    final prescriptions = _convertAnalyticsToPrescriptions(monitoringState.farmAnalytics);
    final filteredPrescriptions = _filterPrescriptions(prescriptions, filter);
    return filteredPrescriptions.length;
  }

  List<String> _getActiveFilters() {
    return _filterOptions.entries
        .where((entry) => entry.value)
        .map((e) => e.key)
        .toList();
  }

  Widget _buildFilterIndicator(List<String> activeFilters, StateSetter setState) {
    return Container(
      margin: EdgeInsets.only(top: kAppSmallGap, bottom: kAppSmallGap),
      padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding, vertical: kAppSmallPadding),
      decoration: BoxDecoration(
        color: MAIZE_ACCENT.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: MAIZE_ACCENT.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: MAIZE_ACCENT,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Filtered by: ${_formatActiveFilters(activeFilters)}',
              style: TextStyle(
                color: MAIZE_ACCENT,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _filterOptions.updateAll((key, value) => false);
              });
            },
            child: Icon(
              Icons.close,
              color: MAIZE_ACCENT,
              size: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  String _formatActiveFilters(List<String> activeFilters) {
    if (activeFilters.isEmpty) return 'None';
    
    final List<String> formattedFilters = [];
    
    for (final filter in activeFilters) {
      if (filter.startsWith('urgency_')) {
        final urgency = filter.split('_')[1].toUpperCase();
        formattedFilters.add('Urgency: $urgency');
      } else if (filter.startsWith('category_')) {
        final category = filter.split('_')[1].replaceAll('_', ' ').toUpperCase();
        formattedFilters.add('Category: $category');
      } else if (filter.startsWith('timeline_')) {
        final timeline = filter.split('_')[1].replaceAll('_', ' ').toUpperCase();
        formattedFilters.add('Timeline: $timeline');
      }
    }
    
    return formattedFilters.join(', ');
  }

  Map<String, List<Map<String, dynamic>>> _groupPrescriptionsByDate(List<Map<String, dynamic>> prescriptions) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (final prescription in prescriptions) {
      final createdAt = prescription['createdAt'] as DateTime;
      final dateKey = _formatDateKey(createdAt);
      
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(prescription);
    }
    
    // Sort by date (most recent first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    return Map.fromEntries(sortedEntries);
  }

  String _formatDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Widget _buildDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final prescriptionDate = DateTime(date.year, date.month, date.day);
    
    String dayText;
    String dateText;
    
    // Calculate the difference in days
    final daysDifference = today.difference(prescriptionDate).inDays;
    
    if (prescriptionDate == today) {
      dayText = 'Today';
      dateText = _formatDate(date);
    } else if (prescriptionDate == yesterday) {
      dayText = 'Yesterday';
      dateText = _formatDate(date);
    } else if (daysDifference <= 7) {
      dayText = 'This week';
      dateText = _formatDate(date);
    } else if (daysDifference <= 14) {
      dayText = 'Last week';
      dateText = _formatDate(date);
    } else if (daysDifference <= 30) {
      dayText = 'This month';
      dateText = _formatDate(date);
    } else if (daysDifference <= 60) {
      dayText = 'Last month';
      dateText = _formatDate(date);
    } else {
      dayText = _getDayName(date.weekday);
      dateText = _formatDate(date);
    }
    
    return Padding(padding: EdgeInsets.symmetric(vertical: kAppSmallGap), child: 
    Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dayText,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: MAIZE_ACCENT,
            ),
          ),
          Text(
            dateText,
            style: TextStyle(
              fontSize: 14.sp,
              color: MAIZE_ACCENT.withOpacity(0.7),
            ),
          ),
        ],
      ));
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}${_getOrdinalSuffix(date.day)}';
  }

  String _getDayName(int weekday) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return days[weekday - 1];
  }

  String _getOrdinalSuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1: return 'st';
      case 2: return 'nd';
      case 3: return 'rd';
      default: return 'th';
    }
  }

  Widget _buildPrescriptionCards(BuildContext context, List<Map<String, dynamic>> prescriptions) {
    // Group prescriptions by date
    final groupedPrescriptions = _groupPrescriptionsByDate(prescriptions);
    
    return Column(
      children: groupedPrescriptions.entries.map((entry) {
        final date = entry.key;
        final prescriptionsForDate = entry.value;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date header
              _buildDateHeader(date),
              // Prescriptions for this date
              ...prescriptionsForDate.map((prescription) => 
        Padding(
                  padding: EdgeInsets.only(top: kAppSmallGap),
          child: _buildModernPrescriptionCard(context, prescription, prescriptions.indexOf(prescription)),
        ),
              ),
              SizedBox(height: 16.h),
            ],
        );
      }).toList(),
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
    
    // Parse the creation timestamp from analytics data
    DateTime createdAt;
    try {
      final timestampStr = prescriptive['created_timestamp'] as String?;
      if (timestampStr != null) {
        createdAt = DateTime.parse(timestampStr);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }
    
    return recommendations.map((rec) {
      final recMap = rec as Map<String, dynamic>;
      return {
        'id': 'analytics_${createdAt.millisecondsSinceEpoch}_${recommendations.indexOf(rec)}',
        'title': recMap['action'] ?? 'Farm Task',
        'description': recMap['details'] ?? 'Follow recommended actions',
        'category': recMap['category'] ?? 'general',
        'urgency': recMap['urgency'] ?? 'MEDIUM',
        'timeline': recMap['timeline'] ?? 'Today',
        'parameter': recMap['parameter'] ?? 'general',
        'fieldName': recMap['field_name'] ?? 'Unknown Field', // ✅ Use real field data
        'soilType': recMap['soil_type'] ?? 'Unknown', // ✅ Use real soil data
        'growthStage': recMap['growth_stage'] ?? 'Unknown', // ✅ Use real growth stage
        'fieldId': recMap['field_id'], // ✅ Include field ID
        'priority': _mapUrgencyToPriority(recMap['urgency'] ?? 'MEDIUM'),
        'status': 'pending',
        'dueDate': _calculateDueDate(recMap['timeline'] ?? 'Today'),
        'createdAt': createdAt, // ✅ Use actual creation timestamp from analytics
        'updatedAt': createdAt,
        // Add missing fields to match task card structure
        'time': _formatTimelineForDisplay(recMap['timeline'] ?? 'Today'),
        'color': _getUrgencyColor(recMap['urgency'] ?? 'MEDIUM'),
        'isActive': (recMap['urgency'] ?? 'MEDIUM').toUpperCase() == 'HIGH' || 
                   (recMap['urgency'] ?? 'MEDIUM').toUpperCase() == 'URGENT' || 
                   (recMap['urgency'] ?? 'MEDIUM').toUpperCase() == 'MEDIUM',
        'details': recMap['details'] ?? 'Follow recommended actions',
        'sendTime': _formatSendTime(recMap['created_timestamp'] as String?),
        'deadline': _calculateDeadline(recMap['timeline'] ?? 'Today', recMap['urgency'] ?? 'MEDIUM'),
        'instructions': recMap['instructions'] as List<dynamic>? ?? [],
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
    List<Map<String, dynamic>> filtered = prescriptions;
    
    // Apply basic filter first
    switch (filter) {
      case 'pending':
        filtered = filtered.where((p) => p['status'] == 'pending').toList();
        break;
      case 'completed':
        filtered = filtered.where((p) => p['status'] == 'completed').toList();
        break;
      case 'urgent':
        filtered = filtered.where((p) => p['urgency'] == 'URGENT' || p['urgency'] == 'HIGH').toList();
        break;
      default:
        // No basic filter applied
        break;
    }
    
    // Apply advanced filters
    final activeFilters = _filterOptions.entries.where((entry) => entry.value).map((e) => e.key).toList();
    
    if (activeFilters.isNotEmpty) {
      filtered = filtered.where((prescription) {
        return activeFilters.any((filterKey) {
          if (filterKey.startsWith('urgency_')) {
            final urgency = filterKey.split('_')[1].toUpperCase();
            return prescription['urgency'] == urgency;
          } else if (filterKey.startsWith('category_')) {
            final category = filterKey.split('_')[1];
            return prescription['category'] == category;
          } else if (filterKey.startsWith('timeline_')) {
            final timeline = filterKey.split('_')[1];
            final prescriptionTimeline = (prescription['timeline'] as String).toLowerCase();
            switch (timeline) {
              case 'today':
                return prescriptionTimeline == 'today';
              case 'this_week':
                return prescriptionTimeline == 'this week';
              case 'next_week':
                return prescriptionTimeline == 'next week';
              default:
                return false;
            }
          }
          return false;
        });
      }).toList();
    }
    
    return filtered;
  }

  // Simple prescription card - farmer-friendly design matching live monitoring task cards
  Widget _buildModernPrescriptionCard(BuildContext context, Map<String, dynamic> prescription, int index) {
    final urgency = prescription['urgency'] as String;
    final urgencyColor = _getUrgencyColor(urgency);
    final isCompleted = prescription['isCompleted'] as bool? ?? false;
    final fieldName = prescription['fieldName'] as String? ?? 'Unknown Field';
    final timeline = prescription['timeline'] as String? ?? 'Today';
    
    // Calculate deadline
    final deadline = _calculateDeadline(timeline, urgency);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
      onTap: () => _navigateToDetailScreen(context, prescription),
        borderRadius: BorderRadius.circular(16.r),
        splashColor: Colors.black.withOpacity(0.1),
        highlightColor: Colors.black.withOpacity(0.1),
      child: Container(
        width: double.infinity,
          padding: EdgeInsets.all(kAppMediumPadding),
        decoration: BoxDecoration(
          color: isCompleted 
              ? Colors.green[50] 
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.r),
          border:  Border.all(color: isCompleted ? Colors.green[50]! : Colors.white),
          ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
                children: [
                  
              
              // Task title with checkbox and clickable icon
              Row(children: [
                
                // Task title
                      Expanded(
                        child: Text(
                          prescription['title'] as String,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: isCompleted ? Colors.green[700] : MAIZE_ACCENT,
                            fontWeight: FontWeight.w600,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                          ),
                    maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                
                      SizedBox(width: 8.w),
                
                      // Urgency badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: urgencyColor,
                    borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                    urgency.toUpperCase(),
                    style: TextTheme.of(context).bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                      fontSize: 12.sp
                          ),
                        ),
                      ),
                
                
                                
              ]),
              
              SizedBox(height: 5.h),
              
                  // Description
                  Text(
                    prescription['description'] as String,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,                 
                      height: 1.3,
              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
              
              SizedBox(height: 12.h),
              
              // Field name and deadline row
                  Row(
                    children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding, vertical: kAppSmallPadding),
                    decoration: BoxDecoration(
                      color: MAIZE_ACCENT.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on, color: MAIZE_ACCENT, size: 12.sp),
                        horizontalSpace(8),
                        Flexible(
                          child: Text(
                            fieldName,
                            style: TextTheme.of(context).bodySmall?.copyWith(
                              color: MAIZE_ACCENT, 
                              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
                  
                   Container(
                    padding: EdgeInsets.symmetric(horizontal: kAppSmallPadding, vertical: kAppSmallPadding),
                    decoration: BoxDecoration(
                      color: MAIZE_ACCENT.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(Icons.timelapse, color: MAIZE_ACCENT, size: 12.sp),
                        horizontalSpace(8),
                        Flexible(
                          child: Text(
                            deadline,
                            style: TextTheme.of(context).bodySmall?.copyWith(
                          color: MAIZE_ACCENT,
                              decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                              fontWeight: FontWeight.bold,                                    
                        ),
                            overflow: TextOverflow.ellipsis,
                      ),
                  ),
                ],
              ),
            ),
                ],
              ),
              
              
            ]
          ),
        ),
      ),
    );
  }


  Color _getUrgencyColor(String urgency) {
    switch (urgency.toUpperCase()) {
      case 'URGENT':
        return Colors.red[700]!;
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


  void _navigateToDetailScreen(BuildContext context, Map<String, dynamic> prescription) {
    Navigator.pushNamed(
      context,
      '/detailed-prescription',
      arguments: prescription,
    );
  }


  Widget _buildFilterSection(String title, List<(String, String)> options, StateSetter setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: MAIZE_ACCENT,
          ),
        ),
        SizedBox(height: 8.h),
        ...options.map((option) => 
          CheckboxListTile(
            title: Text(
              option.$1,
              style: TextStyle(fontSize: 14.sp),
            ),
            value: _filterOptions[option.$2] ?? false,
            onChanged: (bool? value) {
              setState(() {
                _filterOptions[option.$2] = value ?? false;
              });
            },
            activeColor: MAIZE_ACCENT,
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  void _showFilterOptions(BuildContext context, StateSetter parentSetState) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Filter Prescriptions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: MAIZE_ACCENT,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Urgency filters
                    _buildFilterSection(
                      'Urgency',
                      [
                        ('URGENT', 'urgency_urgent'),
                        ('HIGH', 'urgency_high'),
                        ('MEDIUM', 'urgency_medium'),
                        ('LOW', 'urgency_low'),
                      ],
                      setState,
                    ),
                    SizedBox(height: 16.h),
                    // Category filters
                    _buildFilterSection(
                      'Category',
                      [
                        ('Irrigation', 'category_irrigation'),
                        ('Humidity Management', 'category_humidity_management'),
                        ('Soil Treatment', 'category_soil_treatment'),
                        ('Temperature Management', 'category_temperature_management'),
                        ('Light Management', 'category_light_management'),
                      ],
                      setState,
                    ),
                    SizedBox(height: 16.h),
                    // Timeline filters
                    _buildFilterSection(
                      'Timeline',
                      [
                        ('Today', 'timeline_today'),
                        ('This Week', 'timeline_this_week'),
                        ('Next Week', 'timeline_next_week'),
                      ],
                      setState,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _filterOptions.updateAll((key, value) => false);
                    });
                  },
                  child: Text(
                    'Clear All',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    parentSetState(() {
                      // Trigger rebuild to apply filters
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MAIZE_ACCENT,
                    foregroundColor: Colors.white,
                  ),
                  child: Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInstructionsDropdown(Map<String, dynamic> prescription, bool isCompleted) {
    final prescriptionId = prescription['id'] as String? ?? '';
    final instructions = prescription['instructions'] as List<dynamic>? ?? [];
    final isExpanded = _expandedInstructions[prescriptionId] ?? false;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue[200]!, width: 1),
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
            borderRadius: BorderRadius.circular(8.r),
            child: Container(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  Icon(Icons.list_alt, color: Colors.blue[700], size: 16.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Step-by-Step Instructions (${instructions.length} steps)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                  Spacer(),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.blue[700],
                    size: 16.sp,
                  ),
                ],
              ),
            ),
          ),
          // Dropdown content
          if (isExpanded) ...[
            Divider(height: 1, color: Colors.blue[200]),
            Container(
              padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...instructions.asMap().entries.map((entry) => 
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 20.w,
                            height: 20.w,
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.blue[800],
                                fontSize: 11.sp,
                                height: 1.4,
                                decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
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
    );
  }

  String _formatTimelineForDisplay(String timeline) {
    final lowerTimeline = timeline.toLowerCase();

    if (lowerTimeline == 'today') {
      return 'Now';
    } else if (lowerTimeline.contains('next') &&
        lowerTimeline.contains('1-2 days')) {
      return '1-2d';
    } else if (lowerTimeline.contains('next') &&
        lowerTimeline.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final days = match?.group(1) ?? '1';
      return '${days}d';
    } else if (lowerTimeline.contains('week')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final weeks = match?.group(1) ?? '1';
      return '${weeks}w';
    } else if (lowerTimeline.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final hours = match?.group(1) ?? '1';
      return '${hours}h';
    }

    return timeline.length > 8 ? '${timeline.substring(0, 8)}...' : timeline;
  }

  String _formatSendTime(String? timestamp) {
    if (timestamp == null) return 'Just now';
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${dateTime.day}/${dateTime.month}';
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
}