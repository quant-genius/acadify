
import 'package:flutter/material.dart';

import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/groups/presentation/screens/group_screen.dart';
import '../features/groups/presentation/screens/group_members_screen.dart';
import '../features/groups/presentation/screens/create_group_screen.dart';
import '../features/groups/presentation/screens/edit_group_screen.dart';
import '../features/assignments/presentation/screens/assignment_screen.dart';
import '../features/assignments/presentation/screens/create_assignment_screen.dart';
import '../features/assignments/presentation/screens/edit_assignment_screen.dart';
import '../features/assignments/presentation/screens/assignment_submission_screen.dart';
import '../features/assignments/presentation/screens/assignment_submissions_list_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/posts/presentation/screens/post_detail_screen.dart';
import '../features/posts/presentation/screens/create_post_screen.dart';
import '../features/posts/presentation/screens/edit_post_screen.dart';
import '../features/discussions/presentation/screens/discussion_screen.dart';
import '../shared/screens/home_screen.dart';
import '../shared/screens/search_screen.dart';
import '../shared/screens/notifications_screen.dart';
import '../shared/screens/settings_screen.dart';
import '../shared/screens/splash_screen.dart';
import '../shared/screens/onboarding_screen.dart';

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
          builder: (_) => GroupScreen(groupId: groupId),
        );
        
      case groupMembers:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => GroupMembersScreen(groupId: groupId),
        );
        
      case createGroup:
        return MaterialPageRoute(builder: (_) => const CreateGroupScreen());
        
      case editGroup:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditGroupScreen(groupId: groupId),
        );
        
      case profile:
        final userId = settings.arguments as String?;
        return MaterialPageRoute(
          builder: (_) => ProfileScreen(userId: userId),
        );
        
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
        
      case postDetail:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => PostDetailScreen(
            groupId: args['groupId']!,
            postId: args['postId']!,
          ),
        );
        
      case createPost:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => CreatePostScreen(groupId: groupId),
        );
        
      case editPost:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => EditPostScreen(
            groupId: args['groupId']!,
            postId: args['postId']!,
          ),
        );
        
      case discussion:
        final groupId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => DiscussionScreen(groupId: groupId),
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
          builder: (_) => CreateAssignmentScreen(groupId: groupId),
        );
        
      case editAssignment:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => EditAssignmentScreen(
            groupId: args['groupId']!,
            assignmentId: args['assignmentId']!,
          ),
        );
        
      case submitAssignment:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => AssignmentSubmissionScreen(
            groupId: args['groupId']!,
            assignmentId: args['assignmentId']!,
          ),
        );
        
      case assignmentSubmissions:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
          builder: (_) => AssignmentSubmissionsListScreen(
            groupId: args['groupId']!,
            assignmentId: args['assignmentId']!,
          ),
        );
        
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
        
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
        
      default:
        // If route is not defined, return to login screen
        return MaterialPageRoute(builder: (_) => const LoginScreen());
    }
  }
  
  AppRoutes._(); // Private constructor to prevent instantiation
}
