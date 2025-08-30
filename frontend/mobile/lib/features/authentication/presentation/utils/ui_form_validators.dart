import 'package:flutter/material.dart';
import '../../../../generated/l10n.dart';
import '../../domain/validators/form_validators.dart';
import '../../domain/validators/validation_result.dart';

class UIFormValidators {
  /// Converts domain validation result to UI string
  static String? _convertValidationResult(
    ValidationResult result,
    BuildContext context,
  ) {
    if (result.isValid) return null;

    // Map error keys to localized strings
    switch (result.errorKey) {
      case 'first_name_required':
        return S.of(context).first_name_required;
      case 'first_name_too_short':
        return S.of(context).first_name_too_short;
      case 'first_name_too_long':
        return S.of(context).first_name_too_long;
      case 'first_name_invalid_characters':
        return S.of(context).first_name_invalid_characters;
      case 'first_name_invalid_format':
        return S.of(context).first_name_invalid_format;
      case 'first_name_consecutive_special':
        return S.of(context).first_name_consecutive_special;

      // Last name errors
      case 'last_name_required':
        return S.of(context).last_name_required;
      case 'last_name_too_short':
        return S.of(context).last_name_too_short;
      case 'last_name_too_long':
        return S.of(context).last_name_too_long;
      case 'last_name_invalid_characters':
        return S.of(context).last_name_invalid_characters;
      case 'last_name_invalid_format':
        return S.of(context).last_name_invalid_format;
      case 'last_name_consecutive_special':
        return S.of(context).last_name_consecutive_special;

      // Contact number errors
      case 'contact_number_required':
        return S.of(context).contact_number_required;
      case 'contact_number_invalid_length':
        return S.of(context).contact_number_invalid_length;
      case 'contact_number_invalid_format':
        return S.of(context).contact_number_invalid_format;
      case 'contact_number_invalid_prefix':
        return S.of(context).contact_number_invalid_prefix;

      // Address errors
      case 'address_required':
        return S.of(context).address_required;
      case 'address_too_short':
        return S.of(context).address_too_short;
      case 'address_too_long':
        return S.of(context).address_too_long;
      case 'address_invalid_characters':
        return S.of(context).address_invalid_characters;
      case 'address_needs_alphanumeric':
        return S.of(context).address_needs_alphanumeric;

      // Structured address errors
      case 'region_required':
        return 'Region is required';
      case 'province_required':
        return 'Province is required';
      case 'province_too_long':
        return 'Province name cannot exceed 50 characters';
      case 'municipality_required':
        return 'Municipality is required';
      case 'municipality_too_long':
        return 'Municipality name cannot exceed 50 characters';
      case 'barangay_required':
        return 'Barangay is required';
      case 'barangay_too_long':
        return 'Barangay name cannot exceed 50 characters';

      // Username errors
      case 'username_required':
        return S.of(context).username_required;
      case 'username_too_short':
        return S.of(context).username_too_short;
      case 'username_too_long':
        return S.of(context).username_too_long;
      case 'username_invalid_characters':
        return S.of(context).username_invalid_characters;
      case 'username_invalid_start':
        return S.of(context).username_invalid_start;
      case 'username_invalid_end':
        return S.of(context).username_invalid_end;
      case 'username_consecutive_special':
        return S.of(context).username_consecutive_special;

      // Password errors
      case 'password_required':
        return S.of(context).password_required;
      case 'password_too_short':
        return S.of(context).password_too_short;
      case 'password_too_long':
        return S.of(context).password_too_long;
      case 'password_needs_uppercase':
        return S.of(context).password_needs_uppercase;
      case 'password_needs_lowercase':
        return S.of(context).password_needs_lowercase;
      case 'password_needs_number':
        return S.of(context).password_needs_number;
      case 'password_needs_special':
        return S.of(context).password_needs_special;
      case 'password_too_common':
        return S.of(context).password_too_common;

      case 'confirm_password_required':
        return S.of(context).confirm_password_required;
      case 'passwords_dont_match':
        return S.of(context).passwords_dont_match;

      default:
        return 'Validation error'; // Fallback
    }
  }

  // UI validator factory functions
  static String? Function(String?) firstNameValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateFirstName(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) lastNameValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateLastName(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) contactNumberValidator(
    BuildContext context,
  ) {
    return (String? value) {
      final result = FormValidators.validateContactNumber(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) addressValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateAddress(value);
      return _convertValidationResult(result, context);
    };
  }

  // Structured address validators
  static String? Function(String?) regionValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateRegion(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) provinceValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateProvince(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) municipalityValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateMunicipality(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) barangayValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateBarangay(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) usernameValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validateUsername(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) passwordValidator(BuildContext context) {
    return (String? value) {
      final result = FormValidators.validatePassword(value);
      return _convertValidationResult(result, context);
    };
  }

  static String? Function(String?) confirmPasswordValidator(
    BuildContext context,
    String? originalPassword,
  ) {
    return (String? value) {
      final result = FormValidators.validateConfirmPassword(
        value,
        originalPassword,
      );
      return _convertValidationResult(result, context);
    };
  }
}
