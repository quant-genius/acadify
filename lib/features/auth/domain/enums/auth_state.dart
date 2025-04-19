
/// Enum representing the authentication state
enum AuthState {
  /// Initial state when the auth status is not yet determined
  initial,
  
  /// State when the user is authenticated
  authenticated,
  
  /// State when the user is not authenticated
  unauthenticated,
  
  /// State when there's an error in authentication
  error,
}
