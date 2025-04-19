
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
  
  /// Alternative name for canModerateContent to maintain backward compatibility
  bool get canModerate => canModerateContent;
  
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
  
  /// Whether this role can create announcements
  bool get canCreateAnnouncements {
    return this == UserRole.lecturer || this == UserRole.classRep || this == UserRole.admin;
  }
  
  /// Whether this role can manage courses
  bool get canManageCourses {
    return this == UserRole.lecturer || this == UserRole.admin;
  }
  
  /// Create a UserRole from a string
  static UserRole fromString(String roleString) {
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
