
import 'package:equatable/equatable.dart';

/// Domain entity for message information
class MessageEntity extends Equatable {
  /// Unique identifier for the message
  final String id;
  
  /// ID of the group this message belongs to
  final String groupId;
  
  /// ID of the user who sent the message
  final String senderId;
  
  /// Message content
  final String content;
  
  /// URL to an attachment (if any)
  final String? attachmentUrl;
  
  /// ID of the message being replied to (if any)
  final String? replyToId;
  
  /// Whether the message has been deleted
  final bool isDeleted;
  
  /// When the message was created
  final DateTime? createdAt;
  
  /// When the message was last updated
  final DateTime? updatedAt;
  
  /// Creates a MessageEntity with the specified parameters
  const MessageEntity({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.content,
    this.attachmentUrl,
    this.replyToId,
    this.isDeleted = false,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Returns whether the message has an attachment
  bool get hasAttachment => attachmentUrl != null && attachmentUrl!.isNotEmpty;
  
  /// Returns whether the message is a reply
  bool get isReply => replyToId != null && replyToId!.isNotEmpty;
  
  @override
  List<Object?> get props => [
    id,
    groupId,
    senderId,
    content,
    attachmentUrl,
    replyToId,
    isDeleted,
    createdAt,
    updatedAt,
  ];
}
