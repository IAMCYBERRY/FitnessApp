/// Rivals screen for competitive features including challenges and rival sessions.
/// 
/// This screen allows users to:
/// - View and manage their current rival session
/// - Browse and join challenges
/// - View leaderboards
/// - Create new challenges

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';
import '../../models/user_model_clean.dart';
import '../../blocs/points/points_bloc.dart';
import '../../blocs/points/points_event.dart';
import '../../blocs/points/points_state.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import 'create_challenge_screen.dart';
import 'challenge_details_screen.dart';
import '../challenges/full_leaderboard_screen.dart';
import 'find_rival_screen.dart';

class RivalsScreen extends StatefulWidget {
  const RivalsScreen({super.key});

  @override
  State<RivalsScreen> createState() => _RivalsScreenState();
}

class RivalsScreenWrapper extends StatelessWidget {
  const RivalsScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PointsBloc(
        authBloc: context.read<LocalAuthBloc>(),
      ),
      child: const RivalsScreen(),
    );
  }
}

/// Dialog for daily challenge completion
class _DailyChallengeCompletionDialog extends StatefulWidget {
  final DailyChallenge challenge;
  final Function(int) onComplete;

  const _DailyChallengeCompletionDialog({
    required this.challenge,
    required this.onComplete,
  });

  @override
  State<_DailyChallengeCompletionDialog> createState() => 
      _DailyChallengeCompletionDialogState();
}

