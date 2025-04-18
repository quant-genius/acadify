
import 'package:equatable/equatable.dart';

/// Domain entity for post information
class PostEntity extends Equatable {
  /// Unique identifier for the post
  final String id;
  
  /// ID of the group this post belongs to
  final String groupId;
  
  /// ID of the user who created the post
  final String authorId;
  
  /// Post title
  final String title;
  
  /// Post content
  final String content;
  
  /// Post category (e.g., general, announcement, assignment, resource)
  final String category;
  
  /// List of attachment URLs
  final List<String> attachments;
  
  /// List of user IDs who liked the post
  final List<String> likedBy;
  
  /// Whether the post is an announcement
  final bool isAnnouncement;
  
  /// Whether the post is pinned
  final bool isPinned;
  
  /// Whether the post is active
  final bool isActive;
  
  /// When the post was created
  final DateTime? createdAt;
  
  /// When the post was last updated
  final DateTime? updatedAt;
  
  /// Creates a PostEntity with the specified parameters
  const PostEntity({
    required this.id,
    required this.groupId,
    required this.authorId,
    required this.title,
    required this.content,
    required this.category,
    this.attachments = const [],
    this.likedBy = const [],
    this.isAnnouncement = false,
    this.isPinned = false,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Returns the number of likes on the post
  int get likeCount => likedBy.length;
  
  /// Returns the number of attachments on the post
  int get attachmentCount => attachments.length;
  
  /// Returns whether the post has been liked by a user
  bool isLikedBy(String userId) => likedBy.contains(userId);
  
  /// Returns whether the post has attachments
  bool get hasAttachments => attachments.isNotEmpty;
  
  @override
  List<Object?> get props => [
    id,
    groupId,
    authorId,
    title,
    content,
    category,
    attachments,
    likedBy,
    isAnnouncement,
    isPinned,
    isActive,
    createdAt,
    updatedAt,
  ];
}
