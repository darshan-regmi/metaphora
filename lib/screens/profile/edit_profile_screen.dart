import 'package:flutter/material.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: "Alex Johnson");
  final _usernameController = TextEditingController(text: "poetryLover");
  final _bioController = TextEditingController(text: "Poetry enthusiast | Nature lover | Finding beauty in words");
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Show success message and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Text("Save"),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile picture
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                      child: Text(
                        "A",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 20,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Name field
              Text(
                "Name",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  hintText: "Your full name",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your name";
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Username field
              Text(
                "Username",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  hintText: "Your username",
                  prefixText: "@",
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter a username";
                  }
                  if (value.contains(" ")) {
                    return "Username cannot contain spaces";
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Bio field
              Text(
                "Bio",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  hintText: "Tell us about yourself",
                ),
                maxLines: 3,
                maxLength: 150,
              ),
              
              const SizedBox(height: 32),
              
              // Privacy settings section
              Text(
                "Privacy Settings",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildSwitchTile(
                theme,
                title: "Private Account",
                subtitle: "Only approved followers can see your poems",
                value: false,
                onChanged: (value) {},
              ),
              
              _buildSwitchTile(
                theme,
                title: "Show Email",
                subtitle: "Display your email on your public profile",
                value: true,
                onChanged: (value) {},
              ),
              
              const SizedBox(height: 32),
              
              // Notification settings section
              Text(
                "Notification Settings",
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 16),
              
              _buildSwitchTile(
                theme,
                title: "New Likes",
                subtitle: "Get notified when someone likes your poem",
                value: true,
                onChanged: (value) {},
              ),
              
              _buildSwitchTile(
                theme,
                title: "New Comments",
                subtitle: "Get notified when someone comments on your poem",
                value: true,
                onChanged: (value) {},
              ),
              
              _buildSwitchTile(
                theme,
                title: "New Followers",
                subtitle: "Get notified when someone follows you",
                value: true,
                onChanged: (value) {},
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    ThemeData theme, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
        value: value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
