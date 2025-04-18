
import 'dart:io';
import '../../data/repositories/post_repository.dart';
import '../entities/post_entity.dart';

/// Use case for creating a new post
class CreatePostUseCase {
  final PostRepository _postRepository;
  
  /// Constructor
  CreatePostUseCase(this._postRepository);
  
  /// Executes the create post operation
  ///
  /// [groupId] - The ID of the group the post belongs to
  /// [authorId] - The ID of the user creating the post
  /// [title] - The post title
  /// [content] - The post content
  /// [category] - The post category
  /// [attachmentFiles] - List of attachment files (optional)
  /// [isAnnouncement] - Whether the post is an announcement
  /// [isPinned] - Whether the post is pinned
  Future<PostEntity> call({
    required String groupId,
    required String authorId,
    required String title,
    required String content,
    required String category,
    List<File>? attachmentFiles,
    bool isAnnouncement = false,
    bool isPinned = false,
  }) {
    return _postRepository.createPost(
      groupId: groupId,
      authorId: authorId,
      title: title,
      content: content,
      category: category,
      attachmentFiles: attachmentFiles,
      isAnnouncement: isAnnouncement,
      isPinned: isPinned,
    );
  }
}
