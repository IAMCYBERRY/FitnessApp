/// Main entry point for RivalX app without Firebase dependencies.
/// 
/// This version starts directly with the MainScreen for testing
/// all implemented features without authentication dependencies.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/screens/main_screen.dart';

/// Main function for testing RivalX features
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure system UI overlay style for consistent theming
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );
  
  runApp(const RivalXApp());
}

/// Root widget of the RivalX application
class RivalXApp extends StatelessWidget {
  const RivalXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RivalX',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}