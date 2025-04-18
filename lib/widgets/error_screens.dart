import 'package:flutter/material.dart';

class ErrorScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final Widget? customAction;

  const ErrorScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.error_outline,
    this.onRetry,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;
    
    return Container(
      decoration: BoxDecoration(
        color: isLight ? const Color(0xFFFAF3E0) : const Color(0xFF121212),
        image: DecorationImage(
          image: AssetImage(
            isLight ? 'assets/images/light_paper_texture.png'
                   : 'assets/images/dark_paper_texture.png',
          ),
          opacity: 0.05,
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 64,
                color: theme.colorScheme.error,
              ),
              
              const SizedBox(height: 24),
              
              Text(
                title,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                  color: isLight ? const Color(0xFF333333) : const Color(0xFFEAEAEA),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              Text(
                message,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Montserrat',
                  color: isLight 
                    ? const Color(0xFF333333).withOpacity(0.8)
                    : const Color(0xFFEAEAEA).withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 32),
              
              if (onRetry != null)
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              
              if (customAction != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: customAction!,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class NetworkErrorScreen extends StatelessWidget {
  final VoidCallback onRetry;

  const NetworkErrorScreen({
    super.key,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      icon: Icons.wifi_off_rounded,
      title: 'No Connection',
      message: 'Please check your internet connection and try again. Don\'t worry, your changes are saved offline.',
      onRetry: onRetry,
    );
  }
}

class PostFailureScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onSaveAsDraft;

  const PostFailureScreen({
    super.key,
    required this.onRetry,
    required this.onSaveAsDraft,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return ErrorScreen(
      icon: Icons.cloud_off_rounded,
      title: 'Posting Failed',
      message: 'Unable to post your poem right now. You can try again or save it as a draft.',
      onRetry: onRetry,
      customAction: TextButton(
        onPressed: onSaveAsDraft,
        child: Text(
          'Save as Draft',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class EmptyStateScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  const EmptyStateScreen({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return ErrorScreen(
      icon: icon,
      title: title,
      message: message,
      customAction: action,
    );
  }
}
