
import '../../data/repositories/assignment_repository.dart';

/// Use case for deleting an assignment
class DeleteAssignmentUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  DeleteAssignmentUseCase(this._assignmentRepository);
  
  /// Executes the delete assignment operation
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment to delete
  Future<void> call(String groupId, String assignmentId) {
    return _assignmentRepository.deleteAssignment(groupId, assignmentId);
  }
}
