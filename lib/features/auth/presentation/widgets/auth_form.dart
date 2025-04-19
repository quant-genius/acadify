import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/strings.dart';
import '../../../../core/enums/user_roles.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

/// Form for authentication screens
class AuthForm extends StatefulWidget {
  /// Whether this is a registration form
  final bool isRegister;
  
  /// Whether this is a password reset form
  final bool isPasswordReset;
  
  /// Constructor for AuthForm
  const AuthForm({
    Key? key,
    this.isRegister = false,
    this.isPasswordReset = false,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _studentIdController = TextEditingController();
  UserRole _selectedRole = UserRole.student;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _studentIdController.dispose();
    super.dispose();
  }
  
  /// Validates the email field
  String? _validateEmail(String? value) {
    return AppValidators.validateEmail(value);
  }
  
  /// Validates the password field
  String? _validatePassword(String? value) {
    return AppValidators.validatePassword(value);
  }
  
  /// Validates the first name field
  String? _validateFirstName(String? value) {
    if (widget.isRegister && (value == null || value.isEmpty)) {
      return 'Please enter your first name';
    }
    return null;
  }
  
  /// Validates the last name field
  String? _validateLastName(String? value) {
    if (widget.isRegister && (value == null || value.isEmpty)) {
      return 'Please enter your last name';
    }
    return null;
  }
  
  /// Validates the student ID field
  String? _validateStudentId(String? value) {
    if (widget.isRegister && (value == null || value.isEmpty)) {
      return 'Please enter your student ID';
    }
    return null;
  }

  /// Validates a password confirmation field
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Email field
  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        labelText: 'Email',
      ),
      validator: _validateEmail,
    );
  }
  
  /// Password field
  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_showPassword,
      decoration: InputDecoration(
        labelText: 'Password',
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _showPassword = !_showPassword;
            });
          },
        ),
      ),
      validator: _validatePassword,
    );
  }

  /// Password confirmation field
  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_showConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        suffixIcon: IconButton(
          icon: Icon(
            _showConfirmPassword ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _showConfirmPassword = !_showConfirmPassword;
            });
          },
        ),
      ),
      validator: _validateConfirmPassword,
    );
  }
  
  /// First name field
  Widget _buildFirstNameField() {
    return TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        labelText: 'First Name',
      ),
      validator: _validateFirstName,
    );
  }
  
  /// Last name field
  Widget _buildLastNameField() {
    return TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        labelText: 'Last Name',
      ),
      validator: _validateLastName,
    );
  }
  
  /// Student ID field
  Widget _buildStudentIdField() {
    return TextFormField(
      controller: _studentIdController,
      decoration: const InputDecoration(
        labelText: 'Student ID',
      ),
      validator: _validateStudentId,
    );
  }
  
  /// Role selection dropdown
  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<UserRole>(
      decoration: const InputDecoration(
        labelText: 'Role',
      ),
      value: _selectedRole,
      items: UserRole.values.map((role) {
        return DropdownMenuItem<UserRole>(
          value: role,
          child: Text(role.displayName),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRole = value!;
        });
      },
    );
  }
  
  /// Submit button
  Widget _buildSubmitButton(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    return ElevatedButton(
      onPressed: authProvider.isLoading ? null : () {
        if (_formKey.currentState!.validate()) {
          if (widget.isRegister) {
            authProvider.register(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              studentId: _studentIdController.text.trim(),
              role: _selectedRole,
            );
          } else if (widget.isPasswordReset) {
            authProvider.resetPassword(_emailController.text.trim());
          } else {
            authProvider.login(
              _emailController.text.trim(),
              _passwordController.text.trim(),
            );
          }
        }
      },
      child: Text(
        authProvider.isLoading
            ? AppStrings.loading
            : widget.isRegister
            ? AppStrings.signup
            : widget.isPasswordReset
            ? AppStrings.resetPassword
            : AppStrings.login,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          if (widget.isRegister) ...[
            const SizedBox(height: 16),
            _buildConfirmPasswordField(),
            const SizedBox(height: 16),
            _buildFirstNameField(),
            const SizedBox(height: 16),
            _buildLastNameField(),
            const SizedBox(height: 16),
            _buildStudentIdField(),
            const SizedBox(height: 16),
            _buildRoleDropdown(),
          ],
          const SizedBox(height: 32),
          _buildSubmitButton(context),
        ],
      ),
    );
  }
}
