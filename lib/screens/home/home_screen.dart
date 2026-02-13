import '../../main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavour/providers/recipe_provider.dart';
import 'package:flavour/data/mock_recipes.dart';
import 'package:flavour/widgets/common/shimmer_loading.dart';
import 'package:flavour/screens/home/widgets/recipe_card.dart';
import 'package:flavour/screens/home/widgets/category_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final recipeProvider = Provider.of<RecipeProvider>(context);
    final recipes = recipeProvider.getRecipesByCategory(_selectedCategory);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Chef!',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'What would you\nlike to cook?',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        //
                        GestureDetector(
                          onTap: () {
                            MainScreen.switchToTab(context, 4);
                          },
                          child: CircleAvatar(
                            radius: 28,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: const Icon(Icons.person, size: 28),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Category chips
            SliverToBoxAdapter(
              child: CategoryChips(
                categories: MockRecipes.categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                },
              ),
            ),
            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedCategory == 'All' ? 'Popular Recipes' : _selectedCategory,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                 ?_selectedCategory == "All" ? null :
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedCategory = "All";
                        });
                      },
                      child: const Text('See all'),
                    ),
                  ],
                ),
              ),
            ),
            // Recipe grid
            recipeProvider.isLoading
                ? SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => const RecipeCardShimmer(),
                  childCount: 4,
                ),
              ),
            )
                : SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      onFavoriteToggle: () {
                        recipeProvider.toggleFavourite(recipe.id);
                      },
                    );
                  },
                  childCount: recipes.length,
                ),
              ),
            ),
            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }
}