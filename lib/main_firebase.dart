/// Main entry point for the RivalX application with Firebase integration.
/// 
/// This file initializes the app with Firebase services, configures system UI preferences,
/// and launches the root widget with proper authentication flow connected to Firebase.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/screens/auth/auth_wrapper.dart';
import 'package:rivalx/blocs/auth/auth_bloc_firebase.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/points/points_bloc.dart';
import 'package:rivalx/blocs/points/points_event.dart';
import 'package:rivalx/services/local_storage_service.dart';

/// Main function that initializes the app with Firebase and its dependencies.
/// 
/// This function:
/// - Ensures Flutter bindings are initialized
/// - Initializes Firebase with platform-specific configuration
/// - Sets up Crashlytics for error reporting
/// - Initializes local storage services
/// - Sets device orientation to portrait only
/// - Configures system UI styling
/// - Launches the main app widget with Firebase authentication flow
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific configuration
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Set up Crashlytics for error reporting
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  
  // Initialize local storage services (for offline caching)
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
  
  runApp(const RivalXFirebaseApp());
}

/// Root widget of the RivalX application with Firebase integration
class RivalXFirebaseApp extends StatelessWidget {
  const RivalXFirebaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBlocFirebase>(
          create: (context) => AuthBlocFirebase()
            ..add(const AuthCheckSession()),
        ),
        BlocProvider<PointsBloc>(
          create: (context) => PointsBloc(
            authBloc: context.read<AuthBlocFirebase>(),
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