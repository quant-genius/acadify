import 'package:flutter/foundation.dart';
import 'dart:io';

import '../../../../core/services/storage_service.dart';
import '../../data/repositories/post_repository.dart';
import '../../domain/entities/post_entity.dart';
import '../../domain/use_cases/get_posts_use_case.dart';
import '../../domain/use_cases/create_post_use_case.dart';

/// Provider for posts state
class PostProvider extends ChangeNotifier {
  final PostRepository _postRepository = PostRepository();
  final StorageService _storageService = StorageService();
  late GetPostsUseCase _getPostsUseCase;
  late CreatePostUseCase _createPostUseCase;

  bool _isLoading = false;
  String? _errorMessage;
  List<PostEntity> _posts = [];
  String? _currentGroupId;

  /// Constructor
  PostProvider() {
    _getPostsUseCase = GetPostsUseCase(_postRepository);
    _createPostUseCase = CreatePostUseCase(_postRepository);
  }

  /// Sets the current group ID
  void setCurrentGroupId(String groupId) {
    _currentGroupId = groupId;
    notifyListeners();
  }

  /// Gets posts for the current group
  Future<void> getPosts() async {
    if (_currentGroupId == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _posts = await _getPostsUseCase.call(_currentGroupId!);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new post
  Future<bool> createPost({
    required String title,
    required String content,
    File? attachment,
  }) async {
    if (_currentGroupId == null) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      String? attachmentUrl;
      if (attachment != null) {
        attachmentUrl = await uploadPostAttachment(attachment);
        if (attachmentUrl == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
      }

      final post = await _createPostUseCase.call(
        groupId: _currentGroupId!,
        title: title,
        content: content,
        attachmentUrl: attachmentUrl,
      );

      _posts.add(post);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Uploads a file attachment for a post
  Future<String?> uploadPostAttachment(File file) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if the file exists
      if (!file.existsSync()) {
        _errorMessage = 'File does not exist';
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Upload the attachment
      final url = await _storageService.uploadPostAttachment(
        file: file,
        groupId: _currentGroupId!,
      );
      
      _isLoading = false;
      notifyListeners();
      return url;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Whether the posts are currently loading
  bool get isLoading => _isLoading;

  /// Error message, if any
  String? get errorMessage => _errorMessage;

  /// List of posts
  List<PostEntity> get posts => _posts;
}
