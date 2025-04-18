
import 'package:equatable/equatable.dart';

/// Domain entity for group information
class GroupEntity extends Equatable {
  /// Unique identifier for the group
  final String id;
  
  /// Group name
  final String name;
  
  /// Course code
  final String courseCode;
  
  /// Group description
  final String description;
  
  /// ID of the user who created the group
  final String creatorId;
  
  /// Academic semester
  final String semester;
  
  /// Academic year
  final String academicYear;
  
  /// Department
  final String? department;
  
  /// Faculty
  final String? faculty;
  
  /// URL to the group photo
  final String? photoUrl;
  
  /// List of member user IDs
  final List<String> members;
  
  /// Whether the group is active
  final bool isActive;
  
  /// When the group was created
  final DateTime? createdAt;
  
  /// When the group was last updated
  final DateTime? updatedAt;
  
  /// Creates a GroupEntity with the specified parameters
  const GroupEntity({
    required this.id,
    required this.name,
    required this.courseCode,
    required this.description,
    required this.creatorId,
    required this.semester,
    required this.academicYear,
    this.department,
    this.faculty,
    this.photoUrl,
    this.members = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });
  
  /// Returns the number of members in the group
  int get memberCount => members.length;
  
  /// Returns the course code and name combined
  String get fullCourseName => '$courseCode - $name';
  
  /// Returns whether the user is a member of the group
  bool isMember(String userId) => members.contains(userId);
  
  /// Returns whether the user is the creator of the group
  bool isCreator(String userId) => creatorId == userId;
  
  @override
  List<Object?> get props => [
    id,
    name,
    courseCode,
    description,
    creatorId,
    semester,
    academicYear,
    department,
    faculty,
    photoUrl,
    members,
    isActive,
    createdAt,
    updatedAt,
  ];
}
