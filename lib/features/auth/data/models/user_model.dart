
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
