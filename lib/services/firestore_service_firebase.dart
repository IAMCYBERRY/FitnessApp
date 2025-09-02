/// Firestore service for RivalX app.
/// 
/// This service handles all Firestore database operations including
/// user data management, workout storage, challenges, and leaderboards.
/// It provides a centralized interface for all database interactions.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rivalx/models/user_model.dart';

/// Service class for handling Firestore database operations
class FirestoreService {
  /// Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  final String _usersCollection = 'users';
  final String _workoutsCollection = 'workouts';
  final String _challengesCollection = 'challenges';
  final String _leaderboardCollection = 'leaderboard';
  final String _rivalMatchesCollection = 'rival_matches';
  final String _dailyChallengesCollection = 'daily_challenges';

  /// Creates or updates a user document in Firestore
  /// 
  /// @param user UserModel to save
  /// @throws Exception if the operation fails
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.userId)
          .set(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to create user: ${e.toString()}');
    }
  }

  /// Updates a user document in Firestore
  /// 
  /// @param user UserModel with updated data
  /// @throws Exception if the operation fails
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.userId)
          .update(user.toFirestore());
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  /// Updates specific user fields
  /// 
  /// @param userId User ID to update
  /// @param data Map of fields to update
  /// @throws Exception if the operation fails
  Future<void> updateUserFields(String userId, Map<String, dynamic> data) async {
    try {
      data['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(data);
    } catch (e) {
      throw Exception('Failed to update user fields: ${e.toString()}');
    }
  }

  /// Retrieves a user document from Firestore
  /// 
  /// @param userId User ID to retrieve
  /// @return UserModel if found, null otherwise
  /// @throws Exception if the operation fails
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  /// Checks if a username is already taken
  /// 
  /// @param userName Username to check
  /// @return true if username exists, false otherwise
  /// @throws Exception if the operation fails
  Future<bool> isUserNameTaken(String userName) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('userName', isEqualTo: userName)
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Failed to check username: ${e.toString()}');
    }
  }

  /// Gets a stream of user data for real-time updates
  /// 
  /// @param userId User ID to watch
  /// @return Stream of UserModel updates
  Stream<UserModel?> getUserStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserModel.fromFirestore(doc.data()!);
      }
      return null;
    });
  }

  /// Deletes a user document from Firestore
  /// 
  /// @param userId User ID to delete
  /// @throws Exception if the operation fails
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: ${e.toString()}');
    }
  }

  /// Updates user's total points and rank
  /// 
  /// @param userId User ID to update
  /// @param pointsToAdd Points to add to current total
  /// @throws Exception if the operation fails
  Future<void> updateUserPoints(String userId, int pointsToAdd) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final userDoc = await transaction.get(
          _firestore.collection(_usersCollection).doc(userId),
        );

        if (!userDoc.exists) {
          throw Exception('User not found');
        }

        final userData = userDoc.data()!;
        final currentPoints = userData['totalPoints'] ?? 0;
        final newTotalPoints = currentPoints + pointsToAdd;
        final newRank = UserModel.getRankFromPoints(newTotalPoints);

        transaction.update(userDoc.reference, {
          'totalPoints': newTotalPoints,
          'currentRank': newRank.name,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      });
    } catch (e) {
      throw Exception('Failed to update user points: ${e.toString()}');
    }
  }

  /// Updates user's weekly points
  /// 
  /// @param userId User ID to update
  /// @param pointsToAdd Points to add to weekly total
  /// @throws Exception if the operation fails
  Future<void> updateWeeklyPoints(String userId, int pointsToAdd) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'weeklyPoints': FieldValue.increment(pointsToAdd),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update weekly points: ${e.toString()}');
    }
  }

  /// Updates user's workout streak
  /// 
  /// @param userId User ID to update
  /// @param newStreak New streak value
  /// @throws Exception if the operation fails
  Future<void> updateWorkoutStreak(String userId, int newStreak) async {
    try {
      final user = await getUser(userId);
      if (user == null) throw Exception('User not found');

      final updateData = {
        'currentStreak': newStreak,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      // Update longest streak if necessary
      if (newStreak > user.longestStreak) {
        updateData['longestStreak'] = newStreak;
      }

      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update(updateData);
    } catch (e) {
      throw Exception('Failed to update workout streak: ${e.toString()}');
    }
  }

  /// Updates user's volume lifted
  /// 
  /// @param userId User ID to update
  /// @param volumeToAdd Volume in kg to add
  /// @throws Exception if the operation fails
  Future<void> updateVolumeLifted(String userId, double volumeToAdd) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'volumeLifted': FieldValue.increment(volumeToAdd),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update volume lifted: ${e.toString()}');
    }
  }

  /// Updates user's distance walked
  /// 
  /// @param userId User ID to update
  /// @param distanceToAdd Distance in km to add
  /// @throws Exception if the operation fails
  Future<void> updateDistanceWalked(String userId, double distanceToAdd) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'distanceWalked': FieldValue.increment(distanceToAdd),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update distance walked: ${e.toString()}');
    }
  }

  /// Adds a penalty to user's record
  /// 
  /// @param userId User ID to update
  /// @throws Exception if the operation fails
  Future<void> addPenalty(String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'penaltyCount': FieldValue.increment(1),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add penalty: ${e.toString()}');
    }
  }

  /// Sets user's current rival
  /// 
  /// @param userId User ID
  /// @param rivalId Rival's user ID
  /// @throws Exception if the operation fails
  Future<void> setCurrentRival(String userId, String rivalId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'currentRivalId': rivalId,
        'rivalSelectionDate': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to set current rival: ${e.toString()}');
    }
  }

  /// Removes user's current rival
  /// 
  /// @param userId User ID
  /// @throws Exception if the operation fails
  Future<void> removeCurrentRival(String userId) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .update({
        'currentRivalId': null,
        'rivalSelectionDate': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove current rival: ${e.toString()}');
    }
  }

  /// Searches for users by username (for finding friends/rivals)
  /// 
  /// @param searchTerm Username search term
  /// @param limit Maximum number of results
  /// @return List of matching users
  /// @throws Exception if the operation fails
  Future<List<UserModel>> searchUsers(String searchTerm, {int limit = 10}) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('userName', isGreaterThanOrEqualTo: searchTerm)
          .where('userName', isLessThan: '${searchTerm}z')
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => UserModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }

  /// Gets top users for leaderboard
  /// 
  /// @param limit Number of top users to retrieve
  /// @param orderBy Field to order by ('totalPoints', 'weeklyPoints', etc.)
  /// @return List of top users
  /// @throws Exception if the operation fails
  Future<List<UserModel>> getTopUsers({
    int limit = 50,
    String orderBy = 'totalPoints',
  }) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .orderBy(orderBy, descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => UserModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get top users: ${e.toString()}');
    }
  }

  /// Gets users by rank level
  /// 
  /// @param rank Rank level to filter by
  /// @param limit Maximum number of results
  /// @return List of users with specified rank
  /// @throws Exception if the operation fails
  Future<List<UserModel>> getUsersByRank(
    RankLevel rank, {
    int limit = 50,
  }) async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('currentRank', isEqualTo: rank.name)
          .orderBy('totalPoints', descending: true)
          .limit(limit)
          .get();

      return query.docs
          .map((doc) => UserModel.fromFirestore(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users by rank: ${e.toString()}');
    }
  }

  /// Gets user's position in global leaderboard
  /// 
  /// @param userId User ID
  /// @return Position (1-based) or null if not found
  /// @throws Exception if the operation fails
  Future<int?> getUserLeaderboardPosition(String userId) async {
    try {
      final user = await getUser(userId);
      if (user == null) return null;

      final query = await _firestore
          .collection(_usersCollection)
          .where('totalPoints', isGreaterThan: user.totalPoints)
          .get();

      return query.size + 1; // 1-based position
    } catch (e) {
      throw Exception('Failed to get user leaderboard position: ${e.toString()}');
    }
  }

  /// Resets weekly points for all users (called weekly by Cloud Function)
  /// 
  /// @throws Exception if the operation fails
  Future<void> resetWeeklyPointsForAllUsers() async {
    try {
      final query = await _firestore
          .collection(_usersCollection)
          .where('weeklyPoints', isGreaterThan: 0)
          .get();

      final batch = _firestore.batch();
      for (final doc in query.docs) {
        batch.update(doc.reference, {
          'weeklyPoints': 0,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to reset weekly points: ${e.toString()}');
    }
  }

  /// Gets collection reference for users
  /// 
  /// @return CollectionReference for users collection
  CollectionReference get usersCollection =>
      _firestore.collection(_usersCollection);

  /// Gets collection reference for workouts
  /// 
  /// @return CollectionReference for workouts collection
  CollectionReference get workoutsCollection =>
      _firestore.collection(_workoutsCollection);

  /// Gets collection reference for challenges
  /// 
  /// @return CollectionReference for challenges collection
  CollectionReference get challengesCollection =>
      _firestore.collection(_challengesCollection);

  /// Gets collection reference for leaderboard
  /// 
  /// @return CollectionReference for leaderboard collection
  CollectionReference get leaderboardCollection =>
      _firestore.collection(_leaderboardCollection);

  /// Gets collection reference for rival matches
  /// 
  /// @return CollectionReference for rival matches collection
  CollectionReference get rivalMatchesCollection =>
      _firestore.collection(_rivalMatchesCollection);

  /// Gets collection reference for daily challenges
  /// 
  /// @return CollectionReference for daily challenges collection
  CollectionReference get dailyChallengesCollection =>
      _firestore.collection(_dailyChallengesCollection);
}