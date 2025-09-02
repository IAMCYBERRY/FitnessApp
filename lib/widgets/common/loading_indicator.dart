/// Loading indicator widget for RivalX app.
/// 
/// This widget displays a centered loading spinner with the RivalX
/// branding. It's used throughout the app to indicate loading states.

import 'package:flutter/material.dart';
import 'package:rivalx/config/theme.dart';

/// Custom loading indicator with RivalX branding
class LoadingIndicator extends StatelessWidget {
  /// Optional message to display below the spinner
  final String? message;
  
  /// Size of the loading spinner
  final double size;
  
  /// Whether to show the full screen overlay
  final bool fullScreen;

  /// Creates a loading indicator widget
  const LoadingIndicator({
    super.key,
    this.message,
    this.size = 50.0,
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Custom loading animation
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.accentYellow,
                ),
                strokeWidth: 3,
              ),
            ),
            Icon(
              Icons.fitness_center,
              size: size * 0.5,
              color: AppTheme.primaryBlack,
            ),
          ],
        ),
        
        // Loading message
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.slateGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (fullScreen) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundWhite,
        body: Center(child: content),
      );
    }

    return Center(child: content);
  }
}