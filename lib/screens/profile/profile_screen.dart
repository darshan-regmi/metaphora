import 'package:flutter/material.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/screens/poem/poem_view_screen.dart';
import 'package:metaphora/screens/profile/edit_profile_screen.dart';
import 'package:metaphora/screens/settings/settings_screen.dart';
import 'package:metaphora/widgets/poem_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Poem> _userPoems = [];
  List<Poem> _savedPoems = [];
  
  // Mock user data
  final Map<String, dynamic> _userData = {
    "username": "poetryLover",
    "name": "Alex Johnson",
    "bio": "Poetry enthusiast | Nature lover | Finding beauty in words",
    "followers_count": 124,
    "following_count": 87,
    "poems_count": 15,
    "joined_date": "March 2025",
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock data for user's poems
    final mockUserPoems = [
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
        id: 7,
        userId: 1,
        title: "Morning Dew",
        content: "Droplets of crystal,\nClinging to petals at dawn,\nEphemeral gems.",
        category: "Nature",
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        user: {"username": "poetryLover", "profile_pic": null},
        likeCount: 9,
        commentCount: 2,
      ),
    ];

    // Mock data for saved poems
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

    if (mounted) {
      setState(() {
        _userPoems = mockUserPoems;
        _savedPoems = mockSavedPoems;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
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
              onRefresh: _loadUserData,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile header
                    _buildProfileHeader(theme),
                    
                    const SizedBox(height: 16),
                    
                    // Bio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _userData["bio"] ?? "",
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Stats
                    _buildStatsRow(theme),
                    
                    const SizedBox(height: 24),
                    
                    // Tabs
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: theme.dividerColor,
                            width: 1,
                          ),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: "My Poems"),
                          Tab(text: "Saved"),
                        ],
                        labelStyle: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelStyle: theme.textTheme.titleMedium,
                      ),
                    ),
                    
                    // Tab content
                    SizedBox(
                      height: 800, // Fixed height for the grid view
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // My Poems tab
                          _userPoems.isEmpty
                              ? _buildEmptyState(
                                  theme,
                                  "You haven't written any poems yet",
                                  "Tap the + button to start writing",
                                  Icons.edit_note,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: MasonryGridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _userPoems.length,
                                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    itemBuilder: (context, index) {
                                      return PoemCard(
                                        poem: _userPoems[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PoemViewScreen(poemId: _userPoems[index].id!),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                          
                          // Saved Poems tab
                          _savedPoems.isEmpty
                              ? _buildEmptyState(
                                  theme,
                                  "No saved poems yet",
                                  "Bookmark poems to save them here",
                                  Icons.bookmark_border,
                                )
                              : Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: MasonryGridView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _savedPoems.length,
                                    gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                    ),
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    itemBuilder: (context, index) {
                                      return PoemCard(
                                        poem: _savedPoems[index],
                                        onTap: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => PoemViewScreen(poemId: _savedPoems[index].id!),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile picture
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            child: Text(
              _userData["username"]?.substring(0, 1).toUpperCase() ?? "U",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userData["name"] ?? "User",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "@${_userData["username"] ?? "username"}",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Joined ${_userData["joined_date"] ?? ""}",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          
          // Edit profile button
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text("Edit"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            theme,
            "${_userData["poems_count"] ?? 0}",
            "Poems",
          ),
          _buildDivider(theme),
          _buildStatItem(
            theme,
            "${_userData["followers_count"] ?? 0}",
            "Followers",
          ),
          _buildDivider(theme),
          _buildStatItem(
            theme,
            "${_userData["following_count"] ?? 0}",
            "Following",
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 30,
      width: 1,
      color: theme.dividerColor,
    );
  }

  Widget _buildEmptyState(ThemeData theme, String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurface.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
