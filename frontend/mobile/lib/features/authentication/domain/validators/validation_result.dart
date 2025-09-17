class ValidationResult {
  final bool isValid;
  final String? errorKey;

  const ValidationResult._(this.isValid, this.errorKey);

  factory ValidationResult.valid() => const ValidationResult._(true, null);

  factory ValidationResult.error(String errorKey) =>
      ValidationResult._(false, errorKey);
}
