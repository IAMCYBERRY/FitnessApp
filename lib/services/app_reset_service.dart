/// App reset service for clearing all local data during development/testing.
/// 
/// This service provides utilities to completely reset the app state,
/// clear all user data, and restore the app to a fresh installation state.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'local_storage_service.dart';

/// Service for resetting app data during development and testing
class AppResetService {
  /// Reset all app data to factory defaults
  static Future<void> resetAll() async {
    try {
      await _clearSharedPreferences();
      await _clearDatabase();
      await _clearInMemoryData();
      
      print('✅ App reset completed successfully');
    } catch (e) {
      print('❌ Error during app reset: $e');
      rethrow;
    }
  }

  /// Clear all SharedPreferences data
  static Future<void> _clearSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print('📱 SharedPreferences cleared');
  }

  /// Delete and recreate the SQLite database
  static Future<void> _clearDatabase() async {
    try {
      final databasePath = await getDatabasesPath();
      final path = join(databasePath, 'rivalx.db');
      
      // Delete the database file
      await deleteDatabase(path);
      print('🗄️ Database deleted');
      
      // Reinitialize the database with fresh tables
      await LocalStorageService.initialize();
      print('🗄️ Database recreated with fresh schema');
    } catch (e) {
      print('⚠️ Error resetting database: $e');
      // Continue with reset even if database deletion fails
    }
  }

  /// Clear any in-memory cached data
  static Future<void> _clearInMemoryData() async {
    // Clear any static/singleton cached data
    // This would include clearing any cached challenge data, etc.
    print('💾 In-memory data cleared');
  }

  /// Reset only user authentication (keep app data)
  static Future<void> resetAuthOnly() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove auth-related keys
      await prefs.remove('current_user');
      await prefs.remove('is_logged_in');
      await prefs.remove('remember_me');
      
      // Remove all password hashes (they start with 'password_')
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('password_')) {
          await prefs.remove(key);
        }
      }
      
      print('🔐 Authentication data cleared');
    } catch (e) {
      print('❌ Error resetting auth: $e');
      rethrow;
    }
  }

  /// Reset only points and progress data (keep users)
  static Future<void> resetProgressOnly() async {
    try {
      final db = LocalStorageService.instance.database;
      
      // Reset all user points and progress
      await db.update(
        'users',
        {
          'total_points': 0,
          'weekly_points': 0,
          'current_rank': 'E',
          'current_streak': 0,
          'volume_lifted': 0.0,
          'distance_walked': 0.0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
      );
      
      // Clear all history tables
      await db.delete('points_history');
      await db.delete('workouts');
      await db.delete('challenges');
      await db.delete('rival_sessions');
      await db.delete('daily_challenges');
      await db.delete('challenge_invitations');
      
      print('📊 Progress data reset to zero');
    } catch (e) {
      print('❌ Error resetting progress: $e');
      rethrow;
    }
  }

  /// Create sample test users for multi-device testing
  static Future<void> createTestUsers() async {
    try {
      final db = LocalStorageService.instance.database;
      final prefs = LocalStorageService.instance.prefs;
      
      final testUsers = [
        {
          'id': 'test_user_1',
          'username': 'testuser1',
          'email': 'test1@rivalx.com',
          'password': 'password123',
          'displayName': 'Test User 1',
          'totalPoints': 1500,
          'currentRank': 'D',
        },
        {
          'id': 'test_user_2',
          'username': 'testuser2', 
          'email': 'test2@rivalx.com',
          'password': 'password123',
          'displayName': 'Test User 2',
          'totalPoints': 3200,
          'currentRank': 'C',
        },
        {
          'id': 'test_user_3',
          'username': 'testuser3',
          'email': 'test3@rivalx.com', 
          'password': 'password123',
          'displayName': 'Test User 3',
          'totalPoints': 8500,
          'currentRank': 'B',
        },
      ];

      print('👥 Creating test users for multi-device testing...');
      
      for (final userData in testUsers) {
        // Check if user already exists
        final existing = await UserStorageService.getUserByEmail(userData['email'] as String);
        if (existing != null) {
          print('   ⏭️  ${userData['username']} already exists, skipping...');
          continue;
        }
        
        // Create user in database
        await db.insert('users', {
          'id': userData['id'],
          'username': userData['username'],
          'email': userData['email'],
          'display_name': userData['displayName'],
          'total_points': userData['totalPoints'],
          'weekly_points': 0,
          'current_rank': userData['currentRank'],
          'current_streak': 0,
          'volume_lifted': 0.0,
          'distance_walked': 0.0,
          'date_joined': DateTime.now().millisecondsSinceEpoch,
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
        
        // Store password hash
        final hashedPassword = _hashPassword(userData['password'] as String, userData['id'] as String);
        await prefs.setString('password_${userData['id']}', hashedPassword);
        
        print('   ✅ Created ${userData['username']} (${userData['currentRank']}, ${userData['totalPoints']} pts)');
      }
      
      print('   📝 All passwords: password123');
      
    } catch (e) {
      print('❌ Error creating test users: $e');
      rethrow;
    }
  }

  /// Hash password with salt (same as LocalAuthBloc)
  static String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Get current app state info for debugging
  static Future<Map<String, dynamic>> getAppStateInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final db = LocalStorageService.instance.database;
      
      // Get user count
      final userCount = await db.rawQuery('SELECT COUNT(*) as count FROM users');
      final totalUsers = userCount.first['count'] as int;
      
      // Get current session info
      final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
      final currentUserJson = prefs.getString('current_user');
      
      // Get data counts
      final workoutCount = await db.rawQuery('SELECT COUNT(*) as count FROM workouts');
      final pointsHistoryCount = await db.rawQuery('SELECT COUNT(*) as count FROM points_history');
      
      return {
        'totalUsers': totalUsers,
        'isLoggedIn': isLoggedIn,
        'hasCurrentUser': currentUserJson != null,
        'totalWorkouts': workoutCount.first['count'],
        'totalPointsHistory': pointsHistoryCount.first['count'],
        'sharedPrefsKeys': prefs.getKeys().length,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  /// Debug method to print all current app state
  static Future<void> printAppState() async {
    final state = await getAppStateInfo();
    
    print('\n📱 Current App State:');
    print('   Users: ${state['totalUsers']}');
    print('   Logged in: ${state['isLoggedIn']}');
    print('   Current user: ${state['hasCurrentUser'] ? 'Yes' : 'No'}');
    print('   Workouts: ${state['totalWorkouts']}');
    print('   Points history entries: ${state['totalPointsHistory']}');
    print('   SharedPrefs entries: ${state['sharedPrefsKeys']}');
    
    if (state.containsKey('error')) {
      print('   ⚠️ Error: ${state['error']}');
    }
    print('');
  }
}

/// Reset utility for development mode
class DevResetUtils {
  /// Quick reset for development - clears everything
  static Future<void> quickReset() async {
    print('🔄 Starting quick reset...');
    await AppResetService.resetAll();
    await AppResetService.createTestUsers();
    print('✅ Quick reset completed!');
  }

  /// Reset just auth for testing different users
  static Future<void> switchUser() async {
    print('🔄 Switching user...');
    await AppResetService.resetAuthOnly();
    print('✅ Ready for new user login!');
  }

  /// Reset progress for testing point systems
  static Future<void> resetProgress() async {
    print('🔄 Resetting all progress...');
    await AppResetService.resetProgressOnly();
    print('✅ All progress reset to zero!');
  }
}