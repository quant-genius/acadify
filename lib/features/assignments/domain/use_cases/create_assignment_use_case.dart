
import 'dart:io';
import '../../data/repositories/assignment_repository.dart';
import '../entities/assignment_entity.dart';

/// Use case for creating a new assignment
class CreateAssignmentUseCase {
  final AssignmentRepository _assignmentRepository;
  
  /// Constructor
  CreateAssignmentUseCase(this._assignmentRepository);
  
  /// Executes the create assignment operation
  ///
  /// [groupId] - The ID of the group for the assignment
  /// [creatorId] - The ID of the user creating the assignment
  /// [title] - The assignment title
  /// [description] - The assignment description
  /// [dueDate] - When the assignment is due
  /// [points] - Points or marks for the assignment
  /// [attachmentFiles] - Files to attach to the assignment
  Future<AssignmentEntity> call({
    required String groupId,
    required String creatorId,
    required String title,
    required String description,
    required DateTime dueDate,
    int? points,
    List<File>? attachmentFiles,
  }) {
    return _assignmentRepository.createAssignment(
      groupId: groupId,
      creatorId: creatorId,
      title: title,
      description: description,
      dueDate: dueDate,
      points: points,
      attachmentFiles: attachmentFiles,
    );
  }
}
