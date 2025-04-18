
import '../../data/repositories/assignment_repository.dart';
import '../entities/submission_entity.dart';

/// Use case for getting submissions for an assignment
class GetSubmissionsUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  GetSubmissionsUseCase(this._assignmentRepository);
  
  /// Executes the get submissions operation
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment
  Future<List<SubmissionEntity>> call(String groupId, String assignmentId) {
    return _assignmentRepository.getAssignmentSubmissions(groupId, assignmentId);
  }
  
  /// Streams submissions for an assignment
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment
  Stream<List<SubmissionEntity>> streamSubmissions(String groupId, String assignmentId) {
    return _assignmentRepository.streamAssignmentSubmissions(groupId, assignmentId);
  }
}
