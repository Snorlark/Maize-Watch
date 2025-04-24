import 'package:flutter/material.dart';

class SensorStatusWidget extends StatefulWidget {
  bool isLDRSensorEnabled;
  bool isDHT11Enabled;
  bool isYL69Enabled;

  SensorStatusWidget({
    super.key,
    this.isLDRSensorEnabled = false,
    this.isDHT11Enabled = false,
    this.isYL69Enabled = false
  });

  @override
  State<SensorStatusWidget> createState() => _SensorStatusWidgetState();
}

class _SensorStatusWidgetState extends State<SensorStatusWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
              "Sensors",
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
                value: widget.isLDRSensorEnabled,
                onChanged: (bool value) {
                  setState(() {
                    widget.isLDRSensorEnabled = value;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Color(0xFF418036),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Color(0xFFC9C9C9),
              ),
              const SizedBox(width: 10),
              const Text(
                "Light Dependent Resistor Sensor",
                style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Other Sensors
          Row(
            children: [
              Switch(
                value: widget.isDHT11Enabled,
                onChanged: (bool value) {
                  setState(() {
                    widget.isDHT11Enabled = value;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Color(0xFF418036),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Color(0xFFC9C9C9),
              ),
              const SizedBox(width: 5),
              const Text("DHT11",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Switch(
                value: widget.isYL69Enabled,
                onChanged: (bool value) {
                  setState(() {
                    widget.isYL69Enabled = value;
                  });
                },
                activeColor: Colors.white,
                activeTrackColor: Color(0xFF418036),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Color(0xFFC9C9C9),
              ),
              const SizedBox(width: 5),
              const Text("YL-69",
                  style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}