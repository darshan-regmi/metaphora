import 'package:flutter/material.dart';

import 'package:metaphora/controllers/client/poem_controller.dart';
import 'package:provider/provider.dart';

class CreatePoemScreen extends StatefulWidget {
  const CreatePoemScreen({super.key});

  @override
  State<CreatePoemScreen> createState() => _CreatePoemScreenState();
}

class _CreatePoemScreenState extends State<CreatePoemScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCategory;
  bool _isFullScreen = false;
  bool _isLoading = false;
  int _characterCount = 0;
  
  final List<String> _categories = [
    'Nature',
    'Love',
    'Life',
    'Spirituality',
    'Urban',
    'Night',
    'Emotions',
    'Relationships',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _contentController.text.length;
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });
  }

  Future<void> _publishPoem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final poemController = Provider.of<PoemController>(context, listen: false);
        final poem = await poemController.createPoem(
          context,
          _titleController.text.trim(),
          _contentController.text.trim(),
          category: _selectedCategory,
        );
        
        if (mounted) {
          if (poem != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Poem published successfully!"),
                behavior: SnackBarBehavior.floating,
              ),
            );
            Navigator.pop(context);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(poemController.errorMessage ?? "Failed to publish poem"),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error: ${e.toString()}"),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: _isFullScreen
          ? null
          : AppBar(
              title: const Text("Create Poem"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.fullscreen),
                  onPressed: _toggleFullScreen,
                  tooltip: "Distraction-free mode",
                ),
              ],
            ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          image: DecorationImage(
            image: AssetImage(
              theme.brightness == Brightness.light
                  ? 'assets/images/light_paper_texture.png'
                  : 'assets/images/dark_paper_texture.png',
            ),
            fit: BoxFit.cover,
            opacity: 0.05,
          ),
        ),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Fullscreen toggle in body when in fullscreen mode
                if (_isFullScreen)
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.fullscreen_exit),
                      onPressed: _toggleFullScreen,
                      tooltip: "Exit distraction-free mode",
                    ),
                  ),
                
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: "Title of your poem",
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Playfair Display',
                          ),
                          maxLines: 1,
                          textCapitalization: TextCapitalization.words,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter a title";
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Content
                        TextFormField(
                          controller: _contentController,
                          decoration: InputDecoration(
                            hintText: "Express your thoughts through poetry...",
                            border: InputBorder.none,
                            filled: false,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            height: 1.8,
                            fontFamily: 'Merriweather',
                            fontSize: 18,
                          ),
                          maxLines: null,
                          minLines: 10,
                          textCapitalization: TextCapitalization.sentences,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your poem";
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Character count
                        Text(
                          "$_characterCount characters",
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.end,
                        ),
                        
                        if (!_isFullScreen) ...[
                          const SizedBox(height: 32),
                          
                          // Category dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            decoration: const InputDecoration(
                              labelText: "Category",
                              border: OutlineInputBorder(),
                            ),
                            items: _categories.map((category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                            hint: const Text("Select a category"),
                          ),
                          
                          const SizedBox(height: 32),
                          
                          // Hashtags
                          Text(
                            "Hashtags",
                            style: theme.textTheme.titleMedium,
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              '#poetry',
                              '#metaphora',
                              '#writing',
                              if (_selectedCategory != null) '#${_selectedCategory!.toLowerCase()}',
                            ].map((tag) {
                              return Chip(
                                label: Text(tag),
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: theme.colorScheme.primary,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                
                // Bottom bar with publish button
                if (!_isFullScreen)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Draft button
                        OutlinedButton.icon(
                          onPressed: _isLoading ? null : () {
                            // Save as draft
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Saved as draft"),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          icon: const Icon(Icons.save_outlined),
                          label: const Text("Save Draft"),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Publish button
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _isLoading ? null : _publishPoem,
                            icon: _isLoading
                                ? Container(
                                    width: 24,
                                    height: 24,
                                    padding: const EdgeInsets.all(2.0),
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.publish),
                            label: const Text("Publish"),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      // Floating publish button in fullscreen mode
      floatingActionButton: _isFullScreen
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _publishPoem,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.publish),
              label: const Text("Publish"),
            )
          : null,
    );
  }
}
