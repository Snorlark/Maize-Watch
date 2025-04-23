import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:maize_watch/custom/constants.dart';
import 'package:maize_watch/custom/custom_font.dart';

class UserInfoWidget extends StatefulWidget {
  final String userName;
  final String name;
  final String contactNumber;
  final String address;
  final Function(Map<String, String>) onUpdate;

  const UserInfoWidget({
    super.key,
    required this.userName,
    required this.name,
    required this.contactNumber,
    required this.address,
    required this.onUpdate,
  });

  @override
  State<UserInfoWidget> createState() => _UserInfoWidgetState();
}

class _UserInfoWidgetState extends State<UserInfoWidget> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomFont(
                text: widget.userName,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: MAIZE_ACCENT,
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.black54),
                onPressed: _showEditOverlay,
              ),
            ],
          ),
          const SizedBox(height: 10),
          buildUserInfo(title: "Name", value: widget.name),
          buildUserInfo(title: "Contact No.", value: widget.contactNumber),
          buildUserInfo(title: "Address", value: widget.address),
        ],
      ),
    );
  }

  buildUserInfo({required String title, required String value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontFamily: 'Montserrat',
          ),
          children: [
            TextSpan(
              text: "$title : ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  _showEditOverlay() {
    final nameController = TextEditingController(text: widget.name);
    final contactController = TextEditingController(text: widget.contactNumber);
    final addressController = TextEditingController(text: widget.address);
    final userNameController = TextEditingController(text: widget.userName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: MAIZE_BOTTOM_OVERLAY,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 30,
          right: 30,
          top: 40,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomFont(
                  text: 'Username', 
                  fontWeight: FontWeight.w500, 
                  color: MAIZE_ACCENT, 
                  fontSize: 16,
                ),
                TextFormField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    filled:  true,
                    fillColor: MAIZE_PRIMARY_LIGHT,     
                    focusColor: MAIZE_ACCENT,
                    hoverColor: MAIZE_ACCENT,             
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ScreenUtil().setHeight(12)),
                const CustomFont(
                  text: 'Full Name', 
                  fontWeight: FontWeight.w500, 
                  color: MAIZE_ACCENT, 
                  fontSize: 16,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    filled:  true,
                    fillColor: MAIZE_PRIMARY_LIGHT,     
                    focusColor: MAIZE_ACCENT,
                    hoverColor: MAIZE_ACCENT, 
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ScreenUtil().setHeight(12)),
                const CustomFont(
                  text: 'Contact Number', 
                  fontWeight: FontWeight.w500, 
                  color: MAIZE_ACCENT, 
                  fontSize: 16,
                ),
                TextFormField(
                  controller: contactController,
                  decoration: const InputDecoration(
                    filled:  true,
                    fillColor: MAIZE_PRIMARY_LIGHT,     
                    focusColor: MAIZE_ACCENT,
                    hoverColor: MAIZE_ACCENT, 
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter contact number';
                    }
                    if (!RegExp(r'^\+[0-9]{1,3} [0-9]{3} [0-9]{3,4} [0-9]{3,4}$')
                        .hasMatch(value)) {
                      return 'Invalid format. Example: +639 023 2311 321';
                    }
                    return null;
                  },
                ),
                SizedBox(height: ScreenUtil().setHeight(12)),
                const CustomFont(
                  text: 'Address', 
                  fontWeight: FontWeight.w500, 
                  color: MAIZE_ACCENT, 
                  fontSize: 16,
                ),
                TextFormField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    filled:  true,
                    fillColor: MAIZE_PRIMARY_LIGHT,     
                    focusColor: MAIZE_ACCENT,
                    hoverColor: MAIZE_ACCENT, 
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: MAIZE_PRIMARY_LIGHT,
                    backgroundColor: MAIZE_ACCENT,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onUpdate({
                        'userName': userNameController.text,
                        'name': nameController.text,
                        'contactNumber': contactController.text,
                        'address': addressController.text,
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const CustomFont(
                    text: 'Save Changes',
                    fontWeight: FontWeight.w500, 
                    color: MAIZE_PRIMARY_LIGHT, 
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}