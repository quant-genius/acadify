
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/strings.dart';
import '../../core/utils/helpers.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/groups/presentation/providers/group_provider.dart';
import '../../features/assignments/presentation/providers/assignment_provider.dart';
import '../../routes/app_routes.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_bottom_nav_bar.dart';

/// Home screen of the application
class HomeScreen extends StatefulWidget {
  /// Creates a HomeScreen
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadData();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final groupProvider = Provider.of<GroupProvider>(context, listen: false);
      final assignmentProvider = Provider.of<AssignmentProvider>(context, listen: false);
      
      final userId = authProvider.currentUser!.id;
      
      // Load user's groups
      await groupProvider.loadUserGroups(userId);
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  void _navigateToCreateGroup() {
    Navigator.of(context).pushNamed(AppRoutes.createGroup);
  }
  
  void _navigateToSearch() {
    Navigator.of(context).pushNamed(AppRoutes.search);
  }
  
  void _navigateToProfile() {
    Navigator.of(context).pushNamed(AppRoutes.profile);
  }
  
  void _navigateToSettings() {
    Navigator.of(context).pushNamed(AppRoutes.settings);
  }
  
  void _navigateToNotifications() {
    Navigator.of(context).pushNamed(AppRoutes.notifications);
  }
  
  void _onBottomNavTap(int index) {
    // This would typically handle navigation between main screens
    // Since we're on the Home screen (index 0), we only need to
    // handle navigation away from Home
    switch (index) {
      case 0:
        // Already on Home, no action needed
        break;
      case 1:
        _navigateToSearch();
        break;
      case 2:
        _navigateToNotifications();
        break;
      case 3:
        _navigateToProfile();
        break;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final groupProvider = Provider.of<GroupProvider>(context);
    final assignmentProvider = Provider.of<AssignmentProvider>(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: const Text(AppStrings.appName),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _navigateToSearch,
            tooltip: AppStrings.search,
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: _navigateToNotifications,
            tooltip: AppStrings.notifications,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Text(
                      authProvider.currentUser?.initials ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authProvider.currentUser?.fullName ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    authProvider.currentUser?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text(AppStrings.home),
              selected: true,
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.group),
              title: const Text(AppStrings.groups),
              onTap: () {
                Navigator.of(context).pop();
                // Implementation would go to a groups list
              },
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text(AppStrings.assignments),
              onTap: () {
                Navigator.of(context).pop();
                // Implementation would go to assignments list
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(AppStrings.profile),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToProfile();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(AppStrings.settings),
              onTap: () {
                Navigator.of(context).pop();
                _navigateToSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text(AppStrings.logout),
              onTap: () async {
                Navigator.of(context).pop();
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting section
                      Text(
                        'Hello, ${authProvider.currentUser?.firstName ?? 'User'}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome to Acadify',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // My Groups section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            AppStrings.myGroups,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: authProvider.currentUser?.role.canCreateGroups ?? false
                                ? _navigateToCreateGroup
                                : null,
                            child: const Text(AppStrings.createGroup),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Groups list or empty state
                      SizedBox(
                        height: 130,
                        child: groupProvider.groups.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.group_off,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'You haven\'t joined any groups yet',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: groupProvider.groups.length,
                                itemBuilder: (context, index) {
                                  final group = groupProvider.groups[index];
                                  return _buildGroupCard(group);
                                },
                              ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Upcoming assignments section
                      const Text(
                        'Upcoming Assignments',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Assignments or empty state
                      Column(
                        children: [
                          // For demonstration purposes, show sample assignments
                          _buildAssignmentCard(
                            'CS101 Assignment 1',
                            'Introduction to Programming',
                            DateTime.now().add(const Duration(days: 2)),
                            'CS101 - Introduction to Programming',
                          ),
                          const SizedBox(height: 12),
                          _buildAssignmentCard(
                            'MATH201 Problem Set 3',
                            'Solve the problems from Chapter 5',
                            DateTime.now().add(const Duration(days: 5)),
                            'MATH201 - Calculus II',
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Recent discussions section
                      const Text(
                        'Recent Discussions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Discussions or empty state
                      Column(
                        children: [
                          // For demonstration purposes, show sample discussions
                          _buildDiscussionCard(
                            'John Smith',
                            'Has anyone started the assignment yet?',
                            DateTime.now().subtract(const Duration(hours: 2)),
                            'CS101 - Introduction to Programming',
                          ),
                          const SizedBox(height: 12),
                          _buildDiscussionCard(
                            'Sarah Johnson',
                            'When is the next lecture?',
                            DateTime.now().subtract(const Duration(hours: 5)),
                            'MATH201 - Calculus II',
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: _onBottomNavTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // This would typically show a quick action menu
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quick action button pressed'),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildGroupCard(dynamic group) {
    // This would use the actual GroupEntity in production
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(
          AppRoutes.group,
          arguments: group.id,
        );
      },
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: group.coverImageUrl != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(group.coverImageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              alignment: Alignment.center,
              child: group.coverImageUrl == null
                  ? Text(
                      group.name.substring(0, 2).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${group.memberCount} members',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAssignmentCard(
    String title,
    String description,
    DateTime dueDate,
    String groupName,
  ) {
    // Calculate days until due
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    // Determine if it's due soon (3 days or less)
    final isDueSoon = difference >= 0 && difference <= 3;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDueSoon ? Colors.orange : AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.assignment,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              DateFormat('MMM d').format(dueDate),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDueSoon ? Colors.orange : null,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isDueSoon
                  ? 'Due soon'
                  : 'In ${difference} days',
              style: TextStyle(
                fontSize: 12,
                color: isDueSoon ? Colors.orange : Colors.grey[600],
              ),
            ),
          ],
        ),
        onTap: () {
          // Navigate to assignment details
          // This would require the actual assignment ID and group ID
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing assignment: $title'),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDiscussionCard(
    String sender,
    String message,
    DateTime timestamp,
    String groupName,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryLight,
          child: Text(
            sender.substring(0, 1),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                sender,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              AppHelpers.getRelativeTime(timestamp),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.group,
                  size: 14,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  groupName,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () {
          // Navigate to discussion
          // This would require the actual group ID
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Viewing discussion in: $groupName'),
            ),
          );
        },
      ),
    );
  }
}
