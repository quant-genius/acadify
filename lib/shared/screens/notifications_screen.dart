
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/services/notification_service.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Model class for notifications
class NotificationItem {
  /// Unique ID of the notification
  final String id;
  
  /// Title of the notification
  final String title;
  
  /// Body text of the notification
  final String body;
  
  /// When the notification was received
  final DateTime timestamp;
  
  /// Whether the notification has been read
  final bool isRead;
  
  /// Type of notification (assignment, post, etc.)
  final String type;
  
  /// Associated data (e.g., group ID, post ID)
  final Map<String, String>? data;
  
  /// Creates a NotificationItem
  const NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.isRead,
    required this.type,
    this.data,
  });
}

/// Screen for displaying user notifications
class NotificationsScreen extends StatefulWidget {
  /// Creates a NotificationsScreen
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _error;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id;
      
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      // For now, let's create some sample notifications
      // In a production app, this would fetch from a real backend
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _notifications.clear();
        _notifications.addAll([
          NotificationItem(
            id: '1',
            title: 'New Assignment',
            body: 'A new assignment has been posted in CS101 group.',
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
            isRead: false,
            type: 'assignment',
            data: {'groupId': 'group1', 'assignmentId': 'assignment1'},
          ),
          NotificationItem(
            id: '2',
            title: 'Assignment Due Soon',
            body: 'Your Physics assignment is due in 24 hours.',
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
            isRead: true,
            type: 'assignment',
            data: {'groupId': 'group2', 'assignmentId': 'assignment2'},
          ),
          NotificationItem(
            id: '3',
            title: 'New Discussion Message',
            body: 'John Smith posted in the Math 101 discussion.',
            timestamp: DateTime.now().subtract(const Duration(days: 2)),
            isRead: true,
            type: 'discussion',
            data: {'groupId': 'group3'},
          ),
        ]);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }
  
  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        final notification = _notifications[index];
        _notifications[index] = NotificationItem(
          id: notification.id,
          title: notification.title,
          body: notification.body,
          timestamp: notification.timestamp,
          isRead: true,
          type: notification.type,
          data: notification.data,
        );
      }
    });
    
    // In a production app, this would update the read status on the backend
  }
  
  void _markAllAsRead() {
    setState(() {
      for (int i = 0; i < _notifications.length; i++) {
        final notification = _notifications[i];
        if (!notification.isRead) {
          _notifications[i] = NotificationItem(
            id: notification.id,
            title: notification.title,
            body: notification.body,
            timestamp: notification.timestamp,
            isRead: true,
            type: notification.type,
            data: notification.data,
          );
        }
      }
    });
    
    // In a production app, this would update all read statuses on the backend
  }
  
  void _handleNotificationTap(NotificationItem notification) {
    _markAsRead(notification.id);
    
    // Navigate based on notification type
    if (notification.data != null) {
      switch (notification.type) {
        case 'assignment':
          if (notification.data!.containsKey('groupId') && 
              notification.data!.containsKey('assignmentId')) {
            Navigator.of(context).pushNamed(
              AppRoutes.assignment,
              arguments: {
                'groupId': notification.data!['groupId']!,
                'assignmentId': notification.data!['assignmentId']!,
              },
            );
          }
          break;
          
        case 'discussion':
          if (notification.data!.containsKey('groupId')) {
            Navigator.of(context).pushNamed(
              AppRoutes.discussion,
              arguments: notification.data!['groupId']!,
            );
          }
          break;
          
        case 'post':
          if (notification.data!.containsKey('groupId') &&
              notification.data!.containsKey('postId')) {
            Navigator.of(context).pushNamed(
              AppRoutes.postDetail,
              arguments: {
                'groupId': notification.data!['groupId']!,
                'postId': notification.data!['postId']!,
              },
            );
          }
          break;
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.notifications),
        actions: [
          if (_notifications.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.done_all),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error loading notifications: $_error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_off,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No notifications yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'You will see your notifications here',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _loadNotifications,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _buildNotificationTile(notification);
                        },
                      ),
                    ),
    );
  }
  
  Widget _buildNotificationTile(NotificationItem notification) {
    return InkWell(
      onTap: () => _handleNotificationTap(notification),
      child: Container(
        decoration: BoxDecoration(
          color: notification.isRead ? null : AppColors.primaryLight.withOpacity(0.1),
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.3),
              width: 1,
            ),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getNotificationColor(notification.type),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Notification content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            
            // Unread indicator
            if (!notification.isRead)
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'assignment':
        return Icons.assignment;
      case 'discussion':
        return Icons.forum;
      case 'post':
        return Icons.post_add;
      case 'group':
        return Icons.group;
      default:
        return Icons.notifications;
    }
  }
  
  Color _getNotificationColor(String type) {
    switch (type) {
      case 'assignment':
        return Colors.orange;
      case 'discussion':
        return Colors.green;
      case 'post':
        return Colors.blue;
      case 'group':
        return Colors.purple;
      default:
        return AppColors.primary;
    }
  }
}
