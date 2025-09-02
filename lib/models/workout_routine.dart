/// Workout routine model for creating and managing custom workout routines.
/// 
/// This model represents a saved workout routine that can be reused
/// for multiple workout sessions. It contains exercises, sets, and
/// all the information needed to start a workout session.

import 'package:flutter/material.dart';
import 'muscle_group.dart';

/// Represents a workout routine that can be saved and reused
class WorkoutRoutine {
  final String id;
  final String name;
  final String description;
  final List<RoutineExercise> exercises;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final int timesUsed;
  final Color? color;
  final String? notes;

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.createdAt,
    this.lastUsedAt,
    this.timesUsed = 0,
    this.color,
    this.notes,
  });

  /// Get the estimated duration for this routine (mock calculation)
  Duration get estimatedDuration {
    final totalSets = exercises.fold(0, (sum, exercise) => sum + exercise.plannedSets.length);
    // Assume 2 minutes per set + 5 minutes per exercise setup
    return Duration(minutes: (totalSets * 2) + (exercises.length * 5));
  }

  /// Get all unique muscle groups in this routine
  Set<MuscleGroup> get muscleGroups {
    return exercises.map((e) => e.muscleGroup).toSet();
  }

  /// Get total number of exercises
  int get totalExercises => exercises.length;

  /// Get total planned sets
  int get totalPlannedSets {
    return exercises.fold(0, (sum, exercise) => sum + exercise.plannedSets.length);
  }

  /// Create a copy of this routine with updated values
  WorkoutRoutine copyWith({
    String? id,
    String? name,
    String? description,
    List<RoutineExercise>? exercises,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    int? timesUsed,
    Color? color,
    String? notes,
  }) {
    return WorkoutRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      timesUsed: timesUsed ?? this.timesUsed,
      color: color ?? this.color,
      notes: notes ?? this.notes,
    );
  }
}

/// Represents an exercise within a routine with planned sets
class RoutineExercise {
  final String name;
  final MuscleGroup muscleGroup;
  final List<PlannedSet> plannedSets;
  final String? notes;
  final int? restTimeSeconds;

  RoutineExercise({
    required this.name,
    required this.muscleGroup,
    required this.plannedSets,
    this.notes,
    this.restTimeSeconds,
  });

  /// Create a copy with updated values
  RoutineExercise copyWith({
    String? name,
    MuscleGroup? muscleGroup,
    List<PlannedSet>? plannedSets,
    String? notes,
    int? restTimeSeconds,
  }) {
    return RoutineExercise(
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      plannedSets: plannedSets ?? this.plannedSets,
      notes: notes ?? this.notes,
      restTimeSeconds: restTimeSeconds ?? this.restTimeSeconds,
    );
  }
}

/// Represents a planned set within a routine exercise
class PlannedSet {
  final double? targetWeight;
  final int? targetReps;
  final int? targetRPE; // Rate of Perceived Exertion (1-10)
  final String? notes;

  PlannedSet({
    this.targetWeight,
    this.targetReps,
    this.targetRPE,
    this.notes,
  });

  /// Create a copy with updated values
  PlannedSet copyWith({
    double? targetWeight,
    int? targetReps,
    int? targetRPE,
    String? notes,
  }) {
    return PlannedSet(
      targetWeight: targetWeight ?? this.targetWeight,
      targetReps: targetReps ?? this.targetReps,
      targetRPE: targetRPE ?? this.targetRPE,
      notes: notes ?? this.notes,
    );
  }

  /// Display string for this planned set
  String get displayString {
    final weight = targetWeight != null ? '${targetWeight!.toStringAsFixed(0)} lbs' : '- lbs';
    final reps = targetReps != null ? '${targetReps!} reps' : '- reps';
    return '$weight × $reps';
  }
}

/// Service class for managing workout routines (mock implementation)
class RoutineService {
  static final List<WorkoutRoutine> _routines = [];

  /// Get all saved routines
  static List<WorkoutRoutine> getAllRoutines() {
    return List.from(_routines);
  }

  /// Save a new routine
  static void saveRoutine(WorkoutRoutine routine) {
    _routines.add(routine);
  }

  /// Update an existing routine
  static void updateRoutine(WorkoutRoutine routine) {
    final index = _routines.indexWhere((r) => r.id == routine.id);
    if (index != -1) {
      _routines[index] = routine;
    }
  }

  /// Delete a routine
  static void deleteRoutine(String routineId) {
    _routines.removeWhere((r) => r.id == routineId);
  }

  /// Get routine by ID
  static WorkoutRoutine? getRoutineById(String id) {
    try {
      return _routines.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Mark routine as used
  static void markRoutineAsUsed(String routineId) {
    final routine = getRoutineById(routineId);
    if (routine != null) {
      final updatedRoutine = routine.copyWith(
        lastUsedAt: DateTime.now(),
        timesUsed: routine.timesUsed + 1,
      );
      updateRoutine(updatedRoutine);
    }
  }
}