
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../domain/entities/profile_entity.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';

/// Repository for profile-related operations
class ProfileRepository {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  /// Constructor
  ProfileRepository({
    FirestoreService? firestoreService,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;
  
  /// Gets a user's profile
  Future<ProfileEntity> getUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      
      return ProfileEntity(
        id: userId,
        firstName: userData['firstName'] ?? '',
        lastName: userData['lastName'] ?? '',
        email: userData['email'] ?? '',
        photoUrl: userData['photoUrl'],
        bio: userData['bio'],
        phoneNumber: userData['phoneNumber'],
        faculty: userData['faculty'],
        department: userData['department'],
        role: userData['role'] ?? 'student',
      );
    } catch (e) {
      throw Exception('Error getting user profile: ${e.toString()}');
    }
  }
  
  /// Updates a user's profile
  Future<ProfileEntity> updateUserProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? bio,
    String? phoneNumber,
    String? faculty,
    String? department,
    File? profileImage,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (bio != null) updateData['bio'] = bio;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (faculty != null) updateData['faculty'] = faculty;
      if (department != null) updateData['department'] = department;
      
      // Upload profile image if provided
      if (profileImage != null) {
        final storageRef = _storage.ref().child('profile_images/$userId.jpg');
        await storageRef.putFile(profileImage);
        final downloadUrl = await storageRef.getDownloadURL();
        updateData['photoUrl'] = downloadUrl;
      }
      
      // Update Firestore document
      await _firestore.collection('users').doc(userId).update(updateData);
      
      // Get updated profile
      return getUserProfile(userId);
    } catch (e) {
      throw Exception('Error updating user profile: ${e.toString()}');
    }
  }
}
