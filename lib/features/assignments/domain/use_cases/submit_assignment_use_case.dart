
import 'dart:io';
import '../../data/repositories/assignment_repository.dart';
import '../entities/submission_entity.dart';

/// Use case for submitting an assignment
class SubmitAssignmentUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  SubmitAssignmentUseCase(this._assignmentRepository);
  
  /// Executes the submit assignment operation
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment being submitted
  /// [studentId] - The ID of the student submitting the assignment
  /// [comment] - Comment or note from the student
  /// [attachmentFiles] - Files to attach to the submission
  Future<SubmissionEntity> call({
    required String groupId,
    required String assignmentId,
    required String studentId,
    required String comment,
    List<File>? attachmentFiles,
  }) {
    return _assignmentRepository.submitAssignment(
      groupId: groupId,
      assignmentId: assignmentId,
      studentId: studentId,
      comment: comment,
      attachmentFiles: attachmentFiles,
    );
  }
  
  /// Gets student's submission for an assignment
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment
  /// [studentId] - The ID of the student
  Future<SubmissionEntity?> getStudentSubmission(
    String groupId,
    String assignmentId,
    String studentId,
  ) {
    return _assignmentRepository.getStudentSubmission(
      groupId,
      assignmentId,
      studentId,
    );
  }
}
