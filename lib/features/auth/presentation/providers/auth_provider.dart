
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/user_entity.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import '../../domain/use_cases/reset_password_use_case.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/enums/user_roles.dart';

/// AuthProvider state
enum AuthState {
  /// Initial state
  initial,
  
  /// Loading state during authentication operations
  loading,
  
  /// Authenticated state - user is logged in
  authenticated,
  
  /// Unauthenticated state - no user is logged in
  unauthenticated,
  
  /// Error state - authentication operation failed
  error,
}

/// Provider for authentication state and operations
class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  late final AuthRepository _authRepository;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final ResetPasswordUseCase _resetPasswordUseCase;
  
  /// Current authentication state
  AuthState _authState = AuthState.initial;
  
  /// Current user entity
  UserEntity? _user;
  
  /// Error message, if any
  String? _errorMessage;
  
  /// Stream subscription for auth state changes
  Stream<User?>? _authStateStream;
  
  /// Constructor that initializes repositories and use cases
  AuthProvider({required SharedPreferences prefs}) : _prefs = prefs {
    _initializeRepositories();
    _checkInitialAuthState();
    _listenToAuthChanges();
  }
  
  /// Initializes repositories and use cases
  void _initializeRepositories() {
    final authService = AuthService(prefs: _prefs);
    _authRepository = AuthRepository(
      authService: authService,
      prefs: _prefs,
    );
    
    _loginUseCase = LoginUseCase(_authRepository);
    _registerUseCase = RegisterUseCase(_authRepository);
    _resetPasswordUseCase = ResetPasswordUseCase(_authRepository);
  }
  
  /// Checks the initial authentication state
  Future<void> _checkInitialAuthState() async {
    _authState = AuthState.loading;
    notifyListeners();
    
    try {
      if (_authRepository.isUserSignedIn) {
        final userId = _authRepository.currentUserId;
        if (userId != null) {
          _user = await _authRepository.getUserProfile(userId);
          _authState = AuthState.authenticated;
        } else {
          _authState = AuthState.unauthenticated;
        }
      } else {
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _authState = AuthState.unauthenticated;
      _errorMessage = e.toString();
    }
    
    notifyListeners();
  }
  
  /// Listens to authentication state changes
  void _listenToAuthChanges() {
    _authStateStream = _authRepository.authStateChanges;
    _authStateStream?.listen((User? user) async {
      if (user != null) {
        try {
          _user = await _authRepository.getUserProfile(user.uid);
          _authState = AuthState.authenticated;
        } catch (e) {
          _user = null;
          _authState = AuthState.unauthenticated;
          _errorMessage = e.toString();
        }
      } else {
        _user = null;
        _authState = AuthState.unauthenticated;
      }
      
      notifyListeners();
    });
  }
  
  /// Signs in a user with email and password
  Future<void> login(String email, String password) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _user = await _loginUseCase(email, password);
      _authState = AuthState.authenticated;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _getReadableErrorMessage(e);
    }
    
    notifyListeners();
  }
  
  /// Creates a new user account with email and password
  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required UserRole role,
  }) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _user = await _registerUseCase(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
        role: role,
      );
      _authState = AuthState.authenticated;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _getReadableErrorMessage(e);
    }
    
    notifyListeners();
  }
  
  /// Signs out the current user
  Future<void> logout() async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _authRepository.signOut();
      _user = null;
      _authState = AuthState.unauthenticated;
    } catch (e) {
      _authState = AuthState.error;
      _errorMessage = _getReadableErrorMessage(e);
    }
    
    notifyListeners();
  }
  
  /// Sends a password reset email to the specified email address
  Future<void> resetPassword(String email) async {
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      await _resetPasswordUseCase(email);
      _authState = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    } catch (e) {
      _authState = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
      _errorMessage = _getReadableErrorMessage(e);
    }
    
    notifyListeners();
  }
  
  /// Updates the user's profile information
  Future<void> updateProfile({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? photoUrl,
    String? faculty,
    String? department,
    String? bio,
  }) async {
    if (_user == null) return;
    
    _authState = AuthState.loading;
    _errorMessage = null;
    notifyListeners();
    
    try {
      _user = await _authRepository.updateUserProfile(
        userId: _user!.id,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        photoUrl: photoUrl,
        faculty: faculty,
        department: department,
        bio: bio,
      );
      _authState = AuthState.authenticated;
    } catch (e) {
      _authState = AuthState.authenticated;
      _errorMessage = _getReadableErrorMessage(e);
    }
    
    notifyListeners();
  }
  
  /// Returns a human-readable error message
  String _getReadableErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'Invalid email address format.';
        case 'user-disabled':
          return 'This account has been disabled.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'weak-password':
          return 'Password is too weak. Please use a stronger password.';
        case 'requires-recent-login':
          return 'This operation requires a recent login. Please log in again.';
        default:
          return error.message ?? 'An authentication error occurred.';
      }
    }
    
    return error.toString();
  }
  
  /// Returns true if the user can moderate content
  Future<bool> canModerate() {
    return _authRepository.canModerate();
  }
  
  /// Returns true if the user can create announcements
  Future<bool> canCreateAnnouncements() {
    return _authRepository.canCreateAnnouncements();
  }
  
  /// Returns true if the user can manage courses
  Future<bool> canManageCourses() {
    return _authRepository.canManageCourses();
  }
  
  /// Get access to shared preferences
  Future<SharedPreferences?> getPrefs() async {
    return _prefs;
  }
  
  /// Current authentication state
  AuthState get authState => _authState;
  
  /// Current user entity
  UserEntity? get user => _user;
  
  /// Error message, if any
  String? get errorMessage => _errorMessage;
  
  /// Returns true if a user is currently authenticated
  bool get isAuthenticated => _authState == AuthState.authenticated;
  
  /// Returns true if a user is currently not authenticated
  bool get isNotAuthenticated => _authState == AuthState.unauthenticated;
  
  /// Returns true if authentication is in progress
  bool get isLoading => _authState == AuthState.loading;
  
  /// Returns true if there was an authentication error
  bool get hasError => _authState == AuthState.error;
  
  @override
  void dispose() {
    super.dispose();
  }
}
