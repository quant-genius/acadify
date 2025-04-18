
import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_roles.dart';

/// Domain entity for user information
class UserEntity extends Equatable {
  /// Unique identifier for the user
  final String id;
  
  /// User's email address
  final String email;
  
  /// User's first name
  final String firstName;
  
  /// User's last name
  final String lastName;
  
  /// User's student ID
  final String studentId;
  
  /// User's role
  final UserRole role;
  
  /// User's phone number
  final String? phoneNumber;
  
  /// URL to the user's profile photo
  final String? photoUrl;
  
  /// User's faculty
  final String? faculty;
  
  /// User's department
  final String? department;
  
  /// User's bio
  final String? bio;
  
  /// Whether the user is active
  final bool isActive;
  
  /// When the user was created
  final DateTime? createdAt;
  
  /// When the user was last updated
  final DateTime? updatedAt;
  
  /// When the user last logged in
  final DateTime? lastLoginAt;
  
  /// Creates a UserEntity with the specified parameters
  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.studentId,
    required this.role,
    this.phoneNumber,
    this.photoUrl,
    this.faculty,
    this.department,
    this.bio,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });
  
  /// Returns the user's full name
  String get fullName => '$firstName $lastName';
  
  /// Returns the user's initials
  String get initials {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '${firstName[0]}${lastName[0]}'.toUpperCase();
    } else if (firstName.isNotEmpty) {
      return firstName[0].toUpperCase();
    } else if (lastName.isNotEmpty) {
      return lastName[0].toUpperCase();
    } else {
      return '';
    }
  }
  
  /// Returns true if the user is a student
  bool get isStudent => role == UserRole.student;
  
  /// Returns true if the user is a lecturer
  bool get isLecturer => role == UserRole.lecturer;
  
  /// Returns true if the user is a class representative
  bool get isClassRep => role == UserRole.classRep;
  
  /// Returns true if the user is an admin
  bool get isAdmin => role == UserRole.admin;
  
  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    studentId,
    role,
    phoneNumber,
    photoUrl,
    faculty,
    department,
    bio,
    isActive,
    createdAt,
    updatedAt,
    lastLoginAt,
  ];
}
