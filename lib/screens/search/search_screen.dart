import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavour/providers/recipe_provider.dart';
import 'package:flavour/models/recipe.dart';
import 'package:flavour/screens/home/widgets/recipe_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';
  bool _hasSearched = false;  // Track if user has searched

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    setState(() {
      _query = query;
      _hasSearched = query.isNotEmpty;
    });
  }

  void _selectCategory(String category) {
    _searchController.text = category;
    setState(() {
      _query = category;
      _hasSearched = true;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
      _hasSearched = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final searchResults = recipeProvider.searchRecipes(_query);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Search',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search TextField
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: (value) {
                        setState(() => _query = value);
                        // Only mark as searched if there's actual text
                        if (value.isNotEmpty) {
                          _hasSearched = true;
                        }
                      },
                      onSubmitted: _performSearch,
                      decoration: InputDecoration(
                        hintText: 'Make it happen...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _query.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: _clearSearch,
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: !_hasSearched
                  ? _buildInitialState()  // Show categories only
                  : _buildSearchResults(searchResults, recipeProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Popular Categories
          Text(
            'Popular Categories',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildCategoryGrid(),
          const SizedBox(height: 40),

          // Hint text
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.search,
                  size: 48,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 12),
                Text(
                  'Search for recipes or\nselect a category above',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Breakfast', 'icon': Icons.breakfast_dining, 'color': const Color(0xFFFF9F43)},
      {'name': 'Pasta', 'icon': Icons.dinner_dining, 'color': const Color(0xFFFF6B35)},
      {'name': 'Salads', 'icon': Icons.eco, 'color': const Color(0xFF2EC4B6)},
      {'name': 'Dessert', 'icon': Icons.cake, 'color': const Color(0xFFE84393)},
      {'name': 'Seafood', 'icon': Icons.set_meal, 'color': const Color(0xFF0984E3)},
      {'name': 'Asian', 'icon': Icons.ramen_dining, 'color': const Color(0xFFFD79A8)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () => _selectCategory(category['name'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: (category['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  category['icon'] as IconData,
                  color: category['color'] as Color,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  category['name'] as String,
                  style: TextStyle(
                    color: category['color'] as Color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(List<Recipe> results, RecipeProvider provider) {
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No recipes found',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(color: Colors.grey[500]),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: _clearSearch,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back to categories'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${results.length} results found',
                style: TextStyle(color: Colors.grey[600]),
              ),
              TextButton(
                onPressed: _clearSearch,
                child: const Text('Clear'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final recipe = results[index];
              return RecipeCard(
                recipe: recipe,
                onFavoriteToggle: () => provider.toggleFavourite(recipe.id),
              );
            },
          ),
        ),
      ],
    );
  }
}