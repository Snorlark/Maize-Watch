import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../generated/l10n.dart';

class RegisterFormPage extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final RegisterControllers controllers;
  final int pageIndex;

  const RegisterFormPage({
    super.key,
    required this.formKey,
    required this.controllers,
    required this.pageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
              pageIndex == 0
                  ? _buildPersonalInfoFields(context)
                  : _buildCredentialsFields(context),
        ),
      ),
    );
  }

  List<Widget> _buildPersonalInfoFields(BuildContext context) {
    return [
      Text(
        S.of(context).field_name,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: MAIZE_ACCENT,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 32.h),
      _buildTextField(
        controller: controllers.firstNameController,
        label: S.of(context).first_name,
        icon: Icons.person,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).first_name_required;
          }
          if (value.trim().length < 2) {
            return 'First name must be at least 2 characters';
          }
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildTextField(
        controller: controllers.lastNameController,
        label: S.of(context).last_name,
        icon: Icons.person_outline,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).last_name_required;
          }
          if (value.trim().length < 2) {
            return 'Last name must be at least 2 characters';
          }
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildTextField(
        controller: controllers.contactController,
        label: S.of(context).contact_number,
        icon: Icons.phone,
        keyboardType: TextInputType.phone,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).contact_number_required;
          }
          if (value.trim().length < 10) {
            return 'Please enter a valid phone number';
          }
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildTextField(
        controller: controllers.addressController,
        label: S.of(context).address,
        icon: Icons.location_on,
        maxLines: 3,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).address_required;
          }
          if (value.trim().length < 10) {
            return 'Please provide a more detailed address';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildCredentialsFields(BuildContext context) {
    return [
      Text(
        S.of(context).register,
        style: TextStyle(
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: MAIZE_ACCENT,
        ),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 32.h),
      _buildTextField(
        controller: controllers.usernameController,
        label: S.of(context).username,
        icon: Icons.account_circle,
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return S.of(context).username_required;
          }
          if (value.trim().length < 4) {
            return 'Username must be at least 4 characters';
          }
          if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
            return 'Username can only contain letters, numbers, and underscores';
          }
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildTextField(
        controller: controllers.passwordController,
        label: S.of(context).password,
        icon: Icons.lock,
        isPassword: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return S.of(context).password_required;
          }
          if (value.length < 8) {
            return 'Password must be at least 8 characters';
          }
          if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
            return 'Password must contain uppercase, lowercase, and number';
          }
          return null;
        },
      ),
      SizedBox(height: 20.h),
      _buildTextField(
        controller: controllers.confirmPasswordController,
        label: S.of(context).confirm_password,
        icon: Icons.lock_outline,
        isPassword: true,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return S.of(context).password_required;
          }
          if (value != controllers.passwordController.text) {
            return S.of(context).passwords_dont_match;
          }
          return null;
        },
      ),
    ];
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool isPassword = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: isPassword,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: MAIZE_ACCENT),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: MAIZE_ACCENT, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}

class RegisterControllers {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactController = TextEditingController();
  final addressController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }
}
