
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/profile_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../routes/app_routes.dart';

/// Screen for viewing a user's profile
class ProfileScreen extends StatefulWidget {
  /// ID of the user whose profile to display
  final String? userId;
  
  /// Creates a ProfileScreen
  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _userId;
  
  @override
  void initState() {
    super.initState();
    
    // If userId is not provided, use current user's ID
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    _userId = widget.userId ?? authProvider.currentUser!.id;
    
    // Load the profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }
  
  Future<void> _loadProfile() async {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    await profileProvider.loadUserProfile(_userId);
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.userProfile;
    
    // Check if this is the current user's profile
    final isCurrentUser = authProvider.currentUser?.id == _userId;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.profile),
        actions: [
          if (isCurrentUser)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.editProfile);
              },
            ),
        ],
      ),
      body: profileProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Profile not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      
                      // Profile image
                      Center(
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: profile.photoUrl != null
                              ? CachedNetworkImageProvider(profile.photoUrl!)
                              : null,
                          child: profile.photoUrl == null
                              ? Text(
                                  profile.initials,
                                  style: const TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Name
                      Text(
                        profile.fullName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      
                      // Role badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          profile.role,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Profile details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          children: [
                            // Bio section if available
                            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                              _buildSection(
                                title: 'Bio',
                                content: profile.bio!,
                              ),
                              const SizedBox(height: 24),
                            ],
                            
                            // Contact information
                            _buildSection(
                              title: 'Contact Information',
                              items: [
                                _buildInfoRow(
                                  icon: Icons.email,
                                  title: 'Email',
                                  value: profile.email,
                                ),
                                if (profile.phoneNumber != null)
                                  _buildInfoRow(
                                    icon: Icons.phone,
                                    title: 'Phone',
                                    value: profile.phoneNumber!,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            
                            // Academic information
                            _buildSection(
                              title: 'Academic Information',
                              items: [
                                if (profile.faculty != null)
                                  _buildInfoRow(
                                    icon: Icons.school,
                                    title: 'Faculty',
                                    value: profile.faculty!,
                                  ),
                                if (profile.department != null)
                                  _buildInfoRow(
                                    icon: Icons.business,
                                    title: 'Department',
                                    value: profile.department!,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildSection({
    required String title,
    String? content,
    List<Widget>? items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const Divider(),
        const SizedBox(height: 8),
        if (content != null)
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
            ),
          )
        else if (items != null)
          Column(
            children: items,
          )
        else
          const Text('No information available'),
      ],
    );
  }
  
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
