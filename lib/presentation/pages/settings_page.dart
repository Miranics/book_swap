import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../providers/auth_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profile',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppTheme.accentColor,
                    child: Text(
                      currentUser?.displayName?.isNotEmpty == true
                          ? currentUser!.displayName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Name: ${currentUser?.displayName ?? 'Unknown'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${currentUser?.email ?? 'N/A'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email Verified: ${currentUser?.emailVerified == true ? 'Yes' : 'No'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: currentUser?.emailVerified == true
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Notification Reminders'),
                  value: _notificationsEnabled,
                  onChanged: (value) {
                    setState(() => _notificationsEnabled = value);
                  },
                ),
                SwitchListTile(
                  title: const Text('Email Updates'),
                  value: _emailUpdatesEnabled,
                  onChanged: (value) {
                    setState(() => _emailUpdatesEnabled = value);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Actions Section
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('About'),
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
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppTheme.errorColor),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: AppTheme.errorColor),
                  ),
                  onTap: () {
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
                            child: const Text('Logout'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
