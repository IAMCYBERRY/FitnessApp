/// Debug screen for development and testing utilities.
/// 
/// This screen provides various debugging tools, reset options,
/// and testing utilities for development purposes only.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/theme.dart';
import '../../services/app_reset_service.dart';
import '../../blocs/auth/local_auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';

/// Debug screen for development tools
class DebugScreen extends StatefulWidget {
  const DebugScreen({super.key});

  @override
  State<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  Map<String, dynamic>? _appState;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAppState();
  }

  Future<void> _loadAppState() async {
    final state = await AppResetService.getAppStateInfo();
    setState(() {
      _appState = state;
    });
  }

  Future<void> _performAction(String action, Future<void> Function() operation) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await operation();
      
      // Reload app state
      await _loadAppState();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$action completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      appBar: AppBar(
        title: const Text('Debug Tools'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.textPrimary,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.accentYellow),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App State Info
                  _buildAppStateCard(),
                  const SizedBox(height: 16),
                  
                  // Reset Options
                  _buildResetOptionsCard(),
                  const SizedBox(height: 16),
                  
                  // Test Users
                  _buildTestUsersCard(),
                  const SizedBox(height: 16),
                  
                  // Network Testing Info
                  _buildNetworkTestingCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildAppStateCard() {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info, color: AppTheme.accentYellow),
                const SizedBox(width: 8),
                Text(
                  'App State',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: AppTheme.textSecondary),
                  onPressed: _loadAppState,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_appState != null) ...[
              _buildStateItem('Total Users', '${_appState!['totalUsers']}'),
              _buildStateItem('Logged In', '${_appState!['isLoggedIn']}'),
              _buildStateItem('Current User', _appState!['hasCurrentUser'] ? 'Yes' : 'No'),
              _buildStateItem('Total Workouts', '${_appState!['totalWorkouts']}'),
              _buildStateItem('Points History', '${_appState!['totalPointsHistory']}'),
              _buildStateItem('Storage Entries', '${_appState!['sharedPrefsKeys']}'),
            ] else
              const Text(
                'Loading app state...',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStateItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResetOptionsCard() {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.refresh, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Reset Options',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildActionButton(
              'Reset Everything',
              'Clear all data and start fresh',
              Colors.red,
              Icons.delete_forever,
              () => _performAction('Full reset', AppResetService.resetAll),
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              'Logout Current User',
              'Clear authentication only',
              Colors.orange,
              Icons.logout,
              () => _performAction('Auth reset', () async {
                await AppResetService.resetAuthOnly();
                if (mounted) {
                  context.read<LocalAuthBloc>().add(const AuthCheckSession());
                }
              }),
            ),
            
            const SizedBox(height: 12),
            
            _buildActionButton(
              'Reset Progress Only',
              'Keep users, clear points and workouts',
              Colors.amber,
              Icons.trending_down,
              () => _performAction('Progress reset', AppResetService.resetProgressOnly),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestUsersCard() {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Test Users',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Pre-configured test accounts:',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            
            _buildTestUserItem('testuser1', 'test1@rivalx.com', 'Rank D, 1500 pts'),
            _buildTestUserItem('testuser2', 'test2@rivalx.com', 'Rank C, 3200 pts'),
            _buildTestUserItem('testuser3', 'test3@rivalx.com', 'Rank B, 8500 pts'),
            
            const SizedBox(height: 12),
            
            const Text(
              'All passwords: password123',
              style: TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            _buildActionButton(
              'Create Test Users',
              'Add pre-configured test accounts',
              Colors.blue,
              Icons.person_add,
              () => _performAction('Test users creation', AppResetService.createTestUsers),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestUserItem(String username, String email, String stats) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.person, size: 16, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$username ($email)',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  stats,
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
  }

  Widget _buildNetworkTestingCard() {
    return Card(
      color: AppTheme.surfaceColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.network_check, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Multi-Device Testing',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Current Status: Local Storage Only',
              style: TextStyle(
                color: AppTheme.accentYellow,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            const Text(
              '• Each device has independent local storage\n'
              '• Users cannot compete across devices yet\n'
              '• Challenge invites work within single device only\n'
              '• Real-time features require network implementation',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'For Network Communication:',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Implement Firebase Firestore\n'
                    '• Add real-time subscriptions\n'
                    '• Set up push notifications\n'
                    '• Configure user discovery system',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.2),
          foregroundColor: color,
          elevation: 0,
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: color.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: color.withOpacity(0.8),
                      fontSize: 12,
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
}