/// Firestore service for managing all database operations.
/// 
/// This service provides a centralized interface for all Firestore
/// operations including users, workouts, challenges, and leaderboards.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model_clean.dart';
import '../models/challenge.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  /// Users collection reference
  CollectionReference<Map<String, dynamic>> get usersCollection =>
      _db.collection('users');

  /// Create or update user profile
  Future<void> createOrUpdateUser(UserModel user) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await usersCollection.doc(user.userId).set({
      'userId': user.userId,
      'userName': user.userName,
      'email': user.email,
      'displayName': user.displayName,
      'totalPoints': user.totalPoints,
      'weeklyPoints': user.weeklyPoints,
      'currentRank': user.currentRank.name,
      'currentStreak': user.currentStreak,
      'longestStreak': user.longestStreak,
      'volumeLifted': user.volumeLifted,
      'distanceWalked': user.distanceWalked,
      'penaltyCount': user.penaltyCount,
      'fitnessLevel': user.fitnessLevel?.name,
      'dateJoined': user.dateJoined.millisecondsSinceEpoch,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return UserModel(
        userId: data['userId'],
        userName: data['userName'],
        email: data['email'],
        displayName: data['displayName'],
        totalPoints: data['totalPoints'] ?? 0,
        weeklyPoints: data['weeklyPoints'] ?? 0,
        currentRank: RankLevel.values.firstWhere(
          (rank) => rank.name == data['currentRank'],
          orElse: () => RankLevel.E,
        ),
        currentStreak: data['currentStreak'] ?? 0,
        longestStreak: data['longestStreak'] ?? 0,
        volumeLifted: data['volumeLifted']?.toDouble() ?? 0.0,
        distanceWalked: data['distanceWalked']?.toDouble() ?? 0.0,
        penaltyCount: data['penaltyCount'] ?? 0,
        fitnessLevel: data['fitnessLevel'] != null
            ? FitnessLevel.values.firstWhere(
                (level) => level.name == data['fitnessLevel'],
                orElse: () => FitnessLevel.beginner,
              )
            : null,
        dateJoined: DateTime.fromMillisecondsSinceEpoch(data['dateJoined']),
        lastUpdated: data['lastUpdated'] != null
            ? (data['lastUpdated'] as Timestamp).toDate()
            : DateTime.now(),
      );
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Stream user data
  Stream<UserModel?> streamUser(String userId) {
    return usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      return UserModel(
        userId: data['userId'],
        userName: data['userName'],
        email: data['email'],
        displayName: data['displayName'],
        totalPoints: data['totalPoints'] ?? 0,
        weeklyPoints: data['weeklyPoints'] ?? 0,
        currentRank: RankLevel.values.firstWhere(
          (rank) => rank.name == data['currentRank'],
          orElse: () => RankLevel.E,
        ),
        currentStreak: data['currentStreak'] ?? 0,
        longestStreak: data['longestStreak'] ?? 0,
        volumeLifted: data['volumeLifted']?.toDouble() ?? 0.0,
        distanceWalked: data['distanceWalked']?.toDouble() ?? 0.0,
        penaltyCount: data['penaltyCount'] ?? 0,
        fitnessLevel: data['fitnessLevel'] != null
            ? FitnessLevel.values.firstWhere(
                (level) => level.name == data['fitnessLevel'],
                orElse: () => FitnessLevel.beginner,
              )
            : null,
        dateJoined: DateTime.fromMillisecondsSinceEpoch(data['dateJoined']),
        lastUpdated: data['lastUpdated'] != null
            ? (data['lastUpdated'] as Timestamp).toDate()
            : DateTime.now(),
      );
    });
  }

  /// Search users by username or email
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    
    try {
      // Search by username
      final userNameQuery = await usersCollection
          .where('userName', isGreaterThanOrEqualTo: query)
          .where('userName', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();
      
      // Search by email
      final emailQuery = await usersCollection
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + '\uf8ff')
          .limit(10)
          .get();
      
      final Map<String, QueryDocumentSnapshot> uniqueDocs = {};
      
      for (var doc in userNameQuery.docs) {
        uniqueDocs[doc.id] = doc;
      }
      for (var doc in emailQuery.docs) {
        uniqueDocs[doc.id] = doc;
      }
      
      return uniqueDocs.values.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserModel(
          userId: data['userId'],
          userName: data['userName'],
          email: data['email'],
          displayName: data['displayName'],
          totalPoints: data['totalPoints'] ?? 0,
          weeklyPoints: data['weeklyPoints'] ?? 0,
          currentRank: RankLevel.values.firstWhere(
            (rank) => rank.name == data['currentRank'],
            orElse: () => RankLevel.E,
          ),
          currentStreak: data['currentStreak'] ?? 0,
          longestStreak: data['longestStreak'] ?? 0,
          volumeLifted: data['volumeLifted']?.toDouble() ?? 0.0,
          distanceWalked: data['distanceWalked']?.toDouble() ?? 0.0,
          penaltyCount: data['penaltyCount'] ?? 0,
          fitnessLevel: data['fitnessLevel'] != null
              ? FitnessLevel.values.firstWhere(
                  (level) => level.name == data['fitnessLevel'],
                  orElse: () => FitnessLevel.beginner,
                )
              : null,
          dateJoined: DateTime.fromMillisecondsSinceEpoch(data['dateJoined']),
          lastUpdated: data['lastUpdated'] != null
              ? (data['lastUpdated'] as Timestamp).toDate()
              : DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  /// Create a new challenge
  Future<String> createChallenge(Challenge challenge) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    final docRef = _db.collection('challenges').doc();
    await docRef.set({
      'id': docRef.id,
      'name': challenge.name,
      'description': challenge.description,
      'createdBy': currentUserId,
      'participants': [currentUserId],
      'isPublic': challenge.isPublic,
      'startDate': challenge.startDate.millisecondsSinceEpoch,
      'endDate': challenge.endDate.millisecondsSinceEpoch,
      'type': challenge.type.name,
      'targetValue': challenge.targetValue,
      'targetUnit': challenge.targetUnit,
      'prizePool': challenge.prizePool,
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    return docRef.id;
  }

  /// Join a challenge
  Future<void> joinChallenge(String challengeId) async {
    if (currentUserId == null) throw Exception('User not authenticated');
    
    await _db.collection('challenges').doc(challengeId).update({
      'participants': FieldValue.arrayUnion([currentUserId]),
    });
  }

  /// Get leaderboard data
  Future<List<UserModel>> getLeaderboard({
    required String period,
    int limit = 10,
  }) async {
    Query<Map<String, dynamic>> query = usersCollection;
    
    switch (period) {
      case 'daily':
        // This would normally filter by today's points
        // For now, we'll just order by weekly points
        query = query.orderBy('weeklyPoints', descending: true);
        break;
      case 'weekly':
        query = query.orderBy('weeklyPoints', descending: true);
        break;
      case 'monthly':
      case 'allTime':
        query = query.orderBy('totalPoints', descending: true);
        break;
    }
    
    final snapshot = await query.limit(limit).get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return UserModel(
        userId: data['userId'],
        userName: data['userName'],
        email: data['email'],
        displayName: data['displayName'],
        totalPoints: data['totalPoints'] ?? 0,
        weeklyPoints: data['weeklyPoints'] ?? 0,
        currentRank: RankLevel.values.firstWhere(
          (rank) => rank.name == data['currentRank'],
          orElse: () => RankLevel.E,
        ),
        currentStreak: data['currentStreak'] ?? 0,
        longestStreak: data['longestStreak'] ?? 0,
        volumeLifted: data['volumeLifted']?.toDouble() ?? 0.0,
        distanceWalked: data['distanceWalked']?.toDouble() ?? 0.0,
        penaltyCount: data['penaltyCount'] ?? 0,
        fitnessLevel: data['fitnessLevel'] != null
            ? FitnessLevel.values.firstWhere(
                (level) => level.name == data['fitnessLevel'],
                orElse: () => FitnessLevel.beginner,
              )
            : null,
        dateJoined: DateTime.fromMillisecondsSinceEpoch(data['dateJoined']),
        lastUpdated: data['lastUpdated'] != null
            ? (data['lastUpdated'] as Timestamp).toDate()
            : DateTime.now(),
      );
    }).toList();
  }

  /// Update user points
  Future<void> updateUserPoints({
    required String userId,
    required int pointsToAdd,
    required String reason,
  }) async {
    final userRef = usersCollection.doc(userId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) {
        throw Exception('User does not exist');
      }
      
      final currentTotal = snapshot.data()!['totalPoints'] ?? 0;
      final currentWeekly = snapshot.data()!['weeklyPoints'] ?? 0;
      
      transaction.update(userRef, {
        'totalPoints': currentTotal + pointsToAdd,
        'weeklyPoints': currentWeekly + pointsToAdd,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      // Add to points history
      final historyRef = userRef.collection('pointsHistory').doc();
      transaction.set(historyRef, {
        'points': pointsToAdd,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  /// Reset weekly points (called by Cloud Function weekly)
  Future<void> resetWeeklyPoints() async {
    // This would typically be done by a Cloud Function
    // For testing, we can call it manually
    final batch = _db.batch();
    final snapshot = await usersCollection.get();
    
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'weeklyPoints': 0});
    }
    
    await batch.commit();
  }
}