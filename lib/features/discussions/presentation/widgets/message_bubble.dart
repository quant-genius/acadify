
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/message_entity.dart';
import '../../../../core/constants/colors.dart';

/// Widget for displaying a message in a chat bubble
class MessageBubble extends StatelessWidget {
  /// The message to display
  final MessageEntity message;
  
  /// Whether the message is from the current user
  final bool isCurrentUser;
  
  /// Creates a MessageBubble
  const MessageBubble({
    Key? key,
    required this.message,
    required this.isCurrentUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Create default timestamp
    final messageTime = message.createdAt ?? DateTime.now();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sender avatar (only for received messages)
          if (!isCurrentUser)
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blueGrey.shade200,
              child: Text(
                message.senderId.isNotEmpty
                    ? message.senderId[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          
          const SizedBox(width: 8),
          
          // Message content
          Flexible(
            child: InkWell(
              onLongPress: () {
                // This would show message options in a future implementation
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCurrentUser ? AppColors.primary : Colors.grey[200],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Sender ID (only for received messages)
                    if (!isCurrentUser && message.senderId.isNotEmpty) ...[
                      Text(
                        "User ${message.senderId}",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.purple.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                    
                    // Message text
                    Text(
                      message.content,
                      style: TextStyle(
                        color: isCurrentUser ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    
                    // Timestamp
                    const SizedBox(height: 4),
                    Text(
                      timeago.format(messageTime),
                      style: TextStyle(
                        color: isCurrentUser
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Empty space for alignment of sent messages
          if (isCurrentUser) const SizedBox(width: 32),
        ],
      ),
    );
  }
}
