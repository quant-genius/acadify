
import '../../domain/entities/user_entity.dart';
import '../../../../core/enums/user_roles.dart';

/// Data model for user information
class UserModel extends UserEntity {
  /// Creates a UserModel with the specified parameters
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.studentId,
    required super.role,
    super.phoneNumber,
    super.photoUrl,
    super.faculty,
    super.department,
    super.bio,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
    super.lastLoginAt,
  });
  
  /// Creates a UserModel from a Firestore document
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'] as String,
      firstName: data['firstName'] as String,
      lastName: data['lastName'] as String,
      studentId: data['studentId'] as String,
      role: UserRole.fromString(data['role'] as String),
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
  
  /// Converts the UserModel to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'studentId': studentId,
      'role': role.name,
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
  
  /// Creates a copy of this UserModel with the given fields replaced with new values
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? studentId,
    UserRole? role,
    String? phoneNumber,
    String? photoUrl,
    String? faculty,
    String? department,
    String? bio,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      studentId: studentId ?? this.studentId,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      faculty: faculty ?? this.faculty,
      department: department ?? this.department,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
  
  /// Creates a new UserModel with empty/default values
  factory UserModel.empty() {
    return UserModel(
      id: '',
      email: '',
      firstName: '',
      lastName: '',
      studentId: '',
      role: UserRole.student,
      isActive: true,
    );
  }
}
