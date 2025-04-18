
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/firestore_service.dart';
import '../../../../core/services/storage_service.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../../domain/entities/assignment_entity.dart';
import '../../domain/entities/submission_entity.dart';

/// Repository for assignment operations
class AssignmentRepository {
  final FirestoreService _firestoreService;
  final StorageService _storageService;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Uuid _uuid = const Uuid();
  
  /// Constructor
  AssignmentRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _storageService = storageService ?? StorageService(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _storage = storage ?? FirebaseStorage.instance;
  
  /// Creates a new assignment
  Future<AssignmentEntity> createAssignment({
    required String groupId,
    required String creatorId,
    required String title,
    required String description,
    required DateTime dueDate,
    int? points,
    List<File>? attachmentFiles,
  }) async {
    try {
      // Upload attachment files if any
      List<String> attachmentUrls = [];
      if (attachmentFiles != null && attachmentFiles.isNotEmpty) {
        for (final file in attachmentFiles) {
          final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
          final storagePath = 'groups/$groupId/assignments/attachments/$fileName';
          final downloadUrl = await _storageService.uploadFile(file, storagePath);
          attachmentUrls.add(downloadUrl);
        }
      }
      
      // Create assignment document
      final assignmentId = _uuid.v4();
      final assignmentData = AssignmentModel(
        id: assignmentId,
        groupId: groupId,
        creatorId: creatorId,
        title: title,
        description: description,
        dueDate: dueDate,
        points: points,
        attachments: attachmentUrls,
        isActive: true,
      ).toFirestore();
      
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .set(assignmentData);
      
      return AssignmentModel.fromFirestore(assignmentData, assignmentId);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets assignments for a specific group
  Future<List<AssignmentEntity>> getGroupAssignments(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .orderBy('dueDate', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return AssignmentModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets active assignments for a specific group
  Future<List<AssignmentEntity>> getActiveGroupAssignments(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .where('isActive', isEqualTo: true)
          .orderBy('dueDate', descending: false)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return AssignmentModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a single assignment by ID
  Future<AssignmentEntity> getAssignment(String groupId, String assignmentId) async {
    try {
      final docSnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .get();
      
      if (!docSnapshot.exists || docSnapshot.data() == null) {
        throw Exception('Assignment not found');
      }
      
      return AssignmentModel.fromFirestore(
        docSnapshot.data()!,
        docSnapshot.id,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates an existing assignment
  Future<AssignmentEntity> updateAssignment({
    required String groupId,
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? points,
    List<String>? attachmentsToRemove,
    List<File>? attachmentsToAdd,
    bool? isActive,
  }) async {
    try {
      // Get current assignment data
      final assignmentDoc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .get();
      
      if (!assignmentDoc.exists || assignmentDoc.data() == null) {
        throw Exception('Assignment not found');
      }
      
      AssignmentModel assignment = AssignmentModel.fromFirestore(
        assignmentDoc.data()!,
        assignmentDoc.id,
      );
      
      // Handle attachment removals
      List<String> currentAttachments = List.from(assignment.attachments);
      if (attachmentsToRemove != null && attachmentsToRemove.isNotEmpty) {
        for (final urlToRemove in attachmentsToRemove) {
          if (currentAttachments.contains(urlToRemove)) {
            // Remove from storage
            try {
              await _storage.refFromURL(urlToRemove).delete();
            } catch (e) {
              // If deletion fails, continue with other operations
              print('Failed to delete attachment: $e');
            }
            
            // Remove from list
            currentAttachments.remove(urlToRemove);
          }
        }
      }
      
      // Handle new attachments
      if (attachmentsToAdd != null && attachmentsToAdd.isNotEmpty) {
        for (final file in attachmentsToAdd) {
          final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
          final storagePath = 'groups/$groupId/assignments/attachments/$fileName';
          final downloadUrl = await _storageService.uploadFile(file, storagePath);
          currentAttachments.add(downloadUrl);
        }
      }
      
      // Update assignment data
      final updatedAssignment = assignment.copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
        points: points,
        attachments: currentAttachments,
        isActive: isActive,
        updatedAt: DateTime.now(),
      );
      
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .update(updatedAssignment.toFirestore());
      
      return updatedAssignment;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes an assignment
  Future<void> deleteAssignment(String groupId, String assignmentId) async {
    try {
      // Get the assignment first to check for attachments
      final assignmentDoc = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .get();
      
      if (assignmentDoc.exists && assignmentDoc.data() != null) {
        final assignment = AssignmentModel.fromFirestore(
          assignmentDoc.data()!,
          assignmentDoc.id,
        );
        
        // Delete all attachments from storage
        for (final attachmentUrl in assignment.attachments) {
          try {
            await _storage.refFromURL(attachmentUrl).delete();
          } catch (e) {
            // If deletion fails, continue with other operations
            print('Failed to delete attachment: $e');
          }
        }
        
        // Delete all submissions for this assignment
        final submissionsSnapshot = await _firestore
            .collection('groups')
            .doc(groupId)
            .collection('assignments')
            .doc(assignmentId)
            .collection('submissions')
            .get();
        
        final batch = _firestore.batch();
        
        for (final submissionDoc in submissionsSnapshot.docs) {
          batch.delete(submissionDoc.reference);
        }
        
        // Delete the assignment document
        batch.delete(_firestore
            .collection('groups')
            .doc(groupId)
            .collection('assignments')
            .doc(assignmentId));
        
        await batch.commit();
      } else {
        throw Exception('Assignment not found');
      }
    } catch (e) {
      rethrow;
    }
  }
  
  /// Submit an assignment
  Future<SubmissionEntity> submitAssignment({
    required String groupId,
    required String assignmentId,
    required String studentId,
    required String comment,
    List<File>? attachmentFiles,
  }) async {
    try {
      // Upload attachment files if any
      List<String> attachmentUrls = [];
      if (attachmentFiles != null && attachmentFiles.isNotEmpty) {
        for (final file in attachmentFiles) {
          final fileName = '${_uuid.v4()}_${file.path.split('/').last}';
          final storagePath = 'groups/$groupId/assignments/$assignmentId/submissions/$studentId/$fileName';
          final downloadUrl = await _storageService.uploadFile(file, storagePath);
          attachmentUrls.add(downloadUrl);
        }
      }
      
      // Create submission document
      final submissionId = _uuid.v4();
      final submissionData = SubmissionModel(
        id: submissionId,
        assignmentId: assignmentId,
        studentId: studentId,
        comment: comment,
        attachments: attachmentUrls,
        submittedAt: DateTime.now(),
        grade: null,
        feedback: null,
        gradedAt: null,
        gradedBy: null,
      ).toFirestore();
      
      await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .collection('submissions')
          .doc(submissionId)
          .set(submissionData);
      
      return SubmissionModel.fromFirestore(submissionData, submissionId);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get submissions for an assignment
  Future<List<SubmissionEntity>> getAssignmentSubmissions(
    String groupId,
    String assignmentId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .collection('submissions')
          .orderBy('submittedAt', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return SubmissionModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Get a student's submission for an assignment
  Future<SubmissionEntity?> getStudentSubmission(
    String groupId,
    String assignmentId,
    String studentId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .collection('submissions')
          .where('studentId', isEqualTo: studentId)
          .get();
      
      if (querySnapshot.docs.isEmpty) {
        return null;
      }
      
      final doc = querySnapshot.docs.first;
      return SubmissionModel.fromFirestore(doc.data(), doc.id);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Grade a submission
  Future<SubmissionEntity> gradeSubmission({
    required String groupId,
    required String assignmentId,
    required String submissionId,
    required int grade,
    required String feedback,
    required String gradedBy,
  }) async {
    try {
      final submissionRef = _firestore
          .collection('groups')
          .doc(groupId)
          .collection('assignments')
          .doc(assignmentId)
          .collection('submissions')
          .doc(submissionId);
      
      final submissionDoc = await submissionRef.get();
      
      if (!submissionDoc.exists || submissionDoc.data() == null) {
        throw Exception('Submission not found');
      }
      
      SubmissionModel submission = SubmissionModel.fromFirestore(
        submissionDoc.data()!,
        submissionDoc.id,
      );
      
      // Update with grade information
      final updatedSubmission = submission.copyWith(
        grade: grade,
        feedback: feedback,
        gradedAt: DateTime.now(),
        gradedBy: gradedBy,
      );
      
      await submissionRef.update(updatedSubmission.toFirestore());
      
      return updatedSubmission;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Stream assignments for a group
  Stream<List<AssignmentEntity>> streamGroupAssignments(String groupId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('assignments')
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AssignmentModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }
  
  /// Stream an assignment
  Stream<AssignmentEntity> streamAssignment(String groupId, String assignmentId) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('assignments')
        .doc(assignmentId)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists || snapshot.data() == null) {
            throw Exception('Assignment not found');
          }
          return AssignmentModel.fromFirestore(snapshot.data()!, snapshot.id);
        });
  }
  
  /// Stream submissions for an assignment
  Stream<List<SubmissionEntity>> streamAssignmentSubmissions(
    String groupId,
    String assignmentId,
  ) {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('assignments')
        .doc(assignmentId)
        .collection('submissions')
        .orderBy('submittedAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return SubmissionModel.fromFirestore(doc.data(), doc.id);
          }).toList();
        });
  }
}
