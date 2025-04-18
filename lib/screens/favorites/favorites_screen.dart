import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/screens/poem/poem_view_screen.dart';
import 'package:metaphora/widgets/poem_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Poem> _likedPoems = [];
  List<Poem> _savedPoems = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadPoems();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPoems() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    final mockLikedPoems = [
      Poem(
        id: 1,
        userId: 1,
        title: "Autumn Leaves",
        content: "Golden leaves falling,\nDancing in the autumn breeze,\nNature's last hurrah.",
        category: "Nature",
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        user: {"username": "poetryLover", "profile_pic": null},
        likeCount: 15,
        commentCount: 3,
      ),
      Poem(
        id: 3,
        userId: 3,
        title: "Ocean Whispers",
        content: "Waves crash on the shore,\nWhispering ancient secrets,\nEndless blue expanse.\n\nSalt spray in the air,\nSeagulls soaring overhead,\nPeace found by the sea.",
        category: "Nature",
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        user: {"username": "seaLover", "profile_pic": null},
        likeCount: 22,
        commentCount: 7,
      ),
      Poem(
        id: 6,
        userId: 2,
        title: "Love's Embrace",
        content: "Hearts beating as one,\nWarm embrace of tender love,\nSouls intertwined deep.\n\nTime stands still for us,\nIn this moment of pure bliss,\nLove's sweet symphony.",
        category: "Love",
        createdAt: DateTime.now().subtract(const Duration(days: 4)),
        user: {"username": "nightWriter", "profile_pic": null},
        likeCount: 30,
        commentCount: 8,
      ),
    ];

    final mockSavedPoems = [
      Poem(
        id: 2,
        userId: 2,
        title: "Moonlight",
        content: "Silver beams cascading,\nIlluminating the night sky,\nMoonlight's gentle touch.",
        category: "Night",
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        user: {"username": "nightWriter", "profile_pic": null},
        likeCount: 8,
        commentCount: 1,
      ),
      Poem(
        id: 7,
        userId: 5,
        title: "Inner Peace",
        content: "Quiet mind, still heart,\nBreath flowing like gentle stream,\nInner peace found here.",
        category: "Spirituality",
        createdAt: DateTime.now().subtract(const Duration(days: 6)),
        user: {"username": "zenMaster", "profile_pic": null},
        likeCount: 18,
        commentCount: 5,
      ),
    ];

    if (mounted) {
      setState(() {
        _likedPoems = mockLikedPoems;
        _savedPoems = mockSavedPoems;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: theme.colorScheme.primary,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.7),
              indicatorColor: theme.colorScheme.primary,
              indicatorWeight: 3,
              labelStyle: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              unselectedLabelStyle: theme.textTheme.titleMedium,
              tabs: const [
                Tab(
                  icon: Icon(Icons.favorite),
                  text: "Liked",
                ),
                Tab(
                  icon: Icon(Icons.bookmark),
                  text: "Saved",
                ),
              ],
            ),
          ),
          
          // Tab content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                    ),
                  )
                : TabBarView(
                    controller: _tabController,
                    children: [
                      // Liked poems tab
                      _buildPoemGrid(_likedPoems, "liked"),
                      
                      // Saved poems tab
                      _buildPoemGrid(_savedPoems, "saved"),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPoemGrid(List<Poem> poems, String type) {
    final theme = Theme.of(context);
    
    if (poems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              type == "liked" ? Icons.favorite_border : Icons.bookmark_border,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              type == "liked" ? "No liked poems yet" : "No saved poems yet",
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              type == "liked"
                  ? "Poems you like will appear here"
                  : "Poems you save will appear here",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to explore screen
              },
              icon: const Icon(Icons.explore),
              label: const Text("Explore Poems"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadPoems,
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: MasonryGridView.builder(
          itemCount: poems.length,
          gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          itemBuilder: (context, index) {
            return PoemCard(
              poem: poems[index],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PoemViewScreen(poemId: poems[index].id!),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
