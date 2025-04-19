
import 'package:equatable/equatable.dart';
import '../../../../core/enums/user_roles.dart';
import '../../domain/entities/user_entity.dart';

/// Data model for user information
class UserModel extends Equatable {
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
  
  /// Creates a UserModel with the specified parameters
  const UserModel({
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
  
  /// Converts this model to a domain entity
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      studentId: studentId,
      role: role,
      phoneNumber: phoneNumber,
      photoUrl: photoUrl,
      faculty: faculty,
      department: department,
      bio: bio,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLoginAt: lastLoginAt,
    );
  }
  
  /// Creates a model from a domain entity
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      studentId: entity.studentId,
      role: entity.role,
      phoneNumber: entity.phoneNumber,
      photoUrl: entity.photoUrl,
      faculty: entity.faculty,
      department: entity.department,
      bio: entity.bio,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      lastLoginAt: entity.lastLoginAt,
    );
  }
  
  /// Creates a model from a Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      studentId: data['studentId'] as String,
      role: _roleFromString(data['role'] as String),
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      faculty: data['faculty'] as String?,
      department: data['department'] as String?,
      bio: data['bio'] as String?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as dynamic).toDate() 
          : null,
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as dynamic).toDate() 
          : null,
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as dynamic).toDate() 
          : null,
    );
  }
  
  /// Converts this model to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'studentId': studentId,
      'role': role.toString().split('.').last,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'faculty': faculty,
      'department': department,
      'bio': bio,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'lastLoginAt': lastLoginAt,
    };
  }
  
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
  
  /// Helper method to convert role string to UserRole enum
  static UserRole _roleFromString(String roleString) {
    switch (roleString.toLowerCase()) {
      case 'student':
        return UserRole.student;
      case 'lecturer':
        return UserRole.lecturer;
      case 'classrep':
      case 'class_rep':
      case 'class representative':
        return UserRole.classRep;
      case 'admin':
      case 'administrator':
        return UserRole.admin;
      default:
        return UserRole.student;
    }
  }
}
