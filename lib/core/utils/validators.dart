
/// Utility class for form validation functions
class Validators {
  /// Validates a required field
  ///
  /// [value] - The field value to validate
  /// [fieldName] - The name of the field for the error message
  static String? validateRequired(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  /// Validates an email address
  ///
  /// [value] - The email to validate
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Simple regex for email validation
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }
  
  /// Validates a password
  ///
  /// [value] - The password to validate
  /// [isSignUp] - Whether this is for sign up (stricter validation)
  static String? validatePassword(String? value, {bool isSignUp = false}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (isSignUp && value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    if (isSignUp && !RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (isSignUp && !RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    return null;
  }
  
  /// Validates a phone number
  ///
  /// [value] - The phone number to validate
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone number can be optional
    }
    
    // Simple regex for international phone number validation
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }
  
  /// Validates a URL
  ///
  /// [value] - The URL to validate
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL can be optional
    }
    
    // Simple regex for URL validation
    final urlRegex = RegExp(
      r'^(http|https)://[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+([/?].*)?$',
    );
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }
  
  /// Validates a date in the future
  ///
  /// [value] - The date to validate
  static String? validateFutureDate(DateTime? value) {
    if (value == null) {
      return 'Date is required';
    }
    
    if (value.isBefore(DateTime.now())) {
      return 'Date must be in the future';
    }
    
    return null;
  }
  
  /// Validates a numeric value
  ///
  /// [value] - The numeric value to validate
  /// [min] - Minimum allowed value
  /// [max] - Maximum allowed value
  static String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.isEmpty) {
      return 'Value is required';
    }
    
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }
    
    if (min != null && number < min) {
      return 'Value must be at least $min';
    }
    
    if (max != null && number > max) {
      return 'Value must be at most $max';
    }
    
    return null;
  }
  
  // Private constructor to prevent instantiation
  Validators._();
}
