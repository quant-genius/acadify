
import '../entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';

/// Use case for user login operation
class LoginUseCase {
  final AuthRepository _authRepository;
  
  /// Constructor that takes AuthRepository
  LoginUseCase(this._authRepository);
  
  /// Executes the login operation with email and password
  ///
  /// Returns a UserEntity if successful, throws an exception otherwise
  Future<UserEntity> call(String email, String password) {
    return _authRepository.signInWithEmailAndPassword(email, password);
  }
}
