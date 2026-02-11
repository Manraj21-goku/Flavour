import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flavour/core/theme/app_theme.dart';
import 'package:flavour/core/theme/theme_provider.dart';
import 'package:flavour/providers/recipe_provider.dart';
import 'package:flavour/screens/onboarding/onboarding_screen.dart';
import 'package:flavour/screens/home/home_screen.dart';
import 'package:flavour/screens/search/search_screen.dart';
import 'package:flavour/screens/favourite/favourites_screen.dart';
import 'package:flavour/screens/profile/profile_screen.dart';
import 'package:flavour/widgets/navigation/animated_bottom_nav.dart';
import 'package:flavour/screens/splash/splash_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => RecipeProvider()),
      ],
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
      home: const SplashScreen()
    );
  }
}

// Main screen with navigation - use this after onboarding
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  static void switchToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainScreenState>();
    state?.switchTab(index);
  }

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    FavouritesScreen(),
    ProfileScreen(),
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