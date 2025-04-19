
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/enums/user_roles.dart';
import '../models/user_model.dart';
import '../../domain/entities/user_entity.dart';

/// Repository for authentication operations
class AuthRepository {
  final AuthService _authService;
  final FirebaseFirestore _firestore;
  final SharedPreferences _prefs;
  
  /// Constructor that takes AuthService and SharedPreferences
  AuthRepository({
    required AuthService authService,
    required SharedPreferences prefs,
    FirebaseFirestore? firestore,
  }) : _authService = authService,
       _prefs = prefs,
       _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Gets the current user ID
  String? get currentUserId => _authService.currentUserId;
  
  /// Returns true if a user is currently signed in
  bool get isUserSignedIn => _authService.isUserSignedIn;
  
  /// Streams authentication state changes
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  
  /// Signs in a user with email and password
  ///
  /// Returns the UserEntity if successful, throws an exception otherwise
  Future<UserEntity> signInWithEmailAndPassword(String email, String password) async {
    try {
      final user = await _authService.signInWithEmailAndPassword(email, password);
      
      if (user != null) {
        return await getUserProfile(user.uid);
      } else {
        throw Exception('Sign in failed');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Creates a new user account with email and password
  ///
  /// Returns the UserEntity if successful, throws an exception otherwise
  Future<UserEntity> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String firstName, 
    String lastName, 
    String studentId, 
    UserRole role,
  ) async {
    try {
      final user = await _authService.createUserWithEmailAndPassword(
        email, 
        password, 
        firstName, 
        lastName, 
        studentId, 
        role,
      );
      
      if (user != null) {
        return await getUserProfile(user.uid);
      } else {
        throw Exception('Sign up failed');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sends a password reset email to the specified email address
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets the user profile for the specified user ID
  Future<UserEntity> getUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User profile not found');
      }
      
      return UserModel.fromFirestore(userDoc.data()!, userId);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets the current user's profile
  Future<UserEntity> getCurrentUserProfile() async {
    final userId = currentUserId;
    
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    
    return await getUserProfile(userId);
  }
  
  /// Gets the current user entity
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        return null;
      }
      return await getUserProfile(userId);
    } catch (e) {
      return null;
    }
  }
  
  /// Streams the current user's profile
  Stream<UserEntity> streamUserProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return UserModel.fromFirestore(snapshot.data()!, snapshot.id);
          } else {
            throw Exception('User profile not found');
          }
        });
  }
  
  /// Updates the user's profile information
  Future<UserEntity> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    String? faculty,
    String? department,
    String? bio,
  }) async {
    try {
      await _authService.updateUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        faculty: faculty,
        department: department,
        bio: bio,
      );
      
      return await getUserProfile(userId);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes the current user's account
  Future<void> deleteAccount() async {
    try {
      await _authService.deleteAccount();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets the current user's role
  Future<UserRole> getCurrentUserRole() async {
    try {
      return await _authService.getCurrentUserRole();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Verifies if the user has the specified role
  Future<bool> hasRole(UserRole role) async {
    try {
      final userRole = await getCurrentUserRole();
      return userRole == role;
    } catch (e) {
      return false;
    }
  }
  
  /// Verifies if the user can moderate content
  Future<bool> canModerate() async {
    try {
      final userRole = await getCurrentUserRole();
      return userRole.canModerate;
    } catch (e) {
      return false;
    }
  }
  
  /// Verifies if the user can create announcements
  Future<bool> canCreateAnnouncements() async {
    try {
      final userRole = await getCurrentUserRole();
      return userRole.canCreateAnnouncements;
    } catch (e) {
      return false;
    }
  }
  
  /// Verifies if the user can manage courses
  Future<bool> canManageCourses() async {
    try {
      final userRole = await getCurrentUserRole();
      return userRole.canManageCourses;
    } catch (e) {
      return false;
    }
  }
}
