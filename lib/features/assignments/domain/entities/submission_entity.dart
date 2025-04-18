
import 'package:equatable/equatable.dart';

/// Domain entity for assignment submission information
class SubmissionEntity extends Equatable {
  /// Unique identifier for the submission
  final String id;
  
  /// ID of the assignment this submission is for
  final String assignmentId;
  
  /// ID of the student who made the submission
  final String studentId;
  
  /// Comment or note from the student
  final String comment;
  
  /// List of attachment URLs
  final List<String> attachments;
  
  /// When the submission was made
  final DateTime submittedAt;
  
  /// Grade assigned to the submission
  final int? grade;
  
  /// Feedback from the grader
  final String? feedback;
  
  /// When the submission was graded
  final DateTime? gradedAt;
  
  /// ID of the user who graded the submission
  final String? gradedBy;
  
  /// Creates a SubmissionEntity with the specified parameters
  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.comment,
    required this.attachments,
    required this.submittedAt,
    this.grade,
    this.feedback,
    this.gradedAt,
    this.gradedBy,
  });
  
  /// Returns whether the submission has attachments
  bool get hasAttachments => attachments.isNotEmpty;
  
  /// Returns whether the submission has been graded
  bool get isGraded => grade != null;
  
  @override
  List<Object?> get props => [
    id,
    assignmentId,
    studentId,
    comment,
    attachments,
    submittedAt,
    grade,
    feedback,
    gradedAt,
    gradedBy,
  ];
}
