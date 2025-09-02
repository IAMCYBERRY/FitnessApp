/// Local storage service for RivalX app data persistence.
/// 
/// This service handles all local data storage using SharedPreferences
/// and SQLite for complex data structures. Replaces in-memory mock services
/// with persistent storage for offline functionality.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user_model_clean.dart';
import '../models/challenge.dart';
// import '../models/workout.dart'; // TODO: Create workout model
import '../services/points_service.dart';
import '../blocs/points/points_state.dart';

/// Main local storage service managing all app data
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;
  static Database? _database;

  LocalStorageService._();

  /// Singleton instance
  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  /// Initialize storage services
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _database = await _initDatabase();
  }

  /// Initialize SQLite database
  static Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'rivalx.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Users table
        await db.execute('''
          CREATE TABLE users (
            id TEXT PRIMARY KEY,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            display_name TEXT NOT NULL,
            total_points INTEGER DEFAULT 0,
            weekly_points INTEGER DEFAULT 0,
            current_rank TEXT DEFAULT 'E',
            current_streak INTEGER DEFAULT 0,
            volume_lifted REAL DEFAULT 0,
            distance_walked REAL DEFAULT 0,
            fitness_level TEXT,
            date_joined INTEGER NOT NULL,
            last_workout INTEGER,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Workouts table
        await db.execute('''
          CREATE TABLE workouts (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            name TEXT NOT NULL,
            duration INTEGER NOT NULL,
            exercises TEXT NOT NULL,
            points_earned INTEGER DEFAULT 0,
            completed_at INTEGER NOT NULL,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');

        // Challenges table
        await db.execute('''
          CREATE TABLE challenges (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            type TEXT NOT NULL,
            status TEXT NOT NULL,
            start_date INTEGER NOT NULL,
            end_date INTEGER NOT NULL,
            creator_id TEXT NOT NULL,
            creator_name TEXT NOT NULL,
            participant_ids TEXT NOT NULL,
            leaderboard TEXT NOT NULL,
            max_participants INTEGER DEFAULT 100,
            image_url TEXT,
            rules TEXT NOT NULL,
            entry_fee INTEGER DEFAULT 0,
            prize_pool INTEGER DEFAULT 0,
            invite_status TEXT DEFAULT '{}',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Rival sessions table
        await db.execute('''
          CREATE TABLE rival_sessions (
            id TEXT PRIMARY KEY,
            user_id_1 TEXT NOT NULL,
            user_id_2 TEXT NOT NULL,
            user_1_name TEXT NOT NULL,
            user_2_name TEXT NOT NULL,
            user_1_avatar TEXT,
            user_2_avatar TEXT,
            start_date INTEGER NOT NULL,
            end_date INTEGER NOT NULL,
            user_1_points INTEGER DEFAULT 0,
            user_2_points INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            winner_id TEXT,
            wager_amount INTEGER DEFAULT 0,
            activities TEXT DEFAULT '{}',
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');

        // Friends table
        await db.execute('''
          CREATE TABLE friends (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            friend_id TEXT NOT NULL,
            friend_username TEXT NOT NULL,
            friend_display_name TEXT NOT NULL,
            friend_email TEXT NOT NULL,
            friend_avatar_url TEXT,
            friend_rank TEXT NOT NULL,
            friend_total_points INTEGER DEFAULT 0,
            friend_weekly_points INTEGER DEFAULT 0,
            friend_fitness_level TEXT,
            is_online INTEGER DEFAULT 0,
            last_active INTEGER NOT NULL,
            wins INTEGER DEFAULT 0,
            losses INTEGER DEFAULT 0,
            current_streak INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');

        // Points history table
        await db.execute('''
          CREATE TABLE points_history (
            id TEXT PRIMARY KEY,
            user_id TEXT NOT NULL,
            points INTEGER NOT NULL,
            activity TEXT NOT NULL,
            description TEXT NOT NULL,
            timestamp INTEGER NOT NULL,
            icon TEXT NOT NULL,
            is_bonus INTEGER DEFAULT 0,
            created_at INTEGER NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');

        // Daily challenges table
        await db.execute('''
          CREATE TABLE daily_challenges (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            instruction TEXT NOT NULL,
            date INTEGER NOT NULL,
            target_value INTEGER NOT NULL,
            unit TEXT NOT NULL,
            icon TEXT NOT NULL,
            base_points INTEGER DEFAULT 100,
            is_completed INTEGER DEFAULT 0,
            completed_value INTEGER,
            completed_at INTEGER,
            created_at INTEGER NOT NULL
          )
        ''');

        // Challenge invitations table
        await db.execute('''
          CREATE TABLE challenge_invitations (
            id TEXT PRIMARY KEY,
            sender_id TEXT NOT NULL,
            sender_name TEXT NOT NULL,
            receiver_id TEXT NOT NULL,
            receiver_name TEXT NOT NULL,
            challenge_type TEXT NOT NULL,
            duration INTEGER NOT NULL,
            wager_amount INTEGER DEFAULT 0,
            personal_message TEXT,
            status TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            responded_at INTEGER,
            expires_at INTEGER
          )
        ''');
      },
    );
  }

  /// Get SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('LocalStorageService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  /// Get Database instance
  Database get database {
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }
}

/// Authentication storage service
class AuthStorageService {
  static const String _currentUserKey = 'current_user';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _rememberMeKey = 'remember_me';

  /// Save current user session
  static Future<void> saveUserSession(UserModel user, {bool rememberMe = false}) async {
    final prefs = LocalStorageService.instance.prefs;
    
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setBool(_rememberMeKey, rememberMe);
  }

  /// Get current user session
  static Future<UserModel?> getCurrentUser() async {
    final prefs = LocalStorageService.instance.prefs;
    
    if (!(prefs.getBool(_isLoggedInKey) ?? false)) {
      return null;
    }

    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null) return null;

    try {
      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Update current user in storage
  static Future<void> updateCurrentUser(UserModel user) async {
    final prefs = LocalStorageService.instance.prefs;
    await prefs.setString(_currentUserKey, jsonEncode(user.toJson()));
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = LocalStorageService.instance.prefs;
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// Log out user
  static Future<void> logout() async {
    final prefs = LocalStorageService.instance.prefs;
    
    await prefs.remove(_currentUserKey);
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_rememberMeKey);
  }

  /// Check if remember me is enabled
  static Future<bool> shouldRememberUser() async {
    final prefs = LocalStorageService.instance.prefs;
    return prefs.getBool(_rememberMeKey) ?? false;
  }
}

/// User data storage service
class UserStorageService {
  /// Save user to database
  static Future<void> saveUser(UserModel user) async {
    final db = LocalStorageService.instance.database;
    
    await db.insert(
      'users',
      {
        'id': user.userId,
        'username': user.userName,
        'email': user.email,
        'display_name': user.displayName,
        'total_points': user.totalPoints,
        'weekly_points': user.weeklyPoints,
        'current_rank': user.currentRank.name,
        'current_streak': user.currentStreak,
        'volume_lifted': user.volumeLifted,
        'distance_walked': user.distanceWalked,
        'fitness_level': user.fitnessLevel?.name,
        'date_joined': user.dateJoined.millisecondsSinceEpoch,
        // 'last_workout': user.lastWorkout?.millisecondsSinceEpoch, // TODO: Add lastWorkout field
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get user by ID
  static Future<UserModel?> getUser(String userId) async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;

    final userData = maps.first;
    return UserModel(
      userId: userData['id'],
      userName: userData['username'],
      email: userData['email'],
      displayName: userData['display_name'],
      totalPoints: userData['total_points'],
      weeklyPoints: userData['weekly_points'],
      currentRank: RankLevel.values.firstWhere(
        (rank) => rank.name == userData['current_rank'],
        orElse: () => RankLevel.E,
      ),
      currentStreak: userData['current_streak'],
      longestStreak: userData['longest_streak'] ?? 0,
      volumeLifted: userData['volume_lifted'],
      distanceWalked: userData['distance_walked'],
      penaltyCount: userData['penalty_count'] ?? 0,
      fitnessLevel: userData['fitness_level'] != null
          ? FitnessLevel.values.firstWhere(
              (level) => level.name == userData['fitness_level'],
              orElse: () => FitnessLevel.beginner,
            )
          : null,
      dateJoined: DateTime.fromMillisecondsSinceEpoch(userData['date_joined']),
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(userData['last_updated'] ?? DateTime.now().millisecondsSinceEpoch),
      // lastWorkout: userData['last_workout'] != null // TODO: Add lastWorkout field
      //     ? DateTime.fromMillisecondsSinceEpoch(userData['last_workout'])
      //     : null,
    );
  }

  /// Update user
  static Future<void> updateUser(UserModel user) async {
    final db = LocalStorageService.instance.database;
    
    await db.update(
      'users',
      {
        'username': user.userName,
        'email': user.email,
        'display_name': user.displayName,
        'total_points': user.totalPoints,
        'weekly_points': user.weeklyPoints,
        'current_rank': user.currentRank.name,
        'current_streak': user.currentStreak,
        'volume_lifted': user.volumeLifted,
        'distance_walked': user.distanceWalked,
        'fitness_level': user.fitnessLevel?.name,
        // 'last_workout': user.lastWorkout?.millisecondsSinceEpoch, // TODO: Add lastWorkout field
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [user.userId],
    );

    // Update session if this is the current user
    final currentUser = await AuthStorageService.getCurrentUser();
    if (currentUser?.userId == user.userId) {
      await AuthStorageService.updateCurrentUser(user);
    }
  }

  /// Get user by username
  static Future<UserModel?> getUserByUsername(String username) async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );

    if (maps.isEmpty) return null;
    return getUser(maps.first['id']);
  }

  /// Get user by email
  static Future<UserModel?> getUserByEmail(String email) async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (maps.isEmpty) return null;
    return getUser(maps.first['id']);
  }

  /// Check if username exists
  static Future<bool> usernameExists(String username) async {
    final user = await getUserByUsername(username);
    return user != null;
  }

  /// Check if email exists
  static Future<bool> emailExists(String email) async {
    final user = await getUserByEmail(email);
    return user != null;
  }

  /// Get all users (for development/testing)
  static Future<List<UserModel>> getAllUsers() async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query('users');
    
    return Future.wait(maps.map((userData) async {
      return UserModel(
        userId: userData['id'],
        userName: userData['username'],
        email: userData['email'],
        displayName: userData['display_name'],
        totalPoints: userData['total_points'],
        weeklyPoints: userData['weekly_points'],
        currentRank: RankLevel.values.firstWhere(
          (rank) => rank.name == userData['current_rank'],
          orElse: () => RankLevel.E,
        ),
        currentStreak: userData['current_streak'],
        longestStreak: userData['longest_streak'] ?? 0,
        volumeLifted: userData['volume_lifted'],
        distanceWalked: userData['distance_walked'],
        penaltyCount: userData['penalty_count'] ?? 0,
        fitnessLevel: userData['fitness_level'] != null
            ? FitnessLevel.values.firstWhere(
                (level) => level.name == userData['fitness_level'],
                orElse: () => FitnessLevel.beginner,
              )
            : null,
        dateJoined: DateTime.fromMillisecondsSinceEpoch(userData['date_joined']),
        lastUpdated: DateTime.fromMillisecondsSinceEpoch(userData['last_updated'] ?? DateTime.now().millisecondsSinceEpoch),
        // lastWorkout: userData['last_workout'] != null // TODO: Add lastWorkout field
        //     ? DateTime.fromMillisecondsSinceEpoch(userData['last_workout'])
        //     : null,
      );
    }));
  }
}

/// Points history storage service
class PointsHistoryService {
  /// Save points history entry
  static Future<void> savePointsEntry(String userId, PointHistoryEntry entry) async {
    final db = LocalStorageService.instance.database;
    
    await db.insert(
      'points_history',
      {
        'id': entry.id,
        'user_id': userId,
        'points': entry.points,
        'activity': entry.activity,
        'description': entry.description,
        'timestamp': entry.timestamp.millisecondsSinceEpoch,
        'icon': entry.icon,
        'is_bonus': entry.isBonus ? 1 : 0,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get recent points history for user
  static Future<List<PointHistoryEntry>> getRecentHistory(String userId, {int limit = 10}) async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'points_history',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'timestamp DESC',
      limit: limit,
    );

    return maps.map((data) => PointHistoryEntry(
      id: data['id'],
      points: data['points'],
      activity: data['activity'],
      description: data['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      icon: data['icon'],
      isBonus: data['is_bonus'] == 1,
    )).toList();
  }

  /// Get points history for date range
  static Future<List<PointHistoryEntry>> getHistoryForDateRange(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'points_history',
      where: 'user_id = ? AND timestamp >= ? AND timestamp <= ?',
      whereArgs: [
        userId,
        startDate.millisecondsSinceEpoch,
        endDate.millisecondsSinceEpoch,
      ],
      orderBy: 'timestamp DESC',
    );

    return maps.map((data) => PointHistoryEntry(
      id: data['id'],
      points: data['points'],
      activity: data['activity'],
      description: data['description'],
      timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      icon: data['icon'],
      isBonus: data['is_bonus'] == 1,
    )).toList();
  }

  /// Clear old history entries (keep last 100)
  static Future<void> cleanupOldHistory(String userId) async {
    final db = LocalStorageService.instance.database;
    
    // Get count of entries
    final countResult = await db.rawQuery(
      'SELECT COUNT(*) as count FROM points_history WHERE user_id = ?',
      [userId],
    );
    
    final count = countResult.first['count'] as int;
    
    if (count > 100) {
      // Delete oldest entries beyond 100
      await db.rawDelete('''
        DELETE FROM points_history 
        WHERE user_id = ? 
        AND id NOT IN (
          SELECT id FROM points_history 
          WHERE user_id = ? 
          ORDER BY timestamp DESC 
          LIMIT 100
        )
      ''', [userId, userId]);
    }
  }
}

/* TODO: Implement workout storage when workout model is created
/// Workout storage service
class WorkoutStorageService {
  /// Save completed workout
  static Future<void> saveWorkout(CompletedWorkout workout) async {
    final db = LocalStorageService.instance.database;
    
    await db.insert(
      'workouts',
      {
        'id': workout.id,
        'user_id': workout.userId,
        'name': workout.name,
        'duration': workout.duration.inMinutes,
        'exercises': jsonEncode(workout.exercises.map((e) => e.toJson()).toList()),
        'points_earned': workout.pointsEarned ?? 0,
        'completed_at': workout.completedAt.millisecondsSinceEpoch,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get workouts for user
  static Future<List<CompletedWorkout>> getUserWorkouts(String userId, {int limit = 50}) async {
    final db = LocalStorageService.instance.database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'workouts',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'completed_at DESC',
      limit: limit,
    );

    return maps.map((data) {
      final exercisesJson = jsonDecode(data['exercises']) as List;
      final exercises = exercisesJson.map((e) => CompletedExercise.fromJson(e)).toList();
      
      return CompletedWorkout(
        id: data['id'],
        userId: data['user_id'],
        name: data['name'],
        duration: Duration(minutes: data['duration']),
        exercises: exercises,
        completedAt: DateTime.fromMillisecondsSinceEpoch(data['completed_at']),
        pointsEarned: data['points_earned'],
      );
    }).toList();
  }

  /// Get workout statistics for user
  static Future<Map<String, dynamic>> getWorkoutStats(String userId) async {
    final db = LocalStorageService.instance.database;
    
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_workouts,
        SUM(duration) as total_minutes,
        AVG(duration) as avg_duration,
        SUM(points_earned) as total_points
      FROM workouts 
      WHERE user_id = ?
    ''', [userId]);

    if (result.isEmpty) {
      return {
        'total_workouts': 0,
        'total_minutes': 0,
        'avg_duration': 0.0,
        'total_points': 0,
      };
    }

    return result.first;
  }
}
*/

/// Initialize all storage services
Future<void> initializeLocalStorage() async {
  await LocalStorageService.initialize();
}