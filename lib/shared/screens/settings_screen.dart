import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/constants/strings.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../shared/providers/app_provider.dart';
import '../../routes/app_routes.dart';

/// Settings screen with customization options
class SettingsScreen extends StatefulWidget {
  /// Creates a SettingsScreen
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  
  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }
  
  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appProvider = Provider.of<AppProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Account section
          const ListTile(
            title: Text(
              'Account',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            subtitle: const Text('View and edit your profile information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).pushNamed(AppRoutes.profile);
            },
          ),
          const Divider(),
          
          // Appearance section
          const ListTile(
            title: Text(
              'Appearance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Dark Mode'),
            subtitle: const Text('Toggle dark theme'),
            trailing: Switch(
              value: appProvider.isDarkMode,
              activeColor: AppColors.primary,
              onChanged: (value) {
                appProvider.setDarkMode(value);
              },
            ),
            onTap: () {
              appProvider.setDarkMode(!appProvider.isDarkMode);
            },
          ),
          const Divider(),
          
          // Notifications section
          const ListTile(
            title: Text(
              'Notifications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for important updates'),
            trailing: Switch(
              value: appProvider.arePushNotificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) {
                appProvider.setPushNotificationsEnabled(value);
              },
            ),
            onTap: () {
              appProvider.setPushNotificationsEnabled(
                !appProvider.arePushNotificationsEnabled,
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive email updates'),
            trailing: Switch(
              value: appProvider.areEmailNotificationsEnabled,
              activeColor: AppColors.primary,
              onChanged: (value) {
                appProvider.setEmailNotificationsEnabled(value);
              },
            ),
            onTap: () {
              appProvider.setEmailNotificationsEnabled(
                !appProvider.areEmailNotificationsEnabled,
              );
            },
          ),
          const Divider(),
          
          // Privacy & Security section
          const ListTile(
            title: Text(
              'Privacy & Security',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text('Change Password'),
            subtitle: const Text('Update your account password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to change password screen
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacy Policy'),
            subtitle: const Text('Read our privacy policy'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to privacy policy
            },
          ),
          ListTile(
            leading: const Icon(Icons.description),
            title: const Text('Terms of Service'),
            subtitle: const Text('Read our terms of service'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to terms of service
            },
          ),
          const Divider(),
          
          // Support section
          const ListTile(
            title: Text(
              'Support',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help Center'),
            subtitle: const Text('Get help and support'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to help center
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            subtitle: const Text('Send feedback to improve the app'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigate to feedback form
            },
          ),
          const Divider(),
          
          // About section
          const ListTile(
            title: Text(
              'About',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('App Version'),
            subtitle: Text(
              _packageInfo != null
                  ? '${_packageInfo!.version} (Build ${_packageInfo!.buildNumber})'
                  : 'Loading...',
            ),
            onTap: null,
          ),
          const Divider(),
          
          // Logout
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
            onTap: () {
              _handleLogout(context);
            },
          ),
        ],
      ),
    );
  }
  
  /// Handles logout action
  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Logout'),
          ),
        ],
      ),
    ) ?? false;
    
    if (shouldLogout) {
      await authProvider.logout();
      
      if (authProvider.isNotAuthenticated && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }
}
