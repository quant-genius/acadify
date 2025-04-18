
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/helpers.dart';
import '../providers/group_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../posts/presentation/providers/post_provider.dart';
import '../../../posts/presentation/widgets/post_item.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../../routes/app_routes.dart';

/// Screen for displaying a group's details and posts
class GroupScreen extends StatefulWidget {
  /// The ID of the group to display
  final String groupId;
  
  /// Creates a GroupScreen
  const GroupScreen({
    Key? key,
    required this.groupId,
  }) : super(key: key);

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize tab controller for the different sections
    _tabController = TabController(length: 3, vsync: this);
    
    // Load group data and posts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    // Load group data
    await Provider.of<GroupProvider>(context, listen: false)
        .getGroup(widget.groupId);
    
    // Load posts for the group
    await Provider.of<PostProvider>(context, listen: false)
        .loadGroupPosts(widget.groupId);
  }
  
  void _navigateToDiscussion() {
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    
    if (group != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.discussion,
        arguments: {
          'groupId': group.id,
          'groupName': group.name,
        },
      );
    }
  }
  
  void _navigateToCreatePost() {
    Navigator.of(context).pushNamed(
      AppRoutes.createPost,
      arguments: widget.groupId,
    );
  }
  
  void _showGroupOptions() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final groupProvider = Provider.of<GroupProvider>(context, listen: false);
    final group = groupProvider.selectedGroup;
    final currentUser = authProvider.user;
    
    if (group == null || currentUser == null) return;
    
    final isCreator = group.isCreator(currentUser.id);
    final isMember = group.isMember(currentUser.id);
    
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
                leading: const Icon(Icons.group),
                title: const Text('View Members'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushNamed(
                    AppRoutes.groupMembers,
                    arguments: group.id,
                  );
                },
              ),
              if (isCreator)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit Group'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed(
                      AppRoutes.editGroup,
                      arguments: group.id,
                    );
                  },
                ),
              if (isMember && !isCreator)
                ListTile(
                  leading: const Icon(Icons.exit_to_app),
                  title: const Text('Leave Group'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLeaveGroup(currentUser.id);
                  },
                ),
              if (isCreator)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Delete Group',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmDeleteGroup();
                  },
                ),
            ],
          ),
        );
      },
    );
  }
  
  void _confirmLeaveGroup(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: const Text('Are you sure you want to leave this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final groupProvider = Provider.of<GroupProvider>(context, listen: false);
              final success = await groupProvider.leaveGroup(widget.groupId, userId);
              
              if (success && mounted) {
                Navigator.of(context).pop(); // Go back to groups list
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(groupProvider.errorMessage ?? 'Failed to leave group')),
                );
              }
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
  
  void _confirmDeleteGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: const Text(
          'Are you sure you want to delete this group? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final groupProvider = Provider.of<GroupProvider>(context, listen: false);
              final success = await groupProvider.deleteGroup(widget.groupId);
              
              if (success && mounted) {
                Navigator.of(context).pop(); // Go back to groups list
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(groupProvider.errorMessage ?? 'Failed to delete group')),
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
  
  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final postProvider = Provider.of<PostProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final group = groupProvider.selectedGroup;
    final posts = postProvider.groupPosts;
    final currentUser = authProvider.user;
    
    final isLoading = groupProvider.isLoading || 
                      (postProvider.isLoading && posts.isEmpty);
    
    if (isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Loading...',
          showBackButton: true,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (group == null) {
      return Scaffold(
        appBar: const CustomAppBar(
          title: 'Group Not Found',
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
                'Group not found',
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
    
    return Scaffold(
      appBar: CustomAppBar(
        title: group.name,
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: _showGroupOptions,
          ),
        ],
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: _buildGroupHeader(group),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey[600],
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'About'),
                    Tab(text: 'Members'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Posts tab
            _buildPostsTab(posts, currentUser),
            
            // About tab
            _buildAboutTab(group),
            
            // Members tab
            _buildMembersTab(group),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }
  
  Widget _buildGroupHeader(GroupEntity group) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Group photo/avatar
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary.withOpacity(0.2),
                backgroundImage: group.photoUrl != null
                    ? CachedNetworkImageProvider(group.photoUrl!)
                    : null,
                child: group.photoUrl == null
                    ? Text(
                        Helpers.getInitials(group.name),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              
              // Group info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.fullCourseName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.academicYear} • ${group.semester}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${group.memberCount} members',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Group description
          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              group.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildPostsTab(List<PostEntity> posts, UserEntity? currentUser) {
    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noPosts,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _navigateToCreatePost,
              icon: const Icon(Icons.add),
              label: const Text('Create Post'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<PostProvider>(context, listen: false)
            .loadGroupPosts(widget.groupId);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: PostItem(post: post),
          );
        },
      ),
    );
  }
  
  Widget _buildAboutTab(GroupEntity group) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course information
          const Text(
            'Course Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Course Code', group.courseCode),
          _buildInfoRow('Course Name', group.name),
          if (group.department != null)
            _buildInfoRow('Department', group.department!),
          if (group.faculty != null)
            _buildInfoRow('Faculty', group.faculty!),
          _buildInfoRow('Semester', group.semester),
          _buildInfoRow('Academic Year', group.academicYear),
          
          // Creator information
          const SizedBox(height: 24),
          const Text(
            'Group Creator',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<UserEntity>(
            future: _getUserData(group.creatorId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              
              final creator = snapshot.data;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: creator?.photoUrl != null
                      ? CachedNetworkImageProvider(creator!.photoUrl!)
                      : null,
                  child: creator?.photoUrl == null
                      ? Text(
                          creator?.initials ?? '',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                ),
                title: Text(creator?.fullName ?? 'Unknown User'),
                subtitle: Text(creator?.email ?? ''),
              );
            },
          ),
          
          // Group creation date
          const SizedBox(height: 24),
          _buildInfoRow(
            'Created',
            group.createdAt != null
                ? Helpers.formatDate(group.createdAt!)
                : 'Unknown',
          ),
          _buildInfoRow(
            'Last Updated',
            group.updatedAt != null
                ? Helpers.formatDate(group.updatedAt!)
                : 'Unknown',
          ),
        ],
      ),
    );
  }
  
  Widget _buildMembersTab(GroupEntity group) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: group.members.length,
      itemBuilder: (context, index) {
        final memberId = group.members[index];
        final isCreator = memberId == group.creatorId;
        
        return FutureBuilder<UserEntity>(
          future: _getUserData(memberId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(
                leading: CircleAvatar(
                  child: CircularProgressIndicator(),
                ),
                title: Text('Loading...'),
              );
            }
            
            final member = snapshot.data;
            
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: isCreator
                    ? AppColors.primary.withOpacity(0.2)
                    : Colors.grey[200],
                backgroundImage: member?.photoUrl != null
                    ? CachedNetworkImageProvider(member!.photoUrl!)
                    : null,
                child: member?.photoUrl == null
                    ? Text(
                        member?.initials ?? '',
                        style: TextStyle(
                          color: isCreator
                              ? AppColors.primary
                              : Colors.grey[700],
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(member?.fullName ?? 'Unknown User'),
              subtitle: Text(member?.role.name.toUpperCase() ?? ''),
              trailing: isCreator
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Creator',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : null,
            );
          },
        );
      },
    );
  }
  
  Widget _buildFloatingActionButton() {
    // Show different FAB based on the current tab
    switch (_tabController.index) {
      case 0: // Posts tab
        return FloatingActionButton(
          onPressed: _navigateToCreatePost,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add),
        );
      case 1: // About tab
        return const SizedBox.shrink();
      case 2: // Members tab
        return const SizedBox.shrink();
      default:
        return const SizedBox.shrink();
    }
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
  
  Future<UserEntity> _getUserData(String userId) async {
    // In a real app, this would fetch data from AuthRepository
    // For now, we'll return a mock user
    // This would be replaced with a proper implementation
    return const UserEntity(
      id: '1',
      email: 'user@example.com',
      firstName: 'John',
      lastName: 'Doe',
      studentId: '123456',
      role: UserRole.student,
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  
  _SliverAppBarDelegate(this.tabBar);
  
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }
  
  @override
  double get maxExtent => tabBar.preferredSize.height;
  
  @override
  double get minExtent => tabBar.preferredSize.height;
  
  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar;
  }
}
