import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_services.dart';
import '../services/firestore_service.dart';

// 🔄 AUTH PROVIDER
// Manages authentication state throughout the app
// Uses ChangeNotifier for state management

class AuthProvider extends ChangeNotifier {
  // Services
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  // Current user model
  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  // Firebase user
  User? get firebaseUser => _authService.currentUser;

  // Loading state
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Error message
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Is user logged in?
  bool get isLoggedIn => firebaseUser != null;

  // Constructor
  AuthProvider() {
    _init();
  }

  // ==================== INITIALIZATION ====================

  /// Initialize provider and listen to auth state changes
  void _init() {
    // Listen to Firebase auth state changes
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        // User is logged in - fetch their data
        await _loadUserData(user.uid);
      } else {
        // User is logged out - clear data
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String uid) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userData = await _firestoreService.getUserData(uid);
      _currentUser = userData;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Error loading user data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== AUTHENTICATION METHODS ====================

  /// Sign up with email and password
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      _currentUser = user;

      // Initialize default categories for new user
      await _firestoreService.initializeDefaultCategories(user.uid);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Signup error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      _currentUser = user;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Login error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _authService.signOut();
      _currentUser = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Logout error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send password reset email
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Password reset error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserModel updatedUser) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateUserData(updatedUser);
      _currentUser = updatedUser;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Update profile error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      if (firebaseUser != null) {
        // Delete all user data from Firestore
        await _firestoreService.deleteAllUserData(firebaseUser!.uid);

        // Delete authentication account
        await _authService.deleteAccount();

        _currentUser = null;
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Delete account error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Refresh user data
  Future<void> refreshUserData() async {
    if (firebaseUser != null) {
      await _loadUserData(firebaseUser!.uid);
    }
  }
}