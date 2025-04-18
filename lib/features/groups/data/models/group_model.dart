
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/group_entity.dart';

/// Data model for group information
class GroupModel extends GroupEntity {
  /// Creates a GroupModel with the specified parameters
  const GroupModel({
    required super.id,
    required super.name,
    required super.courseCode,
    required super.description,
    required super.creatorId,
    required super.semester,
    required super.academicYear,
    super.department,
    super.faculty,
    super.photoUrl,
    super.members = const [],
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });
  
  /// Creates a GroupModel from a Firestore document
  factory GroupModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GroupModel(
      id: id,
      name: data['name'] as String,
      courseCode: data['courseCode'] as String,
      description: data['description'] as String,
      creatorId: data['creatorId'] as String,
      semester: data['semester'] as String,
      academicYear: data['academicYear'] as String,
      department: data['department'] as String?,
      faculty: data['faculty'] as String?,
      photoUrl: data['photoUrl'] as String?,
      members: List<String>.from(data['members'] as List? ?? []),
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null 
        ? (data['createdAt'] as dynamic).toDate() 
        : null,
      updatedAt: data['updatedAt'] != null 
        ? (data['updatedAt'] as dynamic).toDate() 
        : null,
    );
  }
  
  /// Converts the GroupModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'courseCode': courseCode,
      'description': description,
      'creatorId': creatorId,
      'semester': semester,
      'academicYear': academicYear,
      'department': department,
      'faculty': faculty,
      'photoUrl': photoUrl,
      'members': members,
      'isActive': isActive,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
  
  /// Creates a copy of this GroupModel with the given fields replaced with new values
  GroupModel copyWith({
    String? id,
    String? name,
    String? courseCode,
    String? description,
    String? creatorId,
    String? semester,
    String? academicYear,
    String? department,
    String? faculty,
    String? photoUrl,
    List<String>? members,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      courseCode: courseCode ?? this.courseCode,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      department: department ?? this.department,
      faculty: faculty ?? this.faculty,
      photoUrl: photoUrl ?? this.photoUrl,
      members: members ?? this.members,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
  
  /// Creates a new GroupModel with empty/default values
  factory GroupModel.empty() {
    return GroupModel(
      id: '',
      name: '',
      courseCode: '',
      description: '',
      creatorId: '',
      semester: '',
      academicYear: '',
      members: [],
      isActive: true,
    );
  }
}
