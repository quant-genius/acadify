
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post_entity.dart';

/// Data model for post information
class PostModel extends PostEntity {
  /// Creates a PostModel with the specified parameters
  const PostModel({
    required super.id,
    required super.groupId,
    required super.authorId,
    required super.title,
    required super.content,
    required super.category,
    super.attachments = const [],
    super.likedBy = const [],
    super.isAnnouncement = false,
    super.isPinned = false,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });
  
  /// Creates a PostModel from a Firestore document
  factory PostModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PostModel(
      id: id,
      groupId: data['groupId'] as String,
      authorId: data['authorId'] as String,
      title: data['title'] as String,
      content: data['content'] as String,
      category: data['category'] as String,
      attachments: List<String>.from(data['attachments'] as List? ?? []),
      likedBy: List<String>.from(data['likedBy'] as List? ?? []),
      isAnnouncement: data['isAnnouncement'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? false,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as dynamic).toDate() 
        : null,
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as dynamic).toDate() 
        : null,
    );
  }
  
  /// Converts the PostModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'authorId': authorId,
      'title': title,
      'content': content,
      'category': category,
      'attachments': attachments,
      'likedBy': likedBy,
      'isAnnouncement': isAnnouncement,
      'isPinned': isPinned,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  /// Creates a copy of this PostModel with the given fields replaced with new values
  PostModel copyWith({
    String? id,
    String? groupId,
    String? authorId,
    String? title,
    String? content,
    String? category,
    List<String>? attachments,
    List<String>? likedBy,
    bool? isAnnouncement,
    bool? isPinned,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      attachments: attachments ?? this.attachments,
      likedBy: likedBy ?? this.likedBy,
      isAnnouncement: isAnnouncement ?? this.isAnnouncement,
      isPinned: isPinned ?? this.isPinned,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Creates a new PostModel with empty/default values
  factory PostModel.empty() {
    return PostModel(
      id: '',
      groupId: '',
      authorId: '',
      title: '',
      content: '',
      category: 'general',
      attachments: [],
      likedBy: [],
      isAnnouncement: false,
      isPinned: false,
      isActive: true,
    );
  }
}
