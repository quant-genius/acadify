
import 'package:flutter/foundation.dart';
import 'dart:async';
import '../../domain/entities/post_entity.dart';
import '../../data/models/post_model.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import 'dart:io';

/// PostProvider state
enum PostState {
  /// Initial state
  initial,
  
  /// Loading state during post operations
  loading,
  
  /// Success state after successful operation
  success,
  
  /// Error state after failed operation
  error,
}

/// Provider for post state and operations
class PostProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  
  /// Current state of post operations
  PostState _state = PostState.initial;
  
  /// List of posts for a specific group
  List<PostEntity> _groupPosts = [];
  
  /// Currently selected post
  PostEntity? _selectedPost;
  
  /// Error message, if any
  String? _errorMessage;
  
  /// Constructor that initializes services
  PostProvider({
    FirestoreService? firestoreService,
    StorageService? storageService,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _storageService = storageService ?? StorageService(prefs: null);
  
  /// Loads posts for a specific group
  Future<void> loadGroupPosts(String groupId) async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final querySnapshot = await _firestoreService.getCollection(
        'posts',
        queryBuilder: (query) => query
            .where('groupId', isEqualTo: groupId)
            .where('isActive', isEqualTo: true)
            .orderBy('isPinned', descending: true)
            .orderBy('createdAt', descending: true),
      );
      
      _groupPosts = querySnapshot.docs
          .map((doc) => PostModel.fromFirestore(
                doc.data() as Map<String, dynamic>, 
                doc.id,
              ))
          .toList();
      
      _state = PostState.success;
    } catch (e) {
      _state = PostState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Creates a new post
  Future<PostEntity?> createPost({
    required String groupId,
    required String authorId,
    required String title,
    required String content,
    required String category,
    List<File>? attachmentFiles,
    bool isAnnouncement = false,
    bool isPinned = false,
  }) async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Upload attachments if any
      List<String> attachmentUrls = [];
      
      if (attachmentFiles != null && attachmentFiles.isNotEmpty) {
        for (final file in attachmentFiles) {
          final url = await _storageService.uploadPostAttachment(
            file,
            groupId: groupId,
            postId: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
            file: file,
          );
          
          attachmentUrls.add(url);
        }
      }
      
      // Create post model
      final newPost = PostModel(
        id: '',
        groupId: groupId,
        authorId: authorId,
        title: title,
        content: content,
        category: category,
        attachments: attachmentUrls,
        isAnnouncement: isAnnouncement,
        isPinned: isPinned,
        isActive: true,
      );
      
      // Save to Firestore
      final docRef = await _firestoreService.createDocument(
        'posts',
        newPost.toFirestore(),
      );
      
      // Get the created post with ID
      final createdPost = newPost.copyWith(id: docRef.id);
      
      // Add to local list
      _groupPosts = [createdPost, ..._groupPosts];
      
      _state = PostState.success;
      notifyListeners();
      
      return createdPost;
    } catch (e) {
      _state = PostState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Gets a specific post by ID
  Future<PostEntity?> getPost(String postId) async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final docSnapshot = await _firestoreService.getDocument('posts', postId);
      
      final post = PostModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
      
      _selectedPost = post;
      _state = PostState.success;
      notifyListeners();
      
      return post;
    } catch (e) {
      _state = PostState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Updates an existing post
  Future<PostEntity?> updatePost(PostModel post) async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _firestoreService.updateDocument(
        'posts',
        post.id,
        post.toFirestore(),
      );
      
      // Update post in local list
      _groupPosts = _groupPosts.map((p) {
        return p.id == post.id ? post : p;
      }).toList();
      
      if (_selectedPost?.id == post.id) {
        _selectedPost = post;
      }
      
      _state = PostState.success;
      notifyListeners();
      
      return post;
    } catch (e) {
      _state = PostState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }
  
  /// Deletes a post
  Future<bool> deletePost(String postId) async {
    _state = PostState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      // Get the post to access attachments
      final post = _groupPosts.firstWhere((p) => p.id == postId);
      
      // Delete post document
      await _firestoreService.updateDocument(
        'posts',
        postId,
        {'isActive': false, 'updatedAt': DateTime.now()},
      );
      
      // Remove post from local list
      _groupPosts = _groupPosts.where((p) => p.id != postId).toList();
      
      if (_selectedPost?.id == postId) {
        _selectedPost = null;
      }
      
      _state = PostState.success;
      notifyListeners();
      
      return true;
    } catch (e) {
      _state = PostState.error;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Likes or unlikes a post
  Future<bool> toggleLike(String postId, String userId) async {
    try {
      final post = _groupPosts.firstWhere((p) => p.id == postId);
      final isLiked = post.isLikedBy(userId);
      
      // Create a copy of likedBy list
      final likedBy = List<String>.from(post.likedBy);
      
      if (isLiked) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }
      
      // Update post in Firestore
      await _firestoreService.updateDocument(
        'posts',
        postId,
        {
          'likedBy': likedBy,
          'updatedAt': DateTime.now(),
        },
      );
      
      // Update post in local list
      if (post is PostModel) {
        final updatedPost = post.copyWith(likedBy: likedBy);
        _groupPosts = _groupPosts.map((p) {
          return p.id == postId ? updatedPost : p;
        }).toList();
        
        if (_selectedPost?.id == postId) {
          _selectedPost = updatedPost;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  /// Pins or unpins a post
  Future<bool> togglePin(String postId) async {
    try {
      final post = _groupPosts.firstWhere((p) => p.id == postId);
      final isPinned = !post.isPinned;
      
      // Update post in Firestore
      await _firestoreService.updateDocument(
        'posts',
        postId,
        {
          'isPinned': isPinned,
          'updatedAt': DateTime.now(),
        },
      );
      
      // Update post in local list
      if (post is PostModel) {
        final updatedPost = post.copyWith(isPinned: isPinned);
        _groupPosts = _groupPosts.map((p) {
          return p.id == postId ? updatedPost : p;
        }).toList();
        
        // Sort posts (pinned first, then by date)
        _groupPosts.sort((a, b) {
          if (a.isPinned && !b.isPinned) return -1;
          if (!a.isPinned && b.isPinned) return 1;
          
          final aDate = a.createdAt ?? DateTime.now();
          final bDate = b.createdAt ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
        
        if (_selectedPost?.id == postId) {
          _selectedPost = updatedPost;
        }
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
  
  /// Sets the selected post
  void selectPost(PostEntity post) {
    _selectedPost = post;
    notifyListeners();
  }
  
  /// Clears the selected post
  void clearSelectedPost() {
    _selectedPost = null;
    notifyListeners();
  }
  
  /// Current state of post operations
  PostState get state => _state;
  
  /// List of posts for a specific group
  List<PostEntity> get groupPosts => _groupPosts;
  
  /// Currently selected post
  PostEntity? get selectedPost => _selectedPost;
  
  /// Error message, if any
  String? get errorMessage => _errorMessage;
  
  /// Returns true if posts are currently loading
  bool get isLoading => _state == PostState.loading;
  
  /// Returns true if a post operation was successful
  bool get isSuccess => _state == PostState.success;
  
  /// Returns true if a post operation failed
  bool get hasError => _state == PostState.error;
  
  /// Returns the pinned posts
  List<PostEntity> get pinnedPosts => 
      _groupPosts.where((post) => post.isPinned).toList();
  
  /// Returns the announcements
  List<PostEntity> get announcements => 
      _groupPosts.where((post) => post.isAnnouncement).toList();
}
