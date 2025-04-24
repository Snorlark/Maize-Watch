import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_font.dart';
import 'package:maize_watch/widget/sensor_status_widget.dart';

// ignore: must_be_immutable
class SettingsScreen extends StatefulWidget {
  
  bool isNotificationsEnabled;

  bool isHelpExpanded;
  bool isFAQsExpanded;

  SettingsScreen({
    super.key, 
    this.isNotificationsEnabled = false, 
    this.isHelpExpanded = false, 
    this.isFAQsExpanded = false
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/GRADIENT.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Settings",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/images/maize_watch_logo.png',
                    height: 50,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              SensorStatusWidget(),
              
              const SizedBox(height: 20),
              
              //Notification Container
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        "Notification",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                          value: widget.isNotificationsEnabled,
                          onChanged: (bool value) {
                            setState(() {
                              widget.isNotificationsEnabled = value;
                            });
                          },
                          activeColor: Colors.white,
                          activeTrackColor: Color(0xFF418036),
                          inactiveThumbColor: Colors.white,
                          inactiveTrackColor: Color(0xFFC9C9C9),
                        ),
                        const SizedBox(width: 10),
                        CustomFont(
                          text: "On",
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              buildExpandableSection("Help", widget.isHelpExpanded,
                  "Lorem ipsum dolor sit amet consectetur. Massa tincidunt sed mauris quam sed. Sagittis dolor facilisis tortor vitae tortor felis a rhoncus. \n\nFeugiat quam non cum eros. Nullam mattis sapien quam risus. \n\nAmet hac integer sodales. Sed vestibulum lorem nisi in turpis urna sit. Pellentesque pellentesque. ",
                  () {
                setState(() {
                  widget.isHelpExpanded = !widget.isHelpExpanded;
                });
              }),
              buildExpandableSection("FAQs", widget.isFAQsExpanded,
                  "Frequently asked questions and answers about the app.", () {
                setState(() {
                  widget.isFAQsExpanded = !widget.isFAQsExpanded;
                });
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildExpandableSection(
      String title, bool isExpanded, String content, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            ListTile(
              title: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up
                    : Icons.keyboard_arrow_down,
                size: 18,
                color: Colors.black54,
              ),
              onTap: onTap,
            ),
            if (isExpanded)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                child: Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Montserrat',
                    color: Colors.black87,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}