import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const SafeHerApp());
}

class SafeHerApp extends StatelessWidget {
  const SafeHerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SafeHer',
      home: const SplashScreen(),
    );
  }
}