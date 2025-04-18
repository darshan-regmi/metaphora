import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/screens/poem/poem_view_screen.dart';
import 'package:metaphora/widgets/poem_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _isLoading = true;
  List<Poem> _trendingPoems = [];
  List<Poem> _filteredPoems = [];
  String _selectedCategory = "All";
  final TextEditingController _searchController = TextEditingController();
  
  final List<String> _categories = [
    "All",
    "Nature",
    "Love",
    "Life",
    "Spirituality",
    "Urban",
    "Night",
    "Emotions",
  ];

  @override
  void initState() {
    super.initState();
    _loadPoems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPoems() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data
    final mockPoems = [
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
        id: 4,
        userId: 1,
        title: "City Lights",
        content: "Neon signs flicker,\nHumming with electric life,\nCity never sleeps.",
        category: "Urban",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        user: {"username": "poetryLover", "profile_pic": null},
        likeCount: 12,
        commentCount: 4,
      ),
      Poem(
        id: 5,
        userId: 4,
        title: "Mountain Peak",
        content: "Standing tall and proud,\nReaching for the azure sky,\nMountain peak divine.",
        category: "Nature",
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        user: {"username": "mountainClimber", "profile_pic": null},
        likeCount: 5,
        commentCount: 0,
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
      Poem(
        id: 8,
        userId: 6,
        title: "Rainy Day",
        content: "Raindrops on windows,\nGray skies and melancholy,\nCozy blanket waits.",
        category: "Emotions",
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        user: {"username": "rainLover", "profile_pic": null},
        likeCount: 14,
        commentCount: 3,
      ),
    ];

    if (mounted) {
      setState(() {
        _trendingPoems = mockPoems;
        _filterPoems();
        _isLoading = false;
      });
    }
  }

  void _filterPoems() {
    if (_selectedCategory == "All") {
      _filteredPoems = _trendingPoems;
    } else {
      _filteredPoems = _trendingPoems
          .where((poem) => poem.category == _selectedCategory)
          .toList();
    }

    // Apply search filter if there's a search query
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      _filteredPoems = _filteredPoems
          .where((poem) =>
              poem.title.toLowerCase().contains(query) ||
              poem.content.toLowerCase().contains(query) ||
              (poem.user?["username"]?.toLowerCase() ?? "").contains(query))
          .toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchModal(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadPoems,
              color: theme.colorScheme.primary,
              child: Column(
                children: [
                  // Category filters
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _categories.length,
                      itemBuilder: (context, index) {
                        final category = _categories[index];
                        final isSelected = category == _selectedCategory;
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(category),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = category;
                                _filterPoems();
                              });
                            },
                            backgroundColor: theme.cardColor,
                            selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                            checkmarkColor: theme.colorScheme.primary,
                            labelStyle: TextStyle(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Poems grid
                  Expanded(
                    child: _filteredPoems.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.search_off,
                                  size: 64,
                                  color: theme.colorScheme.onSurface.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  "No poems found",
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Try a different category or search term",
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: MasonryGridView.builder(
                              itemCount: _filteredPoems.length,
                              gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                              ),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              itemBuilder: (context, index) {
                                return PoemCard(
                                  poem: _filteredPoems[index],
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) => PoemViewScreen(poemId: _filteredPoems[index].id!),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  void _showSearchModal(BuildContext context) {
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 16,
                left: 16,
                right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bottom sheet handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.dividerColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search header
                  Text(
                    "Search Poems",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Playfair Display',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search field
                  TextField(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: "Search by title, content, or author",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onSubmitted: (value) {
                      setState(() {
                        _filterPoems();
                      });
                      Navigator.pop(context);
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Search button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _filterPoems();
                        });
                        Navigator.pop(context);
                      },
                      child: const Text("Search"),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Popular searches
                  Text(
                    "Popular Searches",
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Wrap(
                    spacing: 8,
                    children: [
                      _buildSearchChip(theme, "Haiku"),
                      _buildSearchChip(theme, "Love"),
                      _buildSearchChip(theme, "Nature"),
                      _buildSearchChip(theme, "Sadness"),
                      _buildSearchChip(theme, "Hope"),
                      _buildSearchChip(theme, "Ocean"),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchChip(ThemeData theme, String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        setState(() {
          _searchController.text = label;
          _filterPoems();
        });
        Navigator.pop(context);
      },
      backgroundColor: theme.colorScheme.surface,
      side: BorderSide(color: theme.dividerColor),
    );
  }
}
