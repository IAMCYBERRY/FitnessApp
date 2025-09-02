/// Sign up screen for RivalX app.
/// 
/// This screen allows new users to create an account with email/password
/// and provides optional profile setup including height, weight, and fitness level.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/auth/local_auth_bloc.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/models/user_model_clean.dart';
import 'package:rivalx/widgets/common/custom_text_field.dart';
import 'package:rivalx/widgets/common/loading_indicator.dart';

/// Sign up screen widget for user registration
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalWeightController = TextEditingController();
  
  /// Whether passwords are visible
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  
  /// Selected fitness level
  FitnessLevel? _selectedFitnessLevel;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _userNameController.dispose();
    _displayNameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    super.dispose();
  }

  /// Handles form submission
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      context.read<LocalAuthBloc>().add(
        AuthSignup(
          username: _userNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
          fitnessLevel: _selectedFitnessLevel,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(
        title: const Text('Join the Challenge'),
        backgroundColor: AppTheme.slateGrey,
        foregroundColor: AppTheme.accentYellow,
        elevation: 0,
      ),
      body: BlocConsumer<LocalAuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorRed,
              ),
            );
          } else if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Welcome to RivalX! Ready to compete?'),
                backgroundColor: Colors.green,
              ),
            );
            // Pop back to login screen, AuthWrapper will handle showing main app
            Navigator.of(context).pop();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingIndicator(message: 'Creating your account...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Required fields section
                  _buildRequiredFields(),
                  
                  const SizedBox(height: 32),
                  
                  // Optional profile setup
                  _buildOptionalFields(),
                  
                  const SizedBox(height: 32),
                  
                  // Sign up button
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('JOIN THE CHALLENGE'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Sign in link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already a challenger? ',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds required fields section
  Widget _buildRequiredFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        const SizedBox(height: 16),
        
        // Email field
        CustomTextField(
          controller: _emailController,
          label: 'Email *',
          hint: 'Enter your email',
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Username field
        CustomTextField(
          controller: _userNameController,
          label: 'Username *',
          hint: 'Choose a unique username',
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Display name field
        CustomTextField(
          controller: _displayNameController,
          label: 'Display Name *',
          hint: 'How you want to be known',
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Display name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Password field
        CustomTextField(
          controller: _passwordController,
          label: 'Password *',
          hint: 'At least 6 characters',
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.next,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
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
              return 'Password is required';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Confirm password field
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password *',
          hint: 'Re-enter your password',
          obscureText: !_isConfirmPasswordVisible,
          textInputAction: TextInputAction.done,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
              color: AppTheme.slateGrey,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Builds optional profile fields section
  Widget _buildOptionalFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Setup (Optional)',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help us personalize your experience',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.lightSlateGrey,
          ),
        ),
        const SizedBox(height: 16),
        
        // Height and weight row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _heightController,
                label: 'Height (cm)',
                hint: '170',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _weightController,
                label: 'Weight (kg)',
                hint: '70',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Goal weight
        CustomTextField(
          controller: _goalWeightController,
          label: 'Goal Weight (kg)',
          hint: 'Your target weight',
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
        ),
        
        const SizedBox(height: 16),
        
        // Fitness level dropdown
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fitness Level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textWhite,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<FitnessLevel>(
              value: _selectedFitnessLevel,
              decoration: InputDecoration(
                hintText: 'Select your fitness level',
                filled: true,
                fillColor: AppTheme.surfaceDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.lightSlateGrey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.lightSlateGrey.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(
                    color: AppTheme.accentYellow,
                    width: 2,
                  ),
                ),
                hintStyle: TextStyle(
                  color: AppTheme.lightSlateGrey.withValues(alpha: 0.6),
                ),
              ),
              items: FitnessLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(
                    _getFitnessLevelText(level),
                    style: const TextStyle(color: AppTheme.textWhite),
                  ),
                );
              }).toList(),
              dropdownColor: AppTheme.surfaceDark,
              style: const TextStyle(color: AppTheme.textWhite),
              onChanged: (value) {
                setState(() {
                  _selectedFitnessLevel = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Gets display text for fitness level
  String _getFitnessLevelText(FitnessLevel level) {
    switch (level) {
      case FitnessLevel.beginner:
        return 'Beginner - New to fitness';
      case FitnessLevel.intermediate:
        return 'Intermediate - Some experience';
      case FitnessLevel.advanced:
        return 'Advanced - Very experienced';
    }
  }
}