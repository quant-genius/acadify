
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/profile_provider.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/utils/validators.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

/// Screen for editing a user's profile
class EditProfileScreen extends StatefulWidget {
  /// Creates an EditProfileScreen
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facultyController = TextEditingController();
  final _departmentController = TextEditingController();
  
  File? _profileImage;
  bool _loading = true;
  
  @override
  void initState() {
    super.initState();
    
    // Load the profile data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }
  
  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _facultyController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
    });
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    
    final userId = authProvider.currentUser!.id;
    await profileProvider.loadUserProfile(userId);
    
    final profile = profileProvider.userProfile;
    if (profile != null) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
      _bioController.text = profile.bio ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
      _facultyController.text = profile.faculty ?? '';
      _departmentController.text = profile.department ?? '';
    }
    
    setState(() {
      _loading = false;
    });
  }
  
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }
  
  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
      
      final userId = authProvider.currentUser!.id;
      
      await profileProvider.updateProfile(
        userId: userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        bio: _bioController.text.isEmpty ? null : _bioController.text,
        phoneNumber: _phoneController.text.isEmpty ? null : _phoneController.text,
        faculty: _facultyController.text.isEmpty ? null : _facultyController.text,
        department: _departmentController.text.isEmpty ? null : _departmentController.text,
        profileImage: _profileImage,
      );
      
      if (!profileProvider.hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop();
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);
    final profile = profileProvider.userProfile;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.editProfile),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Profile not found'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadProfile,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile image
                          GestureDetector(
                            onTap: _pickImage,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 60,
                                  backgroundColor: AppColors.primaryLight,
                                  backgroundImage: _profileImage != null
                                      ? FileImage(_profileImage!)
                                      : profile.photoUrl != null
                                          ? CachedNetworkImageProvider(profile.photoUrl!)
                                          : null,
                                  child: _profileImage == null && profile.photoUrl == null
                                      ? Text(
                                          profile.initials,
                                          style: const TextStyle(
                                            fontSize: 40,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // First name
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.firstName,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => Validators.validateRequired(
                              value,
                              fieldName: 'First name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Last name
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.lastName,
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => Validators.validateRequired(
                              value,
                              fieldName: 'Last name',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Bio
                          TextFormField(
                            controller: _bioController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.bio,
                              border: OutlineInputBorder(),
                              hintText: 'Tell us about yourself',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone number
                          TextFormField(
                            controller: _phoneController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.phoneNumber,
                              border: OutlineInputBorder(),
                              hintText: 'e.g., +1234567890',
                            ),
                            keyboardType: TextInputType.phone,
                            validator: Validators.validatePhone,
                          ),
                          const SizedBox(height: 16),
                          
                          // Faculty
                          TextFormField(
                            controller: _facultyController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.faculty,
                              border: OutlineInputBorder(),
                              hintText: 'e.g., Engineering',
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Department
                          TextFormField(
                            controller: _departmentController,
                            decoration: const InputDecoration(
                              labelText: AppStrings.department,
                              border: OutlineInputBorder(),
                              hintText: 'e.g., Computer Science',
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Save button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: profileProvider.isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                              ),
                              child: profileProvider.isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      AppStrings.save,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          
                          // Error message
                          if (profileProvider.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              profileProvider.errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}
