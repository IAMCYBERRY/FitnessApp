/// Example integration of Challenge Bloc with RivalsScreen.
/// 
/// This file demonstrates how to integrate the Challenge Bloc
/// with the existing RivalsScreen for proper state management.
/// This is an example file and should be used as a reference
/// for updating the actual screen files.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../lib/blocs/challenge/challenge_barrel.dart';
import '../lib/config/theme.dart';
import '../lib/models/challenge.dart';

class RivalsScreenWithBloc extends StatefulWidget {
  const RivalsScreenWithBloc({super.key});

  @override
  State<RivalsScreenWithBloc> createState() => _RivalsScreenWithBlocState();
}

class _RivalsScreenWithBlocState extends State<RivalsScreenWithBloc>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final String _currentUserId = '123'; // Mock current user

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load challenges when screen initializes
    context.read<ChallengeBloc>().add(LoadChallenges(userId: _currentUserId));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
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
                  Tab(text: 'Active'),
                  Tab(text: 'Challenges'),
                  Tab(text: 'History'),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Content with BLoC integration
            Expanded(
              child: BlocConsumer<ChallengeBloc, ChallengeState>(
                listener: (context, state) {
                  // Handle state changes that require user feedback
                  if (state is ChallengeError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is ChallengeCreated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is ChallengeJoined) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else if (state is InvitationSent) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  // Handle loading state
                  if (state is ChallengeLoading || state is ChallengeInitial) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.accentYellow,
                      ),
                    );
                  }
                  
                  // Handle error state
                  if (state is ChallengeError && state.previousState == null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Error Loading Challenges',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.message,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ChallengeBloc>().add(
                                LoadChallenges(userId: _currentUserId),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentYellow,
                              foregroundColor: Colors.black,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  // Extract challenge data from various states
                  List<Challenge> allChallenges = [];
                  List<Challenge> userChallenges = [];
                  List<Challenge> activeChallenges = [];
                  RivalSession? activeRivalSession;
                  List<ChallengeInvitation> receivedInvitations = [];
                  
                  if (state is ChallengeLoaded) {
                    allChallenges = state.allChallenges;
                    userChallenges = state.userChallenges;
                    activeChallenges = state.activeChallenges;
                    activeRivalSession = state.activeRivalSession;
                    receivedInvitations = state.receivedInvitations;
                  } else if (state is ChallengeRefreshing && state.previousState != null) {
                    // Show previous data while refreshing
                    allChallenges = state.previousState!.allChallenges;
                    userChallenges = state.previousState!.userChallenges;
                    activeChallenges = state.previousState!.activeChallenges;
                    activeRivalSession = state.previousState!.activeRivalSession;
                    receivedInvitations = state.previousState!.receivedInvitations;
                  } else if (state is ChallengeError && state.previousState != null) {
                    // Show previous data on error with previous state
                    allChallenges = state.previousState!.allChallenges;
                    userChallenges = state.previousState!.userChallenges;
                    activeChallenges = state.previousState!.activeChallenges;
                    activeRivalSession = state.previousState!.activeRivalSession;
                    receivedInvitations = state.previousState!.receivedInvitations;
                  }
                  
                  return Column(
                    children: [
                      // Show refreshing indicator
                      if (state is ChallengeRefreshing)
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: const LinearProgressIndicator(
                            color: AppTheme.accentYellow,
                            backgroundColor: AppTheme.surfaceColor,
                          ),
                        ),
                      
                      // Pending invitations banner
                      if (receivedInvitations.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentYellow.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.accentYellow.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.notifications_active,
                                color: AppTheme.accentYellow,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  '${receivedInvitations.length} challenge invitation(s) pending',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showInvitations(receivedInvitations),
                                child: Text(
                                  'View',
                                  style: TextStyle(color: AppTheme.accentYellow),
                                ),
                              ),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Tab content
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Active Tab
                            _buildActiveTab(activeRivalSession, activeChallenges),
                            
                            // Challenges Tab
                            _buildChallengesTab(allChallenges),
                            
                            // History Tab
                            _buildHistoryTab(),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _refreshData(),
        backgroundColor: AppTheme.accentYellow,
        foregroundColor: Colors.black,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildActiveTab(RivalSession? activeRivalSession, List<Challenge> activeChallenges) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      color: AppTheme.accentYellow,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          if (activeRivalSession != null) ...[
            _buildRivalSessionCard(activeRivalSession),
            const SizedBox(height: 16),
          ],
          
          if (activeChallenges.isNotEmpty) ...[
            Text(
              'Active Challenges',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...activeChallenges.map((challenge) => 
              _buildChallengeCard(challenge, isParticipating: true)),
          ] else ...[
            const SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.sports_mma,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Active Challenges',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join a challenge or find a rival to get started!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _tabController.animateTo(1),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentYellow,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Browse Challenges'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildChallengesTab(List<Challenge> challenges) {
    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      color: AppTheme.accentYellow,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _createNewChallenge,
                  icon: const Icon(Icons.add),
                  label: const Text('Create Challenge'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _findRival,
                  icon: const Icon(Icons.person_search),
                  label: const Text('Find Rival'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.accentYellow),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          if (challenges.isNotEmpty) ...[
            Text(
              'Available Challenges',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...challenges.map((challenge) => 
              _buildChallengeCard(challenge, isParticipating: false)),
          ] else ...[
            const SizedBox(height: 100),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.emoji_events,
                    size: 64,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Challenges Available',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to create a challenge!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
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

  Widget _buildHistoryTab() {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ChallengeBloc>().add(
          LoadChallengeHistory(userId: _currentUserId),
        );
      },
      color: AppTheme.accentYellow,
      child: BlocBuilder<ChallengeBloc, ChallengeState>(
        builder: (context, state) {
          if (state is ChallengeHistoryLoaded) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Statistics Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Stats',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem('Challenges', '${state.statistics['totalChallenges']}'),
                          _buildStatItem('Total Points', '${state.statistics['totalPoints']}'),
                          _buildStatItem('Best Rank', '#${state.statistics['bestRank']}'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                if (state.completedChallenges.isNotEmpty) ...[
                  Text(
                    'Completed Challenges',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...state.completedChallenges.map((challenge) => 
                    _buildChallengeCard(challenge, isParticipating: false, isCompleted: true)),
                ] else ...[
                  const SizedBox(height: 50),
                  Center(
                    child: Text(
                      'No completed challenges yet',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ],
            );
          } else {
            // Load history if not loaded
            context.read<ChallengeBloc>().add(
              LoadChallengeHistory(userId: _currentUserId),
            );
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.accentYellow),
            );
          }
        },
      ),
    );
  }

  Widget _buildRivalSessionCard(RivalSession rivalSession) {
    final isWinning = rivalSession.isUserWinning(_currentUserId);
    final userPoints = rivalSession.getUserPoints(_currentUserId);
    final opponentPoints = rivalSession.getOpponentPoints(_currentUserId);
    final opponentName = rivalSession.getOpponentName(_currentUserId);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinning ? AppTheme.accentYellow : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Current Rival Session',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWinning ? AppTheme.accentYellow : Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isWinning ? 'WINNING' : 'LOSING',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'vs $opponentName',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Points',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '$userPoints',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Opponent Points',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '$opponentPoints',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Time Remaining: ${rivalSession.remainingTimeFormatted}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Challenge challenge, {required bool isParticipating, bool isCompleted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  challenge.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: challenge.statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  challenge.typeDisplayName,
                  style: TextStyle(
                    color: challenge.statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            challenge.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Participants',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  Text(
                    '${challenge.participantIds.length}/${challenge.maxParticipants}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (!isCompleted) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time Remaining',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      challenge.remainingTimeFormatted,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _viewChallengeDetails(challenge),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textPrimary,
                    side: const BorderSide(color: AppTheme.accentYellow),
                  ),
                  child: const Text('View Details'),
                ),
              ),
              if (!isParticipating && !isCompleted && challenge.status == ChallengeStatus.active) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _joinChallenge(challenge),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentYellow,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Join'),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: AppTheme.accentYellow,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _createNewChallenge() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ChallengeBloc>(),
          child: const CreateChallengeScreen(),
        ),
      ),
    ).then((_) {
      // Refresh data after returning from create challenge screen
      _refreshData();
    });
  }

  void _findRival() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ChallengeBloc>(),
          child: const FindRivalScreen(),
        ),
      ),
    ).then((_) {
      // Refresh data after returning from find rival screen
      _refreshData();
    });
  }

  void _joinChallenge(Challenge challenge) {
    context.read<ChallengeBloc>().add(
      JoinChallenge(challengeId: challenge.id, userId: _currentUserId),
    );
  }

  void _viewChallengeDetails(Challenge challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: context.read<ChallengeBloc>(),
          child: ChallengeDetailsScreen(challenge: challenge),
        ),
      ),
    );
  }

  void _refreshData() {
    context.read<ChallengeBloc>().add(
      RefreshChallenges(userId: _currentUserId),
    );
  }

  void _showInvitations(List<ChallengeInvitation> invitations) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Challenge Invitations',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...invitations.map((invitation) => _buildInvitationCard(invitation)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(ChallengeInvitation invitation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'From: ${invitation.senderName}',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${invitation.challengeTypeDisplayName} • ${invitation.durationFormatted}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (invitation.personalMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              invitation.personalMessage!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _respondToInvitation(invitation, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Decline'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _respondToInvitation(invitation, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentYellow,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Accept'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _respondToInvitation(ChallengeInvitation invitation, bool accept) {
    Navigator.pop(context); // Close the modal
    context.read<ChallengeBloc>().add(
      RespondToInvitation(
        invitationId: invitation.id,
        accept: accept,
        userId: _currentUserId,
      ),
    );
  }
}