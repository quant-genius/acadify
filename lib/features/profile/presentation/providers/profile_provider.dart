
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/profile_entity.dart';
import '../../data/repositories/profile_repository.dart';

/// Provider for profile-related operations
class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;
  
  ProfileEntity? _userProfile;
  bool _isLoading = false;
  String? _errorMessage;
  
  /// Constructor
  ProfileProvider({ProfileRepository? profileRepository})
      : _profileRepository = profileRepository ?? ProfileRepository();
  
  /// Current user profile
  ProfileEntity? get userProfile => _userProfile;
  
  /// Whether a profile operation is in progress
  bool get isLoading => _isLoading;
  
  /// Error message from the last operation
  String? get errorMessage => _errorMessage;
  
  /// Whether an error occurred in the last operation
  bool get hasError => _errorMessage != null;
  
  /// Loads a user's profile
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _userProfile = await _profileRepository.getUserProfile(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load profile: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Updates a user's profile
  Future<void> updateProfile({
    required String userId,
    String? firstName,
    String? lastName,
    String? bio,
    String? phoneNumber,
    String? faculty,
    String? department,
    File? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _userProfile = await _profileRepository.updateUserProfile(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        bio: bio,
        phoneNumber: phoneNumber,
        faculty: faculty,
        department: department,
        profileImage: profileImage,
      );
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Clears any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
