// lib/presentation/pages/register/register_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/colors.dart';
import '../../../../generated/l10n.dart';
import '../../../../core/constants/philippine_regions.dart';
import '../../../../core/constants/address_data.dart';
import '../utils/ui_form_validators.dart';

class RegisterFormPage extends StatefulWidget {
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
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  // Track selected values for cascading dropdowns
  String? selectedRegion;
  String? selectedProvince;
  String? selectedMunicipality;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children:
              widget.pageIndex == 0
                  ? _buildPersonalInfoFields(context)
                  : _buildCredentialsFields(context),
        ),
      ),
    );
  }

  List<Widget> _buildPersonalInfoFields(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return [
      Text(
        S.of(context).register_page1_title,
        style: textTheme.headlineMedium?.copyWith(
          fontSize: 35.sp,
          height: 1,
          letterSpacing: 0,
        ),
      ),
      SizedBox(height: 10.h),
      Text(
        S.of(context).register_page1_description,
        style: textTheme.bodySmall,
      ),
      SizedBox(height: 30.h),

      // Using Clean Architecture validators
      _buildInputField(
        S.of(context).first_name,
        'Juan',
        widget.controllers.firstNameController,
        validator: UIFormValidators.firstNameValidator(context),
      ),
      SizedBox(height: 20.h),
      _buildInputField(
        S.of(context).last_name,
        'Dela Cruz',
        widget.controllers.lastNameController,
        validator: UIFormValidators.lastNameValidator(context),
      ),
      SizedBox(height: 20.h),
      _buildInputField(
        S.of(context).contact_number,
        '9123456789',
        widget.controllers.contactController,
        showPHPrefix: true,
        validator: UIFormValidators.contactNumberValidator(context),
      ),
      SizedBox(height: 20.h),
      // Region Dropdown
      _buildResponsiveDropdownField(
        S.of(context).region,
        S.of(context).select_region,
        widget.controllers.regionController,
        PhilippineRegions.regions,
        validator: UIFormValidators.regionValidator(context),
        onChanged: (value) {
          setState(() {
            selectedRegion = value;
            selectedProvince = null;
            selectedMunicipality = null;
            widget.controllers.provinceController.clear();
            widget.controllers.municipalityController.clear();
            widget.controllers.barangayController.clear();
          });
        },
      ),
      SizedBox(height: 20.h),

      // Province Field - Only show if region is selected
      if (selectedRegion != null) ...[
        _buildResponsiveDropdownField(
          S.of(context).province,
          S.of(context).select_province,
          widget.controllers.provinceController,
          AddressData.getProvincesForRegion(selectedRegion!),
          validator: UIFormValidators.provinceValidator(context),
          onChanged: (value) {
            setState(() {
              selectedProvince = value;
              selectedMunicipality = null;
              widget.controllers.municipalityController.clear();
              widget.controllers.barangayController.clear();
            });
          },
        ),
        SizedBox(height: 20.h),
      ],

      // Municipality Field - Only show if province is selected
      if (selectedProvince != null) ...[
        _buildResponsiveDropdownField(
          S.of(context).municipality,
          S.of(context).select_municipality,
          widget.controllers.municipalityController,
          AddressData.getMunicipalitiesForProvince(selectedProvince!),
          validator: UIFormValidators.municipalityValidator(context),
          onChanged: (value) {
            setState(() {
              selectedMunicipality = value;
              widget.controllers.barangayController.clear();
            });
          },
        ),
        SizedBox(height: 20.h),
      ],

      // Barangay Field - Only show if municipality is selected
      if (selectedMunicipality != null) ...[
        _buildInputField(
          S.of(context).barangay,
          S.of(context).enter_barangay,
          widget.controllers.barangayController,
          validator: UIFormValidators.barangayValidator(context),
        ),
        SizedBox(height: 20.h),
      ],
    ];
  }

  List<Widget> _buildCredentialsFields(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return [
      Text(
        S.of(context).register_page2_title +
            widget.controllers.firstNameController.text,
        style: textTheme.headlineMedium?.copyWith(
          fontSize: 35.sp,
          height: 1,
          letterSpacing: 0,
        ),
      ),
      SizedBox(height: 10.h),
      Text(
        S.of(context).register_page2_description,
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w300),
      ),
      SizedBox(height: 20.h),
      _buildInputField(
        S.of(context).username,
        '@',
        widget.controllers.usernameController,
        validator: UIFormValidators.usernameValidator(context),
      ),
      SizedBox(height: 20.h),
      _buildPasswordField(
        S.of(context).password,
        widget.controllers.passwordController,
        true,
      ),
      SizedBox(height: 20.h),
      _buildPasswordField(
        S.of(context).confirm_password,
        widget.controllers.confirmPasswordController,
        false,
      ),
    ];
  }

  Widget _buildInputField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isMultiline = false,
    bool showPHPrefix = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyLarge?.copyWith(fontSize: 16.sp)),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          maxLines: isMultiline ? 3 : 1,
          keyboardType: showPHPrefix ? TextInputType.phone : keyboardType,
          style: textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: MAIZE_PRIMARY_LIGHT,
            hintStyle: TextStyle(
              color: const Color.fromARGB(122, 43, 70, 37),
              fontSize: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
            errorMaxLines: 2,
            prefixIcon:
                showPHPrefix
                    ? Padding(
                      padding: const EdgeInsets.only(left: 10.0, top: 1.5),
                      child: Text(
                        '+63',
                        style: textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                      ),
                    )
                    : null,
            prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField(
    String label,
    TextEditingController controller,
    bool isPasswordField,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyLarge?.copyWith(fontSize: 16.sp)),
        SizedBox(height: 5.h),
        TextFormField(
          controller: controller,
          obscureText:
              isPasswordField ? !isPasswordVisible : !isConfirmPasswordVisible,
          style: textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
          decoration: InputDecoration(
            filled: true,
            fillColor: MAIZE_PRIMARY_LIGHT,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
            errorMaxLines: 2,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordField
                    ? (isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off)
                    : (isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off),
                color: Color(0xFF72AB50),
              ),
              onPressed: () {
                setState(() {
                  if (isPasswordField) {
                    isPasswordVisible = !isPasswordVisible;
                  } else {
                    isConfirmPasswordVisible = !isConfirmPasswordVisible;
                  }
                });
              },
            ),
          ),
          validator:
              isPasswordField
                  ? UIFormValidators.passwordValidator(context)
                  : (String? value) {
                    // Get the current password value when validation runs
                    return UIFormValidators.confirmPasswordValidator(
                      context,
                      widget.controllers.passwordController.text,
                    )(value);
                  },
        ),
      ],
    );
  }

  Widget _buildResponsiveDropdownField(
    String label,
    String hint,
    TextEditingController controller,
    List<String> options, {
    String? Function(String?)? validator,
    Function(String?)? onChanged,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: textTheme.bodyLarge?.copyWith(fontSize: 16.sp)),
        SizedBox(height: 5.h),
        DropdownButtonFormField<String>(
          value: controller.text.isEmpty ? null : controller.text,
          isExpanded: true, // Prevent overflow
          menuMaxHeight: 300.h, // Limit dropdown height
          dropdownColor: Colors.white,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: MAIZE_PRIMARY_LIGHT,
            hintStyle: TextStyle(
              color: const Color.fromARGB(122, 43, 70, 37),
              fontSize: 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
            ),
            errorStyle: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.red.shade700,
            ),
            errorMaxLines: 2,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
          ),
          items:
              options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      option,
                      style: textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.text = newValue;
              if (onChanged != null) {
                onChanged(newValue);
              }
            }
          },
          validator: validator,
        ),
      ],
    );
  }
}

class RegisterControllers {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final contactController = TextEditingController();

  // Structured address controllers
  final regionController = TextEditingController();
  final provinceController = TextEditingController();
  final municipalityController = TextEditingController();
  final barangayController = TextEditingController();

  // Legacy address controller (kept for backward compatibility)
  final addressController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    contactController.dispose();
    regionController.dispose();
    provinceController.dispose();
    municipalityController.dispose();
    barangayController.dispose();

    addressController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Helper method to get structured address object
  Map<String, dynamic> getAddressObject() {
    return {
      'region': regionController.text.trim(),
      'province': provinceController.text.trim(),
      'municipality': municipalityController.text.trim(),
      'barangay': barangayController.text.trim(),
    };
  }
}
