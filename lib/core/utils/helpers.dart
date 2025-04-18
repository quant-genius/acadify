
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

/// Helper functions for common tasks throughout the app
class AppHelpers {
  /// Formats a timestamp into a readable date string
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }
  
  /// Formats a timestamp into a readable date and time string
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, y – h:mm a').format(dateTime);
  }
  
  /// Formats a timestamp into a readable time string
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
  
  /// Get a relative time string (e.g., "2 hours ago")
  static String getRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} ${(difference.inDays / 7).floor() == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  
  /// Generates a unique ID
  static String generateUniqueId() {
    const uuid = Uuid();
    return uuid.v4();
  }
  
  /// Returns a file size string (e.g., "2.5 MB")
  static String getFileSizeString(int bytes) {
    if (bytes <= 0) return '0 B';
    
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }
  
  /// Truncates a string if it's longer than maxLength
  static String truncateString(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
  
  /// Gets a file extension from a path
  static String getFileExtension(String path) {
    return path.split('.').last.toLowerCase();
  }
  
  /// Gets a filename from a path
  static String getFileName(String path) {
    return path.split('/').last;
  }
  
  /// Launches a URL
  static Future<void> launchURL(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'Could not launch $url';
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }
  
  /// Gets a random color from the material color palette
  static Color getRandomColor() {
    final colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
    ];
    
    final random = Random();
    return colors[random.nextInt(colors.length)];
  }
  
  /// Gets the initial character from a string
  static String getInitial(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase();
  }

  // Private constructor to prevent instantiation
  AppHelpers._();
}
