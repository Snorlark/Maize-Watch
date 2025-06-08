import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_dialog.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widget/prescription_widget.dart';
import '../services/prescription_service.dart';
import '../model/prescription_model.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  String selectedFilter = 'View All';
  List<Prescription> prescriptions = [];
  List<Prescription> filteredPrescriptions = [];
  bool isLoading = true;
  String errorMessage = '';
  final PrescriptionService _prescriptionService = PrescriptionService();

  @override
  void initState() {
    super.initState();
    _loadPrescriptions();
  }

  

  // Load prescriptions from the service
  Future<void> _loadPrescriptions() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      print('🔍 Fetching prescriptions...');
      final result = await _prescriptionService.checkForNewPrescriptions(context);
      
      if (!result['success']) {
        setState(() {
          isLoading = false;
          errorMessage = result['message'] ?? 'Failed to load prescriptions';
        });
        return;
      }

      // Handle offline state
      if (result['isOffline'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Using cached data'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      final fetchedPrescriptions = await _prescriptionService.getAllPrescriptions(context);
      print('📋 Found ${fetchedPrescriptions.length} prescriptions in total');
      
      // Group prescriptions by parameter and severity
      Map<String, Prescription> latestPrescriptions = {};
      for (var prescription in fetchedPrescriptions) {
        String key = '${prescription.parameter}_${prescription.status}';
        if (!latestPrescriptions.containsKey(key) || 
            prescription.timestamp.isAfter(latestPrescriptions[key]!.timestamp)) {
          latestPrescriptions[key] = prescription;
        }
      }
      
      setState(() {
        this.prescriptions = latestPrescriptions.values.toList();
        isLoading = false;
      });

      // Apply the current filter
      filterPrescriptions(selectedFilter);
    } catch (e) {
      print('❗ Error loading prescriptions: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load prescriptions. Please try again.';
      });
    }
  }


  // Update prescription status (checked/unchecked)
  Future<void> _updatePrescriptionStatus(Prescription prescription, bool isChecked) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      print('🔄 Updating prescription ${prescription.id} to completed: $isChecked');
      
      final result = await _prescriptionService.updatePrescriptionStatus(
        prescription.fieldId,
        prescription.id,
        isChecked
      );

      if (result['success']) {
        // Update the local prescription list immediately
        setState(() {
          final index = prescriptions.indexWhere((p) => p.id == prescription.id);
          
          if (index != -1) {
            // Create a new prescription with updated status
            prescriptions[index] = Prescription(
              id: prescription.id,
              timestamp: prescription.timestamp,
              parameter: prescription.parameter,
              value: prescription.value,
              status: prescription.status,
              recommendation: prescription.recommendation,
              priority: prescription.priority,
              impactScore: prescription.impactScore,
              isCompleted: isChecked,
              fieldId: prescription.fieldId,
              growthStage: prescription.growthStage,
            );
            
            // Refresh the filtered list
            filterPrescriptions(selectedFilter);
            print('✅ Updated prescription status locally');
          }
        });
        
        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChecked 
              ? localizations.status_prescription_completed 
              : localizations.status_prescription_pending),
            backgroundColor: Colors.green,
          )
        );
      } else {
        // Show error toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? localizations.error_update_prescription),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      print('❗ Error updating prescription status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.error_update_prescription),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // Delete prescription
 Future<void> _deletePrescription(Prescription prescription) async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.dialog_delete_prescription),
          content: Text(localizations.dialog_delete_prescription_confirm(
            prescription.parameter.replaceAll('_', ' ').toLowerCase()
          )),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localizations.action_delete,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        setState(() {
          // Remove from both lists
          prescriptions.removeWhere((p) => p.id == prescription.id);
          filteredPrescriptions.removeWhere((p) => p.id == prescription.id);
        });

        // Update SharedPreferences
        await _prescriptionService.updateLocalStorageAfterDelete(prescription.id);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.status_prescription_deleted),
            backgroundColor: Colors.green,
          )
        );
        
        print('✅ Prescription ${prescription.id} deleted successfully');
      }
    } catch (e) {
      print('❗ Error deleting prescription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.error_delete_prescription),
          backgroundColor: Colors.red,
        )
      );
    }
  }

   void filterPrescriptions(String filterBy) {
    List<Prescription> tempList = List.from(prescriptions);

    // Apply status filter
    switch (filterBy) {
      case 'Done':
        tempList = tempList.where((prescription) => prescription.isCompleted).toList();
        break;
      case 'Not Yet Done':
        tempList = tempList.where((prescription) => !prescription.isCompleted).toList();
        break;
      case 'Newest First':
        // No filtering, just sorting
        break;
      case 'Oldest First':
        // No filtering, just sorting
        break;
      case 'View All':
      default:
        // No filtering
        break;
    }

    // Apply sorting
    switch (filterBy) {
      case 'Newest First':
        tempList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case 'Oldest First':
        tempList.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      default:
        // Default sorting: Priority first, then newest first
        tempList.sort((a, b) {
          int priorityComparison = a.priority.compareTo(b.priority);
          if (priorityComparison != 0) return priorityComparison;
          return b.timestamp.compareTo(a.timestamp); // Newest first for same priority
        });
        break;
    }

    setState(() {
      selectedFilter = filterBy;
      filteredPrescriptions = tempList;
    });
    
    print('🔍 Filtered prescriptions: ${tempList.length} items for filter: $filterBy');
  }

  // Handle bulk operations
  Future<void> _handleCheckAll(bool isChecked) async {
    try {
      // Only update non-completed prescriptions
      final prescriptionsToUpdate = prescriptions.where((p) => p.isCompleted != isChecked).toList();
      
      if (prescriptionsToUpdate.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isChecked ? 'All prescriptions are already completed' : 'All prescriptions are already pending'),
            backgroundColor: Colors.blue,
          )
        );
        return;
      }

      await _prescriptionService.updateAllPrescriptionsStatus(isChecked);
      await _loadPrescriptions(); // Reload to reflect changes
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isChecked ? 'All prescriptions marked as completed' : 'All prescriptions marked as pending'),
          backgroundColor: Colors.green,
        )
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating prescriptions: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> _handleDeleteCompleted() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.dialog_delete_completed_prescriptions),
          content: Text(localizations.dialog_delete_completed_prescriptions_confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localizations.action_delete,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _prescriptionService.deleteAllCompletedPrescriptions();
        await _loadPrescriptions(); // Reload to reflect changes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.status_all_completed_deleted),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.error_delete_prescriptions),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> _handleDeleteAll() async {
    final localizations = AppLocalizations.of(context)!;
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(localizations.dialog_delete_all_prescriptions),
          content: Text(localizations.dialog_delete_all_prescriptions_confirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(localizations.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                localizations.action_delete_all,
                style: TextStyle(color: Colors.red.shade900),
              ),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        await _prescriptionService.deleteAllPrescriptions();
        await _loadPrescriptions(); // Reload to reflect changes
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.status_all_deleted),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizations.error_delete_prescriptions),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Function() onPressed,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        textStyle: const TextStyle(fontSize: 12),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPrescriptions,
        child: Container(
          decoration: const BoxDecoration(
            color: MAIZE_BOTTOM_OVERLAY
          ),
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        CustomFont(
                          text: localizations.prescriptions_title,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 4),
                        CustomFont(
                          text: localizations.prescriptions_subtitle(prescriptions.length),
                          fontSize: 14,
                          color: MAIZE_PRIMARY,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadPrescriptions,
                      tooltip: localizations.tooltip_refresh_prescriptions,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filter dropdown and Check All button in a row
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Filter dropdown
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: PopupMenuButton<String>(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'View All',
                            child: Text(localizations.filter_view_all),
                          ),
                          PopupMenuItem(
                            value: 'Done',
                            child: Text(localizations.filter_done),
                          ),
                          PopupMenuItem(
                            value: 'Not Yet Done',
                            child: Text(localizations.filter_not_done),
                          ),
                          PopupMenuItem(
                            value: 'Newest First',
                            child: Text(localizations.filter_newest),
                          ),
                          PopupMenuItem(
                            value: 'Oldest First',
                            child: Text(localizations.filter_oldest),
                          ),
                        ],
                        onSelected: (value) => filterPrescriptions(value),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.sort, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                selectedFilter == 'View All' ? localizations.filter_view_all :
                                selectedFilter == 'Done' ? localizations.filter_done :
                                selectedFilter == 'Not Yet Done' ? localizations.filter_not_done :
                                selectedFilter == 'Newest First' ? localizations.filter_newest :
                                localizations.filter_oldest,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Action buttons in a row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Check All toggle button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final allChecked = prescriptions.every((p) => p.isCompleted);
                              _handleCheckAll(!allChecked);
                            },
                            icon: Icon(
                              prescriptions.every((p) => p.isCompleted) 
                                ? Icons.check_box 
                                : Icons.check_box_outline_blank,
                              size: 20,
                            ),
                            label: Text(
                              prescriptions.every((p) => p.isCompleted) 
                                ? localizations.action_uncheck_all 
                                : localizations.action_check_all,
                              overflow: TextOverflow.ellipsis,
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                        // Delete Checked button (only shown when some items are checked)
                        if (prescriptions.any((p) => p.isCompleted))
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: ElevatedButton.icon(
                              onPressed: _handleDeleteCompleted,
                              icon: const Icon(Icons.delete_sweep, size: 20),
                              label: Text(
                                localizations.action_delete_completed,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Prescriptions list
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : errorMessage.isNotEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    errorMessage.contains('log in') 
                                        ? Icons.login 
                                        : errorMessage.contains('register') 
                                            ? Icons.add_location_alt
                                            : Icons.error_outline,
                                    size: 64,
                                    color: errorMessage.contains('log in') || errorMessage.contains('register')
                                        ? Colors.blue.shade400
                                        : Colors.red.shade400,
                                  ),
                                  const SizedBox(height: 16),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 32),
                                    child: Text(
                                      errorMessage,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: errorMessage.contains('log in') || errorMessage.contains('register')
                                            ? Colors.blue.shade700
                                            : Colors.red.shade700,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  if (errorMessage.contains('log in'))
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Navigate to login screen
                                        Navigator.pushReplacementNamed(context, '/login');
                                      },
                                      icon: const Icon(Icons.login),
                                      label: const Text('Go to Login'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    )
                                  else if (errorMessage.contains('register'))
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        // Navigate to field registration screen
                                        Navigator.pushNamed(context, '/register-field');
                                      },
                                      icon: const Icon(Icons.add_location_alt),
                                      label: const Text('Register Field'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                        foregroundColor: Colors.white,
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      onPressed: _loadPrescriptions,
                                      child: Text(localizations.button_retry),
                                    ),
                                ],
                              ),
                            )
                          : filteredPrescriptions.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.medical_services_outlined, size: 64, color: Colors.grey.shade400),
                                      const SizedBox(height: 16),
                                      Text(
                                        selectedFilter == 'View All' 
                                          ? localizations.empty_no_prescriptions 
                                          : localizations.empty_no_prescriptions_filter(selectedFilter),
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: filteredPrescriptions.length,
                                  itemBuilder: (context, index) {
                                    final prescription = filteredPrescriptions[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: PrescriptionWidget(
                                        prescription: prescription,
                                        onStatusChanged: (isChecked) =>
                                            _updatePrescriptionStatus(prescription, isChecked),
                                        onDelete: prescription.isCompleted 
                                          ? () => _deletePrescription(prescription)
                                          : null,
                                      ),
                                    );
                                  },
                                ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Helper method to update local storage after deletion
