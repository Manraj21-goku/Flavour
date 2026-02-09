class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String category;
  final int cookingTime;
  final int calories;
  final int servings;
  final double rating;
  final List<Ingredient> ingredients;
  final List<String> instructions;
  final NutritionInfo nutrition;
  bool isFavorite;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.cookingTime,
    required this.calories,
    required this.servings,
    required this.rating,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    this.isFavorite = false,
  });
}

class Ingredient {
  final String name;
  final String quantity;
  final String? unit;

  Ingredient({required this.name, required this.quantity, this.unit});
}

class NutritionInfo {
  final double protein; // grams
  final double carbs; // grams
  final double fat; // grams
  final double fiber; // grams

  NutritionInfo({
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
  });
}
