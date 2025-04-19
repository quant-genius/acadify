
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

/// Service for handling storage operations
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final SharedPreferences? _prefs;
  final Uuid _uuid = const Uuid();
  
  /// Constructor for StorageService
  StorageService({required SharedPreferences? prefs}) : _prefs = prefs;
  
  /// Uploads a file to Firebase Storage
  ///
  /// [file] - The file to upload
  /// [storagePath] - The path in storage where the file should be saved
  Future<String> uploadFile(File file, String storagePath) async {
    try {
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
  
  /// Uploads a group photo to storage
  ///
  /// [groupId] - The ID of the group
  /// [file] - The photo file to upload
  Future<String> uploadGroupPhoto(String groupId, File file) async {
    final fileExt = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'groups/$groupId/photos/photo_$timestamp$fileExt';
    return uploadFile(file, storagePath);
  }
  
  /// Uploads a post attachment to storage
  ///
  /// [groupId] - The ID of the group
  /// [postId] - The ID of the post
  /// [file] - The file to upload
  Future<String> uploadPostAttachment(
    File file, 
    {required String groupId, required String postId}
  ) async {
    final fileExt = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'groups/$groupId/posts/$postId/attachment_$timestamp$fileExt';
    return uploadFile(file, storagePath);
  }
  
  /// Uploads a message attachment to storage
  ///
  /// [groupId] - The ID of the group
  /// [messageId] - The ID of the message
  /// [file] - The file to upload
  Future<String> uploadMessageAttachment({
    required String groupId,
    required String messageId,
    required File file,
  }) async {
    final fileExt = path.extension(file.path);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'groups/$groupId/messages/$messageId/attachment_$timestamp$fileExt';
    return uploadFile(file, storagePath);
  }
  
  /// Deletes a file from storage
  ///
  /// [fileUrl] - The URL of the file to delete
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete file: $e');
    }
  }
  
  /// Gets a cached file URL
  ///
  /// [key] - The key to lookup
  String? getCachedFileUrl(String key) {
    return _prefs?.getString('file_url_$key');
  }
  
  /// Caches a file URL
  ///
  /// [key] - The key to store under
  /// [url] - The URL to cache
  Future<void> cacheFileUrl(String key, String url) async {
    await _prefs?.setString('file_url_$key', url);
  }
}
