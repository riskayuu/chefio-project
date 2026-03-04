import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const EditProfilePage({
    Key? key,
    required this.currentName,
    required this.currentEmail,
  }) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _nameController;
  final _usernameController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  late final TextEditingController _emailController;

  bool _isLoading = true;
  String? _existingImageUrl;
  File? _selectedImageFile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _loadCurrentProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentProfile() async {
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        final profile = await _profileService.getUserProfile(user.id);
        if (mounted) {
          setState(() {
            _nameController.text = profile['full_name'] ?? widget.currentName;
            _usernameController.text = profile['username'] ?? '';
            _genderController.text = profile['gender'] ?? '';
            _phoneController.text = profile['phone_number'] ?? '';
            _existingImageUrl = profile['profile_image_url'];
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512, maxHeight: 512);
      if (pickedFile != null) {
        setState(() => _selectedImageFile = File(pickedFile.path));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to pick image: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final user = _authService.getCurrentUser();
      if (user == null) throw Exception("User not logged in");

      String? finalImageUrl = _existingImageUrl;
      if (_selectedImageFile != null) {
        if (_existingImageUrl != null) await _profileService.deleteProfileImage(_existingImageUrl!);
        finalImageUrl = await _profileService.uploadProfileImage(_selectedImageFile!, user.id);
      }
      
      await _profileService.createOrUpdateProfile(
        userId: user.id,
        fullName: _nameController.text.trim(),
        email: _emailController.text.trim(),
        username: _usernameController.text.trim().isEmpty ? null : _usernameController.text.trim(),
        gender: _genderController.text.trim().isEmpty ? null : _genderController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        profileImageUrl: finalImageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update profile: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 20),
                  _buildProfileImagePicker(),
                  const SizedBox(height: 32),
                  _buildFormField(label: 'Name', controller: _nameController, placeholder: 'Full Name', validator: (v) => v == null || v.trim().isEmpty ? 'Please enter your name' : null),
                  const SizedBox(height: 24),
                  _buildFormField(label: 'Username', controller: _usernameController, placeholder: 'Enter your username'),
                  const SizedBox(height: 24),
                  _buildGenderField(),
                  const SizedBox(height: 24),
                  _buildFormField(label: 'Phone Number', controller: _phoneController, placeholder: 'Enter your phone number', keyboardType: TextInputType.phone),
                  const SizedBox(height: 24),
                  _buildFormField(label: 'Email', controller: _emailController, placeholder: 'Enter your email', readOnly: true),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Save Changes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Column(
      children: [
        GestureDetector(
          onTap: _pickImage,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).cardColor,
            backgroundImage: _selectedImageFile != null
                ? FileImage(_selectedImageFile!) as ImageProvider
                : (_existingImageUrl != null && _existingImageUrl!.isNotEmpty
                    ? NetworkImage(_existingImageUrl!)
                    : null),
            child: (_selectedImageFile == null && (_existingImageUrl == null || _existingImageUrl!.isEmpty))
                ? Icon(Icons.add_a_photo_outlined, color: Colors.grey.shade600, size: 30)
                : null,
          ),
        ),
        const SizedBox(height: 12),
        Text("Change picture", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildFormField({required String label, required TextEditingController controller, required String placeholder, String? Function(String?)? validator, TextInputType? keyboardType, bool readOnly = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: readOnly ? Theme.of(context).scaffoldBackgroundColor : Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _genderController.text.isEmpty ? null : _genderController.text,
          decoration: InputDecoration(
            hintText: 'Select your gender',
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          items: const [
            DropdownMenuItem(value: 'Male', child: Text('Male')),
            DropdownMenuItem(value: 'Female', child: Text('Female')),
            DropdownMenuItem(value: 'Other', child: Text('Other')),
          ],
          onChanged: (value) => setState(() => _genderController.text = value ?? ''),
        ),
      ],
    );
  }
}