
import '../../../../core/enums/user_roles.dart';
import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';

/// Use case for user registration operation
class RegisterUseCase {
  final AuthRepository _authRepository;
  
  /// Constructor that takes AuthRepository
  RegisterUseCase(this._authRepository);
  
  /// Executes the registration operation with email and password
  ///
  /// [email] - The user's email address
  /// [password] - The user's password
  /// [firstName] - The user's first name
  /// [lastName] - The user's last name
  /// [studentId] - The user's student ID
  /// [role] - The user's role
  Future<UserEntity> call({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required UserRole role,
  }) {
    return _authRepository.createUserWithEmailAndPassword(
      email,
      password,
      firstName,
      lastName,
      studentId,
      role,
    );
  }
}
