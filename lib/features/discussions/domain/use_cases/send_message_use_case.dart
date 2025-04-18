
import 'dart:io';
import '../../data/repositories/discussion_repository.dart';
import '../entities/message_entity.dart';

/// Use case for sending a message to a group
class SendMessageUseCase {
  final DiscussionRepository _discussionRepository;
  
  /// Constructor
  SendMessageUseCase(this._discussionRepository);
  
  /// Executes the send message operation
  ///
  /// [groupId] - The ID of the group to send the message to
  /// [senderId] - The ID of the user sending the message
  /// [content] - The message content
  /// [replyToId] - The ID of the message being replied to (optional)
  /// [attachment] - The file to attach to the message (optional)
  Future<MessageEntity> call({
    required String groupId,
    required String senderId,
    required String content,
    String? replyToId,
    File? attachment,
  }) {
    return _discussionRepository.sendMessage(
      groupId: groupId,
      senderId: senderId,
      content: content,
      replyToId: replyToId,
      attachment: attachment,
    );
  }
}
