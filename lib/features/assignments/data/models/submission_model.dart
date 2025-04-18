
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/submission_entity.dart';

/// Data model for assignment submission
class SubmissionModel extends SubmissionEntity {
  /// Creates a SubmissionModel with the specified parameters
  const SubmissionModel({
    required super.id,
    required super.assignmentId,
    required super.studentId,
    required super.comment,
    required super.attachments,
    required super.submittedAt,
    super.grade,
    super.feedback,
    super.gradedAt,
    super.gradedBy,
  });
  
  /// Creates a SubmissionModel from a Firestore document
  factory SubmissionModel.fromFirestore(Map<String, dynamic> data, String id) {
    return SubmissionModel(
      id: id,
      assignmentId: data['assignmentId'] as String,
      studentId: data['studentId'] as String,
      comment: data['comment'] as String,
      attachments: List<String>.from(data['attachments'] as List? ?? []),
      submittedAt: (data['submittedAt'] as dynamic).toDate(),
      grade: data['grade'] as int?,
      feedback: data['feedback'] as String?,
      gradedAt: data['gradedAt'] != null 
        ? (data['gradedAt'] as dynamic).toDate() 
        : null,
      gradedBy: data['gradedBy'] as String?,
    );
  }
  
  /// Converts the SubmissionModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'assignmentId': assignmentId,
      'studentId': studentId,
      'comment': comment,
      'attachments': attachments,
      'submittedAt': submittedAt,
      'grade': grade,
      'feedback': feedback,
      'gradedAt': gradedAt,
      'gradedBy': gradedBy,
    };
  }
  
  /// Creates a copy of this SubmissionModel with given fields replaced with new values
  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? studentId,
    String? comment,
    List<String>? attachments,
    DateTime? submittedAt,
    int? grade,
    String? feedback,
    DateTime? gradedAt,
    String? gradedBy,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      studentId: studentId ?? this.studentId,
      comment: comment ?? this.comment,
      attachments: attachments ?? this.attachments,
      submittedAt: submittedAt ?? this.submittedAt,
      grade: grade ?? this.grade,
      feedback: feedback ?? this.feedback,
      gradedAt: gradedAt ?? this.gradedAt,
      gradedBy: gradedBy ?? this.gradedBy,
    );
  }
}
