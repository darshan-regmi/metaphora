import 'package:flutter/material.dart';

import 'package:metaphora/screens/auth/login_screen.dart';
import 'package:metaphora/screens/profile/profile_screen.dart';
import 'package:metaphora/screens/settings/settings_screen.dart';
import 'package:metaphora/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // User profile section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                children: [
                  // User avatar
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      "A",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // User name
                  Text(
                    "Darshan Remgi",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  // Username
                  Text(
                    "@poetryLover",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // View profile button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close drawer
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 40),
                    ),
                    child: const Text("View Profile"),
                  ),
                ],
              ),
            ),
            
            const Divider(),
            
            // Menu items
            _buildMenuItem(
              context,
              icon: Icons.home_outlined,
              title: "Home",
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
              delay: 400,
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.bookmark_border,
              title: "Saved Poems",
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
              delay: 500,
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.favorite_border,
              title: "Liked Poems",
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
              delay: 600,
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.history,
              title: "Reading History",
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
              delay: 700,
            ),
            
            const Divider(),
            
            // Theme toggle
            ListTile(
              leading: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                "Dark Mode",
                style: theme.textTheme.titleMedium,
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) {
                  themeProvider.setDarkMode(value);
                },
                activeColor: theme.colorScheme.primary,
              ),
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.settings_outlined,
              title: "Settings",
              onTap: () {
                Navigator.pop(context); // Close drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
              delay: 900,
            ),
            
            _buildMenuItem(
              context,
              icon: Icons.help_outline,
              title: "Help & Feedback",
              onTap: () {
                Navigator.pop(context); // Close drawer
              },
              delay: 1000,
            ),
            
            const Spacer(),
            
            // Logout button
            _buildMenuItem(
              context,
              icon: Icons.logout,
              title: "Logout",
              onTap: () {
                Navigator.pop(context); // Close drawer
                _showLogoutDialog(context);
              },
              delay: 1100,
              isLogout: true,
            ),
            
            const SizedBox(height: 16),
            
            // App version
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Metaphora v1.0.0",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required int delay,
    bool isLogout = false,
  }) {
    final theme = Theme.of(context);
    
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? theme.colorScheme.error : theme.colorScheme.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: isLogout ? theme.colorScheme.error : null,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
