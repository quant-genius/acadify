
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/assignment_entity.dart';

/// Data model for assignment information
class AssignmentModel extends AssignmentEntity {
  /// Creates an AssignmentModel with the specified parameters
  const AssignmentModel({
    required super.id,
    required super.groupId,
    required super.creatorId,
    required super.title,
    required super.description,
    required super.dueDate,
    super.points,
    super.attachments = const [],
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });
  
  /// Creates an AssignmentModel from a Firestore document
  factory AssignmentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return AssignmentModel(
      id: id,
      groupId: data['groupId'] as String,
      creatorId: data['creatorId'] as String,
      title: data['title'] as String,
      description: data['description'] as String,
      dueDate: (data['dueDate'] as dynamic).toDate(),
      points: data['points'] as int?,
      attachments: List<String>.from(data['attachments'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as dynamic).toDate() 
        : null,
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as dynamic).toDate() 
        : null,
    );
  }
  
  /// Converts the AssignmentModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'groupId': groupId,
      'creatorId': creatorId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'points': points,
      'attachments': attachments,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  /// Creates a copy of this AssignmentModel with given fields replaced with new values
  AssignmentModel copyWith({
    String? id,
    String? groupId,
    String? creatorId,
    String? title,
    String? description,
    DateTime? dueDate,
    int? points,
    List<String>? attachments,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      creatorId: creatorId ?? this.creatorId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      points: points ?? this.points,
      attachments: attachments ?? this.attachments,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
