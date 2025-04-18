import 'package:flutter/material.dart';
import 'package:metaphora/controllers/auth_controller.dart';
import 'package:metaphora/controllers/client/poem_controller.dart';
import 'package:metaphora/screens/explore/explore_screen.dart';
import 'package:metaphora/screens/favorites/favorites_screen.dart';
import 'package:metaphora/screens/home/poetry_feed_screen.dart';
import 'package:metaphora/screens/poem/create_poem_screen.dart';
import 'package:metaphora/screens/profile/profile_screen.dart';
import 'package:metaphora/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PoemController()),
      ],
      child: Consumer<AuthController>(
        builder: (context, authController, child) {
          return Scaffold(
            drawer: const AppDrawer(),
            appBar: _buildAppBar(context, authController),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                const PoetryFeedScreen(),
                const ExploreScreen(),
                const FavoritesScreen(),
                const ProfileScreen(),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const CreatePoemScreen(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                    transitionDuration: const Duration(milliseconds: 300),
                  ),
                );
              },
              backgroundColor: theme.colorScheme.primary,
              elevation: 4,
              child: const Icon(Icons.add),
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: _onTabTapped,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: theme.colorScheme.primary,
                unselectedItemColor: theme.colorScheme.onSurface.withOpacity(0.6),
                showSelectedLabels: true,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                ),
                elevation: 0,
                backgroundColor: theme.scaffoldBackgroundColor,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.explore_outlined),
                    activeIcon: Icon(Icons.explore),
                    label: 'Explore',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.bookmark_border_outlined),
                    activeIcon: Icon(Icons.bookmark),
                    label: 'Saved',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person),
                    label: 'Profile',
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  AppBar _buildAppBar(BuildContext context, AuthController authController) {
    final theme = Theme.of(context);
    final titles = ['Metaphora'];
    
    return AppBar(
      title: Text(
        titles[_currentIndex],
        style: theme.textTheme.titleLarge?.copyWith(
          fontFamily: 'Playfair Display',
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: false,
      elevation: 0,
      actions: [
        if (_currentIndex == 0 || _currentIndex == 1)
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Show search modal
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Search coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        if (_currentIndex == 3)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        if (authController.isAuthenticated)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Show notifications
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications coming soon'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
      ],
    );
  }
}
