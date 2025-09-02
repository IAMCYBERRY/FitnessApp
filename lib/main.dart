/// Main entry point for the RivalX application.
/// 
/// This file initializes the app, configures system UI preferences,
/// and launches the root widget with proper authentication flow.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/screens/auth/auth_wrapper.dart';
import 'package:rivalx/blocs/auth/local_auth_bloc.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/points/points_bloc.dart';
import 'package:rivalx/blocs/points/points_event.dart';
import 'package:rivalx/services/local_storage_service.dart';

/// Main function that initializes the app and its dependencies.
/// 
/// This function:
/// - Ensures Flutter bindings are initialized
/// - Initializes local storage services
/// - Sets device orientation to portrait only
/// - Configures system UI styling
/// - Launches the main app widget with authentication flow
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local storage services
  await initializeLocalStorage();
  
  // Set preferred orientations to portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Configure system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  runApp(const RivalXApp());
}

/// Root widget of the RivalX application
class RivalXApp extends StatelessWidget {
  const RivalXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocalAuthBloc>(
          create: (context) => LocalAuthBloc()
            ..add(const AuthCheckSession()),
        ),
        BlocProvider<PointsBloc>(
          create: (context) => PointsBloc(
            authBloc: context.read<LocalAuthBloc>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'RivalX',
        theme: AppTheme.darkTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}