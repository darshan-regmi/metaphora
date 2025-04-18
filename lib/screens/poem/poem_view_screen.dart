import 'package:flutter/material.dart' hide ScrollDirection;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:like_button/like_button.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/models/comment.dart';
import 'package:metaphora/controllers/client/poem_controller.dart';
import 'package:metaphora/widgets/poem_actions_sheet.dart';
import 'package:provider/provider.dart';

class PoemViewScreen extends StatefulWidget {
  final int poemId;
  final Function(Poem)? onPoemChanged;

  const PoemViewScreen({
    super.key,
    required this.poemId,
    this.onPoemChanged,
  });

  @override
  State<PoemViewScreen> createState() => _PoemViewScreenState();
}

class _PoemViewScreenState extends State<PoemViewScreen> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _fadeController;
  
  bool _showAppBar = true;
  bool _isScrolling = false;
  Offset? _dragStartPosition;
  double _dragDistance = 0.0;
  
  // For accessibility and theme
  late final FocusNode _poemFocusNode;
  final double _textScaleFactor = 1.0;
  bool _isDarkMode = false; // Will be set in didChangeDependencies
  double _fontSize = 16.0; // Default size
  bool _isHighContrastMode = false;
  
  // Theme constants
  static const Color _lightBackground = Color(0xFFFAF3E0); // Warm white
  static const Color _lightText = Color(0xFF333333); // Dark grey
  static const Color _darkBackground = Color(0xFF121212); // Deep black
  static const Color _darkText = Color(0xFFEAEAEA); // Soft white
  static const Color _lightAccent = Color(0xFF2D5A88); // Muted blue
  static const Color _darkAccent = Color(0xFF4A90E2); // Bright blue
  
  Poem? _poem;
  bool _isLoading = false;
  String? _errorMessage;
  List<Comment>? _comments;
  bool _loadingComments = false;
  bool _isLiked = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _poemFocusNode = FocusNode();
    
    // Set semantic labels for accessibility
    _poemFocusNode.debugLabel = 'Poem Content';
    
    // Initialize haptic feedback for enhanced interaction
    HapticFeedback.mediumImpact();
    
    // Configure system UI overlay style for a more immersive experience
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));
    
    // Initialize poem controller and load data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final poemController = Provider.of<PoemController>(context, listen: false);
      poemController.setContext(context);
      _loadPoemData();
    });
  }
  
  // Load poem data
  Future<void> _loadPoemData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final poemController = Provider.of<PoemController>(context, listen: false);
      final poem = await poemController.getPoemById(widget.poemId);
      
      if (poem != null) {
        setState(() {
          _poem = poem;
          _isLoading = false;
        });
        
        // Load comments
        _loadComments();
        
        // Check if user has liked/saved this poem
        _checkUserInteractions();
      } else {
        setState(() {
          _errorMessage = 'Poem not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading poem: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
  
  // Load comments for this poem
  Future<void> _loadComments() async {
    if (_poem == null) return;
    
    setState(() {
      _loadingComments = true;
    });
    
    try {
      final poemController = Provider.of<PoemController>(context, listen: false);
      final comments = await poemController.getComments(_poem!.id!);
      
      setState(() {
        _comments = comments;
        _loadingComments = false;
      });
    } catch (e) {
      print('Error loading comments: ${e.toString()}');
      setState(() {
        _loadingComments = false;
      });
    }
  }
  
  // Check if user has liked or saved this poem
  Future<void> _checkUserInteractions() async {
    if (_poem == null) return;
    
    try {
      final poemController = Provider.of<PoemController>(context, listen: false);
      final isLiked = await poemController.hasUserLikedPoem(_poem!.id!);
      final isSaved = await poemController.hasUserSavedPoem(_poem!.id!);
      
      setState(() {
        _isLiked = isLiked;
        _isSaved = isSaved;
      });
    } catch (e) {
      print('Error checking user interactions: ${e.toString()}');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Initialize theme and accessibility settings
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    
    setState(() {
      _isDarkMode = theme.brightness == Brightness.dark;
      _fontSize = theme.textTheme.bodyLarge?.fontSize ?? 16.0;
      _isHighContrastMode = mediaQuery.highContrast;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _fadeController.dispose();
    _poemFocusNode.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.userScrollDirection != ScrollDirection.idle) {
      setState(() {
        _isScrolling = true;
        _showAppBar = _scrollController.position.userScrollDirection == ScrollDirection.reverse ? false : true;
      });
      
      // Reset scrolling state after a delay
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isScrolling = false;
          });
        }
      });
    }
  }

  void _handleDoubleTap() async {
    HapticFeedback.selectionClick();
    // Trigger like animation and update
    setState(() {
      // Toggle like state
    });
  }

  void _handleLongPress() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      builder: (context) => PoemActionsSheet(poem: _poem!),
      backgroundColor: Colors.transparent,
    );
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartPosition = details.globalPosition;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dragStartPosition != null) {
      _dragDistance = details.globalPosition.dx - _dragStartPosition!.dx;
      _fadeController.value = (1.0 - (_dragDistance.abs() / 200)).clamp(0.0, 1.0);
    }
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    if (_dragDistance.abs() > 100 && _poem != null && _poem!.id != null) {
      // Trigger poem change
      if (_dragDistance > 0) {
        // Previous poem
        Provider.of<PoemController>(context, listen: false).getPreviousPoem(_poem!.id!).then((poem) {
          if (poem != null && widget.onPoemChanged != null && mounted) {
            widget.onPoemChanged!(poem);
          }
        });
      } else {
        // Next poem
        Provider.of<PoemController>(context, listen: false).getNextPoem(_poem!.id!).then((poem) {
          if (poem != null && widget.onPoemChanged != null && mounted) {
            widget.onPoemChanged!(poem);
          }
        });
      }
    }
    _dragStartPosition = null;
    _dragDistance = 0.0;
    _fadeController.animateTo(1.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final textScaleFactor = MediaQuery.textScaleFactorOf(context) * _textScaleFactor;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedOpacity(
          opacity: _showAppBar ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.8),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_border, 
                  color: theme.colorScheme.onSurface
                ),
                onPressed: () {
                  if (_poem == null) return;
                  
                  final poemController = Provider.of<PoemController>(context, listen: false);
                  poemController.savePoem(_poem!.id!).then((_) {
                    setState(() {
                      _isSaved = !_isSaved;
                    });
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isSaved 
                          ? "Poem saved to your collection" 
                          : "Poem removed from your collection"
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.share, color: theme.colorScheme.onSurface),
                onPressed: () {
                  // Share poem
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Sharing is not available yet"),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: _isLoading 
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _loadPoemData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : _poem == null
                  ? const Center(
                      child: Text('No poem found'),
                    )
                  : GestureDetector(
                      onDoubleTap: _handleDoubleTap,
                      onLongPress: _handleLongPress,
                      onHorizontalDragStart: _handleHorizontalDragStart,
                      onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                      onHorizontalDragEnd: _handleHorizontalDragEnd,
                      child: Container(
                        width: size.width,
                        height: size.height,
                        color: _isDarkMode ? _darkBackground : _lightBackground,
                        child: FadeTransition(
                          opacity: _fadeController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: kToolbarHeight + 24),
                                
                                // Author info
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                                      child: Text(
                                        (_poem?.user?["username"] ?? "U").substring(0, 1).toUpperCase(),
                                        style: TextStyle(
                                          color: theme.colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _poem?.user?["username"] ?? "Unknown",
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          "Posted ${_getTimeAgo(_poem?.createdAt ?? DateTime.now())}",
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Poem title
                                Text(
                                  _poem?.title ?? "",
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Playfair Display',
                                  ),
                                ),
                                
                                const SizedBox(height: 8),
                                
                                // Category
                                if (_poem?.category?.isNotEmpty ?? false)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      _poem?.category ?? "",
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                
                                const SizedBox(height: 32),
                                
                                // Poem content
                                Text(
                                  _poem?.content ?? "",
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    height: 1.8,
                                    fontFamily: 'Merriweather',
                                    fontSize: _fontSize,
                                  ),
                                  semanticsLabel: 'Poem content: ${_poem?.title} by ${_poem?.user?["username"] ?? "Unknown"}'
                                ),
                                
                                const SizedBox(height: 40),
                                
                                // Engagement buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildEngagementButton(
                                      icon: LikeButton(
                                        size: 28,
                                        likeCount: _poem?.likeCount ?? 0,
                                        countBuilder: (count, isLiked, text) {
                                          return Text(
                                            text,
                                            style: TextStyle(
                                              color: isLiked ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                            ),
                                          );
                                        },
                                        isLiked: _isLiked,
                                        onTap: (isLiked) async {
                                          await _handleLikePressed();
                                          return !isLiked;
                                        },
                                      ),
                                      label: "Like",
                                      onTap: _handleLikePressed,
                                    ),
                                    _buildEngagementButton(
                                      icon: Icon(
                                        Icons.comment_outlined,
                                        size: 28,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                      label: "Comment (${_poem?.commentCount ?? 0})",
                                      onTap: () {
                                        // Show comments
                                        _showCommentsBottomSheet(context);
                                      },
                                    ),
                                    _buildEngagementButton(
                                      icon: Icon(
                                        _isSaved ? Icons.bookmark : Icons.bookmark_border,
                                        size: 28,
                                        color: _isSaved ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                                      ),
                                      label: "Save",
                                      onTap: () {
                                        if (_poem == null) return;
                                        
                                        final poemController = Provider.of<PoemController>(context, listen: false);
                                        poemController.savePoem(_poem!.id!).then((_) {
                                          setState(() {
                                            _isSaved = !_isSaved;
                                          });
                                          
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(_isSaved 
                                                ? "Poem saved to your collection" 
                                                : "Poem removed from your collection"
                                              ),
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 40),
                                
                                // Swipe indicators
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 24),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_back_ios,
                                        size: 16,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Swipe to navigate",
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
    );
  }

  // Handle like button press
  Future<void> _handleLikePressed() async {
    if (_poem == null) return;
    
    try {
      final poemController = Provider.of<PoemController>(context, listen: false);
      final success = await poemController.likePoem(_poem!.id!);
      
      if (success) {
        setState(() {
          if (_isLiked) {
            _poem = _poem!.copyWith(likeCount: _poem!.likeCount - 1);
          } else {
            _poem = _poem!.copyWith(likeCount: _poem!.likeCount + 1);
          }
          _isLiked = !_isLiked;
        });
      }
    } catch (e) {
      print('Error liking poem: ${e.toString()}');
    }
  }

  Widget _buildEngagementButton({
    required Widget icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    // Use our aesthetic color scheme
    final backgroundColor = isDarkMode ? _darkBackground : _lightBackground;
    final textColor = isDarkMode ? _darkText : _lightText;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            Semantics(
              label: '$label button',
              button: true,
              enabled: onTap != null,
              child: icon,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommentsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use our aesthetic color scheme
    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFFAF3E0);
    final textColor = isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333);
    
    showModalBottomSheet(
      useRootNavigator: true, // Better accessibility for modal navigation
      context: context,
      isScrollControlled: true,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Bottom sheet handle
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Comments header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Comments (${_poem?.commentCount})",
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: 'Playfair Display',
                          color: isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333),
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333),
                        ),
                        tooltip: 'Close comments',
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                
                const Divider(),
                
                // Comments list
                Expanded(
                  child: (_poem?.commentCount ?? 0) > 0
                      ? ListView.builder(
                          controller: scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: _poem?.commentCount ?? 0,
                          itemBuilder: (context, index) {
                            // Mock comment data
                            return _buildCommentItem(
                              username: "User ${index + 1}",
                              content: "This is a beautiful poem! I love the imagery and emotion you've captured.",
                              timeAgo: "${index + 1}h ago",
                            );
                          },
                        )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: (isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333)).withOpacity(0.3),
                                semanticLabel: 'No comments icon',
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "No comments yet",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontFamily: 'Merriweather',
                                  color: (isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333)).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Be the first to share your thoughts",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: 'Montserrat',
                                  color: (isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333)).withOpacity(0.5),
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
                
                // Comment input
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Add a comment...",
                            hintStyle: TextStyle(
                              fontFamily: 'Montserrat',
                              color: (isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333)).withOpacity(0.5),
                              fontSize: 14,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: isDark
                                ? const Color(0xFF1E1E1E) // Slightly lighter than background for dark mode
                                : const Color(0xFFF5ECD5), // Slightly darker than background for light mode
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            isDense: true, // More minimal appearance
                          ),
                          style: TextStyle(
                            fontFamily: 'Montserrat',
                            color: isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333),
                            fontSize: 14,
                            height: 1.5,
                          ),
                          cursorColor: isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88),
                          cursorWidth: 2,
                          cursorRadius: const Radius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88),
                        child: IconButton(
                          icon: const Icon(Icons.send, color: Colors.white),
                          tooltip: 'Send comment',
                          onPressed: () {
                            // Send comment with haptic feedback
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Comment posted",
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    color: isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333),
                                  ),
                                ),
                                backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5ECD5),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildCommentItem({
    required String username,
    required String content,
    required String timeAgo,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Use our aesthetic color scheme
    final textColor = isDark ? const Color(0xFFEAEAEA) : const Color(0xFF333333);
    final accentColor = isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: (isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88)).withOpacity(0.2),
            child: Text(
              username.substring(0, 1).toUpperCase(),
              semanticsLabel: 'User avatar for $username',
              style: TextStyle(
                color: isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88),
                fontWeight: FontWeight.bold,
                fontFamily: 'Montserrat',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Playfair Display',
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'Montserrat',
                        color: textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'Merriweather',
                    color: textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 16,
                      color: (isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88)).withOpacity(0.8),
                      semanticLabel: 'Like comment',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Like",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.reply,
                      size: 16,
                      color: (isDark ? const Color(0xFF4A90E2) : const Color(0xFF2D5A88)).withOpacity(0.8),
                      semanticLabel: 'Reply to comment',
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "Reply",
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                        color: textColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 365) {
      return "${(difference.inDays / 365).floor()} years ago";
    } else if (difference.inDays > 30) {
      return "${(difference.inDays / 30).floor()} months ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays} days ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} hours ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} minutes ago";
    } else {
      return "Just now";
    }
  }

  void _autoScroll() {
    final currentPosition = _scrollController.position.pixels;
    final maxPosition = _scrollController.position.maxScrollExtent;
    
    if (currentPosition < maxPosition) {
      // Calculate a position to scroll to (about 20% of the remaining content)
      final targetPosition = currentPosition + ((maxPosition - currentPosition) * 0.2);
      
      _scrollController.animateTo(
        targetPosition.clamp(0.0, maxPosition),
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      // If at the bottom, scroll back to top
      _scrollController.animateTo(
        0,
        duration: const Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    }
  }
}
