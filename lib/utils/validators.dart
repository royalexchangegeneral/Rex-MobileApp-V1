/// Common input validators for form fields.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates an email address format.
  /// Returns null if valid, or an error message string if invalid.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Validates that a field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a phone number (Nigerian format).
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.length < 10 || cleaned.length > 15) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Validates NIN (11 digits).
  static String? nin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'NIN is required';
    }
    if (value.trim().length != 11 || !RegExp(r'^\d{11}$').hasMatch(value.trim())) {
      return 'NIN must be exactly 11 digits';
    }
    return null;
  }
}
