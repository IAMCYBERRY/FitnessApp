/// Screen for creating and editing workout routines.
/// 
/// This screen allows users to:
/// - Create new workout routines
/// - Add multiple exercises with planned sets
/// - Set routine name, description, and notes
/// - Save routines for later use in workouts

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/muscle_group.dart';
import '../../models/workout_routine.dart';

class CreateRoutineScreen extends StatefulWidget {
  final WorkoutRoutine? existingRoutine;

  const CreateRoutineScreen({
    super.key,
    this.existingRoutine,
  });

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _notesController = TextEditingController();
  final List<RoutineExercise> _exercises = [];
  Color _selectedColor = Colors.blue;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.red,
    Colors.teal,
    AppTheme.accentYellow,
    Colors.pink,
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingRoutine != null) {
      _loadExistingRoutine();
    }
  }

  void _loadExistingRoutine() {
    final routine = widget.existingRoutine!;
    _nameController.text = routine.name;
    _descriptionController.text = routine.description;
    _notesController.text = routine.notes ?? '';
    _selectedColor = routine.color ?? Colors.blue;
    _exercises.addAll(routine.exercises);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRoutine != null;

    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: Text(
          isEditing ? 'Edit Routine' : 'Create Routine',
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          TextButton(
            onPressed: _saveRoutine,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Routine Details Section
                  _buildRoutineDetailsSection(),
                  const SizedBox(height: 24),
                  // Color Selection
                  _buildColorSelectionSection(),
                  const SizedBox(height: 24),
                  // Exercises Section
                  _buildExercisesSection(),
                  const SizedBox(height: 80), // Space for FAB
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExercise,
        backgroundColor: AppTheme.accentYellow,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoutineDetailsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routine Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Routine Name
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Routine Name',
            hintText: 'e.g., Upper Body Strength, Push Day',
          ),
        ),
        const SizedBox(height: 16),
        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Brief description of this routine',
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        // Notes
        TextFormField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            hintText: 'Any additional notes or instructions',
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildColorSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Routine Color',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          children: _availableColors.map((color) {
            final isSelected = color == _selectedColor;
            return GestureDetector(
              onTap: () => setState(() => _selectedColor = color),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? AppTheme.textPrimary : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExercisesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Exercises (${_exercises.length})',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_exercises.isNotEmpty)
              Text(
                '${_getTotalSets()} sets',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_exercises.isEmpty)
          _buildEmptyExercisesState()
        else
          Column(
            children: _exercises.asMap().entries.map((entry) {
              final index = entry.key;
              final exercise = entry.value;
              return _buildExerciseCard(exercise, index);
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildEmptyExercisesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center_outlined,
            size: 64,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No exercises added yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first exercise',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(RoutineExercise exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Exercise Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: MuscleGroupExtension.getColor(exercise.muscleGroup).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Muscle group icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: MuscleGroupExtension.getColor(exercise.muscleGroup).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    exercise.muscleGroup.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        exercise.muscleGroup.displayName,
                        style: TextStyle(
                          color: MuscleGroupExtension.getColor(exercise.muscleGroup),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editExercise(index);
                    } else if (value == 'delete') {
                      _removeExercise(index);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  child: const Icon(
                    Icons.more_vert,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Planned Sets
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Planned Sets (${exercise.plannedSets.length})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                ...exercise.plannedSets.asMap().entries.map((entry) {
                  final setIndex = entry.key;
                  final plannedSet = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 30,
                          child: Text(
                            '${setIndex + 1}.',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            plannedSet.displayString,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _addExercise() {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        onAdd: (exercise) {
          setState(() {
            _exercises.add(exercise);
          });
        },
      ),
    );
  }

  void _editExercise(int index) {
    showDialog(
      context: context,
      builder: (context) => _AddExerciseDialog(
        existingExercise: _exercises[index],
        onAdd: (exercise) {
          setState(() {
            _exercises[index] = exercise;
          });
        },
      ),
    );
  }

  void _removeExercise(int index) {
    setState(() {
      _exercises.removeAt(index);
    });
  }

  int _getTotalSets() {
    return _exercises.fold(0, (sum, exercise) => sum + exercise.plannedSets.length);
  }

  void _saveRoutine() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a routine name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one exercise'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final routine = WorkoutRoutine(
      id: widget.existingRoutine?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      exercises: _exercises,
      createdAt: widget.existingRoutine?.createdAt ?? DateTime.now(),
      lastUsedAt: widget.existingRoutine?.lastUsedAt,
      timesUsed: widget.existingRoutine?.timesUsed ?? 0,
      color: _selectedColor,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.existingRoutine != null) {
      RoutineService.updateRoutine(routine);
    } else {
      RoutineService.saveRoutine(routine);
    }

    Navigator.of(context).pop(routine);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.existingRoutine != null 
            ? 'Routine updated successfully!' 
            : 'Routine created successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _AddExerciseDialog extends StatefulWidget {
  final Function(RoutineExercise) onAdd;
  final RoutineExercise? existingExercise;

  const _AddExerciseDialog({
    required this.onAdd,
    this.existingExercise,
  });

  @override
  State<_AddExerciseDialog> createState() => _AddExerciseDialogState();
}

class _AddExerciseDialogState extends State<_AddExerciseDialog> {
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  MuscleGroup _selectedMuscleGroup = MuscleGroup.chest;
  final List<PlannedSet> _plannedSets = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingExercise != null) {
      _loadExistingExercise();
    } else {
      // Start with one empty set
      _plannedSets.add(PlannedSet());
    }
  }

  void _loadExistingExercise() {
    final exercise = widget.existingExercise!;
    _nameController.text = exercise.name;
    _notesController.text = exercise.notes ?? '';
    _selectedMuscleGroup = exercise.muscleGroup;
    _plannedSets.addAll(exercise.plannedSets);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingExercise != null;

    return Dialog(
      backgroundColor: AppTheme.surfaceColor,
      insetPadding: const EdgeInsets.all(20),
      child: SizedBox(
        width: MediaQuery.of(context).size.width - 40,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    isEditing ? 'Edit Exercise' : 'Add Exercise',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise Name
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Exercise Name',
                        hintText: 'e.g., Bench Press, Squats',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Muscle Group
                    DropdownButtonFormField<MuscleGroup>(
                      value: _selectedMuscleGroup,
                      decoration: const InputDecoration(
                        labelText: 'Muscle Group',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      isExpanded: true,
                      items: MuscleGroup.values.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(group.icon, style: const TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  group.displayName,
                                  style: TextStyle(
                                    color: MuscleGroupExtension.getColor(group),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedMuscleGroup = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    // Planned Sets
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Planned Sets',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _addPlannedSet,
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Set'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.accentYellow,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._plannedSets.asMap().entries.map((entry) {
                      final index = entry.key;
                      final set = entry.value;
                      return _buildPlannedSetRow(set, index);
                    }),
                    const SizedBox(height: 16),
                    // Notes
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        hintText: 'Any specific instructions',
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),
            // Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: AppTheme.borderColor),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: ElevatedButton(
                      onPressed: _saveExercise,
                      child: Text(isEditing ? 'Update' : 'Add'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlannedSetRow(PlannedSet set, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          // Set number
          SizedBox(
            width: 30,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Weight input
          Expanded(
            child: TextFormField(
              initialValue: set.targetWeight?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Weight',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final weight = double.tryParse(value);
                _plannedSets[index] = set.copyWith(targetWeight: weight);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Reps input
          Expanded(
            child: TextFormField(
              initialValue: set.targetReps?.toString() ?? '',
              decoration: const InputDecoration(
                labelText: 'Reps',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final reps = int.tryParse(value);
                _plannedSets[index] = set.copyWith(targetReps: reps);
              },
            ),
          ),
          const SizedBox(width: 8),
          // Delete button
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () => _removePlannedSet(index),
          ),
        ],
      ),
    );
  }

  void _addPlannedSet() {
    setState(() {
      _plannedSets.add(PlannedSet());
    });
  }

  void _removePlannedSet(int index) {
    if (_plannedSets.length > 1) {
      setState(() {
        _plannedSets.removeAt(index);
      });
    }
  }

  void _saveExercise() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an exercise name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final exercise = RoutineExercise(
      name: _nameController.text.trim(),
      muscleGroup: _selectedMuscleGroup,
      plannedSets: _plannedSets,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    widget.onAdd(exercise);
    Navigator.of(context).pop();
  }
}