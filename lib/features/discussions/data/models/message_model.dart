
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message_entity.dart';

/// Data model for message information
class MessageModel extends MessageEntity {
  /// Creates a MessageModel with the specified parameters
  const MessageModel({
    required super.id,
    required super.groupId,
    required super.senderId,
    required super.content,
    super.attachmentUrl,
    super.replyToId,
    super.isDeleted = false,
    super.createdAt,
    super.updatedAt,
  });
  
  /// Creates a MessageModel from a Firestore document
  factory MessageModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MessageModel(
      id: id,
      groupId: data['groupId'] as String,
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      attachmentUrl: data['attachmentUrl'] as String?,
      replyToId: data['replyToId'] as String?,
      isDeleted: data['isDeleted'] as bool? ?? false,
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as dynamic).toDate() 
        : null,
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as dynamic).toDate() 
        : null,
    );
  }
  
  /// Converts the MessageModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'senderId': senderId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'replyToId': replyToId,
      'isDeleted': isDeleted,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  /// Creates a copy of this MessageModel with given fields replaced with new values
  MessageModel copyWith({
    String? id,
    String? groupId,
    String? senderId,
    String? content,
    String? attachmentUrl,
    String? replyToId,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MessageModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      replyToId: replyToId ?? this.replyToId,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
