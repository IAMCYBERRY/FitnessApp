/// Find Rival screen for discovering friends and sending challenge invitations.
/// 
/// This screen allows users to:
/// - Search for friends by username/email
/// - Browse friend suggestions based on skill level
/// - View recent rivals and friend activity
/// - Send challenge invitations with custom parameters
/// - Manage pending invitations (sent and received)
/// - Quick challenge random matching

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';
import '../../models/user_model_clean.dart';

class FindRivalScreen extends StatefulWidget {
  const FindRivalScreen({super.key});

  @override
  State<FindRivalScreen> createState() => _FindRivalScreenState();
}

class _FindRivalScreenState extends State<FindRivalScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final String _currentUserId = '123'; // Mock current user ID
  final String _currentUserName = 'John Doe'; // Mock current user name
  
  late TabController _tabController;
  List<Friend> _allFriends = [];
  List<Friend> _filteredFriends = [];
  List<Friend> _suggestedFriends = [];
  List<Friend> _recentRivals = [];
  List<ChallengeInvitation> _sentInvitations = [];
  List<ChallengeInvitation> _receivedInvitations = [];
  
  String _selectedSkillFilter = 'All';
  String _selectedActivityFilter = 'All';
  bool _isLoading = false;

  // Mock current user stats
  final Map<String, int> _currentUserStats = {
    'wins': 15,
    'losses': 8,
    'streak': 3,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadData() {
    setState(() {
      _isLoading = true;
    });

    // Add mock data if needed
    if (FriendService.getAllFriends(_currentUserId).isEmpty) {
      FriendService.addMockData();
    }

    // Load friends and invitations
    setState(() {
      _allFriends = FriendService.getAllFriends(_currentUserId);
      _filteredFriends = List.from(_allFriends);
      _suggestedFriends = FriendService.getSuggestedFriends(_currentUserId);
      _recentRivals = FriendService.getRecentRivals(_currentUserId);
      _sentInvitations = FriendService.getSentInvitations(_currentUserId);
      _receivedInvitations = FriendService.getReceivedInvitations(_currentUserId);
      _isLoading = false;
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    setState(() {
      if (query.isEmpty) {
        _filteredFriends = List.from(_allFriends);
      } else {
        _filteredFriends = FriendService.searchFriends(query);
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Friend> filtered = List.from(_filteredFriends);

    // Apply skill level filter
    if (_selectedSkillFilter != 'All') {
      filtered = filtered.where((friend) => 
        friend.skillLevel == _selectedSkillFilter
      ).toList();
    }

    // Apply activity filter (online status)
    if (_selectedActivityFilter == 'Online') {
      filtered = filtered.where((friend) => friend.isOnline).toList();
    }

    setState(() {
      _filteredFriends = filtered;
    });
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
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDiscoverTab(),
                  _buildFriendsTab(),
                  _buildInvitationsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Bar
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
                onPressed: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: Text(
                  'Find a Rival',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.shuffle, color: AppTheme.accentYellow),
                onPressed: _quickChallenge,
                tooltip: 'Quick Challenge',
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Subtitle
          const Center(
            child: Text(
              'Challenge friends to 1v1 fitness battles',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Current user stats
          _buildCurrentUserStats(),
        ],
      ),
    );
  }

  Widget _buildCurrentUserStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem('Wins', '${_currentUserStats['wins']}', Icons.emoji_events, Colors.green),
          _buildStatItem('Losses', '${_currentUserStats['losses']}', Icons.trending_down, Colors.red),
          _buildStatItem('Streak', '${_currentUserStats['streak']}', Icons.local_fire_department, AppTheme.accentYellow),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 20,
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

  Widget _buildTabBar() {
    return Container(
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
        tabs: [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.explore, size: 20),
                const SizedBox(width: 8),
                const Text('Discover'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.people, size: 20),
                const SizedBox(width: 8),
                Text('Friends (${_allFriends.length})'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mail, size: 20),
                const SizedBox(width: 8),
                Text('Invites (${_receivedInvitations.length})'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Challenge Button
          _buildQuickChallengeCard(),
          const SizedBox(height: 24),
          
          // Recent Rivals Section
          if (_recentRivals.isNotEmpty) ...[
            const Text(
              'Recent Rivals',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recentRivals.length,
                itemBuilder: (context, index) {
                  final friend = _recentRivals[index];
                  return _buildRecentRivalCard(friend);
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Suggested Friends Section
          const Text(
            'Suggested Rivals',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Based on your skill level and activity',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (_suggestedFriends.isEmpty)
            _buildEmptyState('No suggestions available', Icons.person_search)
          else
            ...(_suggestedFriends.map((friend) => _buildFriendCard(friend))),
        ],
      ),
    );
  }

  Widget _buildQuickChallengeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.accentYellow, Color(0xFFFFE135)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentYellow.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.shuffle,
            size: 40,
            color: Colors.black,
          ),
          const SizedBox(height: 12),
          const Text(
            'Quick Challenge',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get matched with a random rival instantly',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _quickChallenge,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: AppTheme.accentYellow,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text(
              'Find Random Rival',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentRivalCard(Friend friend) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: () => _showChallengeSetupModal(friend),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.getRankColor(friend.currentRank.name),
                child: Text(
                  friend.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                friend.displayName.split(' ').first,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                friend.lastActiveFormatted,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsTab() {
    return Column(
      children: [
        // Search and filters
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Search bar
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search by username or email...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
                  border: OutlineInputBorder(),
                ),
                style: const TextStyle(color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              // Filters
              Row(
                children: [
                  Expanded(
                    child: _buildFilterDropdown(
                      'Skill Level',
                      _selectedSkillFilter,
                      ['All', 'Newcomer', 'Beginner', 'Intermediate', 'Advanced', 'Expert'],
                      (value) {
                        setState(() {
                          _selectedSkillFilter = value!;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFilterDropdown(
                      'Activity',
                      _selectedActivityFilter,
                      ['All', 'Online', 'Recent'],
                      (value) {
                        setState(() {
                          _selectedActivityFilter = value!;
                          _applyFilters();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Friends list
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppTheme.accentYellow))
              : _filteredFriends.isEmpty
                  ? _buildEmptyState(
                      _searchController.text.isEmpty
                          ? 'No friends found'
                          : 'No friends match your search',
                      Icons.person_search,
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredFriends.length,
                      itemBuilder: (context, index) {
                        final friend = _filteredFriends[index];
                        return _buildFriendCard(friend);
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown(
    String label,
    String value,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          dropdownColor: AppTheme.surfaceColor,
          icon: const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFriendCard(Friend friend) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: InkWell(
        onTap: () => _showChallengeSetupModal(friend),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar with online status
              Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: AppTheme.getRankColor(friend.currentRank.name),
                    child: Text(
                      friend.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (friend.isOnline)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.surfaceColor, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Friend info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            friend.displayName,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.getRankColor(friend.currentRank.name).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Rank ${friend.currentRank.name}',
                            style: TextStyle(
                              color: AppTheme.getRankColor(friend.currentRank.name),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${friend.username}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildFriendStatChip(Icons.emoji_events, '${friend.wins}W'),
                        const SizedBox(width: 8),
                        _buildFriendStatChip(Icons.trending_down, '${friend.losses}L'),
                        const SizedBox(width: 8),
                        _buildFriendStatChip(Icons.local_fire_department, '${friend.currentStreak}🔥'),
                        const Spacer(),
                        Text(
                          friend.lastActiveFormatted,
                          style: TextStyle(
                            color: friend.isOnline ? Colors.green : AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: friend.isOnline ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Challenge button
              ElevatedButton(
                onPressed: () => _showChallengeSetupModal(friend),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  minimumSize: Size.zero,
                ),
                child: const Text(
                  'Challenge',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFriendStatChip(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
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

  Widget _buildInvitationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Received Invitations
          if (_receivedInvitations.isNotEmpty) ...[
            const Text(
              'Incoming Challenges',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_receivedInvitations.map((invitation) => 
              _buildInvitationCard(invitation, isReceived: true)
            )),
            const SizedBox(height: 24),
          ],
          
          // Sent Invitations
          if (_sentInvitations.isNotEmpty) ...[
            const Text(
              'Sent Challenges',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...(_sentInvitations.map((invitation) => 
              _buildInvitationCard(invitation, isReceived: false)
            )),
          ],
          
          // Empty state
          if (_receivedInvitations.isEmpty && _sentInvitations.isEmpty)
            _buildEmptyState('No pending invitations', Icons.mail_outline),
        ],
      ),
    );
  }

  Widget _buildInvitationCard(ChallengeInvitation invitation, {required bool isReceived}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReceived ? AppTheme.accentYellow.withOpacity(0.3) : AppTheme.borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  invitation.challengeTypeIcon,
                  color: AppTheme.accentYellow,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isReceived 
                          ? 'Challenge from ${invitation.senderName}'
                          : 'Challenge to ${invitation.receiverName}',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        invitation.challengeTypeDisplayName,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: invitation.isExpired 
                        ? Colors.red.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    invitation.timeRemainingFormatted,
                    style: TextStyle(
                      color: invitation.isExpired ? Colors.red : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Challenge details
            Row(
              children: [
                _buildChallengeDetailChip(Icons.schedule, invitation.durationFormatted),
                const SizedBox(width: 12),
                if (invitation.wagerAmount > 0)
                  _buildChallengeDetailChip(Icons.monetization_on, '${invitation.wagerAmount} pts'),
              ],
            ),
            
            // Personal message
            if (invitation.personalMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.darkBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  invitation.personalMessage!,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
            
            // Action buttons
            if (isReceived && !invitation.isExpired) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _declineInvitation(invitation.id),
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
                      onPressed: () => _acceptInvitation(invitation.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentYellow,
                        foregroundColor: Colors.black,
                      ),
                      child: const Text('Accept Challenge'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeDetailChip(IconData icon, String value) {
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

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppTheme.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _quickChallenge() {
    // Mock quick challenge logic
    if (_allFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No friends available for quick challenge'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final randomFriend = (_allFriends..shuffle()).first;
    _showChallengeSetupModal(randomFriend, isQuickChallenge: true);
  }

  void _showChallengeSetupModal(Friend friend, {bool isQuickChallenge = false}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => _ChallengeSetupModal(
        friend: friend,
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
        isQuickChallenge: isQuickChallenge,
        onChallengeSent: (invitation) {
          FriendService.sendChallengeInvitation(invitation);
          _loadData(); // Refresh data
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Challenge sent to ${friend.displayName}!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
    );
  }

  void _acceptInvitation(String invitationId) {
    FriendService.acceptInvitation(invitationId);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Challenge accepted! Your rival session has started.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _declineInvitation(String invitationId) {
    FriendService.declineInvitation(invitationId);
    _loadData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Challenge declined'),
        backgroundColor: Colors.orange,
      ),
    );
  }
}

/// Challenge Setup Modal for configuring challenge parameters
class _ChallengeSetupModal extends StatefulWidget {
  final Friend friend;
  final String currentUserId;
  final String currentUserName;
  final bool isQuickChallenge;
  final Function(ChallengeInvitation) onChallengeSent;

  const _ChallengeSetupModal({
    required this.friend,
    required this.currentUserId,
    required this.currentUserName,
    required this.isQuickChallenge,
    required this.onChallengeSent,
  });

  @override
  State<_ChallengeSetupModal> createState() => _ChallengeSetupModalState();
}

class _ChallengeSetupModalState extends State<_ChallengeSetupModal> {
  final TextEditingController _messageController = TextEditingController();
  
  int _selectedDuration = 7; // Default 7 days
  int _wagerAmount = 0;
  RivalChallengeType _challengeType = RivalChallengeType.general;

  final List<int> _durationOptions = [1, 3, 7, 14];
  final List<int> _wagerOptions = [0, 50, 100, 200, 500];

  @override
  void initState() {
    super.initState();
    if (widget.isQuickChallenge) {
      // Auto-fill for quick challenge
      _messageController.text = 'Ready for a quick fitness battle? Let\'s see what you\'ve got!';
      _wagerAmount = 100;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.getRankColor(widget.friend.currentRank.name),
                child: Text(
                  widget.friend.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Challenge ${widget.friend.displayName}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.isQuickChallenge ? 'Quick Challenge Setup' : 'Custom Challenge Setup',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Challenge Type
          const Text(
            'Challenge Type',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: RivalChallengeType.values.map((type) {
              final isSelected = _challengeType == type;
              return ChoiceChip(
                label: Text(type.name.split('.').last),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _challengeType = type;
                    });
                  }
                },
                selectedColor: AppTheme.accentYellow,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppTheme.darkBackground,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Duration
          const Text(
            'Duration',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _durationOptions.map((duration) {
              final isSelected = _selectedDuration == duration;
              String label;
              if (duration == 1) {
                label = '1 day';
              } else if (duration < 7) {
                label = '$duration days';
              } else if (duration == 7) {
                label = '1 week';
              } else if (duration == 14) {
                label = '2 weeks';
              } else {
                label = '$duration days';
              }

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _selectedDuration = duration;
                    });
                  }
                },
                selectedColor: AppTheme.accentYellow,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppTheme.darkBackground,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Wager
          const Text(
            'Wager (Points)',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: _wagerOptions.map((wager) {
              final isSelected = _wagerAmount == wager;
              return ChoiceChip(
                label: Text(wager == 0 ? 'No wager' : '$wager pts'),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      _wagerAmount = wager;
                    });
                  }
                },
                selectedColor: AppTheme.accentYellow,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : AppTheme.textPrimary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: AppTheme.darkBackground,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Personal Message
          const Text(
            'Personal Message (Optional)',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add a personal message or taunt...',
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 24),

          // Send Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _sendChallenge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                widget.isQuickChallenge ? 'Send Quick Challenge' : 'Send Challenge',
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

  void _sendChallenge() {
    final invitation = ChallengeInvitation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: widget.currentUserId,
      senderName: widget.currentUserName,
      receiverId: widget.friend.id,
      receiverName: widget.friend.displayName,
      challengeType: _challengeType,
      duration: _selectedDuration,
      wagerAmount: _wagerAmount,
      personalMessage: _messageController.text.trim().isEmpty 
          ? null 
          : _messageController.text.trim(),
      status: InvitationStatus.pending,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 2)), // Expires in 2 days
    );

    widget.onChallengeSent(invitation);
    Navigator.of(context).pop();
  }
}