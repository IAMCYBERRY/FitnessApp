/// Authentication service for RivalX app.
/// 
/// This service handles all authentication-related operations including
/// sign up, sign in, sign out, password reset, and biometric authentication.
/// It integrates with Firebase Authentication and manages user sessions.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:local_auth/local_auth.dart';
import 'package:rivalx/models/user_model.dart';
import 'package:rivalx/services/firestore_service.dart';

/// Service class for handling authentication operations
class AuthService {
  /// Firebase Authentication instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  
  /// Firestore service for user data operations
  final FirestoreService _firestoreService = FirestoreService();
  
  /// Local authentication instance for biometrics
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Stream of authentication state changes
  /// 
  /// Emits the current user when auth state changes (sign in/out)
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Gets the currently signed-in user
  /// 
  /// @return Current Firebase User or null if not signed in
  User? get currentUser => _firebaseAuth.currentUser;

  /// Creates a new user account with email and password
  /// 
  /// @param email User's email address
  /// @param password User's password
  /// @param userName Unique username
  /// @param displayName User's display name
  /// @param height Optional height in cm
  /// @param weight Optional weight in kg
  /// @param goalWeight Optional goal weight in kg
  /// @param fitnessLevel Optional fitness level
  /// @return UserModel of the created user
  /// @throws FirebaseAuthException if signup fails
  Future<UserModel> signUpWithEmailPassword({
    required String email,
    required String password,
    required String userName,
    required String displayName,
    double? height,
    double? weight,
    double? goalWeight,
    FitnessLevel? fitnessLevel,
  }) async {
    try {
      // Check if username is already taken
      final isUsernameTaken = await _firestoreService.isUserNameTaken(userName);
      if (isUsernameTaken) {
        throw FirebaseAuthException(
          code: 'username-already-exists',
          message: 'This username is already taken',
        );
      }

      // Create Firebase Auth user
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name in Firebase Auth
      await credential.user!.updateDisplayName(displayName);

      // Create user model
      final newUser = UserModel(
        userId: credential.user!.uid,
        email: email,
        userName: userName,
        displayName: displayName,
        currentRank: RankLevel.E,
        totalPoints: 0,
        weeklyPoints: 0,
        dateJoined: DateTime.now(),
        height: height,
        weight: weight,
        goalWeight: goalWeight,
        fitnessLevel: fitnessLevel,
        volumeLifted: 0,
        distanceWalked: 0,
        penaltyCount: 0,
        currentStreak: 0,
        longestStreak: 0,
        lastUpdated: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestoreService.createUser(newUser);

      return newUser;
    } on FirebaseAuthException catch (e) {
      // Re-throw with more user-friendly messages
      throw _handleAuthException(e);
    }
  }

  /// Signs in user with email and password
  /// 
  /// @param email User's email address
  /// @param password User's password
  /// @return UserModel of the signed-in user
  /// @throws FirebaseAuthException if sign in fails
  Future<UserModel> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Fetch user data from Firestore
      final user = await _firestoreService.getUser(credential.user!.uid);
      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'User data not found',
        );
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Signs in user with biometric authentication
  /// 
  /// Requires user to be previously signed in with biometrics enabled
  /// @return UserModel of the signed-in user
  /// @throws Exception if biometric auth fails
  Future<UserModel> signInWithBiometrics() async {
    try {
      // Check if biometrics are available
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!isAvailable || !isDeviceSupported) {
        throw Exception('Biometric authentication not available');
      }

      // Get available biometric types
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        throw Exception('No biometric methods enrolled');
      }

      // Authenticate with biometrics
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Sign in to RivalX',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!isAuthenticated) {
        throw Exception('Biometric authentication failed');
      }

      // Get stored credentials and sign in
      // Note: In production, store encrypted credentials securely
      // This is a simplified example
      final currentUser = _firebaseAuth.currentUser;
      if (currentUser == null) {
        throw Exception('No user session found');
      }

      // Fetch user data
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      return UserModel.fromFirestore(userDoc.data()!);
    } catch (e) {
      throw Exception('Biometric authentication failed: ${e.toString()}');
    }
  }

  /// Signs out the current user
  /// 
  /// @throws Exception if sign out fails
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  /// Sends password reset email
  /// 
  /// @param email Email address to send reset link to
  /// @throws FirebaseAuthException if email sending fails
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Updates user's email address
  /// 
  /// @param newEmail New email address
  /// @param password Current password for reauthentication
  /// @throws FirebaseAuthException if update fails
  Future<void> updateEmail({
    required String newEmail,
    required String password,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Update email
      await user.updateEmail(newEmail);

      // Update email in Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'email': newEmail,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Updates user's password
  /// 
  /// @param currentPassword Current password for reauthentication
  /// @param newPassword New password
  /// @throws FirebaseAuthException if update fails
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Deletes user account
  /// 
  /// @param password Current password for reauthentication
  /// @throws FirebaseAuthException if deletion fails
  Future<void> deleteAccount(String password) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('No user signed in');

      // Reauthenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // Delete user data from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  /// Checks if biometric authentication is available
  /// 
  /// @return true if biometrics are available and enrolled
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      
      if (!isAvailable || !isDeviceSupported) {
        return false;
      }

      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Gets available biometric types on the device
  /// 
  /// @return List of available biometric authentication types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Handles Firebase Auth exceptions with user-friendly messages
  /// 
  /// @param e FirebaseAuthException to handle
  /// @return FirebaseAuthException with improved message
  FirebaseAuthException _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'The password is too weak. Please use at least 6 characters.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists with this email address.';
        break;
      case 'invalid-email':
        message = 'Please enter a valid email address.';
        break;
      case 'user-not-found':
        message = 'No account found with this email address.';
        break;
      case 'wrong-password':
        message = 'Incorrect password. Please try again.';
        break;
      case 'user-disabled':
        message = 'This account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many failed attempts. Please try again later.';
        break;
      case 'network-request-failed':
        message = 'Network error. Please check your connection.';
        break;
      case 'username-already-exists':
        message = 'This username is already taken. Please choose another.';
        break;
      default:
        message = e.message ?? 'An error occurred. Please try again.';
    }
    
    return FirebaseAuthException(code: e.code, message: message);
  }
}