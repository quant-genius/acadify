import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Model for onboarding page data
class OnboardingPage {
  /// Title text
  final String title;
  
  /// Description text
  final String description;
  
  /// Image asset path
  final String imagePath;
  
  /// Creates an OnboardingPage with the specified parameters
  const OnboardingPage({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

/// Screen for first-time user onboarding
class OnboardingScreen extends StatefulWidget {
  /// Creates an OnboardingScreen
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: 'Welcome to Acadify',
      description: 'Your all-in-one platform for academic communication and collaboration.',
      imagePath: '${AppAssets.imagesPath}/onboarding_1.png',
    ),
    const OnboardingPage(
      title: 'Structured Groups',
      description: 'Join course groups and access announcements, discussions, and assignments in one place.',
      imagePath: '${AppAssets.imagesPath}/onboarding_2.png',
    ),
    const OnboardingPage(
      title: 'Stay Organized',
      description: 'Keep track of deadlines, submit assignments, and communicate with peers and lecturers.',
      imagePath: '${AppAssets.imagesPath}/onboarding_3.png',
    ),
    const OnboardingPage(
      title: 'Secure & Private',
      description: 'Your academic information is kept secure with role-based access controls.',
      imagePath: '${AppAssets.imagesPath}/onboarding_4.png',
    ),
  ];
  
  @override
  void initState() {
    super.initState();
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }
  
  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  /// Marks onboarding as completed and navigates to login
  Future<void> _completeOnboarding() async {
    // Mark onboarding as completed in preferences
    final prefs = Provider.of<AuthProvider>(context, listen: false).getPrefs();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (!mounted) return;
    
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }
  
  /// Skips onboarding and navigates to login
  Future<void> _skipOnboarding() async {
    // Mark onboarding as completed in preferences
    final prefs = Provider.of<AuthProvider>(context, listen: false).getPrefs();
    await prefs.setBool('has_seen_onboarding', true);
    
    if (!mounted) return;
    
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button (only on pages before the last one)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: _skipOnboarding,
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image
                        Image.asset(
                          page.imagePath,
                          height: MediaQuery.of(context).size.height * 0.4,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 32),
                        
                        // Title
                        Text(
                          page.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        Text(
                          page.description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? AppColors.primary
                        : Colors.grey[300],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Next or Get Started button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _currentPage < _pages.length - 1
                      ? _nextPage
                      : _completeOnboarding,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _currentPage < _pages.length - 1
                        ? 'Next'
                        : 'Get Started',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
