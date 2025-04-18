
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for app-wide settings and state
class AppProvider extends ChangeNotifier {
  final SharedPreferences? _prefs;
  
  /// Current theme mode
  ThemeMode _themeMode = ThemeMode.system;
  
  /// Whether push notifications are enabled
  bool _pushNotificationsEnabled = true;
  
  /// Whether email notifications are enabled
  bool _emailNotificationsEnabled = true;
  
  /// Constructor
  AppProvider({SharedPreferences? prefs}) : _prefs = prefs {
    _loadSettings();
  }
  
  /// Loads settings from shared preferences
  Future<void> _loadSettings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    
    final darkModeIndex = prefs.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[darkModeIndex];
    
    _pushNotificationsEnabled = prefs.getBool('push_notifications_enabled') ?? true;
    _emailNotificationsEnabled = prefs.getBool('email_notifications_enabled') ?? true;
    
    notifyListeners();
  }
  
  /// Saves settings to shared preferences
  Future<void> _saveSettings() async {
    final prefs = _prefs ?? await SharedPreferences.getInstance();
    
    await prefs.setInt('theme_mode', _themeMode.index);
    await prefs.setBool('push_notifications_enabled', _pushNotificationsEnabled);
    await prefs.setBool('email_notifications_enabled', _emailNotificationsEnabled);
  }
  
  /// Sets the theme mode
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveSettings();
    notifyListeners();
  }
  
  /// Sets dark mode on or off
  void setDarkMode(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveSettings();
    notifyListeners();
  }
  
  /// Sets whether push notifications are enabled
  void setPushNotificationsEnabled(bool enabled) {
    _pushNotificationsEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }
  
  /// Sets whether email notifications are enabled
  void setEmailNotificationsEnabled(bool enabled) {
    _emailNotificationsEnabled = enabled;
    _saveSettings();
    notifyListeners();
  }
  
  /// Current theme mode
  ThemeMode get themeMode => _themeMode;
  
  /// Whether dark mode is enabled
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  
  /// Whether push notifications are enabled
  bool get arePushNotificationsEnabled => _pushNotificationsEnabled;
  
  /// Whether email notifications are enabled
  bool get areEmailNotificationsEnabled => _emailNotificationsEnabled;
}
