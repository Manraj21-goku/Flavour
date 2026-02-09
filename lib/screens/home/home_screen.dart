import 'package:flutter/material.dart';
import 'package:flavour/data/mock_recipes.dart';
import 'package:flavour/models/recipe.dart';
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
  bool _isLoading = true;
  List<Recipe> _recipes = [];

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _recipes = MockRecipes.recipes;
      _isLoading = false;
    });
  }
  List<Recipe> get _filteredRecipes {
    if (_selectedCategory == 'All') return _recipes;
    return _recipes.where( (r) =>r.category == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Hi Chef! 🧑‍🍳",
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),),
                            const SizedBox(height: 4),
                            Text(
                              'What would you\nlike to cook?',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                          ],
                        ),
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          child: const Icon(Icons.person,size: 28,),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const TextField(
                        decoration: InputDecoration(
                          hintText: 'Search recipes...',
                          icon: Icon(Icons.search),
                          border: InputBorder.none,
                        ),
                      ),
                    )
                  ],
                ),

            ),
          ),
          SliverToBoxAdapter(
            child: CategoryChips(
              categories: MockRecipes.categories,
              selectedCategory: _selectedCategory,
              onCategorySelected : (category){
                setState(() {
                  _selectedCategory = category;
                });
              }
            ),
          ),
          //section title
          SliverToBoxAdapter(
            child: Padding(padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedCategory == 'All' ? 'Popular Recipes' : _selectedCategory,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all'),
                  ),
                ],
              ),
            ),
          ),
          //recipe grid
          _isLoading ?
              SliverPadding(padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                        (context,index) => const RecipeCardShimmer(),
                      childCount: 4
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.75,
                    )
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
                  final recipe = _filteredRecipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    onFavoriteToggle: () {
                      setState(() {
                        recipe.isFavorite = !recipe.isFavorite;
                      });
                    },
                  );
                },
                childCount: _filteredRecipes.length,
              ),
            ),
          ),
          //bottom padding
          const SliverToBoxAdapter(
            child: SizedBox(height: 100,),
          )
        ],
      )),
    );
  }
}
