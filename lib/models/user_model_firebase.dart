/// User model representing a RivalX user.
/// 
/// This model contains all user-related data including profile information,
/// fitness stats, rankings, and account metadata. It serves as the primary
/// data structure for user information throughout the app.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Enumeration representing user's fitness experience level
enum FitnessLevel { beginner, intermediate, advanced }

/// Enumeration representing user's current rank in the system
enum RankLevel { E, D, C, B, A, S, SS }

/// Main user model class containing all user properties
class UserModel extends Equatable {
  /// Unique identifier for the user (Firebase UID)
  final String userId;
  
  /// User's email address
  final String email;
  
  /// Unique username for the user
  final String userName;
  
  /// Display name shown in the app
  final String displayName;
  
  /// User's current rank in the system
  final RankLevel currentRank;
  
  /// Total points accumulated by the user
  final int totalPoints;
  
  /// Points earned in the current week
  final int weeklyPoints;
  
  /// Timestamp when the user joined RivalX
  final DateTime dateJoined;
  
  /// User's height in centimeters
  final double? height;
  
  /// User's current weight in kilograms
  final double? weight;
  
  /// User's target weight in kilograms
  final double? goalWeight;
  
  /// User's fitness experience level
  final FitnessLevel? fitnessLevel;
  
  /// Total volume of weight lifted in kilograms
  final double volumeLifted;
  
  /// Total distance walked/run in kilometers
  final double distanceWalked;
  
  /// Number of penalties incurred
  final int penaltyCount;
  
  /// Current workout streak in days
  final int currentStreak;
  
  /// Longest workout streak achieved
  final int longestStreak;
  
  /// URL to user's profile picture
  final String? profilePictureUrl;
  
  /// Last time the user data was updated
  final DateTime lastUpdated;
  
  /// ID of the current rival (null if no active rival)
  final String? currentRivalId;
  
  /// Date when current rival was selected
  final DateTime? rivalSelectionDate;

  /// Creates a new UserModel instance
  const UserModel({
    required this.userId,
    required this.email,
    required this.userName,
    required this.displayName,
    required this.currentRank,
    required this.totalPoints,
    required this.weeklyPoints,
    required this.dateJoined,
    this.height,
    this.weight,
    this.goalWeight,
    this.fitnessLevel,
    required this.volumeLifted,
    required this.distanceWalked,
    required this.penaltyCount,
    required this.currentStreak,
    required this.longestStreak,
    this.profilePictureUrl,
    required this.lastUpdated,
    this.currentRivalId,
    this.rivalSelectionDate,
  });

  /// Creates an empty UserModel with default values
  /// 
  /// Used when creating a new user account
  factory UserModel.empty() {
    return UserModel(
      userId: '',
      email: '',
      userName: '',
      displayName: '',
      currentRank: RankLevel.E,
      totalPoints: 0,
      weeklyPoints: 0,
      dateJoined: DateTime.now(),
      volumeLifted: 0,
      distanceWalked: 0,
      penaltyCount: 0,
      currentStreak: 0,
      longestStreak: 0,
      lastUpdated: DateTime.now(),
    );
  }

  /// Creates a UserModel from Firestore document data
  /// 
  /// @param data Map containing Firestore document fields
  /// @return UserModel instance
  factory UserModel.fromFirestore(Map<String, dynamic> data) {
    return UserModel(
      userId: data['userId'] ?? '',
      email: data['email'] ?? '',
      userName: data['userName'] ?? '',
      displayName: data['displayName'] ?? '',
      currentRank: _parseRankLevel(data['currentRank']),
      totalPoints: data['totalPoints'] ?? 0,
      weeklyPoints: data['weeklyPoints'] ?? 0,
      dateJoined: (data['dateJoined'] as Timestamp).toDate(),
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      goalWeight: data['goalWeight']?.toDouble(),
      fitnessLevel: _parseFitnessLevel(data['fitnessLevel']),
      volumeLifted: (data['volumeLifted'] ?? 0).toDouble(),
      distanceWalked: (data['distanceWalked'] ?? 0).toDouble(),
      penaltyCount: data['penaltyCount'] ?? 0,
      currentStreak: data['currentStreak'] ?? 0,
      longestStreak: data['longestStreak'] ?? 0,
      profilePictureUrl: data['profilePictureUrl'],
      lastUpdated: (data['lastUpdated'] as Timestamp).toDate(),
      currentRivalId: data['currentRivalId'],
      rivalSelectionDate: data['rivalSelectionDate'] != null
          ? (data['rivalSelectionDate'] as Timestamp).toDate()
          : null,
    );
  }

