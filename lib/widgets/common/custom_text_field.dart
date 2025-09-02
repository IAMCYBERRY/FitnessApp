/// Custom text field widget for consistent styling.
/// 
/// This widget provides a styled text field that follows the RivalX
/// design system. It includes support for labels, hints, validation,
/// and various input types.

import 'package:flutter/material.dart';
import 'package:rivalx/config/theme.dart';

/// Reusable custom text field widget with RivalX styling
class CustomTextField extends StatelessWidget {
  /// Text editing controller
  final TextEditingController controller;
  
  /// Label text displayed above the field
  final String label;
  
  /// Hint text displayed when field is empty
  final String? hint;
  
  /// Whether the text should be obscured (for passwords)
  final bool obscureText;
  
  /// Keyboard type for the input
  final TextInputType? keyboardType;
  
  /// Text input action (next, done, etc.)
  final TextInputAction? textInputAction;
  
  /// Validation function
  final String? Function(String?)? validator;
  
  /// Callback when field is submitted
  final void Function(String)? onFieldSubmitted;
  
  /// Widget to display at the end of the field
  final Widget? suffixIcon;
  
  /// Widget to display at the start of the field
  final Widget? prefixIcon;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Maximum number of lines
  final int? maxLines;
  
  /// Callback when text changes
  final void Function(String)? onChanged;

  /// Creates a custom text field
  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
    this.prefixIcon,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textWhite,
          ),
        ),
        const SizedBox(height: 8),
        
        // Text field
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onFieldSubmitted: onFieldSubmitted,
          enabled: enabled,
          maxLines: obscureText ? 1 : maxLines,
          onChanged: onChanged,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textWhite,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: suffixIcon,
            prefixIcon: prefixIcon,
            filled: true,
            fillColor: enabled ? AppTheme.surfaceDark : AppTheme.surfaceDark.withValues(alpha: 0.5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.slateGrey),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.errorRed),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppTheme.lightSlateGrey.withValues(alpha: 0.2),
              ),
            ),
            hintStyle: TextStyle(
              color: AppTheme.lightSlateGrey.withValues(alpha: 0.6),
            ),
          ),
        ),
      ],
    );
  }
}