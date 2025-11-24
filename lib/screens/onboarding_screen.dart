import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../utils/app_theme.dart';
import '../models/onboarding_model.dart';
import '../providers/onboarding_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingModel> _pages = [
     OnboardingModel(
       title: 'Instant Coverage Delivered Right to Your Fingertips',
      description: 'Say goodbye to paperwork and long waits — buy, manage, and renew policies quickly and securely from your mobile device.',
      imagePath: 'assets/images/onboarding1.png',
      buttonText: 'Next',
    ),
      OnboardingModel(
      title: 'Into a Future Built on Security and Confidence',
      description: 'No matter where life takes you, we provide the foundation you need to grow, explore, and thrive without fear.',
      imagePath: 'assets/images/onboarding2.png',
      buttonText: 'Get Started',
    ),
    OnboardingModel(
      title: 'Protect What Matters Most with Comprehensive Coverage',
      description: 'We offer personalized insurance solutions tailored to every stage of your life.',
      imagePath: 'assets/images/onboarding3.png',
      buttonText: 'Continue',
    ),
  
   
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    // Update provider
    context.read<OnboardingProvider>().setCurrentPage(page);
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    // Mark onboarding as completed
    context.read<OnboardingProvider>().completeOnboarding();
    
    // Navigate to user portal selection screen
    Navigator.of(context).pushReplacementNamed('/user-portal');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView with onboarding screens
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildOnboardingPage(_pages[index]);
            },
          ),
          
          // Skip button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: OutlinedButton(
              onPressed: _navigateToHome,
              child: const Text('Skip'),
            ),
          ),
          
          // Bottom section with indicator and button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Page indicator
                  SmoothPageIndicator(
                    controller: _pageController,
                    count: _pages.length,
                    effect: const WormEffect(
                      dotHeight: 8,
                      dotWidth: 8,
                      activeDotColor: AppTheme.primaryBlue,
                      dotColor: Colors.white30,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_pages[_currentPage].buttonText),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingModel page) {
    // Get page index to apply different overlays
    final pageIndex = _pages.indexOf(page);
    
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.darkBackground,
      ),
      child: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              page.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder(page);
              },
            ),
          ),
          
          // Gradient overlay - different for each screen
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: _getGradientForPage(pageIndex),
              ),
            ),
          ),
          
          // Content
          Positioned(
            bottom: 180,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  page.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  page.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.9),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Get gradient overlay based on page index
  LinearGradient _getGradientForPage(int pageIndex) {
    switch (pageIndex) {
      case 0: // Screen 2.png - Car/plane/animals
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.1),
            Colors.black.withOpacity(0.4),
            Colors.black.withOpacity(0.85),
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      case 1: // Screen 3.png - Woman with phone
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.2),
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.0, 0.6, 1.0],
        );
      case 2: // Screen 4.png - World map
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.3),
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.5, 1.0],
        );
      default:
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.9),
          ],
          stops: const [0.3, 0.7, 1.0],
        );
    }
  }
  
  Widget _buildImagePlaceholder(OnboardingModel page) {
    // Placeholder with different colors for each page
    final colors = [
      const Color(0xFF1A2332),
      const Color(0xFF2A3342),
      const Color(0xFF3A4352),
    ];
    
    return Container(
      color: colors[_pages.indexOf(page)],
      child: Center(
        child: Icon(
          Icons.image,
          size: 100,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}
