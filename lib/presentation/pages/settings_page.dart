import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../domain/models/user_model.dart';
import '../../services/storage_service.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;
  bool _isUploadingAvatar = false;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickAndUploadProfileImage() async {
    final authProvider = context.read<AuthProvider>();
    final currentUser = authProvider.currentUser;
    if (currentUser == null) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final storageService = context.read<StorageService>();

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return;
      }

      if (!mounted) {
        return;
      }
      setState(() => _isUploadingAvatar = true);
      final String imageUrl = await storageService.uploadProfileImage(
        file: pickedFile,
        userId: currentUser.id,
      );

      await authProvider.updateUserProfile(
        displayName:
            (currentUser.displayName?.isNotEmpty ?? false)
                ? currentUser.displayName!
                : currentUser.email,
        profileImageUrl: imageUrl,
      );

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Profile picture updated')),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Could not update profile picture. Please try again.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
      }
    }
  }

  Future<void> _editDisplayName(UserModel user) async {
    final TextEditingController controller =
        TextEditingController(text: user.displayName ?? '');

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    final String? updatedName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update display name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Display name',
              hintText: 'How should others see you?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final String trimmed = controller.text.trim();
                if (trimmed.isEmpty) {
                  return;
                }
                Navigator.of(context).pop(trimmed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (updatedName == null) {
      return;
    }

    if (!mounted) {
      return;
    }
    final authProvider = context.read<AuthProvider>();

    try {
      await authProvider.updateUserProfile(
        displayName: updatedName,
        profileImageUrl: user.profileImageUrl,
      );

      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Display name updated')),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Could not update display name. Please try again.'),
        ),
      );
    }
  }

  Widget _buildTileIcon(IconData icon) {
    return Container(
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: AppTheme.primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    final bool hasProfileImage =
        currentUser?.profileImageUrl?.isNotEmpty == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withValues(alpha: 0.92),
                    AppTheme.secondaryColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: (_isUploadingAvatar || currentUser == null)
                        ? null
                        : _pickAndUploadProfileImage,
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withValues(alpha: 0.9),
                                Colors.white.withValues(alpha: 0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 22,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 58,
                            backgroundColor: AppTheme.accentColor,
                            backgroundImage: hasProfileImage
                                ? NetworkImage(currentUser!.profileImageUrl!)
                                : null,
                            child: hasProfileImage
                                ? null
                                : Text(
                                    currentUser?.displayName?.isNotEmpty ==
                                            true
                                        ? currentUser!.displayName![0]
                                            .toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 34,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          right: 6,
                          bottom: 6,
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.accentColor,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: _isUploadingAvatar
                                  ? const SizedBox(
                                      height: 18,
                                      width: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          AppTheme.primaryColor,
                                        ),
                                      ),
                                    )
                                  : const Icon(
                                      Icons.camera_alt_outlined,
                                      size: 18,
                                      color: AppTheme.primaryColor,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentUser?.displayName ?? 'User',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentUser?.email ?? 'N/A',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.lightTextColor,
                    ),
                  ),
                ],
              ),
            ),

            // Settings List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 2,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.08),
                    child: Column(
                      children: [
                        ListTile(
                          leading: _buildTileIcon(Icons.person_outline),
                          title: const Text('Display name'),
                          subtitle: Text(
                            currentUser?.displayName?.isNotEmpty == true
                                ? currentUser!.displayName!
                                : 'Add your name',
                          ),
                          trailing: const Icon(Icons.edit_outlined),
                          onTap: currentUser == null
                              ? null
                              : () => _editDisplayName(currentUser),
                        ),
                        const Divider(height: 1),
                        ListTile(
                          leading: _buildTileIcon(Icons.alternate_email),
                          title: const Text('Email address'),
                          subtitle: Text(currentUser?.email ?? 'N/A'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                color: (currentUser?.emailVerified ?? false)
                  ? AppTheme.successColor.withValues(alpha: 0.18)
                  : AppTheme.warningColor.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (currentUser?.emailVerified ?? false)
                                  ? 'Verified'
                                  : 'Pending',
                              style: TextStyle(
                                color: (currentUser?.emailVerified ?? false)
                                    ? AppTheme.successColor
                                    : AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Notifications Section
                  Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Notification reminders'),
                          trailing: Switch(
                            value: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                            },
              thumbColor:
                WidgetStateProperty.all(AppTheme.accentColor),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                  ? AppTheme.accentColor.withValues(alpha: 0.4)
                  : Colors.grey.shade300,
              ),
                          ),
                        ),
                        Divider(height: 1, color: Colors.grey.shade200),
                        ListTile(
                          title: const Text('Email Updates'),
                          trailing: Switch(
                            value: _emailUpdatesEnabled,
                            onChanged: (value) {
                              setState(() => _emailUpdatesEnabled = value);
                            },
              thumbColor:
                WidgetStateProperty.all(AppTheme.accentColor),
              trackColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                  ? AppTheme.accentColor.withValues(alpha: 0.4)
                  : Colors.grey.shade300,
              ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Other Section
                  Text(
                    'Support',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 1,
                    shadowColor: AppTheme.primaryColor.withValues(alpha: 0.05),
                    child: Column(
                      children: [
                        ListTile(
                          leading: _buildTileIcon(Icons.info_outline),
                          title: const Text('About'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('About BookSwap'),
                                content: const Text(
                                  'BookSwap v1.0\n\nA marketplace app for students to exchange textbooks.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  if (authProvider.isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: LinearProgressIndicator(),
                    ),

                  // Logout Button
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                context.read<AuthProvider>().logout();
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Logout',
                                style: TextStyle(color: AppTheme.errorColor),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
