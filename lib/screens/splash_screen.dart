import 'dart:async';
import 'package:flutter/material.dart';
import 'package:metaphora/screens/main_navigation_screen.dart';
import 'package:metaphora/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _quoteIndex = 0;
  final List<String> _poetryQuotes = [
    "Poetry is the rhythmical creation of beauty in words.",
    "Words are, of course, the most powerful drug used by mankind.",
    "Poetry is when an emotion has found its thought and the thought has found words.",
    "A poem begins as a lump in the throat, a sense of wrong, a homesickness, a lovesickness.",
    "Poetry is the spontaneous overflow of powerful feelings.",
  ];

  @override
  void initState() {
    super.initState();
    _startQuoteRotation();
    _navigateToLogin();
  }

  void _startQuoteRotation() {
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _quoteIndex = (_quoteIndex + 1) % _poetryQuotes.length;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToLogin() async {
    // Wait for a few seconds to display the splash screen
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;
    
    // Check if this is the first time the user is opening the app
    final prefs = await SharedPreferences.getInstance();
    final isFirstTime = prefs.getBool('first_time') ?? true;
    
    if (isFirstTime) {
      // Set first_time to false for future app opens
      await prefs.setBool('first_time', false);
      
      // Navigate to onboarding for first-time users
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // Navigate to main navigation for returning users
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            Text(
              "M",
              style: theme.textTheme.displayLarge?.copyWith(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // App Name
            Text(
              "Metaphora",
              style: theme.textTheme.displayMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // App Tagline
            Text(
              "Share your poetic journey",
              style: theme.textTheme.titleMedium,
            ),
            
            const SizedBox(height: 60),
            
            // Poetry Quote
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _poetryQuotes[_quoteIndex],
                key: ValueKey<int>(_quoteIndex),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  fontFamily: 'Merriweather',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // Loading Indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                strokeWidth: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
