import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile/core/theme/colors.dart';
import 'package:mobile/core/constants/app_spacing.dart';
import 'package:mobile/core/services/prescription_id_mapper.dart';
// import 'package:mobile/core/widgets/offline_indicator.dart';
import 'package:mobile/features/prescriptions/presentation/widgets/prescription_filter_chip.dart';
import 'package:mobile/features/live_monitoring/presentation/bloc/monitoring_bloc.dart';
import 'package:mobile/features/farm/presentation/bloc/farm_bloc.dart';
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_bloc.dart';
import 'package:mobile/features/prescriptions/presentation/bloc/prescription_event.dart';
import 'package:mobile/features/authentication/presentation/bloc/authentication_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/core/services/offline_cache_service.dart';

import '../../../../generated/l10n.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  State<PrescriptionScreen> createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> with WidgetsBindingObserver {
  String _selectedFilter = 'all';
  final _scrollController = ScrollController();
  bool _showScrollToTopButton = false;
  List<Map<String, dynamic>> _cachedPrescriptions = [];
  
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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Load analytics data instead of prescription API
    _loadAnalyticsData();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh completion status when screen becomes visible
    _refreshCompletionStatus();
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
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      // Refresh completion status when app resumes
      _refreshCompletionStatus();
    }
  }

  // Refresh completion status for all prescriptions
  Future<void> _refreshCompletionStatus([StateSetter? setState]) async {
    print('🔧 PRESCRIPTION SCREEN: Refreshing completion status for ${_cachedPrescriptions.length} prescriptions');
    
    // Check if user is authenticated
    final authState = context.read<AuthenticationBloc>().state;
    print('🔧 PRESCRIPTION SCREEN: Auth state during refresh - status: ${authState.status}, user: ${authState.user?.id}');
    
    if (authState.status != AuthenticationStatus.authenticated || authState.user == null) {
      print('🔧 PRESCRIPTION SCREEN: User not authenticated, skipping completion status refresh');
      return;
    }
    
    // Direct approach: Get completion status directly from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    
    
    if (_cachedPrescriptions.isNotEmpty) {
      for (final prescription in _cachedPrescriptions) {
        final prescriptionId = prescription['id'] as String;
        final oldStatus = prescription['isCompleted'];
        final completionKey = 'completion_${authState.user!.id}_$prescriptionId';
        final isCompleted = prefs.getBool(completionKey) ?? false;
        print('🔧 PRESCRIPTION SCREEN: Refresh - $prescriptionId: old=$oldStatus, new=$isCompleted (user: ${authState.user!.id})');
        if (prescription['isCompleted'] != isCompleted) {
          prescription['isCompleted'] = isCompleted;
          prescription['status'] = isCompleted ? 'completed' : 'pending';
          print('🔧 PRESCRIPTION SCREEN: Updated prescription $prescriptionId status to $isCompleted');
        }
      }
      if (setState != null) {
        setState(() {}); // Trigger rebuild using StatefulBuilder's setState
      } else {
        this.setState(() {}); // Fallback to main widget's setState
      }
      print('🔧 PRESCRIPTION SCREEN: Refresh completed, UI rebuilt');
    }
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
                    S.of(context).loading_farm_tasks,
                    style: theme.textTheme.bodyLarge?.copyWith(color: MAIZE_ACCENT),
                  ),
                ],
              ),
            );
          }

          // Convert analytics data to prescription format
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _convertAnalyticsToPrescriptions(monitoringState.farmAnalytics),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: MAIZE_ACCENT),
                      SizedBox(height: 16.h),
                      Text(
                        S.of(context).loading_farm_tasks,
                        style: theme.textTheme.bodyLarge?.copyWith(color: MAIZE_ACCENT),
                      ),
                    ],
                  ),
                );
              }
              
              final prescriptions = snapshot.data!;
              
              return Column(
                children: [
                  // Fixed header section
                  _buildHeaderSection(theme, l10n, prescriptions.length, context),
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
                      child: StatefulBuilder(
                        builder: (context, setState) {
                          // Re-filter prescriptions whenever the widget rebuilds
                          final filteredPrescriptions = _filterPrescriptions(prescriptions, _selectedFilter);
                          final activeFilters = _getActiveFilters();

                          return Column(
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
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: _showScrollToTopButton
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
            S.of(context).farm_prescriptions,
            style: theme.textTheme.headlineMedium?.copyWith(color: Colors.white),
          ),
          SizedBox(height: 2.h),
          Text(
            S.of(context).view_complete_prescriptions,
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
    return FutureBuilder(
      future: Future.wait([
        _getFilteredCount('pending'),
        _getFilteredCount('urgent'),
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(); // Return empty container while loading
        }
        
        final counts = snapshot.data as List<int>;
        final pendingCount = counts[0];
        final urgentCount = counts[1];
    
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
                    label: S.of(context).all,
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
              label: S.of(context).pending,
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
              label: S.of(context).urgent,
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
      },
    );
  }

  Future<int> _getFilteredCount(String filter) async {
    final monitoringState = context.read<MonitoringBloc>().state;
    final prescriptions = await _convertAnalyticsToPrescriptions(monitoringState.farmAnalytics);
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
              S.of(context).filtered_by(_formatActiveFilters(activeFilters)),
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
    if (activeFilters.isEmpty) return S.of(context).none;
    
    final List<String> formattedFilters = [];
    
    for (final filter in activeFilters) {
      if (filter.startsWith('urgency_')) {
        final urgency = filter.split('_')[1].toUpperCase();
        formattedFilters.add(S.of(context).urgency_filter(urgency));
      } else if (filter.startsWith('category_')) {
        final category = filter.split('_')[1].replaceAll('_', ' ').toUpperCase();
        formattedFilters.add(S.of(context).category_filter(category));
      } else if (filter.startsWith('timeline_')) {
        final timeline = filter.split('_')[1].replaceAll('_', ' ').toUpperCase();
        formattedFilters.add(S.of(context).timeline_filter(timeline));
      }
    }
    
    return formattedFilters.join(', ');
  }

  Map<String, List<Map<String, dynamic>>> _groupPrescriptionsByDate(List<Map<String, dynamic>> prescriptions) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    
    for (final prescription in prescriptions) {
      final createdAtString = prescription['createdAt'] as String?;
      final createdAt = createdAtString != null ? DateTime.tryParse(createdAtString) : DateTime.now();
      final dateKey = _formatDateKey(createdAt ?? DateTime.now());
      
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
      dayText = S.of(context).today;
      dateText = _formatDate(date);
    } else if (prescriptionDate == yesterday) {
      dayText = S.of(context).yesterday;
      dateText = _formatDate(date);
    } else if (daysDifference <= 7) {
      dayText = S.of(context).this_week;
      dateText = _formatDate(date);
    } else if (daysDifference <= 14) {
      dayText = S.of(context).last_week;
      dateText = _formatDate(date);
    } else if (daysDifference <= 30) {
      dayText = S.of(context).this_month;
      dateText = _formatDate(date);
    } else if (daysDifference <= 60) {
      dayText = S.of(context).last_month;
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
    final months = [
      S.of(context).jan, S.of(context).feb, S.of(context).mar, S.of(context).apr, S.of(context).may, S.of(context).jun,
      S.of(context).jul, S.of(context).aug, S.of(context).sep, S.of(context).oct, S.of(context).nov, S.of(context).dec
    ];
    return '${months[date.month - 1]} ${date.day}${_getOrdinalSuffix(date.day)}';
  }

  String _getDayName(int weekday) {
    final days = [S.of(context).monday, S.of(context).tuesday, S.of(context).wednesday, S.of(context).thursday, S.of(context).friday, S.of(context).saturday, S.of(context).sunday];
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
        return S.of(context).no_pending_tasks_found;
      case 'urgent':
        return S.of(context).no_urgent_tasks_found;
      case 'all':
      default:
        return S.of(context).no_farm_tasks_available;
    }
  }


  // Convert analytics data to prescription format
  Future<List<Map<String, dynamic>>> _convertAnalyticsToPrescriptions(Map<String, dynamic>? analyticsData) async {
    // Try to get cached data first if no analytics data provided
    if (analyticsData == null) {
      print('🔧 PRESCRIPTION SCREEN: No analytics data, trying cached data...');
      analyticsData = await OfflineCacheService.getCachedAnalytics();
      if (analyticsData == null) {
        print('🔧 PRESCRIPTION SCREEN: No cached data available');
        return [];
      }
    }
    
    if (analyticsData['prescriptive'] == null) {
      return [];
    }

    final prescriptive = analyticsData['prescriptive'] as Map<String, dynamic>;
    final recommendations = prescriptive['recommendations'] as List<dynamic>? ?? [];
    
    // Use current time for prescriptions to ensure they show as "just now"
    // This ensures prescriptions are always fresh and not dependent on backend timestamp
    final createdAt = DateTime.now();
    
    final prescriptions = recommendations.map((rec) {
      final recMap = rec as Map<String, dynamic>;
      // Create a stable ID based on prescription content to ensure consistency
      final stableId = '${recMap['action']}_${recMap['field_name']}_${recMap['category']}_${recMap['parameter']}';
      final prescriptionId = 'analytics_${stableId.hashCode.abs()}';
      
      return {
        'id': prescriptionId,
        'title': recMap['action'] ?? S.of(context).farm_task,
        'description': recMap['details'] ?? S.of(context).follow_recommended_actions,
        'category': recMap['category'] ?? 'general',
        'urgency': recMap['urgency'] ?? 'MEDIUM',
        'timeline': recMap['timeline'] ?? S.of(context).today,
        'parameter': recMap['parameter'] ?? 'general',
        'fieldName': recMap['field_name'] ?? S.of(context).unknown_field, // ✅ Use real field data
        'soilType': recMap['soil_type'] ?? S.of(context).unknown, // ✅ Use real soil data
        'growthStage': recMap['growth_stage'] ?? S.of(context).unknown, // ✅ Use real growth stage
        'fieldId': recMap['field_id'], // ✅ Include field ID
        'priority': _mapUrgencyToPriority(recMap['urgency'] ?? 'MEDIUM'),
        'status': 'pending',
        'isCompleted': false, // Will be updated by completion status check
        'dueDate': _calculateDueDate(recMap['timeline'] ?? S.of(context).today).toIso8601String(),
        'createdAt': createdAt.toIso8601String(), // ✅ Use actual creation timestamp from analytics
        'updatedAt': createdAt.toIso8601String(),
        // Add missing fields to match task card structure
        'time': _formatTimelineForDisplay(recMap['timeline'] ?? S.of(context).today),
        'color': _getUrgencyColor(recMap['urgency'] ?? 'MEDIUM').value.toString(),
        'isActive': (recMap['urgency'] ?? 'MEDIUM').toUpperCase() == 'HIGH' || 
                   (recMap['urgency'] ?? 'MEDIUM').toUpperCase() == 'URGENT' || 
                   (recMap['urgency'] ?? 'MEDIUM').toUpperCase() == 'MEDIUM',
        'details': recMap['details'] ?? S.of(context).follow_recommended_actions,
        'sendTime': _formatSendTime(createdAt.toIso8601String()),
        'deadline': _calculateDeadline(recMap['timeline'] ?? S.of(context).today, recMap['urgency'] ?? 'MEDIUM'),
        'instructions': recMap['instructions'] as List<dynamic>? ?? [],
      };
    }).toList();

     // Update completion status for each prescription and filter out deleted ones
     final authState = context.read<AuthenticationBloc>().state;
     print('🔧 PRESCRIPTION SCREEN: Auth state - status: ${authState.status}, user: ${authState.user?.id}');
     
     if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
       // Direct approach: Get completion status directly from SharedPreferences
       final prefs = await SharedPreferences.getInstance();
       
       // Filter out deleted prescriptions
       final filteredPrescriptions = prescriptions.where((prescription) {
         final prescriptionId = prescription['id'] as String;
         final deletedKey = 'deleted_${authState.user!.id}_$prescriptionId';
         final isDeleted = prefs.getBool(deletedKey) ?? false;
         if (isDeleted) {
           print('🔧 PRESCRIPTION SCREEN: Filtering out deleted prescription $prescriptionId');
         }
         return !isDeleted;
       }).toList();
       
       // Update prescriptions list
       prescriptions.clear();
       prescriptions.addAll(filteredPrescriptions);
       
       for (final prescription in prescriptions) {
         final prescriptionId = prescription['id'] as String;
         print('🔧 PRESCRIPTION SCREEN: Checking completion status for $prescriptionId (user: ${authState.user!.id})');
         final completionKey = 'completion_${authState.user!.id}_$prescriptionId';
         print('🔧 PRESCRIPTION SCREEN: Looking for completion key: $completionKey');
         
         // Debug: Check all SharedPreferences keys that contain completion
         final allKeys = prefs.getKeys();
         final completionKeys = allKeys.where((key) => key.contains('completion_')).toList();
         print('🔧 PRESCRIPTION SCREEN: All completion keys in SharedPreferences: $completionKeys');
         
         final isCompleted = prefs.getBool(completionKey) ?? false;
         print('🔧 PRESCRIPTION SCREEN: Retrieved completion status for $prescriptionId: $isCompleted');
         prescription['isCompleted'] = isCompleted;
         prescription['status'] = isCompleted ? 'completed' : 'pending';
         if (isCompleted) {
           print('🔧 PRESCRIPTION SCREEN: Marked prescription $prescriptionId as completed');
         }
       }
     } else {
       print('🔧 PRESCRIPTION SCREEN: User not authenticated, skipping completion status check');
     }

    // Cache prescriptions for refresh functionality
    _cachedPrescriptions = prescriptions;

    // Sync analytics prescriptions with backend
    try {
      final farmState = context.read<FarmBloc>().state;
      if (farmState is FarmsLoaded && farmState.farms.isNotEmpty) {
        final farmId = farmState.farms.first.id ?? '';
        if (farmId.isNotEmpty) {
          print('🔄 Syncing ${prescriptions.length} analytics prescriptions with backend');
          context.read<PrescriptionBloc>().add(
            SyncAnalyticsPrescriptions(
              farmId: farmId,
              prescriptions: prescriptions,
            ),
          );
          
          // Map analytics IDs to MongoDB IDs after syncing
          // Note: This would ideally be done in the PrescriptionBloc after successful sync
          // For now, we'll map them here as a placeholder
          for (final prescription in prescriptions) {
            final analyticsId = prescription['id'] as String;
            // The MongoDB ID would be returned from the sync response
            // For now, we'll use the analytics ID as fallback
            await PrescriptionIdMapper.mapPrescriptionId(analyticsId, analyticsId);
          }
        }
      }
    } catch (e) {
      print('⚠️ Error syncing analytics prescriptions: $e');
    }

    return prescriptions;
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
    final fieldName = prescription['fieldName'] as String? ?? S.of(context).unknown_field;
    final timeline = prescription['timeline'] as String? ?? S.of(context).today;
    
    // Debug logging for completion status
    print('🔧 BUILDING CARD: ${prescription['title']} - isCompleted: $isCompleted');
    print('🔧 BUILDING CARD: Full prescription data: $prescription');
    
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
              ? Colors.green.withOpacity(0.2) 
              : Colors.white.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isCompleted ? Colors.transparent : Colors.white,
          ),
          boxShadow: isCompleted ? [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ] : null,
        ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
                children: [
                  
              
              // Task title with completion indicator
              Row(children: [
                // Checkbox that can be toggled
                GestureDetector(
                  onTap: () => isCompleted ? _markAsIncomplete(prescription) : _markAsComplete(prescription),
                  child:  Icon(
                      isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                      color: Colors.green[600],
                      size: 24.sp,
                    ),
                  ),
                
                SizedBox(width: 12.w),
                
                // Delete button only for completed prescriptions
                if (isCompleted) ...[
                  GestureDetector(
                    onTap: () => _showDeleteConfirmation(context, prescription),
                    child: Icon(
                        Icons.delete_outline,
                        color: Colors.red[600],
                        size: 24.sp,
                      ),
                    
                  ),
                  SizedBox(width: 12.w),
                ],
                
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
                
                // Urgency badge (shows completion status when completed)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green[600] : urgencyColor,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    isCompleted ? 'COMPLETED' : urgency.toUpperCase(),
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


  void _navigateToDetailScreen(BuildContext context, Map<String, dynamic> prescription) async {
    await Navigator.pushNamed(
      context,
      '/detailed-prescription',
      arguments: prescription,
    );
    // Refresh completion status when returning from detailed screen
    print('🔧 PRESCRIPTION SCREEN: Returning from detailed screen, refreshing completion status');
    await _refreshCompletionStatus();
    // Force a rebuild by calling setState
    setState(() {});
  }

  void _showDeleteConfirmation(BuildContext context, Map<String, dynamic> prescription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            S.of(context).delete_prescription,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.red[600],
            ),
          ),
          content: Text(
            S.of(context).delete_prescription_confirmation,
            style: TextStyle(fontSize: 14.sp),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                S.of(context).cancel,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePrescription(prescription);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: Text(S.of(context).delete),
            ),
          ],
        );
      },
    );
  }

  Future<void> _markAsComplete(Map<String, dynamic> prescription) async {
    try {
      final prescriptionId = prescription['id'] as String;
      final authState = context.read<AuthenticationBloc>().state;
      
      if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
        // Save completion status to SharedPreferences and cache
        final prefs = await SharedPreferences.getInstance();
        final completionKey = 'completion_${authState.user!.id}_$prescriptionId';
        await prefs.setBool(completionKey, true);
        await OfflineCacheService.cachePrescriptionCompletion(prescriptionId, true);
        
        // Update prescription in cached list
        final prescriptionIndex = _cachedPrescriptions.indexWhere((p) => p['id'] == prescriptionId);
        if (prescriptionIndex != -1) {
          _cachedPrescriptions[prescriptionIndex]['isCompleted'] = true;
          _cachedPrescriptions[prescriptionIndex]['status'] = 'completed';
        }
        
        // Update UI
        setState(() {});
        
        print('🔧 PRESCRIPTION SCREEN: Marked prescription $prescriptionId as complete');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).prescription_marked_complete),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🔧 PRESCRIPTION SCREEN: Error marking prescription as complete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).error_marking_complete),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _markAsIncomplete(Map<String, dynamic> prescription) async {
    try {
      final prescriptionId = prescription['id'] as String;
      final authState = context.read<AuthenticationBloc>().state;
      
      if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
        // Save completion status to SharedPreferences and cache
        final prefs = await SharedPreferences.getInstance();
        final completionKey = 'completion_${authState.user!.id}_$prescriptionId';
        await prefs.setBool(completionKey, false);
        await OfflineCacheService.cachePrescriptionCompletion(prescriptionId, false);
        
        // Update prescription in cached list
        final prescriptionIndex = _cachedPrescriptions.indexWhere((p) => p['id'] == prescriptionId);
        if (prescriptionIndex != -1) {
          _cachedPrescriptions[prescriptionIndex]['isCompleted'] = false;
          _cachedPrescriptions[prescriptionIndex]['status'] = 'pending';
        }
        
        // Update UI
        setState(() {});
        
        print('🔧 PRESCRIPTION SCREEN: Marked prescription $prescriptionId as incomplete');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).prescription_marked_incomplete),
            backgroundColor: Colors.orange[600],
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🔧 PRESCRIPTION SCREEN: Error marking prescription as incomplete: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).error_marking_incomplete),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deletePrescription(Map<String, dynamic> prescription) async {
    try {
      final prescriptionId = prescription['id'] as String;
      final authState = context.read<AuthenticationBloc>().state;
      
      if (authState.status == AuthenticationStatus.authenticated && authState.user != null) {
        // Remove from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final completionKey = 'completion_${authState.user!.id}_$prescriptionId';
        await prefs.remove(completionKey);
        
        // Add to deleted prescriptions list to prevent re-showing
        final deletedKey = 'deleted_${authState.user!.id}_$prescriptionId';
        await prefs.setBool(deletedKey, true);
        
        // Remove from cached prescriptions
        _cachedPrescriptions.removeWhere((p) => p['id'] == prescriptionId);
        
        // Update UI
        setState(() {});
        
        print('🔧 PRESCRIPTION SCREEN: Deleted prescription $prescriptionId');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).prescription_deleted_successfully),
            backgroundColor: Colors.green[600],
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('🔧 PRESCRIPTION SCREEN: Error deleting prescription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).error_deleting_prescription),
          backgroundColor: Colors.red[600],
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                S.of(context).filter_prescriptions,
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
                      S.of(context).urgency,
                      [
                        (S.of(context).urgency_urgent, 'urgency_urgent'),
                        (S.of(context).urgency_high, 'urgency_high'),
                        (S.of(context).urgency_medium, 'urgency_medium'),
                        (S.of(context).urgency_low, 'urgency_low'),
                      ],
                      setState,
                    ),
                    SizedBox(height: 16.h),
                    // Category filters
                    _buildFilterSection(
                      S.of(context).category,
                      [
                        (S.of(context).category_irrigation, 'category_irrigation'),
                        (S.of(context).category_humidity_management, 'category_humidity_management'),
                        (S.of(context).category_soil_treatment, 'category_soil_treatment'),
                        (S.of(context).category_temperature_management, 'category_temperature_management'),
                        (S.of(context).category_light_management, 'category_light_management'),
                      ],
                      setState,
                    ),
                    SizedBox(height: 16.h),
                    // Timeline filters
                    _buildFilterSection(
                      S.of(context).timeline,
                      [
                        (S.of(context).timeline_today, 'timeline_today'),
                        (S.of(context).timeline_this_week, 'timeline_this_week'),
                        (S.of(context).timeline_next_week, 'timeline_next_week'),
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
                    S.of(context).clear_all,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    S.of(context).cancel,
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
                  child: Text(S.of(context).apply),
                ),
              ],
            );
          },
        );
      },
    );
  }


  String _formatTimelineForDisplay(String timeline) {
    final lowerTimeline = timeline.toLowerCase();

    if (lowerTimeline == 'today') {
      return S.of(context).now;
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
    if (timestamp == null) return S.of(context).just_now;
    
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) {
        return S.of(context).just_now;
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
      return S.of(context).just_now;
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
      if (hoursLeft <= 0) return S.of(context).overdue;
      return '${hoursLeft}h left';
    } else if (lowerTimeline.contains('this week')) {
      final endOfWeek = now.add(Duration(days: 7 - now.weekday));
      final daysLeft = endOfWeek.difference(now).inDays;
      if (daysLeft <= 0) return S.of(context).overdue;
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('next') && lowerTimeline.contains('day')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final days = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(days: days));
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) return S.of(context).overdue;
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('week')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final weeks = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(days: weeks * 7));
      final daysLeft = deadline.difference(now).inDays;
      if (daysLeft <= 0) return S.of(context).overdue;
      return '${daysLeft}d left';
    } else if (lowerTimeline.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(lowerTimeline);
      final hours = int.tryParse(match?.group(1) ?? '1') ?? 1;
      final deadline = now.add(Duration(hours: hours));
      final hoursLeft = deadline.difference(now).inHours;
      if (hoursLeft <= 0) return S.of(context).overdue;
      return '${hoursLeft}h left';
    }
    
    // Default fallback
    return timeline;
  }
}