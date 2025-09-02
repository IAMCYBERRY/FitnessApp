/// Simplified main.dart for testing without Firebase
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/screens/splash_screen_simple.dart';

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

class RivalXApp extends StatelessWidget {
  const RivalXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RivalX',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const SplashScreenSimple(),
    );
  }
}