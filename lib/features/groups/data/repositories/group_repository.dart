
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/group_model.dart';
import '../../domain/entities/group_entity.dart';

/// Repository for handling group data operations
class GroupRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  
  /// Constructor
  GroupRepository({
    required FirestoreService firestoreService,
    required StorageService storageService,
  }) : _firestoreService = firestoreService,
       _storageService = storageService;
  
  /// Gets all groups a user is a member of
  ///
  /// [userId] - The ID of the user to get groups for
  Future<List<GroupEntity>> getUserGroups(String userId) async {
    try {
      final querySnapshot = await _firestoreService.getCollection(
        'groups',
        queryBuilder: (query) => query
            .where('members', arrayContains: userId)
            .where('isActive', isEqualTo: true)
            .orderBy('updatedAt', descending: true),
      );
      
      return querySnapshot.docs.map((doc) {
        return GroupModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets all available groups (for discovery)
  ///
  /// [limit] - The maximum number of groups to retrieve
  /// [lastGroupId] - The ID of the last group retrieved in the previous batch
  Future<List<GroupEntity>> getAvailableGroups({
    int limit = 20,
    String? lastGroupId,
  }) async {
    try {
      Query query = _firestoreService.firestore
          .collection('groups')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (lastGroupId != null) {
        // Get the last document for pagination
        final lastDoc = await _firestoreService.firestore
            .collection('groups')
            .doc(lastGroupId)
            .get();
        
        query = query.startAfterDocument(lastDoc);
      }
      
      final querySnapshot = await query.get();
      
      return querySnapshot.docs.map((doc) {
        return GroupModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a specific group by ID
  ///
  /// [groupId] - The ID of the group to retrieve
  Future<GroupEntity> getGroup(String groupId) async {
    try {
      final docSnapshot = await _firestoreService.getDocument('groups', groupId);
      
      return GroupModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Creates a new group
  ///
  /// [creatorId] - The ID of the user creating the group
  /// [name] - The name of the group
  /// [courseCode] - The course code
  /// [description] - The group description
  /// [semester] - The academic semester
  /// [academicYear] - The academic year
  /// [department] - The department (optional)
  /// [faculty] - The faculty (optional)
  /// [photoFile] - The group photo file (optional)
  /// [members] - List of member user IDs (optional)
  Future<GroupEntity> createGroup({
    required String creatorId,
    required String name,
    required String courseCode,
    required String description,
    required String semester,
    required String academicYear,
    String? department,
    String? faculty,
    File? photoFile,
    List<String> members = const [],
  }) async {
    try {
      // Upload photo if provided
      String? photoUrl;
      if (photoFile != null) {
        // Generate a temporary ID for the group
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
        
        photoUrl = await _storageService.uploadGroupPhoto(tempId, photoFile);
      }
      
      // Add creator to members list if not already included
      final membersList = List<String>.from(members);
      if (!membersList.contains(creatorId)) {
        membersList.add(creatorId);
      }
      
      // Create the group model
      final group = GroupModel(
        id: '',
        name: name,
        courseCode: courseCode,
        description: description,
        creatorId: creatorId,
        semester: semester,
        academicYear: academicYear,
        department: department,
        faculty: faculty,
        photoUrl: photoUrl,
        members: membersList,
        isActive: true,
      );
      
      // Add the group to Firestore
      final docRef = await _firestoreService.createDocument(
        'groups',
        group.toFirestore(),
      );
      
      // Return the group with the generated ID
      return group.copyWith(id: docRef.id);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates an existing group
  ///
  /// [groupId] - The ID of the group to update
  /// [name] - The updated name of the group
  /// [courseCode] - The updated course code
  /// [description] - The updated group description
  /// [semester] - The updated academic semester
  /// [academicYear] - The updated academic year
  /// [department] - The updated department (optional)
  /// [faculty] - The updated faculty (optional)
  /// [photoFile] - The updated group photo file (optional)
  Future<GroupEntity> updateGroup({
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
    try {
      // Get the current group data
      final currentGroup = await getGroup(groupId);
      
      // Upload photo if provided
      String? photoUrl = (currentGroup as GroupModel).photoUrl;
      if (photoFile != null) {
        photoUrl = await _storageService.uploadGroupPhoto(groupId, photoFile);
      }
      
      // Create updates map
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      if (name != null) updates['name'] = name;
      if (courseCode != null) updates['courseCode'] = courseCode;
      if (description != null) updates['description'] = description;
      if (semester != null) updates['semester'] = semester;
      if (academicYear != null) updates['academicYear'] = academicYear;
      if (department != null) updates['department'] = department;
      if (faculty != null) updates['faculty'] = faculty;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      
      // Update the group in Firestore
      await _firestoreService.updateDocument(
        'groups',
        groupId,
        updates,
      );
      
      // Return the updated group
      final updatedGroup = GroupModel(
        id: groupId,
        name: name ?? currentGroup.name,
        courseCode: courseCode ?? currentGroup.courseCode,
        description: description ?? currentGroup.description,
        creatorId: currentGroup.creatorId,
        semester: semester ?? currentGroup.semester,
        academicYear: academicYear ?? currentGroup.academicYear,
        department: department ?? currentGroup.department,
        faculty: faculty ?? currentGroup.faculty,
        photoUrl: photoUrl,
        members: currentGroup.members,
        isActive: currentGroup.isActive,
        createdAt: currentGroup.createdAt,
        updatedAt: DateTime.now(),
      );
      
      return updatedGroup;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Adds a member to a group
  ///
  /// [groupId] - The ID of the group to add the member to
  /// [userId] - The ID of the user to add
  Future<void> addGroupMember(String groupId, String userId) async {
    try {
      await _firestoreService.updateDocument(
        'groups',
        groupId,
        {
          'members': FieldValue.arrayUnion([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Removes a member from a group
  ///
  /// [groupId] - The ID of the group to remove the member from
  /// [userId] - The ID of the user to remove
  Future<void> removeGroupMember(String groupId, String userId) async {
    try {
      await _firestoreService.updateDocument(
        'groups',
        groupId,
        {
          'members': FieldValue.arrayRemove([userId]),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes a group
  ///
  /// [groupId] - The ID of the group to delete
  /// [permanent] - Whether to permanently delete the group
  Future<void> deleteGroup(String groupId, {bool permanent = false}) async {
    try {
      if (permanent) {
        // Get the group to access its photo URL
        final groupDoc = await _firestoreService.getDocument('groups', groupId);
        final group = GroupModel.fromFirestore(
          groupDoc.data() as Map<String, dynamic>,
          groupDoc.id,
        );
        
        // Delete the photo if it exists
        if (group.photoUrl != null && group.photoUrl!.isNotEmpty) {
          await _storageService.deleteFile(group.photoUrl!);
        }
        
        // Delete the group document
        await _firestoreService.deleteDocument('groups', groupId);
      } else {
        // Soft delete by marking as inactive
        await _firestoreService.updateDocument(
          'groups',
          groupId,
          {
            'isActive': false,
            'updatedAt': FieldValue.serverTimestamp(),
          },
        );
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Searches for groups by name or course code
  ///
  /// [query] - The search query
  /// [limit] - The maximum number of groups to retrieve
  Future<List<GroupEntity>> searchGroups(String query, {int limit = 20}) async {
    try {
      // Convert query to lowercase for case-insensitive search
      final lowerQuery = query.toLowerCase();
      
      // Get all groups (this is a simple implementation, in production you would use proper search functionality)
      final querySnapshot = await _firestoreService.getCollection(
        'groups',
        queryBuilder: (q) => q.where('isActive', isEqualTo: true).limit(100),
      );
      
      // Filter groups based on query
      final List<GroupEntity> filteredGroups = querySnapshot.docs
          .map((doc) => GroupModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .where((group) =>
              group.name.toLowerCase().contains(lowerQuery) ||
              group.courseCode.toLowerCase().contains(lowerQuery))
          .take(limit)
          .toList();
      
      return filteredGroups;
    } catch (e) {
      rethrow;
    }
  }
}
