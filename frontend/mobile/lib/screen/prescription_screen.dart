import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import '../widget/prescription_widget.dart';
import '../services/prescription_service.dart'; // Import the PrescriptionService

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  String selectedFilter = 'View All';
  List<Map<String, dynamic>> prescriptions = [];
  List<Map<String, dynamic>> filteredPrescriptions = [];
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

      // Get prescriptions from the service
      print('🔍 Fetching prescriptions...');
      final loadedPrescriptions = await _prescriptionService.getAllPrescriptions();
      
      // Debug log the prescriptions count and some details
      print('📋 Found ${loadedPrescriptions.length} prescriptions in total');
      if (loadedPrescriptions.isNotEmpty) {
        print('📝 First prescription: ${loadedPrescriptions[0]["title"]} (${loadedPrescriptions[0]["date"]})');
      } else {
        print('❌ No prescriptions found');
      }
      
      setState(() {
        prescriptions = loadedPrescriptions;
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
  Future<void> _updatePrescriptionStatus(
      Map<String, dynamic> prescription, bool isChecked) async {
    try {
      final result = await _prescriptionService.updatePrescriptionStatus(
        prescription['analysisId'],
        prescription['prescriptionId'],
        isChecked
      );

      if (result['success']) {
        // Update the local prescription list
        setState(() {
          final index = prescriptions.indexWhere((p) => 
              p['prescriptionId'] == prescription['prescriptionId'] && 
              p['analysisId'] == prescription['analysisId']);
          
          if (index != -1) {
            prescriptions[index]['isChecked'] = isChecked;
            filterPrescriptions(selectedFilter); // Refresh the filtered list
          }
        });
      } else {
        // Show error toast or snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update status'))
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating prescription: $e'))
      );
    }
  }

  void filterPrescriptions(String filterBy) {
    List<Map<String, dynamic>> tempList = List.from(prescriptions);

    // First apply status filter if needed
    if (filterBy == 'Done') {
      tempList = tempList.where((prescription) => prescription["isChecked"] == true).toList();
    } else if (filterBy == 'Not Yet Done') {
      tempList = tempList.where((prescription) => prescription["isChecked"] == false).toList();
    }

    // Then apply sorting if needed
    if (filterBy == 'Newest' || filterBy == 'Oldest') {
      tempList.sort((a, b) {
        // Parse the date strings to DateTime objects
        DateTime dateA = DateFormat("dd/MM/yyyy").parse(a["date"]);
        DateTime dateB = DateFormat("dd/MM/yyyy").parse(b["date"]);
        
        // Compare dates
        int dateComparison = filterBy == 'Newest' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
        
        // If dates are equal, compare times
        if (dateComparison == 0 && a["time"] != null && b["time"] != null) {
          DateTime timeA = DateFormat("HH:mm").parse(a["time"]);
          DateTime timeB = DateFormat("HH:mm").parse(b["time"]);
          return filterBy == 'Newest' ? timeB.compareTo(timeA) : timeA.compareTo(timeB);
        }
        
        return dateComparison;
      });
    }

    setState(() {
      selectedFilter = filterBy;
      filteredPrescriptions = tempList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadPrescriptions, // Pull to refresh functionality
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
                        CustomFont(
                          text: "Prescriptions",
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade900,
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                    Image.asset(
                      'assets/images/maize_watch_logo.png',
                      scale: 5.5,
                    ),
                  ],
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white54,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: DropdownButton<String>(
                    elevation: 0,
                    dropdownColor: MAIZE_PRIMARY_LIGHT,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.normal,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    value: selectedFilter,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.green),
                    underline: Container(),
                    items: <String>['View All', 'Newest', 'Oldest', 'Done', 'Not Yet Done']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: TextStyle(color: Colors.green.shade900)),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        filterPrescriptions(newValue);
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : errorMessage.isNotEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(errorMessage, 
                                style: TextStyle(color: Colors.red[700]),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _loadPrescriptions,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                ),
                                child: const Text('Retry', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        )
                      : filteredPrescriptions.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.article_outlined, size: 48, color: Colors.green[300]),
                                const SizedBox(height: 16),
                                Text(
                                  'No prescriptions found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.bold
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  selectedFilter != 'View All' 
                                    ? 'Try changing your filter' 
                                    : 'Pull down to refresh',
                                  style: TextStyle(color: Colors.green[700]),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: filteredPrescriptions.length,
                            itemBuilder: (context, index) {
                              final prescription = filteredPrescriptions[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 15),
                                child: PrescriptionWidget(
                                  title: prescription["title"] ?? 'Untitled',
                                  value: prescription["value"] ?? '',
                                  date: prescription["date"] ?? '',
                                  time: prescription["time"] ?? '',
                                  isChecked: prescription["isChecked"] ?? false,
                                  onChecked: (bool value) {
                                    _updatePrescriptionStatus(prescription, value);
                                  },
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