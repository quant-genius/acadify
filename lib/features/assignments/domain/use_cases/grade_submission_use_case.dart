
import '../../data/repositories/assignment_repository.dart';
import '../entities/submission_entity.dart';

/// Use case for grading a submission
class GradeSubmissionUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  GradeSubmissionUseCase(this._assignmentRepository);
  
  /// Executes the grade submission operation
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment
  /// [submissionId] - The ID of the submission to grade
  /// [grade] - The grade to assign
  /// [feedback] - Feedback for the student
  /// [gradedBy] - ID of the user grading the submission
  Future<SubmissionEntity> call({
    required String groupId,
    required String assignmentId,
    required String submissionId,
    required int grade,
    required String feedback,
    required String gradedBy,
  }) {
    return _assignmentRepository.gradeSubmission(
      groupId: groupId,
      assignmentId: assignmentId,
      submissionId: submissionId,
      grade: grade,
      feedback: feedback,
      gradedBy: gradedBy,
    );
  }
}
