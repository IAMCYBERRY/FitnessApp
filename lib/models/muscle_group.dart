/// Enumeration for muscle groups in workout tracking.
/// 
/// This enum defines all the muscle groups that can be targeted
/// during exercises for comprehensive workout analysis.

import 'package:flutter/material.dart';

enum MuscleGroup {
  shoulders,
  traps,
  triceps,
  biceps,
  hamstrings,
  calves,
  chest,
  abs,
  glutes,
  forearms,
  quads,
}

extension MuscleGroupExtension on MuscleGroup {
  /// Returns the display name for the muscle group
  String get displayName {
    switch (this) {
      case MuscleGroup.shoulders:
        return 'Shoulders';
      case MuscleGroup.traps:
        return 'Traps';
      case MuscleGroup.triceps:
        return 'Triceps';
      case MuscleGroup.biceps:
        return 'Biceps';
      case MuscleGroup.hamstrings:
        return 'Hamstrings';
      case MuscleGroup.calves:
        return 'Calves';
      case MuscleGroup.chest:
        return 'Chest';
      case MuscleGroup.abs:
        return 'Abs';
      case MuscleGroup.glutes:
        return 'Glutes';
      case MuscleGroup.forearms:
        return 'Forearms';
      case MuscleGroup.quads:
        return 'Quads';
    }
  }

  /// Returns an emoji icon for the muscle group
  String get icon {
    switch (this) {
      case MuscleGroup.shoulders:
        return '💪';
      case MuscleGroup.traps:
        return '🏔️';
      case MuscleGroup.triceps:
        return '💥';
      case MuscleGroup.biceps:
        return '💪';
      case MuscleGroup.hamstrings:
        return '🦵';
      case MuscleGroup.calves:
        return '🐄';
      case MuscleGroup.chest:
        return '🫶';
      case MuscleGroup.abs:
        return '🔥';
      case MuscleGroup.glutes:
        return '🍑';
      case MuscleGroup.forearms:
        return '🤜';
      case MuscleGroup.quads:
        return '🦵';
    }
  }

  /// Returns a color for the muscle group for UI display
  static Color getColor(MuscleGroup group) {
    switch (group) {
      case MuscleGroup.shoulders:
        return const Color(0xFF4CAF50); // Green
      case MuscleGroup.traps:
        return const Color(0xFF795548); // Brown
      case MuscleGroup.triceps:
        return const Color(0xFF9C27B0); // Purple
      case MuscleGroup.biceps:
        return const Color(0xFF2196F3); // Blue
      case MuscleGroup.hamstrings:
        return const Color(0xFFFF5722); // Deep Orange
      case MuscleGroup.calves:
        return const Color(0xFF607D8B); // Blue Grey
      case MuscleGroup.chest:
        return const Color(0xFFF44336); // Red
      case MuscleGroup.abs:
        return const Color(0xFFFF9800); // Orange
      case MuscleGroup.glutes:
        return const Color(0xFFE91E63); // Pink
      case MuscleGroup.forearms:
        return const Color(0xFF3F51B5); // Indigo
      case MuscleGroup.quads:
        return const Color(0xFF009688); // Teal
    }
  }
}

