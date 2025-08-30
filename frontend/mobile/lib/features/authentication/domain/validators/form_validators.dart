import 'validation_result.dart';

abstract class FormValidators {
  // Business rule validation (no UI
  static ValidationResult validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('first_name_required');
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return ValidationResult.error('first_name_too_short');
    }

    if (trimmedValue.length > 50) {
      return ValidationResult.error('first_name_too_long');
    }

    if (!RegExp(
      r"^[a-zA-ZñÑáéíóúÁÉÍÓÚàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛ\s\-'\.]+$",
    ).hasMatch(trimmedValue)) {
      return ValidationResult.error('first_name_invalid_characters');
    }

    if (RegExp(r"^[\s\-'\.]+|[\s\-'\.]+$").hasMatch(trimmedValue)) {
      return ValidationResult.error('first_name_invalid_format');
    }

    if (RegExp(r"[\s\-'\.]{2,}").hasMatch(trimmedValue)) {
      return ValidationResult.error('first_name_consecutive_special');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateLastName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('last_name_required');
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 2) {
      return ValidationResult.error('last_name_too_short');
    }

    if (trimmedValue.length > 50) {
      return ValidationResult.error('last_name_too_long');
    }

    if (!RegExp(
      r"^[a-zA-ZñÑáéíóúÁÉÍÓÚàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛ\s\-'\.]+$",
    ).hasMatch(trimmedValue)) {
      return ValidationResult.error('last_name_invalid_characters');
    }

    if (RegExp(r"^[\s\-'\.]+|[\s\-'\.]+$").hasMatch(trimmedValue)) {
      return ValidationResult.error('last_name_invalid_format');
    }

    if (RegExp(r"[\s\-'\.]{2,}").hasMatch(trimmedValue)) {
      return ValidationResult.error('last_name_consecutive_special');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateContactNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('contact_number_required');
    }

    final trimmed = value.trim().replaceAll(RegExp(r'\D'), '');

    // Accept both 10-digit (9xxxxxxxxx) and 11-digit (09xxxxxxxxx) formats
    if (trimmed.length == 10 && trimmed.startsWith('9')) {
      // Will be converted to 09xxxxxxxxx format for backend
    } else if (trimmed.length == 11 && trimmed.startsWith('09')) {
      // Already in correct format for backend
    } else {
      return ValidationResult.error('contact_number_invalid_format');
    }

    // For validation, check the actual 10 digits (remove leading 0 if present)
    final numberToValidate =
        trimmed.startsWith('09') ? trimmed.substring(1) : trimmed;

    if (numberToValidate.length != 10 || !numberToValidate.startsWith('9')) {
      return ValidationResult.error('contact_number_invalid_format');
    }

    final validPrefixes = [
      '905',
      '906',
      '915',
      '916',
      '917',
      '918',
      '919',
      '920',
      '921',
      '922',
      '923',
      '924',
      '925',
      '926',
      '927',
      '928',
      '929',
      '930',
      '931',
      '932',
      '933',
      '934',
      '935',
      '936',
      '937',
      '938',
      '939',
      '940',
      '941',
      '942',
      '943',
      '944',
      '945',
      '946',
      '947',
      '948',
      '949',
      '950',
      '951',
      '992',
      '993',
      '994',
      '995',
      '996',
      '997',
      '998',
      '999',
    ];

    final prefix = trimmed.substring(0, 3);
    if (!validPrefixes.contains(prefix)) {
      return ValidationResult.error('contact_number_invalid_prefix');
    }

    return ValidationResult.valid();
  }

  // Structured address validation for backend compatibility
  static ValidationResult validateRegion(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('region_required');
    }
    return ValidationResult.valid();
  }

  static ValidationResult validateProvince(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('province_required');
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 50) {
      return ValidationResult.error('province_too_long');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateMunicipality(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('municipality_required');
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 50) {
      return ValidationResult.error('municipality_too_long');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateBarangay(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('barangay_required');
    }

    final trimmedValue = value.trim();
    if (trimmedValue.length > 50) {
      return ValidationResult.error('barangay_too_long');
    }

    return ValidationResult.valid();
  }

  // Legacy address validation (kept for backward compatibility)
  static ValidationResult validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('address_required');
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 10) {
      return ValidationResult.error('address_too_short');
    }

    if (trimmedValue.length > 200) {
      return ValidationResult.error('address_too_long');
    }

    if (!RegExp(
      r"^[a-zA-Z0-9ñÑáéíóúÁÉÍÓÚàèìòùÀÈÌÒÙâêîôûÂÊÎÔÛ\s\-'\.#,/()]+$",
    ).hasMatch(trimmedValue)) {
      return ValidationResult.error('address_invalid_characters');
    }

    if (!RegExp(r"[a-zA-Z0-9]").hasMatch(trimmedValue)) {
      return ValidationResult.error('address_needs_alphanumeric');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.error('username_required');
    }

    final trimmedValue = value.trim();

    if (trimmedValue.length < 3) {
      return ValidationResult.error('username_too_short');
    }

    if (trimmedValue.length > 20) {
      return ValidationResult.error('username_too_long');
    }

    if (!RegExp(r"^[a-zA-Z0-9_.]+$").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_invalid_characters');
    }

    if (!RegExp(r"^[a-zA-Z0-9]").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_invalid_start');
    }

    if (!RegExp(r"[a-zA-Z0-9]$").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_invalid_end');
    }

    if (RegExp(r"[_.]{2,}").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_consecutive_special');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.error('password_required');
    }

    if (value.length < 8) {
      return ValidationResult.error('password_too_short');
    }

    if (value.length > 128) {
      return ValidationResult.error('password_too_long');
    }

    if (!RegExp(r"[A-Z]").hasMatch(value)) {
      return ValidationResult.error('password_needs_uppercase');
    }

    if (!RegExp(r"[a-z]").hasMatch(value)) {
      return ValidationResult.error('password_needs_lowercase');
    }

    if (!RegExp(r"[0-9]").hasMatch(value)) {
      return ValidationResult.error('password_needs_number');
    }

    if (!RegExp(r"[!@#$%^&*()_+\-=\[\]{};':\\|,.<>\/?~`]").hasMatch(value)) {
      return ValidationResult.error('password_needs_special');
    }

    final commonPasswords = [
      'password',
      '123456',
      'qwerty',
      'abc123',
      'password123',
    ];
    if (commonPasswords.contains(value.toLowerCase())) {
      return ValidationResult.error('password_too_common');
    }

    return ValidationResult.valid();
  }

  static ValidationResult validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return ValidationResult.error('confirm_password_required');
    }

    if (value != originalPassword) {
      return ValidationResult.error('passwords_dont_match');
    }

    return ValidationResult.valid();
  }
}
