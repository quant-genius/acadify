
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/post_model.dart';
import '../../domain/entities/post_entity.dart';

/// Repository for handling post data operations
class PostRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  
  /// Constructor
  PostRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService;
  
  /// Gets posts for a specific group
  ///
  /// [groupId] - The ID of the group to get posts for
  Future<List<PostEntity>> getGroupPosts(String groupId) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        'posts',
        queryBuilder: (query) => query
            .where('groupId', isEqualTo: groupId)
            .where('isActive', isEqualTo: true)
            .orderBy('isPinned', descending: true)
            .orderBy('createdAt', descending: true),
      );
      
      return querySnapshot.docs.map((doc) {
        return PostModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a specific post by ID
  ///
  /// [postId] - The ID of the post to retrieve
  Future<PostEntity> getPost(String postId) async {
    try {
      final docSnapshot = await _firestoreService.getDocument('posts', postId);
      
      return PostModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Creates a new post
  ///
  /// [groupId] - The ID of the group the post belongs to
  /// [authorId] - The ID of the user creating the post
  /// [title] - The post title
  /// [content] - The post content
  /// [category] - The post category
  /// [attachmentFiles] - List of attachment files (optional)
  /// [isAnnouncement] - Whether the post is an announcement
  /// [isPinned] - Whether the post is pinned
  Future<PostEntity> createPost({
    required String groupId,
    required String authorId,
    required String title,
    required String content,
    required String category,
    List<File>? attachmentFiles,
    bool isAnnouncement = false,
    bool isPinned = false,
  }) async {
    try {
      // Generate a temporary ID for the post
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      
      // Upload attachments if provided
      List<String> attachmentUrls = [];
      
      if (attachmentFiles != null && attachmentFiles.isNotEmpty) {
        for (final file in attachmentFiles) {
          final url = await _storageService.uploadPostAttachment(
            groupId: groupId,
            postId: tempId,
            file: file,
          );
          
          attachmentUrls.add(url);
        }
      }
      
      // Create the post model
      final post = PostModel(
        id: '',
        groupId: groupId,
        authorId: authorId,
        title: title,
        content: content,
        category: category,
        attachments: attachmentUrls,
        isAnnouncement: isAnnouncement,
        isPinned: isPinned,
      );
      
      // Add the post to Firestore
      final docRef = await _firestoreService.createDocument(
        'posts',
        post.toFirestore(),
      );
      
      // Return the post with the generated ID
      return post.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates an existing post
  ///
  /// [postId] - The ID of the post to update
  /// [title] - The updated post title
  /// [content] - The updated post content
  /// [category] - The updated post category
  /// [addAttachmentFiles] - List of new attachment files to add (optional)
  /// [removeAttachmentUrls] - List of attachment URLs to remove (optional)
  /// [isAnnouncement] - Whether the post is an announcement
  /// [isPinned] - Whether the post is pinned
  Future<PostEntity> updatePost({
    required String postId,
    String? title,
    String? content,
    String? category,
    List<File>? addAttachmentFiles,
    List<String>? removeAttachmentUrls,
    bool? isAnnouncement,
    bool? isPinned,
  }) async {
    try {
      // Get the current post data
      final currentPost = await getPost(postId);
      
      if (!(currentPost is PostModel)) {
        throw Exception('Invalid post type');
      }
      
      // Create new attachments list
      List<String> updatedAttachments = List<String>.from(currentPost.attachments);
      
      // Remove specified attachments
      if (removeAttachmentUrls != null && removeAttachmentUrls.isNotEmpty) {
        for (final url in removeAttachmentUrls) {
          updatedAttachments.remove(url);
          
          // Delete the file from storage
          try {
            await _storageService.deleteFile(url);
          } catch (e) {
            // Log the error but continue with the update
            print('Error deleting file: $e');
          }
        }
      }
      
      // Add new attachments
      if (addAttachmentFiles != null && addAttachmentFiles.isNotEmpty) {
        for (final file in addAttachmentFiles) {
          final url = await _storageService.uploadPostAttachment(
            groupId: currentPost.groupId,
            postId: postId,
            file: file,
          );
          
          updatedAttachments.add(url);
        }
      }
      
      // Create updates map
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (category != null) updates['category'] = category;
      if (isAnnouncement != null) updates['isAnnouncement'] = isAnnouncement;
      if (isPinned != null) updates['isPinned'] = isPinned;
      
      // Only update attachments if they've changed
      if (removeAttachmentUrls != null || addAttachmentFiles != null) {
        updates['attachments'] = updatedAttachments;
      }
      
      // Update the post in Firestore
      await _firestoreService.updateDocument(
        'posts',
        postId,
        updates,
      );
      
      // Return the updated post
      return currentPost.copyWith(
        title: title ?? currentPost.title,
        content: content ?? currentPost.content,
        category: category ?? currentPost.category,
        attachments: updatedAttachments,
        isAnnouncement: isAnnouncement ?? currentPost.isAnnouncement,
        isPinned: isPinned ?? currentPost.isPinned,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes a post
  ///
  /// [postId] - The ID of the post to delete
  /// [permanent] - Whether to permanently delete the post
  Future<void> deletePost(String postId, {bool permanent = false}) async {
    try {
      if (permanent) {
        // Get the post to access its attachments
        final postDoc = await _firestoreService.getDocument('posts', postId);
        final post = PostModel.fromFirestore(
          postDoc.data() as Map<String, dynamic>,
          postDoc.id,
        );
        
        // Delete attachments
        for (final url in post.attachments) {
          try {
            await _storageService.deleteFile(url);
          } catch (e) {
            // Log the error but continue with the deletion
            print('Error deleting attachment: $e');
          }
        }
        
        // Delete the post document
        await _firestoreService.deleteDocument('posts', postId);
      } else {
        // Soft delete by marking as inactive
        await _firestoreService.updateDocument(
          'posts',
          postId,
          {
            'isActive': false,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Toggle a user's like on a post
  ///
  /// [postId] - The ID of the post to like/unlike
  /// [userId] - The ID of the user
  Future<PostEntity> toggleLike(String postId, String userId) async {
    try {
      // Get the current post data
      final currentPost = await getPost(postId);
      
      // Check if the user already liked the post
      final isLiked = currentPost.likedBy.contains(userId);
      
      // Update the post in Firestore
      await _firestoreService.updateDocument(
        'posts',
        postId,
        {
          'likedBy': isLiked
              ? FieldValue.arrayRemove([userId])
              : FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      
      // Return the updated post
      final updatedLikedBy = List<String>.from(currentPost.likedBy);
      if (isLiked) {
        updatedLikedBy.remove(userId);
      } else {
        updatedLikedBy.add(userId);
      }
      
      return (currentPost as PostModel).copyWith(
        likedBy: updatedLikedBy,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Toggle whether a post is pinned
  ///
  /// [postId] - The ID of the post to pin/unpin
  Future<PostEntity> togglePin(String postId) async {
    try {
      // Get the current post data
      final currentPost = await getPost(postId);
      
      // Update the post in Firestore
      await _firestoreService.updateDocument(
        'posts',
        postId,
        {
          'isPinned': !currentPost.isPinned,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
      
      // Return the updated post
      return (currentPost as PostModel).copyWith(
        isPinned: !currentPost.isPinned,
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets announcements for a specific group
  ///
  /// [groupId] - The ID of the group to get announcements for
  Future<List<PostEntity>> getGroupAnnouncements(String groupId) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        'posts',
        queryBuilder: (query) => query
            .where('groupId', isEqualTo: groupId)
            .where('isAnnouncement', isEqualTo: true)
            .where('isActive', isEqualTo: true)
            .orderBy('createdAt', descending: true),
      );
      
      return querySnapshot.docs.map((doc) {
        return PostModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
