
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/user_roles.dart';

/// Service for authentication operations
class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final SharedPreferences? _prefs;
  
  /// Constructor that takes SharedPreferences
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    required SharedPreferences? prefs,
  })  : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _prefs = prefs;
  
  /// Gets the current user ID
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Returns true if a user is currently signed in
  bool get isUserSignedIn => _auth.currentUser != null;
  
  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Signs in a user with email and password
  Future<User?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update last login time
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Creates a new user with email and password
  Future<User?> createUserWithEmailAndPassword(
    String email, 
    String password, 
    String firstName, 
    String lastName, 
    String studentId, 
    UserRole role,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Create user profile in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'studentId': studentId,
          'role': role.toString().split('.').last,
          'isActive': true,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastLoginAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential.user;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Sends a password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates the user's profile information
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
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      if (faculty != null) updateData['faculty'] = faculty;
      if (department != null) updateData['department'] = department;
      if (bio != null) updateData['bio'] = bio;
      
      await _firestore.collection('users').doc(userId).update(updateData);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes the current user's account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await _firestore.collection('users').doc(user.uid).delete();
        
        // Delete the user account
        await user.delete();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets the current user's role from Firestore
  Future<UserRole> getCurrentUserRole() async {
    try {
      final userId = currentUserId;
      if (userId == null) {
        throw Exception('User not authenticated');
      }
      
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists || userDoc.data() == null) {
        throw Exception('User profile not found');
      }
      
      final roleString = userDoc.data()!['role'] as String;
      return UserRoleUtils.fromString(roleString);
    } catch (e) {
      rethrow;
    }
  }
}
