
import 'package:flutter/material.dart';

import '../../../../core/constants/colors.dart';
import '../../../../core/utils/validators.dart';

/// A reusable form widget for authentication screens
class AuthForm extends StatefulWidget {
  /// Form title displayed at the top
  final String title;
  
  /// List of form fields to display
  final List<AuthFormField> fields;
  
  /// Text for the submit button
  final String submitButtonText;
  
  /// Callback when form is submitted
  final Future<void> Function(Map<String, String> values) onSubmit;
  
  /// Optional error message to display
  final String? errorMessage;
  
  /// Whether the form is in a loading state
  final bool isLoading;
  
  /// Additional widget to display at the bottom of the form
  final Widget? bottomWidget;
  
  /// Creates a AuthForm
  const AuthForm({
    Key? key,
    required this.title,
    required this.fields,
    required this.submitButtonText,
    required this.onSubmit,
    this.errorMessage,
    this.isLoading = false,
    this.bottomWidget,
  }) : super(key: key);

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _obscureTextState = {};
  final Map<String, String> _fieldValues = {};

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers for each field
    for (final field in widget.fields) {
      _controllers[field.name] = TextEditingController();
      if (field.obscureText) {
        _obscureTextState[field.name] = true;
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _togglePasswordVisibility(String fieldName) {
    setState(() {
      _obscureTextState[fieldName] = !(_obscureTextState[fieldName] ?? true);
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Extract values from controllers
      for (final entry in _controllers.entries) {
        _fieldValues[entry.key] = entry.value.text.trim();
      }
      
      await widget.onSubmit(_fieldValues);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Form title
          Text(
            widget.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          
          // Form fields
          ...widget.fields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: TextFormField(
              controller: _controllers[field.name],
              keyboardType: field.keyboardType,
              obscureText: field.obscureText && (_obscureTextState[field.name] ?? true),
              decoration: InputDecoration(
                labelText: field.label,
                hintText: field.hint,
                prefixIcon: field.prefixIcon != null ? Icon(field.prefixIcon) : null,
                suffixIcon: field.obscureText
                  ? IconButton(
                      icon: Icon(
                        (_obscureTextState[field.name] ?? true)
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () => _togglePasswordVisibility(field.name),
                    )
                  : null,
                border: const OutlineInputBorder(),
              ),
              validator: field.validator,
            ),
          )).toList(),
          
          const SizedBox(height: 24),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: widget.isLoading ? null : _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      widget.submitButtonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          
          // Error message
          if (widget.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              widget.errorMessage!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          
          // Bottom widget
          if (widget.bottomWidget != null) ...[
            const SizedBox(height: 24),
            widget.bottomWidget!,
          ],
        ],
      ),
    );
  }
}

/// Represents a field in an authentication form
class AuthFormField {
  /// Unique identifier for the field
  final String name;
  
  /// Label text for the field
  final String label;
  
  /// Hint text for the field
  final String? hint;
  
  /// Icon to display at the start of the field
  final IconData? prefixIcon;
  
  /// Keyboard type for the field
  final TextInputType keyboardType;
  
  /// Whether the field should obscure text (for passwords)
  final bool obscureText;
  
  /// Validation function for the field
  final String? Function(String?)? validator;
  
  /// Creates an AuthFormField
  const AuthFormField({
    required this.name,
    required this.label,
    this.hint,
    this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
  });
  
  /// Creates an email field
  factory AuthFormField.email() {
    return const AuthFormField(
      name: 'email',
      label: 'Email',
      hint: 'Enter your email address',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      validator: Validators.validateEmail,
    );
  }
  
  /// Creates a password field
  factory AuthFormField.password({
    bool isSignUp = false,
    String name = 'password',
    String label = 'Password',
  }) {
    return AuthFormField(
      name: name,
      label: label,
      hint: 'Enter your password',
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: (value) => Validators.validatePassword(value, isSignUp: isSignUp),
    );
  }
  
  /// Creates a confirm password field
  factory AuthFormField.confirmPassword(String passwordFieldName) {
    return AuthFormField(
      name: 'confirmPassword',
      label: 'Confirm Password',
      hint: 'Confirm your password',
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      validator: (value) => (context) {
        final password = context.form.control(passwordFieldName).value;
        return Validators.validateConfirmPassword(value, password);
      },
    );
  }
}
