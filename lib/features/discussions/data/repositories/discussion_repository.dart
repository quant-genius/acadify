
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/message_model.dart';
import '../../domain/entities/message_entity.dart';
import 'dart:io';

/// Repository for handling message data operations
class DiscussionRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  
  /// Constructor for DiscussionRepository
  DiscussionRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService;
  
  /// Gets messages for a specific group
  ///
  /// [groupId] - The ID of the group to get messages for
  /// [limit] - The maximum number of messages to retrieve
  /// [lastMessageId] - The ID of the last message retrieved in the previous batch
  Future<List<MessageEntity>> getGroupMessages(
    String groupId, {
    int limit = 20,
    String? lastMessageId,
  }) async {
    try {
      Query query = _firestoreService.firestore
          .collection('messages')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (lastMessageId != null) {
        // Get the last document for pagination
        final lastDoc = await _firestoreService.firestore
            .collection('messages')
            .doc(lastMessageId)
            .get();
        
        query = query.startAfterDocument(lastDoc);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        return MessageModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Streams messages for a specific group
  ///
  /// [groupId] - The ID of the group to get messages for
  /// [limit] - The maximum number of messages to retrieve
  Stream<List<MessageEntity>> streamGroupMessages(
    String groupId, {
    int limit = 20,
  }) {
    try {
      return _firestoreService.firestore
          .collection('messages')
          .where('groupId', isEqualTo: groupId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) {
              return MessageModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList();
          });
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sends a message to a group
  ///
  /// [groupId] - The ID of the group to send the message to
  /// [senderId] - The ID of the user sending the message
  /// [content] - The message content
  /// [replyToId] - The ID of the message being replied to (optional)
  /// [attachment] - The file to attach to the message (optional)
  Future<MessageEntity> sendMessage({
    required String groupId,
    required String senderId,
    required String content,
    String? replyToId,
    File? attachment,
  }) async {
    try {
      // Upload attachment if provided
      String? attachmentUrl;
      if (attachment != null) {
        // Generate a temporary ID for the message
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        
        attachmentUrl = await _storageService.uploadMessageAttachment(
          groupId: groupId,
          messageId: tempId,
          file: attachment,
        );
      }
      
      // Create the message model
      final message = MessageModel(
        id: '',
        groupId: groupId,
        senderId: senderId,
        content: content,
        attachmentUrl: attachmentUrl,
        replyToId: replyToId,
      );
      
      // Add the message to Firestore
      final docRef = await _firestoreService.createDocument(
        'messages',
        message.toFirestore(),
      );
      
      // Return the message with the generated ID
      return message.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes a message
  ///
  /// [messageId] - The ID of the message to delete
  /// [permanent] - Whether to permanently delete the message
  Future<void> deleteMessage(String messageId, {bool permanent = false}) async {
    try {
      if (permanent) {
        // Get the message to access its attachment URL
        final messageDoc = await _firestoreService.getDocument('messages', messageId);
        final message = MessageModel.fromFirestore(
          messageDoc.data() as Map<String, dynamic>,
          messageDoc.id,
        );
        
        // Delete the attachment if it exists
        if (message.attachmentUrl != null && message.attachmentUrl!.isNotEmpty) {
          await _storageService.deleteFile(message.attachmentUrl!);
        }
        
        // Delete the message document
        await _firestoreService.deleteDocument('messages', messageId);
      } else {
        // Soft delete by marking as deleted
        await _firestoreService.updateDocument(
          'messages',
          messageId,
          {
            'isDeleted': true,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a specific message by ID
  ///
  /// [messageId] - The ID of the message to retrieve
  Future<MessageEntity> getMessage(String messageId) async {
    try {
      final doc = await _firestoreService.getDocument('messages', messageId);
      
      return MessageModel.fromFirestore(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets replies to a specific message
  ///
  /// [messageId] - The ID of the message to get replies for
  /// [limit] - The maximum number of replies to retrieve
  Future<List<MessageEntity>> getMessageReplies(
    String messageId, {
    int limit = 10,
  }) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        'messages',
        queryBuilder: (query) => query
            .where('replyToId', isEqualTo: messageId)
            .orderBy('createdAt', descending: true)
            .limit(limit),
      );
      
      return querySnapshot.docs.map((doc) {
        return MessageModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
