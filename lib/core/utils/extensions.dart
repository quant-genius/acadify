
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extension methods for String class
extension StringExtensions on String {
  /// Capitalizes the first letter of the string
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  /// Converts a string to title case (first letter of each word capitalized)
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }
  
  /// Returns true if the string is a valid email
  bool isValidEmail() {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }
  
  /// Returns true if the string is a valid URL
  bool isValidUrl() {
    return RegExp(
      r'^(https?:\/\/)?' // protocol
      r'((([a-z\d]([a-z\d-]*[a-z\d])*)\.)+[a-z]{2,}|' // domain name
      r'((\d{1,3}\.){3}\d{1,3}))' // OR ip (v4) address
      r'(\:\d+)?(\/[-a-z\d%_.~+]*)*' // port and path
      r'(\?[;&a-z\d%_.~+=-]*)?' // query string
      r'(\#[-a-z\d_]*)?$', // fragment locator
      caseSensitive: false,
    ).hasMatch(this);
  }
  
  /// Returns the first n characters of a string, with an ellipsis if truncated
  String truncate(int n) {
    if (length <= n) return this;
    return '${substring(0, n)}...';
  }
}

/// Extension methods for DateTime class
extension DateTimeExtensions on DateTime {
  /// Returns true if the date is today
  bool isToday() {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
  
  /// Returns true if the date is yesterday
  bool isYesterday() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }
  
  /// Returns true if the date is tomorrow
  bool isTomorrow() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }
  
  /// Returns a formatted date string (e.g. "Jan 1, 2023")
  String formatDate() {
    return DateFormat('MMM d, y').format(this);
  }
  
  /// Returns a formatted time string (e.g. "3:30 PM")
  String formatTime() {
    return DateFormat('h:mm a').format(this);
  }
  
  /// Returns a formatted date and time string (e.g. "Jan 1, 2023 at 3:30 PM")
  String formatDateTime() {
    return DateFormat('MMM d, y \'at\' h:mm a').format(this);
  }
  
  /// Returns a relative time string (e.g. "2 hours ago")
  String formatRelative() {
    final now = DateTime.now();
    final difference = now.difference(this);
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else {
      return formatDate();
    }
  }
}

/// Extension methods for List class
extension ListExtensions<T> on List<T> {
  /// Returns a new list with duplicates removed
  List<T> removeDuplicates() {
    return toSet().toList();
  }
  
  /// Returns the first element that matches the predicate, or null if none match
  T? firstWhereOrNull(bool Function(T) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

/// Extension methods for BuildContext
extension BuildContextExtensions on BuildContext {
  /// Returns the screen size
  Size get screenSize => MediaQuery.of(this).size;
  
  /// Returns the screen width
  double get screenWidth => MediaQuery.of(this).size.width;
  
  /// Returns the screen height
  double get screenHeight => MediaQuery.of(this).size.height;
  
  /// Returns the current theme
  ThemeData get theme => Theme.of(this);
  
  /// Returns the text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Returns the color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Returns true if the current theme is dark
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Shows a snackbar with the given message
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
  }
  
  /// Navigates to the given route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }
  
  /// Replaces the current route with the given route
  Future<T?> navigateAndReplace<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }
  
  /// Removes all routes and navigates to the given route
  Future<T?> navigateAndRemoveUntil<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }
}
