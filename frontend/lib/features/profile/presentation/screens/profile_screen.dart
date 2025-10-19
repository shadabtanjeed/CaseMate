import 'dart:io';
import 'dart:convert'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/personal_details_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onLogout;

  const ProfileScreen({
    super.key,
    required this.onBack,
    required this.onLogout,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    // Refresh user data when screen loads to get latest profile image
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authProvider.notifier).refreshCurrentUser();
    });
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfileImage() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload image through auth provider
      await ref.read(authProvider.notifier).updateProfileImage(_selectedImage!);

      // Refresh user data to get the updated profile image
      await ref.read(authProvider.notifier).refreshCurrentUser();

      // Clear image cache to force reload
      imageCache.clear();
      imageCache.clearLiveImages();

      if (mounted) {
        // Wait longer to ensure the new image URL is in the provider
        await Future.delayed(const Duration(milliseconds: 300));
        
        setState(() {
          _isUploading = false;
          // Keep _selectedImage - DON'T clear it yet
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile image: $e'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileCard(context, ref),
                  const SizedBox(height: 24),
                  _buildAccountInfo(context, user),
                  const SizedBox(height: 24),
                  _buildNotifications(context),
                  const SizedBox(height: 24),
                  _buildAppearance(context, ref),
                  const SizedBox(height: 24),
                  _buildPrivacySecurity(context),
                  const SizedBox(height: 24),
                  _buildSupport(context, widget.onLogout),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 24), // FIXED: Reduced bottom padding from 80 to 24
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          const Expanded(
            child: Text(
              'Profile & Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final initials = _initialsFrom(user?.fullName ?? '');
    final hasProfileImage =
        user?.profileImageUrl != null && user!.profileImageUrl!.isNotEmpty;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Image Section - FIXED: Always centered
            Center(
              child: Stack(
                children: [
                  // Profile Image or Initial Avatar
                  // PRIORITY: Show selected image first, then database image, then initials
                  _selectedImage != null
                      ? CircleAvatar(
                          radius: 60,
                          backgroundImage: FileImage(_selectedImage!),
                        )
                      : hasProfileImage
                          ? CircleAvatar(
                              key: ValueKey(user.profileImageUrl), // Simple key
                              radius: 60,
                              backgroundImage: _getImageProvider(user.profileImageUrl!),
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.primaryBlue,
                              child: Text(
                              backgroundColor: AppTheme.primaryBlue,
                              onBackgroundImageError: (exception, stackTrace) {
                                // If image fails to load, show initials
                                debugPrint('Error loading profile image: $exception');
                              },
                            )
                          : CircleAvatar(
                              radius: 60,
                              backgroundColor: AppTheme.primaryBlue,
                              child: Text(
                                initials.isEmpty ? 'U' : initials,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 36),
                              ),
                            ),
                  // Edit Button
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: GestureDetector(
                      onTap: _isUploading ? null : _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _isUploading ? Colors.grey : AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          _isUploading ? Icons.hourglass_empty : Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.fullName ?? 'User',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'user@example.com',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Save Button (only show if image is selected and not uploading)
            if (_selectedImage != null) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _saveProfileImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    disabledBackgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isUploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Uploading...',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : const Text(
                          'Save Profile Image',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfo(BuildContext context, dynamic user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Account Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildListTile(
                context,
                Icons.person_outline,
                'Personal Details',
                'Update your information',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalDetailsScreen(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                Icons.email_outlined,
                'Email',
                user?.email ?? '—',
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                Icons.phone_outlined,
                'Phone',
                user?.phone ?? '—',
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                Icons.location_on_outlined,
                'Location',
                user?.location ?? '—',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNotifications(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildSwitchTile(
                Icons.notifications_outlined,
                'Push Notifications',
                'Receive updates about consultations',
                true,
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                Icons.email_outlined,
                'Email Notifications',
                'Get email updates',
                true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppearance(BuildContext context, WidgetRef ref) {
    final isDarkMode = ref.watch(themeNotifierProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: SwitchListTile(
            secondary: Icon(
              Icons.dark_mode_outlined,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            title: const Text('Dark Mode'),
            subtitle: const Text(
              'Use dark theme for better visibility',
              style: TextStyle(fontSize: 12),
            ),
            value: isDarkMode,
            onChanged: (val) {
              ref.read(themeNotifierProvider.notifier).toggleTheme();
            },
            activeThumbColor: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySecurity(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Privacy & Security',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildListTile(
                context,
                Icons.lock_outline,
                'Change Password',
                null,
              ),
              const Divider(height: 1),
              _buildListTile(
                context,
                Icons.privacy_tip_outlined,
                'Privacy Policy',
                null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSupport(BuildContext context, VoidCallback onLogout) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'Support',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _buildListTile(
                context,
                Icons.help_outline,
                'Help & Support',
                null,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: onLogout,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24), // Bottom padding
      ],
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title,
    String? subtitle, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    String subtitle,
    bool value,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppTheme.primaryBlue),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          color: AppTheme.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 13,
          color: AppTheme.textSecondary,
        ),
      ),
      value: value,
      onChanged: (val) {
        // TODO: Implement notification preferences
      },
      activeThumbColor: AppTheme.primaryBlue,
    );
  }

  String _initialsFrom(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  ImageProvider _getImageProvider(String imageUrl) {
    if (imageUrl.startsWith('data:image')) {
      // It's a base64 data URI
      final base64String = imageUrl.split(',')[1];
      return MemoryImage(base64Decode(base64String));
    } else {
      // It's a regular URL
      return NetworkImage(imageUrl);
    }
  }
}
