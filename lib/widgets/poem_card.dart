import 'package:flutter/material.dart';
import 'package:metaphora/models/poem.dart';
import 'package:like_button/like_button.dart';

class PoemCard extends StatelessWidget {
  final Poem poem;
  final VoidCallback onTap;
  final Future<void> Function(bool)? onLikePressed;

  const PoemCard({
    super.key,
    required this.poem,
    required this.onTap,
    this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Fixed height for Instagram-like cards
    final cardHeight = 480.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: cardHeight,
        decoration: BoxDecoration(
          color: theme.cardColor,
          border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      (poem.user?["username"] ?? "U").substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      poem.user?["username"] ?? "Unknown",
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            
            // Poem content container
            Expanded(
              child: Container(
                width: double.infinity,
                color: theme.colorScheme.surface,
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Poem title
                    Text(
                      poem.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Playfair Display',
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Poem preview
                    Text(
                      poem.content,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.8,
                        fontFamily: 'Merriweather',
                        letterSpacing: 0.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 8,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            
            // Engagement bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.dividerColor.withOpacity(0.1)),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  LikeButton(
                    size: 24,
                    likeCount: poem.likeCount,
                    countBuilder: (count, isLiked, text) {
                      return Text(
                        text,
                        style: TextStyle(
                          color: isLiked ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    },
                    isLiked: poem.isLiked ?? false,
                    onTap: onLikePressed != null
                        ? (isLiked) async {
                            await onLikePressed!(isLiked);
                            return !isLiked;
                          }
                        : null,
                  ),
                  
                  const SizedBox(width: 20),
                  
                  Icon(
                    Icons.mode_comment_outlined,
                    size: 22,
                    color: theme.colorScheme.onSurface,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    poem.commentCount.toString(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Category chip
                  if (poem.category != null && poem.category!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        poem.category!,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
