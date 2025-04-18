
import '../../data/repositories/discussion_repository.dart';
import '../entities/message_entity.dart';

/// Use case for getting messages for a specific group
class GetMessagesUseCase {
  final DiscussionRepository _discussionRepository;
  
  /// Constructor
  GetMessagesUseCase(this._discussionRepository);
  
  /// Executes the get messages operation
  ///
  /// [groupId] - The ID of the group to get messages for
  /// [limit] - The maximum number of messages to retrieve
  /// [lastMessageId] - The ID of the last message retrieved in the previous batch
  Future<List<MessageEntity>> call(
    String groupId, {
    int limit = 20,
    String? lastMessageId,
  }) {
    return _discussionRepository.getGroupMessages(
      groupId,
      limit: limit,
      lastMessageId: lastMessageId,
    );
  }
  
  /// Returns a stream of messages for a specific group
  ///
  /// [groupId] - The ID of the group to get messages for
  /// [limit] - The maximum number of messages to retrieve
  Stream<List<MessageEntity>> stream(
    String groupId, {
    int limit = 20,
  }) {
    return _discussionRepository.streamGroupMessages(
      groupId,
      limit: limit,
    );
  }
}
