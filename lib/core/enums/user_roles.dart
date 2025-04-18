
/// Enumeration of user roles in the app
enum UserRole {
  /// Student role
  student,
  
  /// Lecturer role
  lecturer,
  
  /// Class representative role
  classRep,
  
  /// Administrator role
  admin,
}

/// Extension on UserRole to provide additional functionality
extension UserRoleExtension on UserRole {
  /// Display name for the role
  String get displayName {
    switch (this) {
      case UserRole.student:
        return 'Student';
      case UserRole.lecturer:
        return 'Lecturer';
      case UserRole.classRep:
        return 'Class Representative';
      case UserRole.admin:
        return 'Administrator';
    }
  }
  
  /// Whether this role can create groups
  bool get canCreateGroups {
    return this == UserRole.lecturer || this == UserRole.admin;
  }
  
  /// Whether this role can moderate content
  bool get canModerateContent {
    return this == UserRole.lecturer || this == UserRole.classRep || this == UserRole.admin;
  }
  
  /// Whether this role can create assignments
  bool get canCreateAssignments {
    return this == UserRole.lecturer || this == UserRole.admin;
  }
  
  /// Whether this role can grade assignments
  bool get canGradeAssignments {
    return this == UserRole.lecturer || this == UserRole.admin;
  }
  
  /// Whether this role has admin capabilities
  bool get isAdmin {
    return this == UserRole.admin;
  }
}
