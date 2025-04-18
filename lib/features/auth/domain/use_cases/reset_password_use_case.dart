
import '../../data/repositories/auth_repository.dart';

/// Use case for password reset operation
class ResetPasswordUseCase {
  final AuthRepository _authRepository;
  
  /// Constructor that takes AuthRepository
  ResetPasswordUseCase(this._authRepository);
  
  /// Executes the password reset operation
  ///
  /// [email] - The email address to send the password reset to
  Future<void> call(String email) {
    return _authRepository.sendPasswordResetEmail(email);
  }
  
  /// Checks if a reset email was sent successfully
  ///
  /// [email] - The email to check
  Future<bool> checkResetEmailSent(String email) async {
    try {
      // In a real implementation, this might check with the backend
      // For now, we just return true if the email is valid
      return email.contains('@');
    } catch (e) {
      return false;
    }
  }
}
