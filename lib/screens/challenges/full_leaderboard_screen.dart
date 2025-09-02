/// Full leaderboard screen displaying complete participant rankings for challenges.
/// 
/// This screen provides comprehensive leaderboard views with filtering options,
/// search functionality, and detailed user information. It supports all
/// participants in a challenge with enhanced features like rank badges,
/// current user highlighting, and infinite scroll for large lists.

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';
import '../../models/user_model_clean.dart';

/// Filter options for leaderboard display
enum LeaderboardFilter {
  allTime,
  daily,
  weekly,
}

/// Represents a leaderboard entry with extended user information
class LeaderboardEntry {
  final String userId;
  final String userName;
  final String displayName;
  final int points;
  final int rank;
  final String? profilePictureUrl;
  final bool isActive;
  final int pointDifferenceFromAbove;
  final RankLevel userRank;
  final DateTime lastActivity;

  const LeaderboardEntry({
    required this.userId,
    required this.userName,
    required this.displayName,
    required this.points,
    required this.rank,
    this.profilePictureUrl,
    required this.isActive,
    required this.pointDifferenceFromAbove,
    required this.userRank,
    required this.lastActivity,
  });
}

/// Full leaderboard screen with comprehensive ranking display and filtering
class FullLeaderboardScreen extends StatefulWidget {
  /// The challenge for which to display the leaderboard
  final Challenge challenge;

  /// Creates a new FullLeaderboardScreen
  /// 
  /// @param challenge The challenge object containing leaderboard data
  const FullLeaderboardScreen({
    super.key,
    required this.challenge,
  });

  @override
  State<FullLeaderboardScreen> createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends State<FullLeaderboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  LeaderboardFilter _selectedFilter = LeaderboardFilter.allTime;
  List<LeaderboardEntry> _allEntries = [];
  List<LeaderboardEntry> _filteredEntries = [];
  bool _isLoading = false;
  bool _isRefreshing = false;
  String _searchQuery = '';
  
  // Mock current user ID - in real app this would come from auth service
  final String _currentUserId = '123';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadLeaderboardData();
    _setupSearchListener();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  void _setupSearchListener() {
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _filterEntries();
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads leaderboard data and creates entries with extended information
  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // In a real app, this would fetch data from Firebase/API
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      
      final sortedLeaderboard = widget.challenge.sortedLeaderboard;
      _allEntries = sortedLeaderboard.asMap().entries.map((entry) {
        final rank = entry.key + 1;
        final userId = entry.value.key;
        final points = entry.value.value;
        
        // Calculate point difference from the user above
        int pointDiff = 0;
        if (rank > 1) {
          pointDiff = sortedLeaderboard[rank - 2].value - points;
        }

        return LeaderboardEntry(
          userId: userId,
          userName: _getMockUserName(userId),
          displayName: _getMockDisplayName(userId),
          points: points,
          rank: rank,
          profilePictureUrl: null,
          isActive: _isUserActive(userId),
          pointDifferenceFromAbove: pointDiff,
          userRank: _getMockUserRank(points),
          lastActivity: _getMockLastActivity(userId),
        );
      }).toList();

      _filterEntries();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading leaderboard: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Filters entries based on search query and selected filter
  void _filterEntries() {
    _filteredEntries = _allEntries.where((entry) {
      final matchesSearch = _searchQuery.isEmpty ||
          entry.userName.toLowerCase().contains(_searchQuery) ||
          entry.displayName.toLowerCase().contains(_searchQuery);
      
      // Apply time-based filters (for now, all entries match all filters)
      // In a real app, this would filter based on actual time periods
      return matchesSearch;
    }).toList();
  }

  /// Handles pull-to-refresh functionality
  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    
    await _loadLeaderboardData();
    
    setState(() {
      _isRefreshing = false;
    });
  }

  /// Mock function to simulate user names (replace with real data service)
  String _getMockUserName(String userId) {
    if (userId == _currentUserId) return 'You';
    return 'User_$userId';
  }

  /// Mock function to simulate display names (replace with real data service)
  String _getMockDisplayName(String userId) {
    final names = ['Alex Chen', 'Jordan Smith', 'Taylor Brown', 'Casey Davis', 'Riley Wilson'];
    final index = userId.hashCode % names.length;
    return names[index];
  }

  /// Mock function to simulate user activity status
  bool _isUserActive(String userId) {
    return userId.hashCode % 3 != 0; // About 2/3 of users are active
  }

  /// Mock function to simulate user ranks
  RankLevel _getMockUserRank(int points) {
    return UserModel.getRankFromPoints(points * 10); // Scale points for rank calculation
  }

