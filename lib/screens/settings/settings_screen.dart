import 'package:flutter/material.dart';
import 'package:metaphora/controllers/auth_controller.dart';
import 'package:metaphora/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile section
            _buildProfileSection(context, theme),
            const Divider(height: 1),
            // Account Settings
            _buildSettingTile(
              theme,
              title: "Edit Profile",
              subtitle: "Update your profile information",
              icon: Icons.person_outline,
              onTap: () {
                // Navigate to edit profile screen
              },
            ),
            _buildSettingTile(
              theme,
              title: "Change Password",
              subtitle: "Change your account password",
              icon: Icons.lock_outline,
              onTap: () {
                // Navigate to change password screen
              },
            ),
            const Divider(height: 1),

            // Theme Settings
            _buildSettingTile(
              theme,
              title: "Theme",
              subtitle: "Switch between light and dark mode",
              icon: Icons.dark_mode_outlined,
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.setDarkMode(value),
              ),
            ),
            
            // Notifications
            _buildSettingTile(
              theme,
              title: "Notifications",
              subtitle: "Manage notification preferences",
              icon: Icons.notifications_outlined,
              onTap: () {
                // Navigate to notifications settings
              },
            ),
            
            const Divider(height: 1),
            
            // Privacy Settings
            _buildSettingTile(
              theme,
              title: "Privacy",
              subtitle: "Control your privacy settings",
              icon: Icons.lock_outline,
              onTap: () {
                // Navigate to privacy settings
              },
            ),
            
            // Help & Support
            _buildSettingTile(
              theme,
              title: "Help",
              subtitle: "Get help and support",
              icon: Icons.help_outline,
              onTap: () {
                // Navigate to help section
              },
            ),
            
            // About
            _buildSettingTile(
              theme,
              title: "About",
              subtitle: "Learn more about Metaphora",
              icon: Icons.info_outline,
              onTap: () {
                // Navigate to about section
              },
            ),
            
            const Divider(height: 1),
            
            // Logout
            _buildSettingTile(
              theme,
              title: "Log Out",
              subtitle: "Sign out of your account",
              icon: Icons.logout,
              onTap: () async {
                final authController = Provider.of<AuthController>(context, listen: false);
                await authController.logout();
              },
            ),
            
            // Data & storage section
            _buildSectionHeader(theme, "Data & Storage"),
            
            // Clear cache
            _buildSettingTile(
              theme,
              title: "Clear Cache",
              subtitle: "Free up space on your device",
              icon: Icons.cleaning_services_outlined,
              onTap: () {
                // Show clear cache dialog
                _showClearCacheDialog(context);
              },
            ),
            
            // Download data
            _buildSettingTile(
              theme,
              title: "Download Your Data",
              subtitle: "Get a copy of your poems and account information",
              icon: Icons.download_outlined,
              onTap: () {
                // Navigate to data download screen
              },
            ),
            
            // Help & support section
            _buildSectionHeader(theme, "Help & Support"),
            
            // FAQ
            _buildSettingTile(
              theme,
              title: "FAQ",
              subtitle: "Frequently asked questions",
              icon: Icons.help_outline,
              onTap: () {
                // Navigate to FAQ screen
              },
            ),
            
            // Contact us
            _buildSettingTile(
              theme,
              title: "Contact Us",
              subtitle: "Get help or send feedback",
              icon: Icons.support_agent,
              onTap: () {
                // Navigate to contact screen
              },
            ),
            
            // About
            _buildSettingTile(
              theme,
              title: "About Metaphora",
              subtitle: "Version 1.0.0",
              icon: Icons.info_outline,
              onTap: () {
                // Navigate to about screen
              },
            ),
            
            const SizedBox(height: 24),
            
            // Sign out button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Show sign out dialog
                  _showSignOutDialog(context);
                },
                icon: const Icon(Icons.logout),
                label: const Text("Sign Out"),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: theme.colorScheme.error),
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Delete account button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () {
                  // Show delete account dialog
                  _showDeleteAccountDialog(context);
                },
                child: Text(
                  "Delete Account",
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontFamily: 'Playfair Display',
        ),
      ),
    );
  }

  Widget _buildSettingTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Icon(icon, color: theme.colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodyMedium,
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, ThemeData theme) {
    final authController = Provider.of<AuthController>(context);
    final currentUser = authController.currentUser;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            child: const Icon(Icons.person, size: 40),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentUser?.username ?? '',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser?.email ?? '',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Cache"),
        content: const Text(
          "This will clear all cached data. Your poems and account information will not be affected.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              // Clear cache
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Cache cleared"),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              // Sign out
              Navigator.pop(context);
              // Navigate to login screen
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text(
          "This action cannot be undone. All your poems and account information will be permanently deleted.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            onPressed: () {
              // Delete account
              Navigator.pop(context);
              // Navigate to login screen
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
