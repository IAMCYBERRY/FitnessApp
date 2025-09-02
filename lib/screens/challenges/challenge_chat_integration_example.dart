/// Example integration showing how to navigate to Challenge Chat Screen.
/// 
/// This file demonstrates how to integrate the Challenge Chat Screen with
/// existing navigation flows in the RivalX app. It shows proper navigation
/// from various entry points including Challenge Details, direct navigation,
/// and deep linking scenarios.

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/challenge.dart';
import '../rivals/challenge_details_screen.dart';
import 'challenge_chat_screen.dart';

/// Example screen showing different ways to navigate to Challenge Chat
class ChallengeChatIntegrationExample extends StatefulWidget {
  const ChallengeChatIntegrationExample({super.key});

  @override
  State<ChallengeChatIntegrationExample> createState() => _ChallengeChatIntegrationExampleState();
}

class _ChallengeChatIntegrationExampleState extends State<ChallengeChatIntegrationExample> {
  late Challenge _sampleChallenge;

  @override
  void initState() {
    super.initState();
    _initializeSampleChallenge();
  }

  /// Initialize sample challenge data for demonstration
  void _initializeSampleChallenge() {
    _sampleChallenge = Challenge(
      id: 'sample_challenge',
      name: 'Summer Shred Challenge',
      description: 'Get ready for summer with this intense 30-day challenge! Push your limits and compete with others.',
      type: ChallengeType.public,
      status: ChallengeStatus.active,
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().add(const Duration(days: 25)),
      creatorId: 'system',
      creatorName: 'RivalX Team',
      participantIds: ['user1', 'user2', 'user3', 'user4', 'user5', '123'],
      leaderboard: {
        'user1': 2500,
        'user2': 2350,
        'user3': 2100,
        'user4': 1950,
        'user5': 1800,
        '123': 2200, // Current user
      },
      rules: [
        'Log at least 4 workouts per week',
        'Each workout must be minimum 30 minutes',
        'All activities count towards points',
        'Be respectful in chat communications',
        'No spam or inappropriate content',
      ],
      maxParticipants: 500,
      prizePool: 10000,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Challenge Chat Integration'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Navigation Examples',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Different ways to access the Challenge Chat Screen:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Navigation options
              Expanded(
                child: ListView(
                  children: [
                    // Option 1: Via Challenge Details (Recommended)
                    _buildNavigationOption(
                      icon: Icons.info_outline,
                      title: 'Via Challenge Details',
                      subtitle: 'Recommended flow through Challenge Details screen',
                      color: AppTheme.accentYellow,
                      onTap: _navigateViaDetails,
                    ),
                    const SizedBox(height: 16),

                    // Option 2: Direct Navigation
                    _buildNavigationOption(
                      icon: Icons.chat,
                      title: 'Direct to Chat',
                      subtitle: 'Skip details and go straight to chat',
                      color: Colors.blue,
                      onTap: _navigateDirectToChat,
                    ),
                    const SizedBox(height: 16),

                    // Option 3: From Push Notification
                    _buildNavigationOption(
                      icon: Icons.notifications,
                      title: 'From Notification',
                      subtitle: 'Simulate navigation from push notification',
                      color: Colors.orange,
                      onTap: _navigateFromNotification,
                    ),
                    const SizedBox(height: 16),

                    // Option 4: Deep Link Simulation
                    _buildNavigationOption(
                      icon: Icons.link,
                      title: 'Deep Link',
                      subtitle: 'Simulate deep link navigation',
                      color: Colors.purple,
                      onTap: _navigateFromDeepLink,
                    ),
                    const SizedBox(height: 32),

                    // Challenge Info Card
                    _buildChallengeInfoCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a navigation option card
  Widget _buildNavigationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppTheme.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds challenge information card
  Widget _buildChallengeInfoCard() {
    return Card(
      color: AppTheme.surfaceColor,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _sampleChallenge.typeIcon,
                  color: _sampleChallenge.statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _sampleChallenge.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _sampleChallenge.description,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildInfoChip(
                  '${_sampleChallenge.participantIds.length} participants',
                  Icons.people,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  _sampleChallenge.remainingTimeFormatted,
                  Icons.timer,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds small info chips
  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.darkBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigate via Challenge Details screen (recommended flow)
  void _navigateViaDetails() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeDetailsScreen(
          challenge: _sampleChallenge,
        ),
      ),
    );
  }

  /// Navigate directly to chat screen
  void _navigateDirectToChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeChatScreen(
          challenge: _sampleChallenge,
        ),
      ),
    );
  }

  /// Simulate navigation from push notification
  void _navigateFromNotification() {
    // In a real app, this would handle the notification payload
    // and extract challenge ID to load the appropriate challenge
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Push Notification',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: Text(
          'New message in ${_sampleChallenge.name}:\n"Great workout today! 💪"',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateDirectToChat();
            },
            child: const Text('Open Chat'),
          ),
        ],
      ),
    );
  }

  /// Simulate deep link navigation
  void _navigateFromDeepLink() {
    // In a real app, this would parse the deep link URL
    // Format: rivalx://challenge/{challengeId}/chat
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text(
          'Deep Link Navigation',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          'Simulating navigation from deep link:\nrivalx://challenge/sample_challenge/chat',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In real implementation, you would:
              // 1. Parse the URL to extract challenge ID
              // 2. Load challenge data from backend
              // 3. Navigate to appropriate screen
              _navigateDirectToChat();
            },
            child: const Text('Open'),
          ),
        ],
      ),
    );
  }
}

/// Integration Helper Methods
/// 
/// These methods demonstrate how to integrate the chat screen
/// in different scenarios throughout the app.
class ChallengeChatIntegration {
  
  /// Navigate to chat from any screen with challenge data
  /// 
  /// @param context The build context
  /// @param challenge The challenge to open chat for
  static void openChat(BuildContext context, Challenge challenge) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ChallengeChatScreen(
          challenge: challenge,
        ),
      ),
    );
  }

  /// Navigate to chat with slide transition
  /// 
  /// @param context The build context
  /// @param challenge The challenge to open chat for
  static void openChatWithSlideTransition(BuildContext context, Challenge challenge) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          ChallengeChatScreen(challenge: challenge),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  /// Open chat from notification with loading state
  /// 
  /// @param context The build context
  /// @param challengeId The challenge ID from notification
  static Future<void> openChatFromNotification(
    BuildContext context, 
    String challengeId,
  ) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        content: Row(
          children: [
            CircularProgressIndicator(color: AppTheme.accentYellow),
            SizedBox(width: 16),
            Text(
              'Loading challenge...',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );

    try {
      // In real app, load challenge data from backend
      await Future.delayed(const Duration(seconds: 1)); // Simulate network call
      
      // For demo, use mock challenge
      final challenge = Challenge(
        id: challengeId,
        name: 'Challenge from Notification',
        description: 'Loaded from notification',
        type: ChallengeType.public,
        status: ChallengeStatus.active,
        startDate: DateTime.now().subtract(const Duration(days: 1)),
        endDate: DateTime.now().add(const Duration(days: 7)),
        creatorId: 'system',
        creatorName: 'System',
        participantIds: ['123'],
        leaderboard: {'123': 100},
        rules: ['Be respectful', 'Have fun'],
      );

      // Dismiss loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Navigate to chat
        openChat(context, challenge);
      }
    } catch (e) {
      // Handle error
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load challenge: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }
}