  /// Mock function to simulate last activity times
  DateTime _getMockLastActivity(String userId) {
    final hours = userId.hashCode % 48; // Last 48 hours
    return DateTime.now().subtract(Duration(hours: hours));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              _buildHeader(),
              _buildFiltersAndSearch(),
              Expanded(
                child: _buildLeaderboardContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the header section with challenge info and countdown
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderColor.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Navigation and title
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                color: AppTheme.textPrimary,
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.challenge.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.challenge.typeDisplayName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: widget.challenge.statusColor,
                      ),
                    ),
                  ],
                ),
              ),
              // Challenge status icon
              Icon(
                widget.challenge.typeIcon,
                color: widget.challenge.statusColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Challenge stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderStat(
                'Participants',
                '${widget.challenge.participantIds.length}',
                Icons.people_outline,
              ),
              _buildHeaderStat(
                'Time Left',
                widget.challenge.remainingTimeFormatted,
                Icons.timer_outlined,
              ),
              if (widget.challenge.prizePool > 0)
                _buildHeaderStat(
                  'Prize Pool',
                  '${widget.challenge.prizePool} pts',
                  Icons.emoji_events_outlined,
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual header stat items
  Widget _buildHeaderStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.accentYellow, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Builds the filters and search section
  Widget _buildFiltersAndSearch() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Filter chips
          Row(
            children: [
              _buildFilterChip(LeaderboardFilter.allTime, 'All Time'),
              const SizedBox(width: 8),
              _buildFilterChip(LeaderboardFilter.weekly, 'Weekly'),
              const SizedBox(width: 8),
              _buildFilterChip(LeaderboardFilter.daily, 'Daily'),
              const Spacer(),
              // Results count
              Text(
                '${_filteredEntries.length} results',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search participants...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            style: const TextStyle(color: AppTheme.textPrimary),
          ),
        ],
      ),
    );
  }

  /// Builds filter chip widgets
  Widget _buildFilterChip(LeaderboardFilter filter, String label) {
    final isSelected = _selectedFilter == filter;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = filter;
          _filterEntries();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentYellow : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.accentYellow : AppTheme.borderColor,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  /// Builds the main leaderboard content with pull-to-refresh
  Widget _buildLeaderboardContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.accentYellow,
        ),
      );
    }

    if (_filteredEntries.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: AppTheme.accentYellow,
      backgroundColor: AppTheme.surfaceColor,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filteredEntries.length,
        itemBuilder: (context, index) {
          final entry = _filteredEntries[index];
          final isCurrentUser = entry.userId == _currentUserId;
          
          return _buildLeaderboardEntry(entry, isCurrentUser, index);
        },
      ),
    );
  }

  /// Builds empty state when no entries match filter/search
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _searchQuery.isNotEmpty ? Icons.search_off : Icons.leaderboard_outlined,
            size: 80,
            color: AppTheme.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isNotEmpty ? 'No participants found' : 'No leaderboard data',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          if (_searchQuery.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds individual leaderboard entry with enhanced information
  Widget _buildLeaderboardEntry(LeaderboardEntry entry, bool isCurrentUser, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppTheme.accentYellow.withOpacity(0.1)
            : AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
              ? AppTheme.accentYellow.withOpacity(0.3)
              : AppTheme.borderColor.withOpacity(0.3),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: () => _viewUserProfile(entry.userId),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Rank badge
              _buildRankBadge(entry.rank),
              const SizedBox(width: 12),
              // User avatar
              _buildUserAvatar(entry),
              const SizedBox(width: 12),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            isCurrentUser ? 'You' : entry.displayName,
                            style: TextStyle(
                              color: isCurrentUser 
                                  ? AppTheme.accentYellow 
                                  : AppTheme.textPrimary,
                              fontWeight: isCurrentUser 
                                  ? FontWeight.bold 
                                  : FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        // Activity indicator
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: entry.isActive ? Colors.green : Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '@${entry.userName}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Points and difference
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.points}',
                    style: TextStyle(
                      color: isCurrentUser 
                          ? AppTheme.accentYellow 
                          : AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'points',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  if (entry.pointDifferenceFromAbove > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      '-${entry.pointDifferenceFromAbove}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds rank badge with special styling for top positions
  Widget _buildRankBadge(int rank) {
    Color badgeColor;
    Widget? badgeIcon;

    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
      badgeIcon = const Icon(Icons.emoji_events, color: Colors.black, size: 16);
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
      badgeIcon = const Icon(Icons.emoji_events, color: Colors.black, size: 16);
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
      badgeIcon = const Icon(Icons.emoji_events, color: Colors.black, size: 16);
    } else {
      badgeColor = AppTheme.textSecondary;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        boxShadow: rank <= 3 ? [
          BoxShadow(
            color: badgeColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Center(
        child: badgeIcon ?? Text(
          '$rank',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  /// Builds user avatar with fallback to initials
  Widget _buildUserAvatar(LeaderboardEntry entry) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppTheme.getRankColor(entry.userRank.name),
      backgroundImage: entry.profilePictureUrl != null 
          ? NetworkImage(entry.profilePictureUrl!)
          : null,
      child: entry.profilePictureUrl == null
          ? Text(
              entry.displayName.isNotEmpty 
                  ? entry.displayName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            )
          : null,
    );
  }

  /// Placeholder for viewing user profile
  void _viewUserProfile(String userId) {
    // TODO: Navigate to user profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('View profile for user $userId'),
        backgroundColor: AppTheme.accentYellow,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}