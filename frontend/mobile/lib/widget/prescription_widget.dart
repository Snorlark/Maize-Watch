import 'package:flutter/material.dart';
import 'package:maize_watch/custom/custom_font.dart';

class PrescriptionWidget extends StatefulWidget {
  final String title;
  final String value;
  final String date;
  final String time;
  final bool isChecked;
  final Function(bool) onChecked; // ✅ Callback for status update

  const PrescriptionWidget({
    super.key,
    required this.title,
    required this.value,
    required this.date,
    required this.time,
    required this.isChecked,
    required this.onChecked, // ✅ Required function
  });

  @override
  State<PrescriptionWidget> createState() => _PrescriptionWidgetState();
}

class _PrescriptionWidgetState extends State<PrescriptionWidget> {
  late bool isChecked;

  @override
  void initState() {
    super.initState();
    isChecked = widget.isChecked;
  }

  void toggleCheckbox(bool? value) {
    setState(() {
      isChecked = value ?? false;
    });
    widget.onChecked(isChecked); // ✅ Update parent state
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isChecked
            ? const Color.fromARGB(172, 178, 225, 173)
            : Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Transform.scale(
                    scale: 1.1, 
                    child: Checkbox(
                      activeColor: Colors.green,
                      value: isChecked,
                      onChanged: toggleCheckbox, // ✅ Calls function
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomFont(
                        text: widget.title,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        textDecoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: Colors.black,
                      ),
                      CustomFont(
                        text: '${widget.date} • ${widget.time}',
                        fontSize: 14,
                        color: const Color.fromARGB(255, 98, 98, 98),
                        textDecoration: isChecked
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ],
                  ),
                ],
              ),
              const Icon(Icons.delete, color: Colors.red),
            ],
          ),
          const SizedBox(height: 10),
          CustomFont(
            text: widget.value,
            fontSize: 15,
            fontWeight: FontWeight.normal,
            color: Colors.black,
            textDecoration: isChecked
                ? TextDecoration.lineThrough
                : TextDecoration.none,
          ),
        ],
      ),
    );
  }
}
