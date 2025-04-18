
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../domain/entities/post_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/post_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/utils/helpers.dart';
import '../../../../routes/app_routes.dart';

/// Widget for displaying a post item
class PostItem extends StatelessWidget {
  /// The post to display
  final PostEntity post;
  
  /// Creates a PostItem
  const PostItem({
    Key? key,
    required this.post,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final currentUserId = authProvider.user?.id ?? '';
    final isLiked = post.isLikedBy(currentUserId);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRoutes.postDetail,
            arguments: post.id,
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header with author info, time, and options
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author avatar (uses FutureBuilder to get author data)
                  FutureBuilder<Map<String, dynamic>>(
                    future: _getUserData(post.authorId),
                    builder: (context, snapshot) {
                      final hasData = snapshot.hasData && snapshot.data != null;
                      final photoUrl = hasData ? snapshot.data!['photoUrl'] as String? : null;
                      final userName = hasData 
                          ? '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}' 
                          : 'User';
                      
                      return Column(
                        children: [
                          CircleAvatar(
                            radius: 24,
                            backgroundColor: AppColors.primary.withOpacity(0.2),
                            backgroundImage: photoUrl != null
                                ? CachedNetworkImageProvider(photoUrl)
                                : null,
                            child: photoUrl == null
                                ? Text(
                                    Helpers.getInitials(userName),
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: 72,
                            child: Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  
                  // Post content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Post metadata (category, time)
                        Row(
                          children: [
                            // Category
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(post.category).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _getCategoryName(post.category),
                                style: TextStyle(
                                  color: _getCategoryColor(post.category),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            
                            // Time
                            Text(
                              post.createdAt != null
                                  ? timeago.format(post.createdAt!)
                                  : 'Just now',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            
                            // Show if pinned
                            if (post.isPinned) ...[
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.push_pin,
                                size: 14,
                                color: AppColors.accent,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // Post title
                        Text(
                          post.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Post content (truncated)
                        Text(
                          post.content,
                          style: const TextStyle(fontSize: 14),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Post attachments (if any)
            if (post.hasAttachments) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.attachment,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${post.attachmentCount} attachment${post.attachmentCount > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 80,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: post.attachments.length,
                        itemBuilder: (context, index) {
                          final attachment = post.attachments[index];
                          final isImage = Helpers.isImageFile(attachment);
                          
                          return Container(
                            width: 80,
                            height: 80,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            child: isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: attachment,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[200],
                                        child: const Icon(Icons.broken_image),
                                      ),
                                    ),
                                  )
                                : Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getFileIcon(attachment),
                                          color: Colors.grey[700],
                                          size: 32,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Helpers.getFileExtension(attachment).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Post actions (like, comment, etc.)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  // Like button
                  IconButton(
                    onPressed: () {
                      postProvider.toggleLike(post.id, currentUserId);
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked ? Colors.red : Colors.grey[700],
                    ),
                  ),
                  Text(
                    post.likeCount.toString(),
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Comment button
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.postDetail,
                        arguments: post.id,
                      );
                    },
                    icon: Icon(
                      Icons.comment_outlined,
                      color: Colors.grey[700],
                    ),
                  ),
                  const Text('0'), // Placeholder for comment count
                  
                  const Spacer(),
                  
                  // More options
                  if (post.authorId == currentUserId) ...[
                    IconButton(
                      onPressed: () {
                        _showPostOptions(context);
                      },
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper method to get category color
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'announcement':
        return AppColors.announcementColor;
      case 'assignment':
        return AppColors.assignmentColor;
      case 'discussion':
        return AppColors.discussionColor;
      case 'resource':
        return AppColors.resourceColor;
      default:
        return AppColors.primary;
    }
  }
  
  // Helper method to get category display name
  String _getCategoryName(String category) {
    switch (category.toLowerCase()) {
      case 'announcement':
        return 'Announcement';
      case 'assignment':
        return 'Assignment';
      case 'discussion':
        return 'Discussion';
      case 'resource':
        return 'Resource';
      default:
        return 'General';
    }
  }
  
  // Helper method to get file icon
  IconData _getFileIcon(String filePath) {
    final extension = Helpers.getFileExtension(filePath);
    
    switch (extension) {
      case '.pdf':
        return Icons.picture_as_pdf;
      case '.doc':
      case '.docx':
        return Icons.description;
      case '.xls':
      case '.xlsx':
        return Icons.table_chart;
      case '.ppt':
      case '.pptx':
        return Icons.slideshow;
      case '.txt':
        return Icons.text_snippet;
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  // Helper method to get user data
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    // In a real app, this would fetch data from Firestore
    // For now, we'll return mock data
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'firstName': 'John',
      'lastName': 'Doe',
      'photoUrl': null,
    };
  }
  
  // Helper method to show post options
  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Post'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed(
                    AppRoutes.editPost,
                    arguments: post.id,
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  post.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                ),
                title: Text(post.isPinned ? 'Unpin Post' : 'Pin Post'),
                onTap: () {
                  Navigator.of(context).pop();
                  Provider.of<PostProvider>(context, listen: false)
                      .togglePin(post.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Post',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  _confirmDeletePost(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  // Helper method to confirm post deletion
  void _confirmDeletePost(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<PostProvider>(context, listen: false)
                  .deletePost(post.id)
                  .then((success) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted')),
                  );
                }
              });
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
