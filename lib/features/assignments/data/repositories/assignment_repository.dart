import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  /// Constructor that takes FirestoreService and StorageService
  AssignmentRepository({
    FirestoreService? firestoreService,
    StorageService? storageService,
    FirebaseFirestore? firestore,
    required SharedPreferences prefs,
  })  : _firestoreService = firestoreService ?? FirestoreService(),
       _storageService = storageService ?? StorageService(prefs: prefs),
       _firestore = firestore ?? FirebaseFirestore.instance;
  
  /// Creates a new assignment
  Future<AssignmentEntity> createAssignment(AssignmentEntity assignment) async {
    try {
      final assignmentModel = AssignmentModel.fromEntity(assignment);
      final docRef = await _firestore.collection('assignments').add(assignmentModel.toFirestore());
      final doc = await docRef.get();
      return AssignmentModel.fromFirestore(doc.data()!, doc.id).toEntity();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets an assignment by ID
  Future<AssignmentEntity> getAssignment(String assignmentId) async {
    try {
      final doc = await _firestore.collection('assignments').doc(assignmentId).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Assignment not found');
      }
      return AssignmentModel.fromFirestore(doc.data()!, doc.id).toEntity();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates an existing assignment
  Future<AssignmentEntity> updateAssignment(AssignmentEntity assignment) async {
    try {
      final assignmentModel = AssignmentModel.fromEntity(assignment);
      await _firestore.collection('assignments').doc(assignment.id).update(assignmentModel.toFirestore());
      return await getAssignment(assignment.id);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Deletes an assignment by ID
  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await _firestore.collection('assignments').doc(assignmentId).delete();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets all assignments for a group
  Future<List<AssignmentEntity>> getGroupAssignments(String groupId) async {
    try {
      final querySnapshot = await _firestore
          .collection('assignments')
          .where('groupId', isEqualTo: groupId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return AssignmentModel.fromFirestore(doc.data()!, doc.id).toEntity();
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Submits an assignment
  Future<SubmissionEntity> submitAssignment(SubmissionEntity submission) async {
    try {
      final submissionModel = SubmissionModel.fromEntity(submission);
      final docRef = await _firestore.collection('submissions').add(submissionModel.toFirestore());
      final doc = await docRef.get();
      return SubmissionModel.fromFirestore(doc.data()!, doc.id).toEntity();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets a submission by ID
  Future<SubmissionEntity> getSubmission(String submissionId) async {
    try {
      final doc = await _firestore.collection('submissions').doc(submissionId).get();
      if (!doc.exists || doc.data() == null) {
        throw Exception('Submission not found');
      }
      return SubmissionModel.fromFirestore(doc.data()!, doc.id).toEntity();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Updates an existing submission
  Future<SubmissionEntity> updateSubmission(SubmissionEntity submission) async {
    try {
      final submissionModel = SubmissionModel.fromEntity(submission);
      await _firestore.collection('submissions').doc(submission.id).update(submissionModel.toFirestore());
      return await getSubmission(submission.id);
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets all submissions for an assignment
  Future<List<SubmissionEntity>> getAssignmentSubmissions(String assignmentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('assignmentId', isEqualTo: assignmentId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return SubmissionModel.fromFirestore(doc.data()!, doc.id).toEntity();
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
  
  /// Gets all submissions for a user
  Future<List<SubmissionEntity>> getUserSubmissions(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('submissions')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return SubmissionModel.fromFirestore(doc.data()!, doc.id).toEntity();
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
