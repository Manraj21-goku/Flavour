import 'package:flutter/material.dart';
import 'package:flavour/models/recipe.dart';
import 'package:flavour/widgets/common/animated_like_button.dart';
import 'package:flavour/core/painters/nutrition_chart_painter.dart';
import 'package:flavour/screens/cooking/cooking_session_screen.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _chartAnimationController;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _chartAnimationController.forward();
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsing header with Hero image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            stretch: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Hero(
                tag: 'recipe-image-${widget.recipe.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      widget.recipe.imageUrl,
                      fit: BoxFit.cover,
                    ),
                    // Gradient overlay
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                    // Title at bottom
                    Positioned(
                      bottom: 16,
                      left: 16,
                      right: 16,
                      child: Text(
                        widget.recipe.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                backgroundColor: Colors.black38,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.black38,
                  child: AnimatedLikeButton(
                    isLiked: widget.recipe.isFavorite,
                    onChanged: (value) {
                      setState(() {
                        widget.recipe.isFavorite = value;
                      });
                    },
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildInfoChip(
                        Icons.timer_outlined,
                        '${widget.recipe.cookingTime} min',
                      ),
                      _buildInfoChip(
                        Icons.local_fire_department,
                        '${widget.recipe.calories} cal',
                      ),
                      _buildInfoChip(
                        Icons.restaurant,
                        '${widget.recipe.servings} servings',
                      ),
                      _buildInfoChip(
                        Icons.star,
                        widget.recipe.rating.toString(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    widget.recipe.description,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Nutrition Chart
                  Text(
                    'Nutrition',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNutritionSection(),
                  const SizedBox(height: 32),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.recipe.ingredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFF6B35),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${ingredient.quantity}${ingredient.unit != null ? ' ${ingredient.unit}' : ''} ${ingredient.name}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 32),

                  // Instructions
                  Text(
                    'Instructions',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.recipe.instructions.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B35).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      // Start cooking button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context)=> CookingSessionScreen(
                      recipe: widget.recipe)
              )
          );
        },
        backgroundColor: const Color(0xFFFF6B35),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Cooking'),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF6B35)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection() {
    final nutrition = widget.recipe.nutrition;

    return Row(
      children: [
        // Animated chart
        AnimatedBuilder(
          animation: _chartAnimationController,
          builder: (context, child) {
            return CustomPaint(
              size: const Size(100, 100),
              painter: NutritionChartPainter(
                protein: nutrition.protein,
                carbs: nutrition.carbs,
                fat: nutrition.fat,
                animationValue: _chartAnimationController.value,
              ),
            );
          },
        ),
        const SizedBox(width: 24),
        // Legend
        Expanded(
          child: Column(
            children: [
              _buildNutritionRow('Protein', nutrition.protein, const Color(0xFFFF6B35)),
              const SizedBox(height: 8),
              _buildNutritionRow('Carbs', nutrition.carbs, const Color(0xFF2EC4B6)),
              const SizedBox(height: 8),
              _buildNutritionRow('Fat', nutrition.fat, const Color(0xFFFFD93D)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, double value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
        const Spacer(),
        Text(
          '${value.toInt()}g',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}