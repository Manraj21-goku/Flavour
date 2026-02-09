import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavour/core/theme/app_theme.dart';
import 'package:flavour/core/theme/theme_provider.dart';
import 'package:flavour/screens/onboarding/onboarding_screen.dart';
import 'package:flavour/widgets/navigation/animated_bottom_nav.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const FlavourApp(),
    ),
  );
}

class FlavourApp extends StatelessWidget {
  const FlavourApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Flavour',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const OnboardingScreen(), // Start with onboarding
      // Or use: const MainScreen(), // Skip onboarding
    );
  }
}

// Main screen with bottom navigation (use after onboarding)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Placeholder screens - replace with your actual screens
  final List<Widget> _screens = [
    const _PlaceholderScreen(title: 'Home', icon: Icons.home),
    const _PlaceholderScreen(title: 'Search', icon: Icons.search),
    const _PlaceholderScreen(title: 'Favorites', icon: Icons.favorite),
    const _PlaceholderScreen(title: 'Profile', icon: Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AnimatedBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: 'Home',
          ),
          BottomNavItem(
            icon: Icons.search_outlined,
            activeIcon: Icons.search,
            label: 'Search',
          ),
          BottomNavItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            label: 'Favorites',
          ),
          BottomNavItem(
            icon: Icons.person_outline,
            activeIcon: Icons.person,
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// Temporary placeholder screen
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          // Theme toggle button
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              '$title Screen',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}