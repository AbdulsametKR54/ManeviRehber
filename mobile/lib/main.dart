import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const ManeviRehberApp());
}

class ManeviRehberApp extends StatelessWidget {
  const ManeviRehberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Manevi Rehber',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006A40),
          primary: const Color(0xFF006A40),
          surface: const Color(0xFFF9F9F9),
        ),
        fontFamily: 'Manrope', // Note: Ensure fonts are added to pubspec.yaml
      ),
      home: const LoginPage(),
    );
  }
}
