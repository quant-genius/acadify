
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import '../enums/user_roles.dart';

/// Service for handling authentication operations
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;
  
  /// Constructor for AuthService
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required SharedPreferences? prefs,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _prefs = prefs;
  
  /// Returns the current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Returns true if a user is currently signed in
  bool get isUserSignedIn => _auth.currentUser != null;
  
  /// Streams authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Signs in a user with email and password
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update user's last login time
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
        
        // Store user ID in shared preferences
        await _prefs?.setString('user_id', result.user!.uid);
      }
      
      return result.user;
    } catch (e) {
      debugPrint('Sign in error: $e');
      rethrow;
    }
  }
  
  /// Creates a new user account with email and password
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  /// [firstName] - The user's first name
  /// [lastName] - The user's last name
  /// [studentId] - The user's student ID
  /// [role] - The user's role
  Future<User?> createUserWithEmailAndPassword(
    String email,
    String password,
    String firstName,
    String lastName,
    String studentId,
    UserRole role,
  ) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      if (result.user != null) {
        final now = FieldValue.serverTimestamp();
        
        await _firestore.collection('users').doc(result.user!.uid).set({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'studentId': studentId,
          'role': role.name,
          'isActive': true,
          'createdAt': now,
          'updatedAt': now,
          'lastLoginAt': now,
        });
        
        // Store user ID in shared preferences
        await _prefs?.setString('user_id', result.user!.uid);
      }
      
      return result.user;
    } catch (e) {
      debugPrint('Create user error: $e');
      rethrow;
    }
  }
  
  /// Sends a password reset email to the specified email address
  ///
  /// [email] - The email address to send the password reset to
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Password reset error: $e');
      rethrow;
    }
  }
  
  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Clear user ID from shared preferences
      await _prefs?.remove('user_id');
    } catch (e) {
      debugPrint('Sign out error: $e');
      rethrow;
    }
  }
  
  /// Updates the user's profile information
  ///
  /// [userId] - The ID of the user to update
  /// [firstName] - The user's first name
  /// [lastName] - The user's last name
  /// [phoneNumber] - The user's phone number
  /// [photoUrl] - The URL to the user's profile photo
  /// [faculty] - The user's faculty
  /// [department] - The user's department
  /// [bio] - The user's bio
  Future<void> updateUserProfile({
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
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (firstName != null) updates['firstName'] = firstName;
      if (lastName != null) updates['lastName'] = lastName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (faculty != null) updates['faculty'] = faculty;
      if (department != null) updates['department'] = department;
      if (bio != null) updates['bio'] = bio;
      
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      debugPrint('Update user profile error: $e');
      rethrow;
    }
  }
  
  /// Deletes the current user's account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        // Update user document to mark as inactive
        await _firestore.collection('users').doc(user.uid).update({
          'isActive': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Delete the user account
        await user.delete();
        
        // Clear user ID from shared preferences
        await _prefs?.remove('user_id');
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      debugPrint('Delete account error: $e');
      rethrow;
    }
  }
  
  /// Gets the current user's role
  Future<UserRole> getCurrentUserRole() async {
    try {
      final user = _auth.currentUser;
      
      if (user != null) {
        final userDoc = await _firestore.collection('users').doc(user.uid).get();
        
        if (userDoc.exists && userDoc.data() != null) {
          final roleString = userDoc.data()!['role'] as String;
          return UserRole.fromString(roleString);
        } else {
          throw Exception('User document not found');
        }
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      debugPrint('Get current user role error: $e');
      rethrow;
    }
  }
}
