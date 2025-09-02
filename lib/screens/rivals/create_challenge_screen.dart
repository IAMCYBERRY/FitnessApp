/// Screen for creating new fitness challenges.
/// 
/// This screen allows users to:
/// - Create public or private challenges
/// - Set challenge parameters (duration, rules, prizes)
/// - Invite participants
/// - Configure challenge settings

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';

class CreateChallengeScreen extends StatefulWidget {
  const CreateChallengeScreen({super.key});

  @override
  State<CreateChallengeScreen> createState() => _CreateChallengeScreenState();
}

class _CreateChallengeScreenState extends State<CreateChallengeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _maxParticipantsController = TextEditingController(text: '50');
  final _entryFeeController = TextEditingController(text: '0');
  final _prizePoolController = TextEditingController(text: '0');
  
  ChallengeType _selectedType = ChallengeType.public;
  DateTime _startDate = DateTime.now().add(const Duration(hours: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  final List<String> _rules = [];
  final _ruleController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _entryFeeController.dispose();
    _prizePoolController.dispose();
    _ruleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBackground,
        title: const Text(
          'Create Challenge',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          TextButton(
            onPressed: _createChallenge,
            child: const Text(
              'Create',
              style: TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Challenge Type Selection
              _buildSectionTitle('Challenge Type'),
              const SizedBox(height: 12),
              _buildTypeSelection(),
              const SizedBox(height: 24),

              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 12),
              _buildBasicInfoSection(),
              const SizedBox(height: 24),

              // Duration
              _buildSectionTitle('Duration'),
              const SizedBox(height: 12),
              _buildDurationSection(),
              const SizedBox(height: 24),

              // Settings
              _buildSectionTitle('Settings'),
              const SizedBox(height: 12),
              _buildSettingsSection(),
              const SizedBox(height: 24),

              // Rules
              _buildSectionTitle('Rules'),
              const SizedBox(height: 12),
              _buildRulesSection(),
              const SizedBox(height: 80), // Space for keyboard
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: AppTheme.textPrimary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Row(
      children: ChallengeType.values
          .where((type) => type != ChallengeType.daily) // Exclude daily for user creation
          .map((type) {
        final isSelected = _selectedType == type;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: type == ChallengeType.public ? 8 : 0,
            ),
            child: InkWell(
              onTap: () => setState(() => _selectedType = type),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.accentYellow.withOpacity(0.2)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentYellow
                        : AppTheme.borderColor,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      type == ChallengeType.public
                          ? Icons.public
                          : Icons.lock,
                      color: isSelected
                          ? AppTheme.accentYellow
                          : AppTheme.textSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      type == ChallengeType.public ? 'Public' : 'Private',
                      style: TextStyle(
                        color: isSelected
                            ? AppTheme.accentYellow
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == ChallengeType.public
                          ? 'Anyone can join'
                          : 'Invite only',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBasicInfoSection() {
    return Column(
      children: [
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Challenge Name',
            hintText: 'e.g., 30-Day Fitness Challenge',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a challenge name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe your challenge and goals',
          ),
          maxLines: 3,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a description';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Start Date
          InkWell(
            onTap: () => _selectStartDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: AppTheme.accentYellow),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Start Date',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDate(_startDate),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, 
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // End Date
          InkWell(
            onTap: () => _selectEndDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.event, color: AppTheme.accentYellow),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'End Date',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDate(_endDate),
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, 
                    color: AppTheme.textSecondary,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Duration Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentYellow.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'Duration: ${_calculateDuration()}',
                style: const TextStyle(
                  color: AppTheme.accentYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      children: [
        // Max Participants
        TextFormField(
          controller: _maxParticipantsController,
          decoration: const InputDecoration(
            labelText: 'Maximum Participants',
            hintText: 'Leave empty for unlimited',
            suffixText: 'users',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        // Entry Fee
        TextFormField(
          controller: _entryFeeController,
          decoration: const InputDecoration(
            labelText: 'Entry Fee',
            hintText: '0 for free entry',
            prefixIcon: Icon(Icons.toll, color: AppTheme.accentYellow),
            suffixText: 'points',
          ),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        // Prize Pool
        TextFormField(
          controller: _prizePoolController,
          decoration: const InputDecoration(
            labelText: 'Prize Pool',
            hintText: 'Total points for winners',
            prefixIcon: Icon(Icons.emoji_events, color: AppTheme.accentYellow),
            suffixText: 'points',
          ),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildRulesSection() {
    return Column(
      children: [
        // Rule Input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ruleController,
                decoration: const InputDecoration(
                  hintText: 'Add a rule',
                ),
                onSubmitted: (value) => _addRule(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addRule,
              icon: const Icon(Icons.add_circle),
              color: AppTheme.accentYellow,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Rules List
        if (_rules.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
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
                  Icons.rule,
                  size: 48,
                  color: AppTheme.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'No rules added yet',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_rules.length, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _rules[index],
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: Colors.red,
                    onPressed: () => _removeRule(index),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        // Ensure end date is after start date
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: _startDate.add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _calculateDuration() {
    final duration = _endDate.difference(_startDate);
    if (duration.inDays == 0) {
      return '${duration.inHours} hours';
    } else if (duration.inDays == 1) {
      return '1 day';
    } else if (duration.inDays < 7) {
      return '${duration.inDays} days';
    } else if (duration.inDays < 30) {
      final weeks = (duration.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''}';
    } else {
      final months = (duration.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    }
  }

  void _addRule() {
    if (_ruleController.text.trim().isNotEmpty) {
      setState(() {
        _rules.add(_ruleController.text.trim());
        _ruleController.clear();
      });
    }
  }

  void _removeRule(int index) {
    setState(() {
      _rules.removeAt(index);
    });
  }

  void _createChallenge() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_rules.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one rule'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final challenge = Challenge(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      status: _startDate.isAfter(DateTime.now())
          ? ChallengeStatus.upcoming
          : ChallengeStatus.active,
      startDate: _startDate,
      endDate: _endDate,
      creatorId: '123', // Mock user ID
      creatorName: 'John Doe',
      participantIds: ['123'], // Creator auto-joins
      leaderboard: {'123': 0}, // Initialize creator's score
      maxParticipants: int.tryParse(_maxParticipantsController.text) ?? 100,
      rules: _rules,
      entryFee: int.tryParse(_entryFeeController.text) ?? 0,
      prizePool: int.tryParse(_prizePoolController.text) ?? 0,
    );

    ChallengeService.createChallenge(challenge);
    Navigator.of(context).pop(challenge);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Challenge "${challenge.name}" created!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}