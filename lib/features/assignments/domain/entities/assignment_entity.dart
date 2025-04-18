
import 'package:equatable/equatable.dart';

/// Domain entity for assignment information
class AssignmentEntity extends Equatable {
  /// Unique identifier for the assignment
  final String id;
  
  /// ID of the group this assignment belongs to
  final String groupId;
  
  /// ID of the user who created the assignment
  final String creatorId;
  
  /// Assignment title
  final String title;
  
  /// Assignment description
  final String description;
  
  /// When the assignment is due
  final DateTime dueDate;
  
  /// Points or marks for the assignment
  final int? points;
  
  /// List of attachment URLs
  final List<String> attachments;
  
  /// Whether the assignment is active
  final bool isActive;
  
  /// When the assignment was created
  final DateTime? createdAt;
  
  /// When the assignment was last updated
  final DateTime? updatedAt;
  
  /// Creates an AssignmentEntity with the specified parameters
  const AssignmentEntity({
    required this.id,
    required this.groupId,
    required this.creatorId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.points,
    this.attachments = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Returns whether the assignment has attachments
  bool get hasAttachments => attachments.isNotEmpty;
  
  /// Returns whether the assignment is overdue
  bool get isOverdue => DateTime.now().isAfter(dueDate);
  
  /// Returns the number of days until the assignment is due
  int get daysUntilDue {
    final now = DateTime.now();
    return dueDate.difference(now).inDays;
  }
  
  /// Returns whether the assignment is due soon (within 3 days)
  bool get isDueSoon => daysUntilDue >= 0 && daysUntilDue <= 3;
  
  @override
  List<Object?> get props => [
    id,
    groupId,
    creatorId,
    title,
    description,
    dueDate,
    points,
    attachments,
    isActive,
    createdAt,
    updatedAt,
  ];
}
