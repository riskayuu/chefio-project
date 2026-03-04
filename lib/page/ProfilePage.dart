import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../services/theme_provider.dart';
import 'editprofile.dart';
import 'AddRecipe.dart';

class ProfilePage extends StatefulWidget {
  final VoidCallback onGoToHome;

  const ProfilePage({Key? key, required this.onGoToHome}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();

  String? _userName;
  String? _userEmail;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        final profile = await _profileService.getUserProfile(user.id);
        if (mounted) {
          setState(() {
            _userName = profile['full_name'] ?? 'User';
            _userEmail = user.email ?? '';
            _profileImageUrl = profile['profile_image_url'];
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Sign out failed: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onGoToHome,
        ),
        title: const Text('My Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              children: [
                _buildProfileHeader(),
                const SizedBox(height: 40),
                _buildProfileMenuItem(
                  icon: Icons.add_circle_outline,
                  text: 'Add recipe',
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const AddRecipePage()),
                    );
                  },
                ),
                _buildProfileMenuItem(
                  icon: Icons.edit_outlined,
                  text: 'Edit Profile',
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditProfilePage(
                          currentName: _userName ?? '',
                          currentEmail: _userEmail ?? '',
                        ),
                      ),
                    );
                    if (result == true) {
                      _loadUserProfile();
                    }
                  },
                ),
                _buildDarkModeToggle(),
                _buildProfileMenuItem(
                  icon: Icons.logout,
                  text: 'Sign Out',
                  isSignOut: true,
                  onTap: _signOut, 
                ),
              ],
            ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).cardColor,
          backgroundImage:
              _profileImageUrl != null ? NetworkImage(_profileImageUrl!) : null,
          child: _profileImageUrl == null
              ? Icon(Icons.person, size: 50, color: Colors.grey.shade600)
              : null,
        ),
        const SizedBox(height: 16),
        Text(
          _userName ?? 'User',
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _userEmail ?? '',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDarkModeToggle() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isDarkMode ? Icons.dark_mode : Icons.light_mode,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(isDarkMode ? 'Dark Mode' : 'Light Mode',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Switch(
          value: isDarkMode,
          onChanged: (value) => themeProvider.toggleTheme(),
          activeColor: Theme.of(context).colorScheme.primary,
        ),
        onTap: () => themeProvider.toggleTheme(),
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool isSignOut = false,
  }) {
    final color = isSignOut ? Colors.red : Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(text,
            style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSignOut ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color)),
        trailing: isSignOut
            ? null
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}