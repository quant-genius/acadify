
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/enums/user_roles.dart';
import '../../../../core/services/auth_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/enums/auth_state.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/register_use_case.dart';
import '../../domain/use_cases/reset_password_use_case.dart';

/// Provider for authentication state
class AuthProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  final AuthRepository _authRepository;
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;

  bool _isLoading = false;
  bool _isAuthenticated = false;
  String? _errorMessage;
  UserEntity? _user;
  AuthState _authState = AuthState.initial;
  bool _hasError = false;

  /// Constructor for AuthProvider
  AuthProvider({
    required SharedPreferences prefs,
    AuthRepository? authRepository,
    AuthService? authService,
  })  : _prefs = prefs,
        _authRepository = authRepository ?? AuthRepository(
          authService: authService ?? AuthService(prefs: prefs),
          prefs: prefs,
        ),
        _loginUseCase = LoginUseCase(authRepository ?? AuthRepository(
          authService: authService ?? AuthService(prefs: prefs),
          prefs: prefs,
        )),
        _registerUseCase = RegisterUseCase(authRepository ?? AuthRepository(
          authService: authService ?? AuthService(prefs: prefs),
          prefs: prefs,
        )),
        _resetPasswordUseCase = ResetPasswordUseCase(authRepository ?? AuthRepository(
          authService: authService ?? AuthService(prefs: prefs),
          prefs: prefs,
        )) {
    // Check if user is already logged in
    _checkAuthStatus();
  }

  /// Checks the authentication status of the user
  Future<void> _checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = _prefs.getBool('is_logged_in') ?? false;
      
      if (isLoggedIn) {
        // Get the current user from Firebase
        final user = await _authRepository.getCurrentUser();
        
        if (user != null) {
          _user = user;
          _isAuthenticated = true;
          _authState = AuthState.authenticated;
        } else {
          // Clear preferences if user is not found in Firebase
          await _prefs.setBool('is_logged_in', false);
          _isAuthenticated = false;
          _authState = AuthState.unauthenticated;
        }
      } else {
        _isAuthenticated = false;
        _authState = AuthState.unauthenticated;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _authState = AuthState.error;
      _hasError = true;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Logs the user in with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _loginUseCase.call(email, password);
      
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        
        // Save login state
        await _prefs.setBool('is_logged_in', true);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to login';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Registers a new user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String studentId,
    required UserRole role,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _registerUseCase.call(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        studentId: studentId,
        role: role,
      );
      
      if (user != null) {
        _user = user;
        _isAuthenticated = true;
        
        // Save login state
        await _prefs.setBool('is_logged_in', true);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to register';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sends a password reset email
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _resetPasswordUseCase.call(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Updates user profile data
  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    String? photoUrl,
    String? bio,
    String? phoneNumber,
    String? faculty,
    String? department,
  }) async {
    if (_user == null) return false;
    
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authRepository.updateUserProfile(
        userId: _user!.id,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
        bio: bio,
        phoneNumber: phoneNumber,
        faculty: faculty,
        department: department,
      );
      
      if (updatedUser != null) {
        _user = updatedUser;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Failed to update profile';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Logs the user out
  Future<bool> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      
      // Clear login state
      await _prefs.setBool('is_logged_in', false);
      
      _user = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Whether the user is currently loading
  bool get isLoading => _isLoading;
  
  /// Whether the user is authenticated
  bool get isAuthenticated => _isAuthenticated;
  
  /// Error message, if any
  String? get errorMessage => _errorMessage;
  
  /// The current user
  UserEntity? get user => _user;
  
  /// For backward compatibility - alias for user
  UserEntity? get currentUser => _user;
  
  /// The current authentication state
  AuthState get authState => _authState;
  
  /// Whether there is an error
  bool get hasError => _hasError;
  
  /// Whether the user is not authenticated
  bool get isNotAuthenticated => !_isAuthenticated;
  
  /// Get the shared preferences instance
  SharedPreferences getPrefs() {
    return _prefs;
  }
}
