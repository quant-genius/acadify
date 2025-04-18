
import 'dart:io';
import 'package:flutter/material.dart';
import '../../data/repositories/group_repository.dart';
import '../../domain/entities/group_entity.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

/// Provider for group-related operations
class GroupProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  
  List<GroupEntity> _groups = [];
  GroupEntity? _currentGroup;
  bool _isLoading = false;
  String? _errorMessage;
  
  /// Constructor
  GroupProvider({GroupRepository? groupRepository})
      : _groupRepository = groupRepository ?? GroupRepository();
  
  /// List of user's groups
  List<GroupEntity> get groups => _groups;
  
  /// Currently selected group
  GroupEntity? get currentGroup => _currentGroup;
  
  /// Whether a group operation is in progress
  bool get isLoading => _isLoading;
  
  /// Error message from the last operation
  String? get errorMessage => _errorMessage;
  
  /// Whether an error occurred in the last operation
  bool get hasError => _errorMessage != null;
  
  /// Loads the user's groups
  Future<void> loadUserGroups(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _groups = await _groupRepository.getUserGroups(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load groups: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Gets a specific group by ID
  Future<void> getGroup(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _currentGroup = await _groupRepository.getGroup(groupId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load group: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Creates a new group
  Future<void> createGroup({
    required String name,
    required String description,
    required String creatorId,
    File? coverImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final newGroup = await _groupRepository.createGroup(
        name: name,
        description: description,
        creatorId: creatorId,
        coverImage: coverImage,
      );
      
      _groups.add(newGroup);
      _currentGroup = newGroup;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create group: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Updates an existing group
  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    File? coverImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final updatedGroup = await _groupRepository.updateGroup(
        groupId: groupId,
        name: name,
        description: description,
        coverImage: coverImage,
      );
      
      // Update lists with the updated group
      final index = _groups.indexWhere((group) => group.id == groupId);
      if (index != -1) {
        _groups[index] = updatedGroup;
      }
      
      _currentGroup = updatedGroup;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update group: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Joins a group using a group code
  Future<void> joinGroup({
    required String groupCode,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final joinedGroup = await _groupRepository.joinGroup(
        groupCode: groupCode,
        userId: userId,
      );
      
      _groups.add(joinedGroup);
      _currentGroup = joinedGroup;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to join group: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Leaves a group
  Future<void> leaveGroup({
    required String groupId,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _groupRepository.leaveGroup(
        groupId: groupId,
        userId: userId,
      );
      
      // Remove the group from the list
      _groups.removeWhere((group) => group.id == groupId);
      
      // Clear current group if it was the one we left
      if (_currentGroup?.id == groupId) {
        _currentGroup = null;
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to leave group: ${e.toString()}';
      notifyListeners();
    }
  }
  
  /// Gets the members of a group
  Future<List<UserEntity>> getGroupMembers(String groupId) async {
    try {
      return await _groupRepository.getGroupMembers(groupId);
    } catch (e) {
      _errorMessage = 'Failed to get group members: ${e.toString()}';
      notifyListeners();
      return [];
    }
  }
  
  /// Clears any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
