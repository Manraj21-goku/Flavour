import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flavour/models/recipe.dart';
import 'package:flavour/data/mock_recipes.dart';

class RecipeProvider extends ChangeNotifier {
  List<Recipe> _recipes = [];
  Set<String> _favouriteIds = {};
  bool _isLoading = true;

  List<Recipe> get recipes => _recipes;
  bool get isLoading => _isLoading;

  List<Recipe> get favouriteRecipes =>
      _recipes.where((r) => _favouriteIds.contains(r.id)).toList();
  RecipeProvider() {
    _loadRecipes();
  }
  Future<void> _loadRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavourites = prefs.getStringList('favouriteIds') ?? [];
    _favouriteIds = savedFavourites.toSet();

    await Future.delayed(const Duration(seconds: 1));

    _recipes = MockRecipes.recipes.map((recipe) {
      recipe.isFavorite = _favouriteIds.contains(recipe.id);
      return recipe;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavourite(String recipeId) async {
    final recipe = _recipes.firstWhere((r) => r.id == recipeId);
    recipe.isFavorite = !recipe.isFavorite;

    if (recipe.isFavorite) {
      _favouriteIds.add(recipeId);
    } else {
      _favouriteIds.remove(recipeId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favouriteIds', _favouriteIds.toList());
    notifyListeners();
  }

  bool isFavourite(String recipeId) => _favouriteIds.contains(recipeId);

  List<Recipe> searchRecipes(String query) {
    if (query.isEmpty) return _recipes;
    final lowerQuery = query.toLowerCase();
    return _recipes.where((recipe) {
      return recipe.title.toLowerCase().contains(lowerQuery) ||
          recipe.description.toLowerCase().contains(lowerQuery) ||
          recipe.category.toLowerCase().contains(lowerQuery) ||
          recipe.ingredients.any(
            (item) => item.name.toLowerCase().contains(lowerQuery),
          );
    }).toList();
  }

  List<Recipe> getRecipesByCategory(String category) {
    if (category == "All") return _recipes;
    return _recipes.where((r) => r.category == category).toList();
  }
}
