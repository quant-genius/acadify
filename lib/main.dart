
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/config/app_config.dart';
import 'core/services/notification_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/groups/presentation/providers/group_provider.dart';
import 'features/posts/presentation/providers/post_provider.dart';
import 'features/discussions/presentation/providers/discussion_provider.dart';
import 'features/assignments/presentation/providers/assignment_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';
import 'shared/providers/app_provider.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize shared preferences
  final prefs = await SharedPreferences.getInstance();
  
  // Initialize notification service
  await NotificationService().init();
  
  // Set up app configuration
  final appConfig = AppConfig.fromEnvironment();
  
  runApp(MyApp(
    prefs: prefs,
    appConfig: appConfig,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AppConfig appConfig;
  
  const MyApp({
    Key? key,
    required this.prefs,
    required this.appConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(prefs: prefs)),
        ChangeNotifierProvider(create: (_) => GroupProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => DiscussionProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) {
          return MaterialApp(
            title: 'Acadify',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: Colors.deepPurple,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              fontFamily: 'Poppins',
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark().copyWith(
              primaryColor: Colors.deepPurple,
              colorScheme: ColorScheme.dark(
                primary: Colors.deepPurple,
                secondary: Colors.purpleAccent,
              ),
              useMaterial3: true,
            ),
            themeMode: appProvider.themeMode,
            initialRoute: AppRoutes.splash,
            onGenerateRoute: AppRoutes.onGenerateRoute,
          );
        },
      ),
    );
  }
}
