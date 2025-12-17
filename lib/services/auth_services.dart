import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

// 🔐 AUTHENTICATION SERVICE
// Handles all authentication operations: login, signup, logout, password reset
// Includes Google Sign-In integration
// This is a singleton class (only one instance exists throughout the app)

// Web OAuth Client ID from Google Cloud Console
// To enable Google Sign-In on web:
// 1. Go to Google Cloud Console > APIs & Services > Credentials
// 2. Create OAuth 2.0 Client ID (Web application type)
// 3. Add authorized JavaScript origins (localhost for dev, your domain for prod)
// 4. Replace this placeholder with your actual client ID
// TODO: Replace with your Web Client ID from Google Cloud Console
const String? _webClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

class AuthService {
  // Firebase Authentication instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Firestore instance for storing user data
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In instance - only initialized for mobile platforms
  // On web, we'll create it lazily only if clientId is configured
  GoogleSignIn? _googleSignIn;
  
  GoogleSignIn get googleSignIn {
    _googleSignIn ??= GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: kIsWeb ? _webClientId : null,
    );
    return _googleSignIn!;
  }

  // Singleton pattern - ensures only one instance exists
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  // ==================== CURRENT USER ====================

  /// Get currently logged in Firebase user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state changes
  /// Use this to listen for login/logout events
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ==================== SIGN UP ====================

  /// Create new account with email and password
  /// Returns UserModel on success, throws error on failure
  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Create user in Firebase Authentication
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Get the created user
      final User? user = credential.user;

      if (user == null) {
        throw Exception('Failed to create user');
      }

      // Update display name
      await user.updateDisplayName(name);

      // Create UserModel instance
      final UserModel userModel = UserModel(
        uid: user.uid,
        name: name.trim(),
        email: email.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(userModel.toJson());

      return userModel;
    } on FirebaseAuthException catch (e) {
      // Handle Firebase-specific errors with user-friendly messages
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  // ==================== SIGN IN ====================

  /// Login with email and password
  /// Returns UserModel on success, throws error on failure
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in to Firebase
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('Login failed');
      }

      // Fetch user data from Firestore
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        throw Exception('User data not found');
      }

      // Convert Firestore document to UserModel
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  // ==================== SIGN OUT ====================

  /// Logout current user
  Future<void> signOut() async {
    try {
      // Sign out from Google if signed in with Google
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: ${e.toString()}');
    }
  }

  // ==================== GOOGLE SIGN IN ====================

  /// Sign in with Google
  /// Returns UserModel on success, throws error on failure
  Future<UserModel> signInWithGoogle() async {
    try {
      // Check if Google Sign-In is available on web
      if (kIsWeb && _webClientId == null) {
        throw Exception(
          'Google Sign-In is not configured for web. '
          'Please use email/password login, or configure a Web OAuth Client ID.'
        );
      }

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        throw Exception('Google sign-in was cancelled');
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      // Create a new credential
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Check if user document exists in Firestore
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();

      UserModel userModel;

      if (doc.exists) {
        // Existing user - fetch their data
        userModel = UserModel.fromJson(doc.data() as Map<String, dynamic>);
        
        // Update last login time
        final now = DateTime.now();
        userModel = userModel.copyWith(updatedAt: now);
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({'updatedAt': now.toIso8601String()});
      } else {
        // New user - create their profile
        userModel = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          profilePicture: user.photoURL,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toJson());
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      if (e.toString().contains('cancelled')) {
        throw Exception('Google sign-in was cancelled');
      }
      throw Exception('Google sign-in failed: ${e.toString()}');
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedInWithGoogle() async {
    return await googleSignIn.isSignedIn();
  }

  // ==================== PASSWORD RESET ====================

  /// Send password reset email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }

  // ==================== GET USER DATA ====================

  /// Fetch user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        return null;
      }

      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  // ==================== UPDATE USER DATA ====================

  /// Update user data in Firestore
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  // ==================== DELETE ACCOUNT ====================

  /// Delete user account (both Auth and Firestore data)
  Future<void> deleteAccount() async {
    try {
      final User? user = currentUser;
      if (user == null) {
        throw Exception('No user logged in');
      }

      // Delete Firestore data first
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete authentication account
      await user.delete();
    } catch (e) {
      throw Exception('Failed to delete account: ${e.toString()}');
    }
  }

  // ==================== ERROR HANDLING ====================

  /// Convert Firebase error codes to user-friendly messages
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered. Please login instead.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'Authentication error: ${e.message ?? 'Unknown error'}';
    }
  }

  // ==================== VALIDATION HELPERS ====================

  /// Validate email format
  static bool isEmailValid(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  /// Validate password strength
  /// Returns null if valid, error message if invalid
  static String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!password.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!password.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    return null; // Password is valid
  }

  /// Validate name
  static String? validateName(String name) {
    if (name.trim().isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      return 'Name can only contain letters and spaces';
    }
    return null; // Name is valid
  }
}