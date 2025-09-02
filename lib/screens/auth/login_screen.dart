/// Login screen for RivalX app.
/// 
/// This screen allows users to sign in to their account using
/// email/password or biometric authentication. It also provides
/// links to sign up and reset password.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/auth/local_auth_bloc.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/screens/auth/signup_screen.dart';
import 'package:rivalx/screens/auth/forgot_password_screen.dart';
import 'package:rivalx/widgets/common/custom_text_field.dart';
import 'package:rivalx/widgets/common/loading_indicator.dart';

/// Login screen widget for user authentication
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Email text controller
  final _emailController = TextEditingController();
  
  /// Password text controller
  final _passwordController = TextEditingController();
  
  /// Whether password is visible
  bool _isPasswordVisible = false;
  
  /// Whether biometric auth is available
  bool _isBiometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Checks if biometric authentication is available
  Future<void> _checkBiometricAvailability() async {
    // Mock service doesn't support biometrics for now
    setState(() {
      _isBiometricAvailable = false;
    });
  }

  /// Handles form submission
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<LocalAuthBloc>().add(
        AuthLogin(
          identifier: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  /// Handles biometric sign in
  void _handleBiometricSignIn() {
    // Biometric auth not implemented for local storage yet
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometric authentication not available in local mode'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocConsumer<LocalAuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          }
          // Navigation is handled by AuthWrapper - no need to navigate here
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingIndicator();
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    
                    // Logo and title
                    _buildHeader(),
                    
                    const SizedBox(height: 48),
                    
                    // Email field
                    CustomTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter your email',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Password field
                    CustomTextField(
                      controller: _passwordController,
                      label: 'Password',
                      hint: 'Enter your password',
                      obscureText: !_isPasswordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSubmit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: AppTheme.slateGrey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Forgot password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Sign in button
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text('SIGN IN'),
                    ),
                    
                    // Biometric sign in button (if available)
                    if (_isBiometricAvailable) ...[
                      const SizedBox(height: 16),
                      OutlinedButton.icon(
                        onPressed: _handleBiometricSignIn,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Sign in with Biometrics'),
                      ),
                    ],
                    
                    const SizedBox(height: 32),
                    
                    // Divider
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'OR',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Not a challenger yet? ",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textWhite,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SignUpScreen(),
                              ),
                            );
                          },
                          child: const Text('Sign up now'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the header section with logo and title
  Widget _buildHeader() {
    return Column(
      children: [
        // Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppTheme.accentYellow,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.fitness_center,
            size: 50,
            color: AppTheme.primaryBlack,
          ),
        ),
        const SizedBox(height: 24),
        
        // App name
        Text(
          'RivalX',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        
        // Tagline
        Text(
          'COMPETE. CONQUER. REPEAT.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.lightSlateGrey,
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }
}