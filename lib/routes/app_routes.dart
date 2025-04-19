
import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/groups/presentation/screens/group_screen.dart';
import '../features/posts/presentation/screens/post_screen.dart';
import '../features/discussions/presentation/screens/discussion_screen.dart';
import '../features/assignments/presentation/screens/assignment_screen.dart';
import '../shared/screens/home_screen.dart';
import '../shared/screens/splash_screen.dart';
import '../shared/screens/onboarding_screen.dart';
import '../shared/screens/search_screen.dart';
import '../shared/screens/notifications_screen.dart';
import '../shared/screens/settings_screen.dart';

/// Application route definitions
class AppRoutes {
  // Static route names
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String group = '/group';
  static const String createGroup = '/create-group';
  static const String post = '/post';
  static const String createPost = '/create-post';
  static const String discussion = '/discussion';
  static const String assignment = '/assignment';
  static const String createAssignment = '/create-assignment';
  static const String search = '/search';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  
  /// Route generator for the application
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
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
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case group:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => GroupScreen(groupId: groupId),
        );
      case post:
        final postId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => PostScreen(postId: postId),
        );
      case discussion:
        final groupId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => DiscussionScreen(groupId: groupId),
        );
      case assignment:
        final assignmentId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => AssignmentScreen(assignmentId: assignmentId),
        );
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
  
  // Private constructor to prevent instantiation
  AppRoutes._();
}
