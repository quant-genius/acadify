
import 'package:flutter/material.dart';

/// Color constants used throughout the application
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF673AB7);
  static const Color primaryLight = Color(0xFFD1C4E9);
  static const Color primaryDark = Color(0xFF512DA8);
  static const Color accent = Color(0xFFFF4081);
  
  // Neutral colors
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFB00020);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnAccent = Color(0xFFFFFFFF);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // Role-specific colors
  static const Color studentColor = Color(0xFF5C6BC0); // Indigo
  static const Color lecturerColor = Color(0xFF66BB6A); // Green
  static const Color classRepColor = Color(0xFFFFB74D); // Orange
  
  // Category colors for content organization
  static const Color announcementColor = Color(0xFFE57373); // Red
  static const Color assignmentColor = Color(0xFF4DB6AC); // Teal
  static const Color discussionColor = Color(0xFF9575CD); // Deep Purple
  static const Color resourceColor = Color(0xFF4FC3F7); // Light Blue
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF9C27B0),
    Color(0xFF673AB7),
  ];
  
  // Status colors
  static const Color online = Color(0xFF4CAF50);
  static const Color offline = Color(0xFF9E9E9E);
  static const Color busy = Color(0xFFF44336);
  
  AppColors._(); // Private constructor to prevent instantiation
}
