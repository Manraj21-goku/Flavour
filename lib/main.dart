import 'package:flavour/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FlavourApp());
}

class FlavourApp extends StatelessWidget{
  const FlavourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flavour",
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const Scaffold(
        body: Center(
          child: Text("Flavour app -theme working"),
        ),
      ),
    );
  }
}
