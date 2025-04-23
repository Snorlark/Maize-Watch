import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ For date parsing and sorting
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/services/prescription_list.dart';
import '../widget/prescription_widget.dart';

class PrescriptionScreen extends StatefulWidget {
  const PrescriptionScreen({super.key});

  @override
  _PrescriptionScreenState createState() => _PrescriptionScreenState();
}

class _PrescriptionScreenState extends State<PrescriptionScreen> {
  String selectedFilter = 'View All';
  List<Map<String, dynamic>> filteredPrescriptions = [];

  @override
  void initState() {
    super.initState();
    filteredPrescriptions = List.from(PrescriptionList);
  }

  void filterPrescriptions(String filterBy) {
  List<Map<String, dynamic>> tempList = List.from(PrescriptionList);

  // First apply status filter if needed
  if (filterBy == 'Done') {
    tempList = tempList.where((prescription) => prescription["isChecked"] == true).toList();
  } else if (filterBy == 'Not Yet Done') {
    tempList = tempList.where((prescription) => prescription["isChecked"] == false).toList();
  }

  // Then apply sorting if needed
  if (filterBy == 'Newest' || filterBy == 'Oldest') {
    tempList.sort((a, b) {
      DateTime dateA = DateFormat("dd/MM/yyyy").parse(a["date"]);
      DateTime dateB = DateFormat("dd/MM/yyyy").parse(b["date"]);
      return filterBy == 'Newest' ? dateB.compareTo(dateA) : dateA.compareTo(dateB);
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
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/GRADIENT.png'),
            fit: BoxFit.cover,
          ),
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
                      setState(() {
                        selectedFilter = newValue;
                        filterPrescriptions(newValue);
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              Flexible(
                fit: FlexFit.loose,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredPrescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = filteredPrescriptions[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 15),
                      child: PrescriptionWidget(
                        title: prescription["title"],
                        value: prescription["value"],
                        date: prescription["date"],
                        time: prescription["time"],
                        isChecked: prescription["isChecked"], 
                        onChecked: (bool value) {
                          // Find and update the original prescription
                          final originalIndex = PrescriptionList.indexWhere((p) => 
                              p["title"] == prescription["title"] &&
                              p["date"] == prescription["date"] &&
                              p["time"] == prescription["time"]);
                          
                          if (originalIndex != -1) {
                            setState(() {
                              PrescriptionList[originalIndex]["isChecked"] = value;
                              filterPrescriptions(selectedFilter); // Refresh the list
                            });
                          }
                        },
                      ),
                    );
                  },
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
