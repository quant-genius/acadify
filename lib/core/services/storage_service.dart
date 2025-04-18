
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

/// Service for handling file storage operations
class StorageService {
  final FirebaseStorage _storage;
  final SharedPreferences? _prefs;
  
  /// Constructor
  StorageService({SharedPreferences? prefs})
      : _prefs = prefs,
        _storage = FirebaseStorage.instance;
  
  /// Uploads a file to Firebase Storage
  ///
  /// [file] - The file to upload
  /// [storagePath] - The path in Firebase Storage to store the file
  Future<String> uploadFile(File file, String storagePath) async {
    try {
      final fileName = path.basename(file.path);
      final ref = _storage.ref().child('$storagePath/$fileName');
      
      // Upload the file
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }
  
  /// Uploads a file with a unique name to prevent conflicts
  ///
  /// [file] - The file to upload
  /// [storagePath] - The path in Firebase Storage to store the file
  Future<String> uploadFileWithUniqueId(File file, String storagePath) async {
    try {
      final uuid = const Uuid().v4();
      final extension = path.extension(file.path);
      final ref = _storage.ref().child('$storagePath/$uuid$extension');
      
      // Upload the file
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      
      // Get the download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      throw Exception('Failed to upload file: $e');
    }
  }
  
  /// Deletes a file from Firebase Storage
  ///
  /// [fileUrl] - The URL of the file to delete
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      debugPrint('Error deleting file: $e');
      throw Exception('Failed to delete file: $e');
    }
  }
  
  /// Saves a file URL to SharedPreferences for caching
  ///
  /// [key] - The key to store the URL under
  /// [url] - The URL to cache
  Future<void> cacheFileUrl(String key, String url) async {
    try {
      await _prefs?.setString('file_url_$key', url);
    } catch (e) {
      debugPrint('Error caching file URL: $e');
    }
  }
  
  /// Gets a cached file URL from SharedPreferences
  ///
  /// [key] - The key the URL is stored under
  Future<String?> getCachedFileUrl(String key) async {
    try {
      return _prefs?.getString('file_url_$key');
    } catch (e) {
      debugPrint('Error getting cached file URL: $e');
      return null;
    }
  }
  
  /// Clears all cached file URLs from SharedPreferences
  Future<void> clearCachedFileUrls() async {
    try {
      final prefs = _prefs ?? await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith('file_url_')) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      debugPrint('Error clearing cached file URLs: $e');
    }
  }
}
