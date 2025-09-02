/// Forgot password screen for RivalX app.
/// 
/// This screen allows users to reset their password by sending
/// a reset link to their email address.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rivalx/blocs/auth/local_auth_bloc.dart';
import 'package:rivalx/blocs/auth/auth_event.dart';
import 'package:rivalx/blocs/auth/auth_state.dart';
import 'package:rivalx/config/theme.dart';
import 'package:rivalx/widgets/common/custom_text_field.dart';
import 'package:rivalx/widgets/common/loading_indicator.dart';

/// Forgot password screen widget
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  /// Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  /// Email text controller
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  /// Handles form submission
  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      // Password reset not implemented for local storage
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset not available in local mode'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: AppTheme.backgroundWhite,
        foregroundColor: AppTheme.primaryBlack,
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
          } else if (state is AuthPasswordResetSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Reset link sent to ${state.email}'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const LoadingIndicator(message: 'Sending reset link...');
          }

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 32),
                  
                  // Icon
                  Icon(
                    Icons.lock_reset,
                    size: 80,
                    color: AppTheme.accentYellow,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Title
                  Text(
                    'Forgot Password?',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Description
                  Text(
                    'Enter your email address and we\'ll send you a link to reset your password.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.slateGrey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Email field
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    hint: 'Enter your email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _handleSubmit(),
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
                  
                  const SizedBox(height: 24),
                  
                  // Send reset link button
                  ElevatedButton(
                    onPressed: _handleSubmit,
                    child: const Text('SEND RESET LINK'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Back to sign in link
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Sign In'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}