  /// Converts UserModel to Firestore-compatible map
  /// 
  /// @return Map ready for Firestore document creation/update
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'email': email,
      'userName': userName,
      'displayName': displayName,
      'currentRank': currentRank.name,
      'totalPoints': totalPoints,
      'weeklyPoints': weeklyPoints,
      'dateJoined': Timestamp.fromDate(dateJoined),
      'height': height,
      'weight': weight,
      'goalWeight': goalWeight,
      'fitnessLevel': fitnessLevel?.name,
      'volumeLifted': volumeLifted,
      'distanceWalked': distanceWalked,
      'penaltyCount': penaltyCount,
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'profilePictureUrl': profilePictureUrl,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'currentRivalId': currentRivalId,
      'rivalSelectionDate': rivalSelectionDate != null
          ? Timestamp.fromDate(rivalSelectionDate!)
          : null,
    };
  }

  /// Creates a copy of UserModel with updated fields
  UserModel copyWith({
    String? userId,
    String? email,
    String? userName,
    String? displayName,
    RankLevel? currentRank,
    int? totalPoints,
    int? weeklyPoints,
    DateTime? dateJoined,
    double? height,
    double? weight,
    double? goalWeight,
    FitnessLevel? fitnessLevel,
    double? volumeLifted,
    double? distanceWalked,
    int? penaltyCount,
    int? currentStreak,
    int? longestStreak,
    String? profilePictureUrl,
    DateTime? lastUpdated,
    String? currentRivalId,
    DateTime? rivalSelectionDate,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      email: email ?? this.email,
      userName: userName ?? this.userName,
      displayName: displayName ?? this.displayName,
      currentRank: currentRank ?? this.currentRank,
      totalPoints: totalPoints ?? this.totalPoints,
      weeklyPoints: weeklyPoints ?? this.weeklyPoints,
      dateJoined: dateJoined ?? this.dateJoined,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goalWeight: goalWeight ?? this.goalWeight,
      fitnessLevel: fitnessLevel ?? this.fitnessLevel,
      volumeLifted: volumeLifted ?? this.volumeLifted,
      distanceWalked: distanceWalked ?? this.distanceWalked,
      penaltyCount: penaltyCount ?? this.penaltyCount,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      currentRivalId: currentRivalId ?? this.currentRivalId,
      rivalSelectionDate: rivalSelectionDate ?? this.rivalSelectionDate,
    );
  }

  /// Calculates points needed to reach next rank
  /// 
  /// @return Number of points needed for next rank
  int get pointsToNextRank {
    switch (currentRank) {
      case RankLevel.E:
        return 1000 - totalPoints; // D rank at 1000
      case RankLevel.D:
        return 3000 - totalPoints; // C rank at 3000
      case RankLevel.C:
        return 7000 - totalPoints; // B rank at 7000
      case RankLevel.B:
        return 15000 - totalPoints; // A rank at 15000
      case RankLevel.A:
        return 30000 - totalPoints; // S rank at 30000
      case RankLevel.S:
        return 60000 - totalPoints; // SS rank at 60000
      case RankLevel.SS:
        return 0; // Max rank achieved
    }
  }

  /// Determines user's rank based on total points
  /// 
  /// @param points Total points earned
  /// @return Appropriate RankLevel
  static RankLevel getRankFromPoints(int points) {
    if (points >= 60000) return RankLevel.SS;
    if (points >= 30000) return RankLevel.S;
    if (points >= 15000) return RankLevel.A;
    if (points >= 7000) return RankLevel.B;
    if (points >= 3000) return RankLevel.C;
    if (points >= 1000) return RankLevel.D;
    return RankLevel.E;
  }

  /// Parses rank level from string
  static RankLevel _parseRankLevel(String? rank) {
    switch (rank) {
      case 'D':
        return RankLevel.D;
      case 'C':
        return RankLevel.C;
      case 'B':
        return RankLevel.B;
      case 'A':
        return RankLevel.A;
      case 'S':
        return RankLevel.S;
      case 'SS':
        return RankLevel.SS;
      default:
        return RankLevel.E;
    }
  }

  /// Parses fitness level from string
  static FitnessLevel? _parseFitnessLevel(String? level) {
    switch (level) {
      case 'beginner':
        return FitnessLevel.beginner;
      case 'intermediate':
        return FitnessLevel.intermediate;
      case 'advanced':
        return FitnessLevel.advanced;
      default:
        return null;
    }
  }

  @override
  List<Object?> get props => [
        userId,
        email,
        userName,
        displayName,
        currentRank,
        totalPoints,
        weeklyPoints,
        dateJoined,
        height,
        weight,
        goalWeight,
        fitnessLevel,
        volumeLifted,
        distanceWalked,
        penaltyCount,
        currentStreak,
        longestStreak,
        profilePictureUrl,
        lastUpdated,
        currentRivalId,
        rivalSelectionDate,
      ];
}