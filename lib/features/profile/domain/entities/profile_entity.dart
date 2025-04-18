
import 'package:equatable/equatable.dart';

/// Entity representing a user profile
class ProfileEntity extends Equatable {
  /// Unique identifier
  final String id;
  
  /// User's first name
  final String firstName;
  
  /// User's last name
  final String lastName;
  
  /// User's email address
  final String email;
  
  /// URL to the user's profile photo
  final String? photoUrl;
  
  /// User's bio or about text
  final String? bio;
  
  /// User's phone number
  final String? phoneNumber;
  
  /// User's faculty
  final String? faculty;
  
  /// User's department
  final String? department;
  
  /// User's role (student, lecturer, etc.)
  final String role;
  
  /// Creates a ProfileEntity with the specified parameters
  const ProfileEntity({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.photoUrl,
    this.bio,
    this.phoneNumber,
    this.faculty,
    this.department,
    required this.role,
  });
  
  /// Returns the user's full name
  String get fullName => '$firstName $lastName';
  
  /// Returns the user's initials for avatar placeholder
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
  
  @override
  List<Object?> get props => [
    id,
    firstName,
    lastName,
    email,
    photoUrl,
    bio,
    phoneNumber,
    faculty,
    department,
    role,
  ];
}
