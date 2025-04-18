import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

class TutorialOverlay extends StatefulWidget {
  const TutorialOverlay({super.key});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TutorialTip> _tips = [
    TutorialTip(
      title: "Swipe Between Poems",
      description: "Swipe left or right to navigate between poems in your feed",
      icon: Icons.swipe,
      position: Alignment.center,
    ),
    TutorialTip(
      title: "Double Tap to Like",
      description: "Double tap anywhere on a poem to like it instantly",
      icon: Icons.favorite,
      position: Alignment.center,
    ),
    TutorialTip(
      title: "Long Press for Actions",
      description: "Long press to access quick actions like save, share, or adjust text size",
      icon: Icons.more_horiz,
      position: Alignment.bottomCenter,
    ),
    TutorialTip(
      title: "Pull to Refresh",
      description: "Pull down to refresh and see new poems in your feed",
      icon: Icons.refresh,
      position: Alignment.topCenter,
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

  Future<void> _completeTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Material(
      color: Colors.black54,
      child: Stack(
        children: [
          // Tutorial content
          PageView.builder(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            itemCount: _tips.length,
            itemBuilder: (context, index) {
              final tip = _tips[index];
              return Stack(
                children: [
                  // Tip content
                  Align(
                    alignment: tip.position,
                    child: Container(
                      margin: const EdgeInsets.all(32),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            tip.icon,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            tip.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Playfair Display',
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            tip.description,
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom controls
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
                    _tips.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentPage
                            ? theme.colorScheme.primary
                            : theme.colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Next/Done button
                SizedBox(
                  width: size.width * 0.8,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _tips.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeTutorial();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: Text(
                      _currentPage < _tips.length - 1 ? "Next" : "Got it!",
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _completeTutorial,
              child: Text(
                "Skip",
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TutorialTip {
  final String title;
  final String description;
  final IconData icon;
  final Alignment position;

  const TutorialTip({
    required this.title,
    required this.description,
    required this.icon,
    required this.position,
  });
}
