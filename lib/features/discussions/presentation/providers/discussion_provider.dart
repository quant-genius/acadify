
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';

import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../data/repositories/discussion_repository.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/use_cases/get_messages_use_case.dart';
import '../../domain/use_cases/send_message_use_case.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/repositories/auth_repository.dart';

/// Discussion provider states
enum DiscussionState {
  /// Initial state
  initial,
  
  /// Loading state during operations
  loading,
  
  /// Success state after successful operation
  success,
  
  /// Error state after failed operation
  error,
}

/// Provider for discussion state and operations
class DiscussionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final AuthRepository? _authRepository;
  
  late final DiscussionRepository _discussionRepository;
  late final GetMessagesUseCase _getMessagesUseCase;
  late final SendMessageUseCase _sendMessageUseCase;
  
  /// Current state of the discussion provider
  DiscussionState _state = DiscussionState.initial;
  
  /// Current group ID
  String? _currentGroupId;
  
  /// List of messages for the current group
  List<MessageEntity> _messages = [];
  
  /// Map of user entities by user ID for caching
  final Map<String, UserEntity> _userCache = {};
  
  /// Current message being replied to
  MessageEntity? _replyTo;
  
  /// Error message, if any
  String? _errorMessage;
  
  /// Stream subscription for messages
  StreamSubscription<List<MessageEntity>>? _messagesSubscription;
  
  /// Constructor
  DiscussionProvider({
    FirestoreService? firestoreService,
    StorageService? storageService,
    AuthRepository? authRepository,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _storageService = storageService ?? StorageService(prefs: null),
       _authRepository = authRepository {
    _initializeRepositories();
  }
  
  /// Initializes repositories and use cases
  void _initializeRepositories() {
    _discussionRepository = DiscussionRepository(
      firestoreService: _firestoreService,
      storageService: _storageService,
    );
    
    _getMessagesUseCase = GetMessagesUseCase(_discussionRepository);
    _sendMessageUseCase = SendMessageUseCase(_discussionRepository);
  }
  
  /// Loads messages for a specific group
  Future<void> loadMessages(String groupId, {bool refresh = false}) async {
    if (_currentGroupId != groupId || refresh) {
      // Cancel any existing subscription
      await _messagesSubscription?.cancel();
      _messagesSubscription = null;
      
      _state = DiscussionState.loading;
      _currentGroupId = groupId;
      _messages = [];
      _errorMessage = null;
      notifyListeners();
      
      try {
        // Start listening for messages
        _messagesSubscription = _getMessagesUseCase
            .stream(groupId)
            .listen(_onMessagesUpdated, onError: _onMessagesError);
      } catch (e) {
        _state = DiscussionState.error;
        _errorMessage = e.toString();
        notifyListeners();
      }
    }
  }
  
  /// Callback for when messages are updated
  void _onMessagesUpdated(List<MessageEntity> messages) {
    _messages = messages;
    _state = DiscussionState.success;
    notifyListeners();
    
    // Prefetch user data for message senders
    for (final message in messages) {
      if (!_userCache.containsKey(message.senderId)) {
        _fetchUserData(message.senderId);
      }
    }
  }
  
  /// Callback for when there's an error with the messages stream
  void _onMessagesError(dynamic error) {
    _state = DiscussionState.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
  
  /// Fetches user data for a specific user ID
  Future<void> _fetchUserData(String userId) async {
    if (_authRepository == null) return;
    
    try {
      final user = await _authRepository!.getUserProfile(userId);
      _userCache[userId] = user;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }
  
  /// Sends a message to the current group
  Future<void> sendMessage({
    required String content,
    File? attachment,
  }) async {
    if (_currentGroupId == null || _authRepository == null) return;
    
    _state = DiscussionState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final currentUserId = _authRepository!.currentUserId;
      
      if (currentUserId == null) {
        throw Exception('User not authenticated');
      }
      
      await _sendMessageUseCase.call(
        groupId: _currentGroupId!,
        senderId: currentUserId,
        content: content,
        replyToId: _replyTo?.id,
        attachment: attachment,
      );
      
      // Clear reply-to state after sending
      _replyTo = null;
      _state = DiscussionState.success;
    } catch (e) {
      _state = DiscussionState.error;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Deletes a message
  Future<bool> deleteMessage(String messageId) async {
    try {
      await _discussionRepository.deleteMessage(messageId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
  
  /// Sets the message being replied to
  void setReplyTo(MessageEntity? message) {
    _replyTo = message;
    notifyListeners();
  }
  
  /// Gets cached user data for a specific user ID
  UserEntity? getUserData(String userId) {
    return _userCache[userId];
  }
  
  /// Loads more messages (for pagination)
  Future<void> loadMoreMessages() async {
    if (_currentGroupId == null || _messages.isEmpty) return;
    
    try {
      final lastMessageId = _messages.last.id;
      final moreMessages = await _getMessagesUseCase.call(
        _currentGroupId!,
        lastMessageId: lastMessageId,
      );
      
      if (moreMessages.isNotEmpty) {
        _messages.addAll(moreMessages);
        notifyListeners();
        
        // Prefetch user data for message senders
        for (final message in moreMessages) {
          if (!_userCache.containsKey(message.senderId)) {
            _fetchUserData(message.senderId);
          }
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }
  
  /// Gets a specific message by ID
  MessageEntity? getMessageById(String messageId) {
    return _messages.firstWhere(
      (message) => message.id == messageId,
      orElse: () => null as MessageEntity,
    );
  }
  
  /// Current state of the discussion provider
  DiscussionState get state => _state;
  
  /// Current group ID
  String? get currentGroupId => _currentGroupId;
  
  /// List of messages for the current group
  List<MessageEntity> get messages => _messages;
  
  /// Current message being replied to
  MessageEntity? get replyTo => _replyTo;
  
  /// Error message, if any
  String? get errorMessage => _errorMessage;
  
  /// Returns true if messages are currently loading
  bool get isLoading => _state == DiscussionState.loading;
  
  /// Returns true if the operation was successful
  bool get isSuccess => _state == DiscussionState.success;
  
  /// Returns true if there was an error
  bool get hasError => _state == DiscussionState.error;
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    super.dispose();
  }
}
