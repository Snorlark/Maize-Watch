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

    final trimmed = value.trim();
    
    // Match backend validation pattern: /^(09\d{9}|\+639\d{9})$/
    if (!RegExp(r'^(09\d{9}|\+639\d{9})$').hasMatch(trimmed)) {
      return ValidationResult.error('contact_number_invalid_format');
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

    if (trimmedValue.length > 30) {
      return ValidationResult.error('username_too_long');
    }

    if (!RegExp(r"^[a-zA-Z0-9_]+$").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_invalid_characters');
    }

    if (!RegExp(r"^[a-zA-Z0-9]").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_invalid_start');
    }

    if (!RegExp(r"[a-zA-Z0-9]$").hasMatch(trimmedValue)) {
      return ValidationResult.error('username_invalid_end');
    }

    if (RegExp(r"[_]{2,}").hasMatch(trimmedValue)) {
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

    if (!RegExp(r"[!@#$%^&*()_+\-=\[\]{};':\\|,.<>\/?~`.]+").hasMatch(value)) {
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