class _DailyChallengeCompletionDialogState 
    extends State<_DailyChallengeCompletionDialog> {
  late final TextEditingController _controller;
  late int _completedValue;

  @override
  void initState() {
    super.initState();
    _completedValue = widget.challenge.targetValue;
    _controller = TextEditingController(text: _completedValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceColor,
      title: Row(
        children: [
          Text(widget.challenge.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Complete ${widget.challenge.name}',
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.challenge.instruction,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'How many ${widget.challenge.unit} did you complete?',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: widget.challenge.unit,
              labelStyle: const TextStyle(color: AppTheme.textSecondary),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.borderColor),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.accentYellow),
              ),
            ),
            onChanged: (value) {
              _completedValue = int.tryParse(value) ?? 0;
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${widget.challenge.targetValue} ${widget.challenge.unit}',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
        ElevatedButton(
          onPressed: _completedValue > 0 ? () {
            widget.onComplete(_completedValue);
            Navigator.of(context).pop();
          } : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.accentYellow,
            foregroundColor: Colors.black,
          ),
          child: Text(
            'Complete (+${widget.challenge.basePoints} pts)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _RivalsScreenState extends State<RivalsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<Challenge> _challenges = [];
  RivalSession? _activeRivalSession;
  final String _currentUserId = '123'; // Mock current user

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    // Add mock data if needed
    if (ChallengeService.getAllChallenges().isEmpty) {
      ChallengeService.addMockData();
    }
    
    setState(() {
      _challenges = ChallengeService.getAllChallenges();
      _activeRivalSession = ChallengeService.getActiveRivalSession(_currentUserId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PointsBloc, PointsState>(
      listener: (context, state) {
        if (state is PointsAwarding) {
          _showPointsAwardedSnackBar(context, state);
        } else if (state is RankUpAchieved) {
          _showRankUpDialog(context, state);
        } else if (state is PointsError) {
          _showErrorSnackBar(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.darkBackground,
        body: SafeArea(
          child: Column(
            children: [
              // App Bar with Points Display
              BlocBuilder<PointsBloc, PointsState>(
                builder: (context, pointsState) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Rivals',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle),
                              color: AppTheme.accentYellow,
                              iconSize: 32,
                              onPressed: _createNewChallenge,
                            ),
                          ],
                        ),
                        if (pointsState is PointsLoaded) ...[
                          const SizedBox(height: 8),
                          _buildPointsHeader(pointsState),
                        ],
                      ],
                    ),
                  );
                },
              ),
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppTheme.accentYellow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: Colors.black,
                  unselectedLabelColor: AppTheme.textSecondary,
                  tabs: const [
                    Tab(text: 'Rival Mode'),
                    Tab(text: 'Challenges'),
                    Tab(text: 'Leaderboard'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRivalModeTab(),
                    _buildChallengesTab(),
                    _buildLeaderboardTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRivalModeTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Daily Challenge Section
          _buildDailyChallengeCard(),
          const SizedBox(height: 16),
          
          // Active Rival Section
          if (_activeRivalSession != null) ...[
            _buildActiveRivalCard(),
            const SizedBox(height: 16),
            _buildRivalStats(),
            const SizedBox(height: 16),
            _buildRecentRivalActivities(),
          ] else
            _buildNoRivalSession(),
        ],
      ),
    );
  }

  Widget _buildNoRivalSession() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_kabaddi,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Active Rival',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Challenge a friend to a week-long fitness battle!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _findRival,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Find a Rival',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRivalCard() {
    final rival = _activeRivalSession!;
    
    return BlocBuilder<PointsBloc, PointsState>(
      builder: (context, pointsState) {
        // Use real user points from PointsBLoC if available
        int userPoints = rival.getUserPoints(_currentUserId);
        if (pointsState is PointsLoaded) {
          userPoints = pointsState.weeklyPoints; // Use weekly points for rival comparison
        }
        
        final rivalPoints = rival.getOpponentPoints(_currentUserId);
        final isWinning = userPoints > rivalPoints;
        final pointDiff = (userPoints - rivalPoints).abs();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isWinning
                  ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
                  : [Colors.red.withOpacity(0.3), Colors.red.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isWinning ? Colors.green : Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '⏱️ ${rival.remainingTimeFormatted} remaining',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // VS Display
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // User
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: AppTheme.accentYellow,
                        child: Text(
                          rival.user1Name[0],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '$userPoints pts',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (pointsState is PointsLoaded) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${pointsState.currentRank.name} Rank',
                          style: TextStyle(
                            color: _getRankColor(pointsState.currentRank),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                  // VS
                  Column(
                    children: [
                      const Text(
                        'VS',
                        style: TextStyle(
                          color: AppTheme.accentYellow,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (isWinning)
                        Text(
                          '+$pointDiff',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      else
                        Text(
                          '-$pointDiff',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  // Opponent
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.grey,
                        child: Text(
                          rival.getOpponentName(_currentUserId)[0],
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rival.getOpponentName(_currentUserId),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      Text(
                        '$rivalPoints pts',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'C Rank', // Mock opponent rank
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Status
              Text(
                isWinning ? '🔥 You\'re winning!' : '💪 Time to catch up!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isWinning ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (rival.wagerAmount > 0) ...[
                const SizedBox(height: 8),
                Text(
                  '🏆 ${rival.wagerAmount} points at stake',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accentYellow,
                  ),
                ),
              ],
              // End Rival Session Button
              if (rival.isActive && rival.remainingTime.inHours < 24) ...[
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _endRivalSession(rival, userPoints, rivalPoints),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isWinning ? Colors.green : Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    isWinning ? 'Claim Victory' : 'End Session',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildRivalStats() {
    return BlocBuilder<PointsBloc, PointsState>(
      builder: (context, pointsState) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This Week\'s Stats',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (pointsState is PointsLoaded) ...[
                    _buildStatItem(
                      'Weekly Points', 
                      '${pointsState.weeklyPoints}', 
                      Icons.emoji_events,
                    ),
                    _buildStatItem(
                      'Streak', 
                      '${pointsState.currentStreak}', 
                      Icons.local_fire_department,
                    ),
                    _buildStatItem(
                      'Rank Progress', 
                      '${pointsState.rankProgress.toInt()}%', 
                      Icons.trending_up,
                    ),
                  ] else ...[
                    _buildStatItem('Workouts', '5', Icons.fitness_center),
                    _buildStatItem('Total Time', '4h 30m', Icons.timer),
                    _buildStatItem('Calories', '2,450', Icons.local_fire_department),
                  ],
                ],
              ),
              if (pointsState is PointsLoaded && pointsState.activeBonuses.otherBonuses.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(color: AppTheme.borderColor),
                const SizedBox(height: 8),
                Text(
                  'Active Bonuses',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...pointsState.activeBonuses.otherBonuses.map((bonus) => 
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentYellow.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${bonus.name}: ${(bonus.multiplier * 100).toInt()}% bonus',
                      style: const TextStyle(
                        color: AppTheme.accentYellow,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentYellow, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentRivalActivities() {
    final activities = _activeRivalSession?.activities ?? {};
    
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...activities.entries.expand((entry) {
            final isCurrentUser = entry.key == _currentUserId;
            return entry.value.map((activity) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isCurrentUser
                        ? AppTheme.accentYellow
                        : Colors.grey,
                    child: Text(
                      isCurrentUser ? 'Y' : 'R',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      activity,
                      style: TextStyle(
                        color: isCurrentUser
                            ? AppTheme.textPrimary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ));
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    final activeChallenges = _challenges
        .where((c) => c.status == ChallengeStatus.active)
        .toList();
    final upcomingChallenges = _challenges
        .where((c) => c.status == ChallengeStatus.upcoming)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  'Create Challenge',
                  Icons.add_circle,
                  AppTheme.accentYellow,
                  _createNewChallenge,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  'Join Public',
                  Icons.group,
                  Colors.blue,
                  _browsePublicChallenges,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Active Challenges
          if (activeChallenges.isNotEmpty) ...[
            Text(
              'Active Challenges',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...activeChallenges.map((challenge) => 
              _buildChallengeCard(challenge)
            ),
          ],
          // Upcoming Challenges
          if (upcomingChallenges.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Upcoming Challenges',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...upcomingChallenges.map((challenge) => 
              _buildChallengeCard(challenge)
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    final isParticipating = challenge.participantIds.contains(_currentUserId);
    final userRank = challenge.getUserRank(_currentUserId);

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
      child: InkWell(
        onTap: () => _viewChallengeDetails(challenge),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    challenge.typeIcon,
                    color: challenge.statusColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.name,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          challenge.typeDisplayName,
                          style: TextStyle(
                            color: challenge.statusColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (challenge.prizePool > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '🏆 ${challenge.prizePool} pts',
                        style: const TextStyle(
                          color: AppTheme.accentYellow,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                challenge.description,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              // Stats
              Row(
                children: [
                  _buildChallengeStatChip(
                    Icons.people,
                    '${challenge.participantIds.length}',
                  ),
                  const SizedBox(width: 12),
                  _buildChallengeStatChip(
                    Icons.timer,
                    challenge.remainingTimeFormatted,
                  ),
                  const SizedBox(width: 12),
                  if (isParticipating && userRank > 0)
                    _buildChallengeStatChip(
                      Icons.emoji_events,
                      '#$userRank',
                    ),
                ],
              ),
              if (!isParticipating && challenge.status == ChallengeStatus.active) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _joinChallenge(challenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentYellow,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      challenge.entryFee > 0
                          ? 'Join (${challenge.entryFee} pts)'
                          : 'Join Challenge',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeStatChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTab() {
    // Get all active challenges with leaderboards
    final challengesWithLeaderboards = _challenges
        .where((c) => c.status == ChallengeStatus.active && 
                     c.leaderboard.isNotEmpty)
        .toList();

    if (challengesWithLeaderboards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.leaderboard_outlined,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Active Leaderboards',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challengesWithLeaderboards.length,
      itemBuilder: (context, index) {
        final challenge = challengesWithLeaderboards[index];
        return _buildLeaderboardSection(challenge);
      },
    );
  }

  Widget _buildLeaderboardSection(Challenge challenge) {
    final topEntries = challenge.sortedLeaderboard.take(5).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: challenge.statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  challenge.typeIcon,
                  color: challenge.statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    challenge.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  challenge.remainingTimeFormatted,
                  style: TextStyle(
                    color: challenge.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // Leaderboard entries
          BlocBuilder<PointsBloc, PointsState>(
            builder: (context, pointsState) {
              return Column(
                children: topEntries.asMap().entries.map((entry) {
                  final rank = entry.key + 1;
                  final userId = entry.value.key;
                  int points = entry.value.value;
                  final isCurrentUser = userId == _currentUserId;

                  // Use real points for current user if available
                  if (isCurrentUser && pointsState is PointsLoaded) {
                    points = pointsState.weeklyPoints;
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isCurrentUser
                          ? AppTheme.accentYellow.withOpacity(0.1)
                          : Colors.transparent,
                      border: const Border(
                        bottom: BorderSide(
                          color: AppTheme.borderColor,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Rank
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _getLeaderboardRankColor(rank),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$rank',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // User
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isCurrentUser ? 'You' : 'User $userId',
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? AppTheme.accentYellow
                                      : AppTheme.textPrimary,
                                  fontWeight: isCurrentUser
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                              if (isCurrentUser && pointsState is PointsLoaded) ...[
                                Text(
                                  '${pointsState.currentRank.name} Rank',
                                  style: TextStyle(
                                    color: _getRankColor(pointsState.currentRank),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Points
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$points pts',
                              style: TextStyle(
                                color: isCurrentUser
                                    ? AppTheme.accentYellow
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isCurrentUser && pointsState is PointsLoaded && pointsState.currentStreak > 0) ...[
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_fire_department,
                                    color: Colors.orange,
                                    size: 12,
                                  ),
                                  Text(
                                    '${pointsState.currentStreak}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // View more button
          if (challenge.leaderboard.length > 5)
            InkWell(
              onTap: () => _viewFullLeaderboard(challenge),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text(
                    'View Full Leaderboard',
                    style: TextStyle(
                      color: AppTheme.accentYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getLeaderboardRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return AppTheme.textSecondary;
    }
  }

  void _createNewChallenge() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CreateChallengeScreen(),
      ),
    ).then((result) {
      if (result != null) {
        _loadData();
      }
    });
  }

  void _browsePublicChallenges() {
    // TODO: Navigate to public challenges browser
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Browse public challenges coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _findRival() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const FindRivalScreen(),
      ),
    ).then((result) {
      if (result != null) {
        _loadData(); // Refresh data when returning from Find Rival screen
      }
    });
  }

  void _joinChallenge(Challenge challenge) {
    ChallengeService.joinChallenge(challenge.id, _currentUserId);
    
    // Award participation points
    context.read<PointsBloc>().add(
      ChallengeCompleted(
        challengeId: challenge.id,
        challengeType: challenge.typeDisplayName,
        placement: challenge.participantIds.length + 1, // Temporary placement
        totalParticipants: challenge.participantIds.length + 1,
        basePoints: 50, // Base participation points
      ),
    );
    
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Joined ${challenge.name}! +50 participation points earned.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _viewChallengeDetails(Challenge challenge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeDetailsScreen(challenge: challenge),
      ),
    ).then((result) {
      if (result != null) {
        _loadData();
      }
    });
  }

  void _viewFullLeaderboard(Challenge challenge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullLeaderboardScreen(challenge: challenge),
      ),
    );
  }

  /// Build points header widget
  Widget _buildPointsHeader(PointsLoaded state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPointsInfoItem(
            'Total Points',
            '${state.totalPoints}',
            Icons.emoji_events,
            AppTheme.accentYellow,
          ),
          _buildPointsInfoItem(
            'Weekly',
            '${state.weeklyPoints}',
            Icons.calendar_today,
            Colors.blue,
          ),
          _buildPointsInfoItem(
            'Rank',
            state.currentRank.name,
            Icons.star,
            _getRankColor(state.currentRank),
          ),
          _buildPointsInfoItem(
            'Streak',
            '${state.currentStreak}',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _buildPointsInfoItem(String label, String value, IconData icon, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Color _getRankColor(RankLevel rank) {
    switch (rank) {
      case RankLevel.E:
        return Colors.grey;
      case RankLevel.D:
        return Colors.brown;
      case RankLevel.C:
        return Colors.green;
      case RankLevel.B:
        return Colors.blue;
      case RankLevel.A:
        return Colors.purple;
      case RankLevel.S:
        return Colors.orange;
      case RankLevel.SS:
        return Colors.red;
    }
  }

  void _showPointsAwardedSnackBar(BuildContext context, PointsAwarding state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.add_circle, color: AppTheme.accentYellow),
            const SizedBox(width: 8),
            Text(
              '+${state.pointsAwarded} points earned!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showRankUpDialog(BuildContext context, RankUpAchieved state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppTheme.accentYellow),
            SizedBox(width: 8),
            Text(
              'Rank Up!',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Congratulations! You\'ve been promoted to',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '${state.currentRank.name} Rank',
              style: TextStyle(
                color: _getRankColor(state.currentRank),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+${state.rankUpBonus} bonus points awarded!',
              style: const TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Awesome!',
              style: TextStyle(color: AppTheme.accentYellow),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Build daily challenge card
  Widget _buildDailyChallengeCard() {
    final todaysChallenge = DailyChallengeService.getTodaysChallenge();
    
    if (todaysChallenge == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: todaysChallenge.isCompleted
              ? [Colors.green.withOpacity(0.3), Colors.green.withOpacity(0.1)]
              : [AppTheme.accentYellow.withOpacity(0.3), AppTheme.accentYellow.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: todaysChallenge.isCompleted ? Colors.green : AppTheme.accentYellow,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  todaysChallenge.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Daily Challenge',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        if (!todaysChallenge.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.accentYellow.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              todaysChallenge.remainingTimeFormatted,
                              style: const TextStyle(
                                color: AppTheme.accentYellow,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 20,
                          ),
                      ],
                    ),
                    Text(
                      todaysChallenge.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todaysChallenge.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.darkBackground.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Target: ${todaysChallenge.targetValue} ${todaysChallenge.unit}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (todaysChallenge.isCompleted && todaysChallenge.completedValue != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Completed: ${todaysChallenge.completedValue} ${todaysChallenge.unit}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              if (!todaysChallenge.isCompleted)
                Flexible(
                  child: ElevatedButton(
                    onPressed: () => _completeDailyChallenge(todaysChallenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Complete (+${todaysChallenge.basePoints} pts)',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Completed!',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (DailyChallengeService.getCurrentStreak() > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${DailyChallengeService.getCurrentStreak()} day streak!',
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Complete daily challenge
  void _completeDailyChallenge(DailyChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => _DailyChallengeCompletionDialog(
        challenge: challenge,
        onComplete: (completedValue) {
          final completedChallenge = DailyChallengeService.completeChallenge(
            challenge.id,
            completedValue,
          );
          
          if (completedChallenge != null) {
            // Award points through PointsBLoC
            context.read<PointsBloc>().add(
              DailyChallengeCompleted(
                challengeId: completedChallenge.id,
                challengeDescription: completedChallenge.name,
              ),
            );
            
            setState(() {}); // Refresh UI
          }
        },
      ),
    );
  }

  /// End rival session 
  void _endRivalSession(RivalSession rival, int userPoints, int rivalPoints) {
    _processRivalSessionEnd(rival, userPoints, rivalPoints);
  }

  /// Process rival session ending
  void _processRivalSessionEnd(RivalSession rival, int userPoints, int rivalPoints) {
    setState(() {
      _activeRivalSession = null;
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          userPoints > rivalPoints 
              ? 'Victory claimed! Bonus points awarded.'
              : 'Rival session ended.',
        ),
        backgroundColor: userPoints > rivalPoints ? Colors.green : Colors.blue,
      ),
    );
  }
}
