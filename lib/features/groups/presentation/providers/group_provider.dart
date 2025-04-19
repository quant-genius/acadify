
import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../data/repositories/group_repository.dart';
import '../../domain/entities/group_entity.dart';
import '../../domain/use_cases/get_groups_use_case.dart';
import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../features/auth/domain/entities/user_entity.dart';

/// Provider for group state and operations
class GroupProvider extends ChangeNotifier {
  final GroupRepository _groupRepository;
  final GetGroupsUseCase _getGroupsUseCase;
  
  bool _isLoading = false;
  List<GroupEntity> _userGroups = [];
  List<GroupEntity> _availableGroups = [];
  GroupEntity? _selectedGroup;
  String? _errorMessage;
  
  /// Constructor
  GroupProvider({
    GroupRepository? groupRepository,
    FirestoreService? firestoreService,
    StorageService? storageService,
  }) : _groupRepository = groupRepository ?? GroupRepository(
         firestoreService: firestoreService ?? FirestoreService(),
         storageService: storageService ?? StorageService(prefs: null),
       ),
       _getGroupsUseCase = GetGroupsUseCase(
         groupRepository ?? GroupRepository(
           firestoreService: firestoreService ?? FirestoreService(),
           storageService: storageService ?? StorageService(prefs: null),
         ),
       );
  
  /// Loads the groups for a specific user
  Future<void> loadUserGroups(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _userGroups = await _getGroupsUseCase.getUserGroups(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Loads available groups for discovery
  Future<void> loadAvailableGroups() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _availableGroups = await _getGroupsUseCase.getAvailableGroups();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Creates a new group
  Future<GroupEntity?> createGroup({
    required String name,
    required String courseCode,
    required String description,
    required String creatorId,
    required String semester,
    required String academicYear,
    String? department,
    String? faculty,
    File? photoFile,
    List<String> members = const [],
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final group = await _groupRepository.createGroup(
        name: name,
        courseCode: courseCode,
        description: description,
        creatorId: creatorId,
        semester: semester,
        academicYear: academicYear,
        department: department,
        faculty: faculty,
        photoFile: photoFile,
        members: members,
      );
      
      _userGroups.add(group);
      _isLoading = false;
      notifyListeners();
      return group;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Updates an existing group
  Future<GroupEntity?> updateGroup({
    required String groupId,
    String? name,
    String? courseCode,
    String? description,
    String? semester,
    String? academicYear,
    String? department,
    String? faculty,
    File? photoFile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final group = await _groupRepository.updateGroup(
        groupId: groupId,
        name: name,
        courseCode: courseCode,
        description: description,
        semester: semester,
        academicYear: academicYear,
        department: department,
        faculty: faculty,
        photoFile: photoFile,
      );
      
      // Update the group in the lists
      _updateGroupInLists(group);
      
      _isLoading = false;
      notifyListeners();
      return group;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }
  
  /// Gets a specific group by ID
  Future<void> getGroup(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _selectedGroup = await _groupRepository.getGroup(groupId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Joins a group
  Future<bool> joinGroup(String groupId, String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _groupRepository.addGroupMember(groupId, userId);
      
      // Refresh the group data
      await getGroup(groupId);
      
      // Add the group to user groups if not already there
      final groupExists = _userGroups.any((g) => g.id == groupId);
      if (!groupExists && _selectedGroup != null) {
        _userGroups.add(_selectedGroup!);
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Leaves a group
  Future<bool> leaveGroup(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final authProvider = null; // Replace with actual auth provider
      final userId = "current-user-id"; // Replace with actual current user ID
      
      await _groupRepository.removeGroupMember(groupId, userId);
      
      // Remove the group from user groups
      _userGroups.removeWhere((g) => g.id == groupId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Gets the members of a group
  Future<List<UserEntity>> getGroupMembers(String groupId) async {
    try {
      // This is a stub - in a real implementation, we would get the members from a repository
      return [];
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  /// Searches for groups
  Future<List<GroupEntity>> searchGroups(String query) async {
    try {
      return await _groupRepository.searchGroups(query);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }
  
  /// Deletes a group
  Future<bool> deleteGroup(String groupId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _groupRepository.deleteGroup(groupId);
      
      // Remove the group from lists
      _userGroups.removeWhere((g) => g.id == groupId);
      _availableGroups.removeWhere((g) => g.id == groupId);
      if (_selectedGroup?.id == groupId) {
        _selectedGroup = null;
      }
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  /// Updates a group in the lists
  void _updateGroupInLists(GroupEntity group) {
    // Update in user groups
    final userGroupIndex = _userGroups.indexWhere((g) => g.id == group.id);
    if (userGroupIndex >= 0) {
      _userGroups[userGroupIndex] = group;
    }
    
    // Update in available groups
    final availableGroupIndex = _availableGroups.indexWhere((g) => g.id == group.id);
    if (availableGroupIndex >= 0) {
      _availableGroups[availableGroupIndex] = group;
    }
    
    // Update selected group
    if (_selectedGroup?.id == group.id) {
      _selectedGroup = group;
    }
  }
  
  /// Whether the provider is currently loading
  bool get isLoading => _isLoading;
  
  /// The list of user groups
  List<GroupEntity> get groups => _userGroups;
  
  /// The list of available groups
  List<GroupEntity> get availableGroups => _availableGroups;
  
  /// The currently selected group
  GroupEntity? get selectedGroup => _selectedGroup;
  
  /// Error message, if any
  String? get errorMessage => _errorMessage;
}
