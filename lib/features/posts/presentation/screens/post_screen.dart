
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/helpers.dart';
import '../providers/post_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../routes/app_routes.dart';
import '../../../../shared/widgets/custom_app_bar.dart';

/// Screen for displaying a post's details
class PostScreen extends StatefulWidget {
  /// The ID of the post to display
  final String postId;
  
  /// Creates a PostScreen
  const PostScreen({
    Key? key,
    required this.postId,
  }) : super(key: key);

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load post data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false)
          .getPost(widget.postId);
    });
  }
  
  void _toggleLike() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final currentUserId = authProvider.user?.id;
    
    if (currentUserId != null) {
      postProvider.toggleLike(widget.postId, currentUserId);
    }
  }
  
  void _togglePin() {
    Provider.of<PostProvider>(context, listen: false)
        .togglePin(widget.postId);
  }
  
  void _navigateToEdit() {
    Navigator.of(context).pushNamed(
      AppRoutes.editPost,
      arguments: widget.postId,
    );
  }
  
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final postProvider = Provider.of<PostProvider>(context, listen: false);
              final success = await postProvider.deletePost(widget.postId);
              
              if (success && mounted) {
                Navigator.pop(context); // Go back to previous screen
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(postProvider.errorMessage ?? 'Failed to delete post')),
                );
              }
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
  
  void _showAttachment(String url) {
    if (Helpers.isImageFile(url)) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.black,
              iconTheme: const IconThemeData(color: Colors.white),
            ),
            backgroundColor: Colors.black,
            body: Center(
              child: InteractiveViewer(
                child: Image.network(url),
              ),
            ),
          ),
        ),
      );
    } else {
      // TODO: Handle other file types (e.g., download, open in browser)
      Helpers.launchUrl(url);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final post = postProvider.selectedPost;
    final currentUser = authProvider.user;
    
    if (postProvider.isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Post',
          showBackButton: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (post == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Post Not Found',
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                'Post not found',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
    
    final isAuthor = post.authorId == currentUser?.id;
    final isLiked = currentUser != null && post.isLikedBy(currentUser.id);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: post.category.capitalize(),
        showBackButton: true,
        actions: [
          if (isAuthor)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _navigateToEdit();
                } else if (value == 'delete') {
                  _showDeleteConfirmation();
                } else if (value == 'pin') {
                  _togglePin();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: const [
                      Icon(Icons.edit, size: 18),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'pin',
                  child: Row(
                    children: [
                      Icon(
                        post.isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(post.isPinned ? 'Unpin' : 'Pin'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: const [
                      Icon(Icons.delete, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post header (author, time)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Author avatar
                FutureBuilder<Map<String, dynamic>>(
                  future: _getUserData(post.authorId),
                  builder: (context, snapshot) {
                    final hasData = snapshot.hasData && snapshot.data != null;
                    final photoUrl = hasData ? snapshot.data!['photoUrl'] as String? : null;
                    final userName = hasData 
                        ? '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}' 
                        : 'User';
                    
                    return CircleAvatar(
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
                    );
                  },
                ),
                const SizedBox(width: 12),
                
                // Author name and post time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<Map<String, dynamic>>(
                        future: _getUserData(post.authorId),
                        builder: (context, snapshot) {
                          final hasData = snapshot.hasData && snapshot.data != null;
                          final userName = hasData 
                              ? '${snapshot.data!['firstName']} ${snapshot.data!['lastName']}' 
                              : 'User';
                          
                          return Text(
                            userName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 2),
                      Text(
                        post.createdAt != null
                            ? timeago.format(post.createdAt!)
                            : 'Just now',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Category and pin indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(post.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getCategoryName(post.category),
                        style: TextStyle(
                          color: _getCategoryColor(post.category),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (post.isPinned) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Pinned',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
            
            const Divider(height: 32),
            
            // Post title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Post content
            Text(
              post.content,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            
            // Post attachments
            if (post.hasAttachments) ...[
              const SizedBox(height: 24),
              const Text(
                'Attachments',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: post.attachments.length,
                itemBuilder: (context, index) {
                  final attachment = post.attachments[index];
                  final isImage = Helpers.isImageFile(attachment);
                  
                  return GestureDetector(
                    onTap: () => _showAttachment(attachment),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
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
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getFileIcon(attachment),
                                    size: 48,
                                    color: Colors.grey[700],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _getFileName(attachment),
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  );
                },
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Like and comment actions
            Row(
              children: [
                // Like button
                OutlinedButton.icon(
                  onPressed: _toggleLike,
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : null,
                    size: 20,
                  ),
                  label: Text(
                    '${post.likeCount} ${post.likeCount == 1 ? 'Like' : 'Likes'}',
                    style: TextStyle(
                      color: isLiked ? Colors.red : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isLiked ? Colors.red : Colors.grey[300]!,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Comment button (in a future iteration)
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implement comments feature
                  },
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: const Text('Comments'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
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
  
  String _getFileName(String url) {
    try {
      return url.split('/').last.split('?').first;
    } catch (e) {
      return 'File';
    }
  }
  
  IconData _getFileIcon(String url) {
    final extension = Helpers.getFileExtension(url).toLowerCase();
    
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
      case '.zip':
      case '.rar':
        return Icons.folder_zip;
      case '.txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }
  
  Future<Map<String, dynamic>> _getUserData(String userId) async {
    // In a real app, this would fetch data from AuthRepository
    // For now, we'll return a mock user
    await Future.delayed(const Duration(milliseconds: 500));
    
    return {
      'firstName': 'John',
      'lastName': 'Doe',
      'photoUrl': null,
    };
  }
}

/// Extension to capitalize first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
