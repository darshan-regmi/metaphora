import 'package:flutter/material.dart';

import 'package:metaphora/models/poem.dart';

class PoemActionsSheet extends StatelessWidget {
  final Poem poem;

  const PoemActionsSheet({
    super.key,
    required this.poem,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Poem Actions',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Actions List
            ListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListTile(
                  leading: Icon(Icons.bookmark_add_outlined, color: theme.colorScheme.primary),
                  title: Text('Save to Collection', style: theme.textTheme.titleMedium),
                  onTap: () {
                    // TODO: Implement save to collection
                    Navigator.pop(context);
                  },
                ),
                
                ListTile(
                  leading: Icon(Icons.share_outlined, color: theme.colorScheme.primary),
                  title: Text('Share Poem', style: theme.textTheme.titleMedium),
                  onTap: () {
                    // TODO: Implement share
                    Navigator.pop(context);
                  },
                ),
                
                ListTile(
                  leading: Icon(Icons.text_increase, color: theme.colorScheme.primary),
                  title: Text('Adjust Text Size', style: theme.textTheme.titleMedium),
                  onTap: () {
                    // TODO: Implement text size adjustment
                    Navigator.pop(context);
                  },
                ),
                
                ListTile(
                  leading: Icon(Icons.report_outlined, color: theme.colorScheme.error),
                  title: Text('Report', style: theme.textTheme.titleMedium),
                  onTap: () {
                    // TODO: Implement report
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
