/// Challenge Details Screen for displaying comprehensive challenge information.
/// 
/// This screen shows full challenge details including:
/// - Challenge header with name, description, type, and countdown timer
/// - Tabbed interface with Overview, Leaderboard, Activity, and Chat sections
/// - Real-time leaderboard updates and participant activities
/// - Join/Leave functionality with proper error handling
/// - Navigation to challenge chat functionality

import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';
import '../challenges/full_leaderboard_screen.dart';
import '../challenges/challenge_chat_screen.dart';

/// Detailed view screen for a specific challenge
class ChallengeDetailsScreen extends StatefulWidget {
  /// The challenge to display details for
  final Challenge challenge;

  /// Creates a new challenge details screen.
  /// 
  /// @param challenge The challenge to display details for
  const ChallengeDetailsScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<ChallengeDetailsScreen> createState() => _ChallengeDetailsScreenState();
}

class _ChallengeDetailsScreenState extends State<ChallengeDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Challenge _currentChallenge;
  Timer? _countdownTimer;
  bool _isLoading = false;
  String? _errorMessage;

  // Mock current user ID for demonstration
  final String _currentUserId = '123';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _currentChallenge = widget.challenge;
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Starts the countdown timer for live updates
  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Timer update will trigger rebuild and show updated remaining time
        });
      }
    });
  }

  /// Simulates loading updated challenge data
  Future<void> _loadChallengeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      // In a real app, this would fetch updated challenge data from the service
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load challenge data';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: _buildTabContent(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the challenge header section
  Widget _buildHeader() {
    final bool isParticipating = _currentChallenge.participantIds.contains(_currentUserId);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _currentChallenge.statusColor.withOpacity(0.3),
            AppTheme.darkBackground,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top navigation bar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Challenge Details',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AppTheme.accentYellow),
                onPressed: _loadChallengeData,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Challenge title and type
          Row(
            children: [
              Icon(
                _currentChallenge.typeIcon,
                color: _currentChallenge.statusColor,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentChallenge.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _currentChallenge.typeDisplayName,
                      style: TextStyle(
                        color: _currentChallenge.statusColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            _currentChallenge.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            children: [
              _buildStatBadge(
                'Participants',
                '${_currentChallenge.participantIds.length}',
                Icons.people,
              ),
              const SizedBox(width: 12),
              _buildStatBadge(
                'Time Left',
                _currentChallenge.remainingTimeFormatted,
                Icons.timer,
              ),
              if (_currentChallenge.prizePool > 0) ...[
                const SizedBox(width: 12),
                _buildStatBadge(
                  'Prize Pool',
                  '${_currentChallenge.prizePool} pts',
                  Icons.emoji_events,
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          
          // Join/Leave button
          if (_currentChallenge.status == ChallengeStatus.active)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _toggleParticipation(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isParticipating 
                      ? Colors.red.withOpacity(0.8)
                      : AppTheme.accentYellow,
                  foregroundColor: isParticipating ? Colors.white : Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        isParticipating ? 'Leave Challenge' : 
                        (_currentChallenge.entryFee > 0 
                            ? 'Join (${_currentChallenge.entryFee} pts)'
                            : 'Join Challenge'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a stat badge widget
  Widget _buildStatBadge(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppTheme.accentYellow),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the tab bar
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Leaderboard'),
          Tab(text: 'Activity'),
          Tab(text: 'Chat'),
        ],
      ),
    );
  }

  /// Builds the tab content
  Widget _buildTabContent() {
    if (_errorMessage != null) {
      return _buildErrorState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildLeaderboardTab(),
        _buildActivityTab(),
        _buildChatTab(),
      ],
    );
  }

  /// Builds the overview tab content
  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Challenge Rules',
            Icons.rule,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _currentChallenge.rules.map((rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•',
                      style: TextStyle(
                        color: AppTheme.accentYellow,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rule,
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Challenge Info',
            Icons.info,
            Column(
              children: [
                _buildInfoRow('Created by', _currentChallenge.creatorName),
                _buildInfoRow('Start Date', _formatDate(_currentChallenge.startDate)),
                _buildInfoRow('End Date', _formatDate(_currentChallenge.endDate)),
                _buildInfoRow('Max Participants', '${_currentChallenge.maxParticipants}'),
                if (_currentChallenge.entryFee > 0)
                  _buildInfoRow('Entry Fee', '${_currentChallenge.entryFee} points'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Participant Overview',
            Icons.group,
            Column(
              children: [
                _buildInfoRow('Total Participants', '${_currentChallenge.participantIds.length}'),
                _buildInfoRow('Available Spots', '${_currentChallenge.maxParticipants - _currentChallenge.participantIds.length}'),
                if (_currentChallenge.participantIds.contains(_currentUserId))
                  _buildInfoRow('Your Rank', '#${_currentChallenge.getUserRank(_currentUserId)}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the leaderboard tab content
  Widget _buildLeaderboardTab() {
    final sortedEntries = _currentChallenge.sortedLeaderboard;
    
    if (sortedEntries.isEmpty) {
      return _buildEmptyState(
        'No participants yet',
        'Be the first to join and start earning points!',
        Icons.leaderboard,
      );
    }

    return Column(
      children: [
        // View Full Leaderboard button
        if (sortedEntries.length > 5)
          Container(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _viewFullLeaderboard(),
                icon: const Icon(Icons.leaderboard, color: AppTheme.accentYellow),
                label: const Text(
                  'View Full Leaderboard',
                  style: TextStyle(color: AppTheme.accentYellow, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.accentYellow),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        // Leaderboard list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: sortedEntries.length > 10 ? 10 : sortedEntries.length, // Show top 10 in summary
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final userId = entry.key;
              final points = entry.value;
              final rank = index + 1;
              final isCurrentUser = userId == _currentUserId;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isCurrentUser 
                      ? AppTheme.accentYellow.withOpacity(0.1)
                      : AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(12),
                  border: isCurrentUser
                      ? Border.all(color: AppTheme.accentYellow, width: 2)
                      : Border.all(color: AppTheme.borderColor.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    // Rank badge
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getRankColor(rank),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // User info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCurrentUser ? 'You' : 'Participant $userId',
                            style: TextStyle(
                              color: isCurrentUser ? AppTheme.accentYellow : AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (rank <= 3)
                            Text(
                              _getRankTitle(rank),
                              style: TextStyle(
                                color: _getRankColor(rank),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ),
                    
                    // Points
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$points',
                          style: TextStyle(
                            color: isCurrentUser ? AppTheme.accentYellow : AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'points',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds the activity tab content
  Widget _buildActivityTab() {
    // Mock activity data - in a real app this would come from the service
    final activities = [
      {'user': 'User user1', 'activity': 'Completed chest workout - 250 points earned', 'time': '2 hours ago', 'isCurrentUser': false},
      {'user': 'You', 'activity': 'Finished 5K run - 300 points earned', 'time': '4 hours ago', 'isCurrentUser': true},
      {'user': 'User user2', 'activity': 'Logged HIIT session - 200 points earned', 'time': '6 hours ago', 'isCurrentUser': false},
      {'user': 'User user3', 'activity': 'Completed strength training - 275 points earned', 'time': '8 hours ago', 'isCurrentUser': false},
      {'user': 'You', 'activity': 'Joined the challenge', 'time': '1 day ago', 'isCurrentUser': true},
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activities.length,
      itemBuilder: (context, index) {
        final activity = activities[index];
        final isCurrentUser = activity['isCurrentUser'] as bool;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: isCurrentUser ? AppTheme.accentYellow : Colors.grey,
                child: Text(
                  (activity['user'] as String)[0],
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Activity content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['user'] as String,
                      style: TextStyle(
                        color: isCurrentUser ? AppTheme.accentYellow : AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['activity'] as String,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['time'] as String,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Builds the chat tab content
  Widget _buildChatTab() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Challenge Chat',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Connect with other participants and share your progress!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _openChallengeChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text(
                'Open Chat',
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

  /// Helper method to build section containers
  Widget _buildSection(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }

  /// Helper method to build info rows
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds empty state widget
  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds error state widget
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadChallengeData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  /// Gets color for leaderboard rank
  Color _getRankColor(int rank) {
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

  /// Gets title for leaderboard rank
  String _getRankTitle(int rank) {
    switch (rank) {
      case 1:
        return 'Champion';
      case 2:
        return 'Runner-up';
      case 3:
        return 'Third Place';
      default:
        return '';
    }
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Handles joining/leaving the challenge
  Future<void> _toggleParticipation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final isCurrentlyParticipating = _currentChallenge.participantIds.contains(_currentUserId);
      
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (isCurrentlyParticipating) {
        // Leave challenge
        _currentChallenge.participantIds.remove(_currentUserId);
        _currentChallenge.leaderboard.remove(_currentUserId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Left challenge successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        // Join challenge
        if (_currentChallenge.participantIds.length >= _currentChallenge.maxParticipants) {
          throw Exception('Challenge is full');
        }
        
        _currentChallenge.participantIds.add(_currentUserId);
        _currentChallenge.leaderboard[_currentUserId] = 0;
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Joined ${_currentChallenge.name}!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Opens the challenge chat screen
  void _openChallengeChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeChatScreen(
          challenge: _currentChallenge,
        ),
      ),
    );
  }

  /// Navigates to the full leaderboard screen
  void _viewFullLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullLeaderboardScreen(challenge: _currentChallenge),
      ),
    );
  }
}