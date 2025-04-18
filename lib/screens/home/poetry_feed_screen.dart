import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:metaphora/controllers/client/poem_controller.dart';
import 'package:metaphora/controllers/auth_controller.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/screens/poem/poem_view_screen.dart';
import 'package:metaphora/screens/poem/create_poem_screen.dart';

class PoetryFeedScreen extends StatefulWidget {
  const PoetryFeedScreen({super.key});

  @override
  State<PoetryFeedScreen> createState() => _PoetryFeedScreenState();
}

class _PoetryFeedScreenState extends State<PoetryFeedScreen> {
  final ScrollController _scrollController = ScrollController();
  late PoemController _poemController;
  
  @override
  void initState() {
    super.initState();
    _poemController = Provider.of<PoemController>(context, listen: false);
    _poemController.setContext(context);
    _poemController.initialize(context);
    
    _scrollController.addListener(_scrollListener);
  }
  
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollListener() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _poemController.loadMorePoems();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Feed',
          style: TextStyle(
            fontFamily: 'Playfair Display',
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Consumer<PoemController>(
        builder: (context, poemController, child) {
          if (poemController.isLoading && poemController.poems.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          
          if (poemController.poems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No poems yet',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to share your poetry',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Create Poem'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreatePoemScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }
          
          return RefreshIndicator(
            onRefresh: () => poemController.refreshPoems(),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: poemController.poems.length + (poemController.hasMorePoems ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == poemController.poems.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                final poem = poemController.poems[index];
                return PoemCard(
                  poem: poem,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PoemViewScreen(
                          poemId: poem.id!,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreatePoemScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PoemCard extends StatelessWidget {
  final Poem poem;
  final VoidCallback onTap;
  
  const PoemCard({
    super.key,
    required this.poem,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final poemController = Provider.of<PoemController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author info
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    child: Text(
                      poem.user != null && poem.user!['username'] != null
                          ? poem.user!['username'].substring(0, 1).toUpperCase()
                          : 'A',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poem.user != null && poem.user!['username'] != null
                              ? poem.user!['username']
                              : 'Anonymous',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (poem.createdAt != null)
                          Text(
                            _formatDate(poem.createdAt!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (authController.currentUser != null && 
                      poem.userId == authController.currentUser!.id)
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert),
                      onSelected: (value) {
                        if (value == 'edit') {
                          // Navigate to edit poem screen
                        } else if (value == 'delete') {
                          _showDeleteConfirmation(context, poem);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Poem title
              Text(
                poem.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Poem content (truncated)
              Text(
                _truncateContent(poem.content),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontFamily: 'Merriweather',
                  height: 1.5,
                ),
              ),
              
              if (_isContentTruncated(poem.content))
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: onTap,
                    child: const Text('Read more'),
                  ),
                ),
              
              const SizedBox(height: 16),
              
              // Category tag
              if (poem.category != null && poem.category!.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    Chip(
                      label: Text(
                        '#${poem.category}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white : Colors.black87,
                        ),
                      ),
                      backgroundColor: isDarkMode 
                          ? Colors.grey[800] 
                          : Colors.grey[200],
                      padding: const EdgeInsets.all(0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ],
                ),
              
              const SizedBox(height: 16),
              
              // Interaction buttons
              Row(
                children: [
                  _buildInteractionButton(
                    context,
                    icon: Icons.favorite_border,
                    activeIcon: Icons.favorite,
                    count: poem.likeCount,
                    onPressed: () async {
                      if (authController.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You need to be logged in to like poems'),
                          ),
                        );
                        return;
                      }
                      
                      await poemController.likePoem(poem.id!);
                    },
                    isActive: false, // Will be updated with FutureBuilder
                  ),
                  _buildInteractionButton(
                    context,
                    icon: Icons.comment_outlined,
                    activeIcon: Icons.comment,
                    count: poem.commentCount,
                    onPressed: onTap,
                    isActive: false,
                  ),
                  _buildInteractionButton(
                    context,
                    icon: Icons.bookmark_border,
                    activeIcon: Icons.bookmark,
                    onPressed: () async {
                      if (authController.currentUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('You need to be logged in to save poems'),
                          ),
                        );
                        return;
                      }
                      
                      await poemController.savePoem(poem.id!);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Poem saved to your collection'),
                        ),
                      );
                    },
                    isActive: false, // Will be updated with FutureBuilder
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      // Share poem
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildInteractionButton(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required VoidCallback onPressed,
    int? count,
    required bool isActive,
  }) {
    return FutureBuilder<bool>(
      future: _checkInteractionStatus(context),
      builder: (context, snapshot) {
        final isActiveState = snapshot.data ?? isActive;
        
        return TextButton.icon(
          onPressed: onPressed,
          icon: Icon(
            isActiveState ? activeIcon : icon,
            color: isActiveState 
                ? Theme.of(context).colorScheme.primary
                : null,
            size: 20,
          ),
          label: count != null
              ? Text(
                  count.toString(),
                  style: TextStyle(
                    color: isActiveState 
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                )
              : const SizedBox.shrink(),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            minimumSize: const Size(0, 36),
          ),
        );
      },
    );
  }
  
  Future<bool> _checkInteractionStatus(BuildContext context) async {
    // This would be replaced with actual checks based on the button type
    return false;
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
  
  String _truncateContent(String content) {
    const maxLength = 150;
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }
  
  bool _isContentTruncated(String content) {
    return content.length > 150;
  }
  
  void _showDeleteConfirmation(BuildContext context, Poem poem) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poem'),
        content: const Text('Are you sure you want to delete this poem? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<PoemController>(context, listen: false).deletePoem(poem.id!);
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
