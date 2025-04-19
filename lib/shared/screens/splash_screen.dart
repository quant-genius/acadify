
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/assets.dart';
import '../../features/auth/domain/enums/auth_state.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Splash screen shown when the app first loads
class SplashScreen extends StatefulWidget {
  /// Creates a SplashScreen
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Check auth state and navigate after a delay
    Future.delayed(const Duration(seconds: 3), () {
      _checkAuthAndNavigate();
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _checkAuthAndNavigate() async {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for authentication state to be determined
    if (authProvider.authState == AuthState.initial) {
      await Future.delayed(const Duration(seconds: 1));
    }
    
    if (!mounted) return;
    
    if (authProvider.isAuthenticated) {
      // If user is authenticated, go to home screen
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // If first time user, show onboarding, otherwise go to login
      final prefs = authProvider.getPrefs();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (hasSeenOnboarding) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeInAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Hero(
                tag: 'logo',
                child: Image.asset(
                  AppAssets.logoImage,
                  width: size.width * 0.4,
                  height: size.width * 0.4,
                ),
              ),
              const SizedBox(height: 24),
              
              // App name with typing animation
              AnimatedTextKit(
                animatedTexts: [
                  TypewriterAnimatedText(
                    'Acadify',
                    textStyle: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    speed: const Duration(milliseconds: 150),
                  ),
                ],
                isRepeatingAnimation: false,
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 8),
              
              // Tagline
              Text(
                'Connect. Learn. Succeed.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 48),
              
              // Loading indicator
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
