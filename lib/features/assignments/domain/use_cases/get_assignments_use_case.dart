
import '../../data/repositories/assignment_repository.dart';
import '../entities/assignment_entity.dart';

/// Use case for getting assignments for a specific group
class GetAssignmentsUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  GetAssignmentsUseCase(this._assignmentRepository);
  
  /// Executes the get assignments operation
  ///
  /// [groupId] - The ID of the group to get assignments for
  Future<List<AssignmentEntity>> call(String groupId) {
    return _assignmentRepository.getGroupAssignments(groupId);
  }
  
  /// Gets active assignments for a specific group
  ///
  /// [groupId] - The ID of the group to get active assignments for
  Future<List<AssignmentEntity>> getActiveAssignments(String groupId) {
    return _assignmentRepository.getActiveGroupAssignments(groupId);
  }
  
  /// Gets a single assignment by ID
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment to retrieve
  Future<AssignmentEntity> getAssignment(String groupId, String assignmentId) {
    return _assignmentRepository.getAssignment(groupId, assignmentId);
  }
  
  /// Streams assignments for a group
  ///
  /// [groupId] - The ID of the group to stream assignments for
  Stream<List<AssignmentEntity>> streamAssignments(String groupId) {
    return _assignmentRepository.streamGroupAssignments(groupId);
  }
  
  /// Streams a single assignment
  ///
  /// [groupId] - The ID of the group
  /// [assignmentId] - The ID of the assignment to stream
  Stream<AssignmentEntity> streamAssignment(String groupId, String assignmentId) {
    return _assignmentRepository.streamAssignment(groupId, assignmentId);
  }
}
