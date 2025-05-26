import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_dialog.dart';
import 'package:maize_watch/custom/custom_font.dart';
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
      final fetchedPrescriptions = await _prescriptionService.getAllPrescriptions(context);
      
      print('📋 Found ${fetchedPrescriptions.length} prescriptions in total');
      
      setState(() {
        this.prescriptions = fetchedPrescriptions;
        isLoading = false;
      });

      // Apply the current filter
      filterPrescriptions(selectedFilter);
    } catch (e) {
      print('❗ Error loading prescriptions: $e');
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load prescriptions: $e';
      });
    }
  }


  // Update prescription status (checked/unchecked)
  Future<void> _updatePrescriptionStatus(Prescription prescription, bool isChecked) async {
    try {
      print('🔄 Updating prescription ${prescription.id} to completed: $isChecked');
      
      final result = await _prescriptionService.updatePrescriptionStatus(
        prescription.fieldId, // Use fieldId as analysisId
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
              isCompleted: isChecked, // FIXED: Update the isCompleted flag
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
            content: Text(isChecked ? 'Prescription marked as completed' : 'Prescription marked as pending'),
            backgroundColor: Colors.green,
          )
        );
      } else {
        // Show error toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update status'),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      print('❗ Error updating prescription status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating prescription: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  // Delete prescription
 Future<void> _deletePrescription(Prescription prescription) async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Prescription'),
          content: Text('Are you sure you want to delete this ${prescription.parameter.replaceAll('_', ' ')} prescription?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
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
          const SnackBar(
            content: Text('Prescription deleted successfully'),
            backgroundColor: Colors.green,
          )
        );
        
        print('✅ Prescription ${prescription.id} deleted successfully');
      }
    } catch (e) {
      print('❗ Error deleting prescription: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting prescription: $e'),
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
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Completed Prescriptions'),
          content: const Text('Are you sure you want to delete all completed prescriptions?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete',
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
          const SnackBar(
            content: Text('All completed prescriptions deleted'),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting prescriptions: $e'),
          backgroundColor: Colors.red,
        )
      );
    }
  }

  Future<void> _handleDeleteAll() async {
    try {
      // Show confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete All Prescriptions'),
          content: const Text('Are you sure you want to delete ALL prescriptions? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Delete All',
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
          const SnackBar(
            content: Text('All prescriptions deleted'),
            backgroundColor: Colors.green,
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting prescriptions: $e'),
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
                          text: 'Prescriptions',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        const SizedBox(height: 4),
                        CustomFont(
                          text: 'Manage your prescriptions (${prescriptions.length} total)',
                          fontSize: 14,
                          color: MAIZE_PRIMARY,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _loadPrescriptions,
                      tooltip: 'Refresh prescriptions',
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Filter dropdown and Check All button in a row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Filter dropdown
                    Container(
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
                          const PopupMenuItem(
                            value: 'View All',
                            child: Text('View All'),
                          ),
                          const PopupMenuItem(
                            value: 'Done',
                            child: Text('Done'),
                          ),
                          const PopupMenuItem(
                            value: 'Not Yet Done',
                            child: Text('Not Yet Done'),
                          ),
                          const PopupMenuItem(
                            value: 'Newest First',
                            child: Text('Newest First'),
                          ),
                          const PopupMenuItem(
                            value: 'Oldest First',
                            child: Text('Oldest First'),
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
                                selectedFilter,
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Check All and Delete buttons in a column
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Check All toggle button
                        ElevatedButton.icon(
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
                              ? 'Uncheck All' 
                              : 'Check All',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                        ),
                        // Delete Checked button (only shown when some items are checked)
                        if (prescriptions.any((p) => p.isCompleted))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: ElevatedButton.icon(
                              onPressed: _handleDeleteCompleted,
                              icon: const Icon(Icons.delete_sweep, size: 20),
                              label: const Text('Delete'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                  Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
                                  const SizedBox(height: 16),
                                  Text(errorMessage, textAlign: TextAlign.center),
                                  const SizedBox(height: 16),
                                  ElevatedButton(
                                    onPressed: _loadPrescriptions,
                                    child: const Text('Retry'),
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
                                          ? 'No prescriptions found' 
                                          : 'No prescriptions found for "$selectedFilter"',
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
