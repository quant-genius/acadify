
import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../shared/screens/home_screen.dart';
import '../shared/screens/splash_screen.dart';
import '../shared/screens/onboarding_screen.dart';
import '../shared/screens/settings_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/discussions/presentation/screens/discussion_screen.dart';
import '../features/assignments/presentation/screens/assignment_screen.dart';

/// Class for handling app routes
class AppRoutes {
  // Route names
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String group = '/group';
  static const String groupMembers = '/group/members';
  static const String createGroup = '/create-group';
  static const String editGroup = '/edit-group';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String postDetail = '/post/detail';
  static const String createPost = '/post/create';
  static const String editPost = '/post/edit';
  static const String discussion = '/discussion';
  static const String assignment = '/assignment';
  static const String createAssignment = '/assignment/create';
  static const String editAssignment = '/assignment/edit';
  static const String submitAssignment = '/assignment/submit';
  static const String assignmentSubmissions = '/assignment/submissions';
  static const String settings = '/settings';
  static const String search = '/search';
  static const String notifications = '/notifications';
  
  /// Generates a route based on settings
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
        
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
        
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
        
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
        
      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());
        
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
        
      case group:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Group')),
            body: const Center(child: Text('Group Screen - Implement Me')),
          ),
        );
        
      case groupMembers:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Group Members')),
            body: const Center(child: Text('Group Members Screen - Implement Me')),
          ),
        );
        
      case createGroup:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Create Group')),
            body: const Center(child: Text('Create Group Screen - Implement Me')),
          ),
        );
        
      case editGroup:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Edit Group')),
            body: const Center(child: Text('Edit Group Screen - Implement Me')),
          ),
        );
        
      case profile:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: userId),
        );
        
      case editProfile:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Edit Profile')),
            body: const Center(child: Text('Edit Profile Screen - Implement Me')),
          ),
        );
        
      case postDetail:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Post Detail')),
            body: const Center(child: Text('Post Detail Screen - Implement Me')),
          ),
        );
        
      case createPost:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Create Post')),
            body: const Center(child: Text('Create Post Screen - Implement Me')),
          ),
        );
        
      case editPost:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Edit Post')),
            body: const Center(child: Text('Edit Post Screen - Implement Me')),
          ),
        );
        
      case discussion:
        final args = settings.arguments as Map<String, String>;
        final groupId = args['groupId']!;
        final groupName = args['groupName']!;
        return MaterialPageRoute(
          builder: (_) => DiscussionScreen(
            groupId: groupId,
            groupName: groupName,
          ),
        );
        
      case assignment:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => AssignmentScreen(
            groupId: args['groupId']!,
            assignmentId: args['assignmentId']!,
          ),
        );
        
      case createAssignment:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Create Assignment')),
            body: const Center(child: Text('Create Assignment Screen - Implement Me')),
          ),
        );
        
      case editAssignment:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Edit Assignment')),
            body: const Center(child: Text('Edit Assignment Screen - Implement Me')),
          ),
        );
        
      case submitAssignment:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Submit Assignment')),
            body: const Center(child: Text('Submit Assignment Screen - Implement Me')),
          ),
        );
        
      case assignmentSubmissions:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Assignment Submissions')),
            body: const Center(child: Text('Assignment Submissions Screen - Implement Me')),
          ),
        );
        
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case search:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Search')),
            body: const Center(child: Text('Search Screen - Implement Me')),
          ),
        );
        
      case notifications:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Notifications')),
            body: const Center(child: Text('Notifications Screen - Implement Me')),
          ),
        );
        
      default:
        // If route is not defined, return to login screen
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
  
  // Private constructor to prevent instantiation
  AppRoutes._();
}
