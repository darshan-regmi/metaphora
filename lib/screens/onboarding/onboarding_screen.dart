import 'package:flutter/material.dart';

import 'package:metaphora/screens/auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: "Discover Poetry",
      description: "Explore a world of emotions and creativity through beautiful poems from writers around the globe.",
      image: "assets/images/onboarding_discover.png",
      color: const Color(0xFF5E35B1),
    ),
    OnboardingPage(
      title: "Express Yourself",
      description: "Write and share your own poems in a supportive community that celebrates creativity and self-expression.",
      image: "assets/images/onboarding_write.png",
      color: const Color(0xFF3949AB),
    ),
    OnboardingPage(
      title: "Connect with Poets",
      description: "Follow your favorite poets, engage with their work, and build meaningful connections through the power of words.",
      image: "assets/images/onboarding_connect.png",
      color: const Color(0xFF00897B),
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
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Page View
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(context, _pages[index]);
            },
          ),
          
          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _navigateToLogin,
              child: Text(
                "Skip",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          
          // Bottom indicators and button
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => _buildPageIndicator(index == _currentPage),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Next or Get Started button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage == _pages.length - 1) {
                          _navigateToLogin();
                        } else {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: _pages[_currentPage].color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1 ? "Get Started" : "Next",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _pages[_currentPage].color,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(BuildContext context, OnboardingPage page) {
    final theme = Theme.of(context);
    
    return Container(
      color: page.color,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Placeholder for image
            Container(
              width: 280,
              height: 280,
              margin: const EdgeInsets.only(bottom: 40),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  _getIconForPage(page.title),
                  size: 120,
                  color: Colors.white,
                ),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                page.title,
                style: theme.textTheme.displayMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                page.description,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: isActive ? 12 : 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  IconData _getIconForPage(String title) {
    switch (title) {
      case "Discover Poetry":
        return Icons.auto_stories;
      case "Express Yourself":
        return Icons.edit_note;
      case "Connect with Poets":
        return Icons.people;
      default:
        return Icons.book;
    }
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}
