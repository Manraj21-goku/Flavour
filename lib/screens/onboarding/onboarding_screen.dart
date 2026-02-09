import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Discover Recipes',
      description:
          'Explore thousands of delicious recipes from around the world',
      lottieAsset: 'assets/animations/cooking.json',
      color: const Color(0xFFFF6B35),
    ),
    OnboardingPage(
      title: 'Save Favorites',
      description: 'Bookmark your favorite recipes and access them anytime',
      lottieAsset: 'assets/animations/bookmark.json',
      color: const Color(0xFF2EC4B6),
    ),
    OnboardingPage(
      title: 'Start Cooking',
      description: 'Follow step-by-step instructions and become a master chef',
      lottieAsset: 'assets/animations/chef.json',
      color: const Color(0xFFFFD93D),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _pages[_currentPage].color.withOpacity(0.1),
                  _pages[_currentPage].color.withOpacity(0.05),
                ],
              ),
            ),
          ),
          // Page content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          // Bottom controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? _pages[_currentPage].color
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // Get Started button
                if (_currentPage == _pages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to home
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Skip button
          Positioned(
            top: 60,
            right: 20,
            child: TextButton(
              onPressed: () {
                // Skip to home
              },
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Use Lottie animation or placeholder
          Container(
            height: 300,
            width: 300,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.restaurant_menu, size: 120, color: page.color),
            // Replace with: Lottie.asset(page.lottieAsset)
          ),
          const SizedBox(height: 48),
          Text(
            page.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String lottieAsset;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.lottieAsset,
    required this.color,
  });
}
