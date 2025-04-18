import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:metaphora/screens/poem/poem_view_screen.dart';
import 'package:metaphora/screens/poem/create_poem_screen.dart';
import 'package:metaphora/widgets/poem_card.dart';
import 'package:metaphora/models/poem.dart';
import 'package:metaphora/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:metaphora/repositories/poem_repository.dart';
import 'package:metaphora/widgets/empty_assets_placeholder.dart';
import 'package:metaphora/database/database_helper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  List<Poem> _poems = [];
  PoemRepository? _poemRepository;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }
  
  Future<void> _initializeRepository() async {
    try {
      // Make sure database is initialized
      if (!DatabaseHelper.instance.isInitialized) {
        await DatabaseHelper.instance.initialize();
      }
      
      _poemRepository = PoemRepository();
      _loadPoems();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        debugPrint('Error initializing repository: $e');
      }
    }
  }

  Future<void> _loadPoems() async {
    if (_poemRepository == null) {
      await _initializeRepository();
      return;
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final poems = await _poemRepository!.getAllPoems(limit: 20);
      
      if (mounted) {
        setState(() {
          _poems = poems;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
        debugPrint('Error loading poems: $e');
      }
    }
  }

  void _navigateToCreatePoem() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const CreatePoemScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Failed to load poems',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _initializeRepository,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: null,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
              ),
            )
          : _poems.isEmpty
              ? EmptyAssetsPlaceholder(
                  iconData: Icons.book_outlined,
                  title: 'No Poems Yet',
                  description: 'Poems you create or follow will appear here',
                  actionLabel: 'Create Your First Poem',
                  onAction: _navigateToCreatePoem,
                )
              : RefreshIndicator(
                  onRefresh: _loadPoems,
                  color: theme.colorScheme.primary,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: MasonryGridView.builder(
                      itemCount: _poems.length,
                      gridDelegate: const SliverSimpleGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      itemBuilder: (context, index) {
                        return PoemCard(
                          poem: _poems[index],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => PoemViewScreen(poemId: _poems[index].id!),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
    );
  }
}
