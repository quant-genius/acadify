
import 'dart:io';
import '../../data/repositories/assignment_repository.dart';
import '../entities/assignment_entity.dart';

/// Use case for updating an existing assignment
class UpdateAssignmentUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  UpdateAssignmentUseCase(this._assignmentRepository);
  
  /// Executes the update assignment operation
  ///
  /// [groupId] - The ID of the group for the assignment
  /// [assignmentId] - The ID of the assignment to update
  /// [title] - The new assignment title
  /// [description] - The new assignment description
  /// [dueDate] - The new due date
  /// [points] - The new points value
  /// [attachmentsToRemove] - List of attachment URLs to remove
  /// [attachmentsToAdd] - List of new files to attach
  /// [isActive] - Whether the assignment is active
  Future<AssignmentEntity> call({
    required String groupId,
    required String assignmentId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? points,
    List<String>? attachmentsToRemove,
    List<File>? attachmentsToAdd,
    bool? isActive,
  }) {
    return _assignmentRepository.updateAssignment(
      groupId: groupId,
      assignmentId: assignmentId,
      title: title,
      description: description,
      dueDate: dueDate,
      points: points,
      attachmentsToRemove: attachmentsToRemove,
      attachmentsToAdd: attachmentsToAdd,
      isActive: isActive,
    );
  }
}
