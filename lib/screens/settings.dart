import 'dart:async';

import 'package:flutter/material.dart';
import 'package:invotrack/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  StreamSubscription<User?>? _authSubscription;
  final User? _user = FirebaseAuth.instance.currentUser;
  bool _isLoading = false;


    @override
  void initState() {
    super.initState();
    // Listen to auth state changes if needed
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Handle user signed out
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
        );
      }
    });
  }


  @override
  void dispose() {
    _authSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  Future<void> _signOut() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error signing out: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await context.read<AuthService>().sendEmailVerification();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent!')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send verification email')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final isEmailVerified = authService.isEmailVerified;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Profile Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.person, color: Colors.blue),
                          title: const Text('Display Name'),
                          subtitle: Text(
                            _user?.displayName ?? 'Not set',
                            style: TextStyle(
                              color: _user?.displayName == null
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              // TODO: Implement display name editing
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Edit name functionality coming soon')),
                              );
                            },
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.email, color: Colors.green),
                          title: const Text('Email'),
                          subtitle: Text(
                            _user?.email ?? 'No email',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const Divider(),
                        ListTile(
                          leading: Icon(
                            Icons.verified_user,
                            color: isEmailVerified ? Colors.green : Colors.orange,
                          ),
                          title: const Text('Email Verification'),
                          subtitle: Text(
                            isEmailVerified ? 'Verified' : 'Not Verified',
                            style: TextStyle(
                              color: isEmailVerified ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: !isEmailVerified
                              ? TextButton(
                                  onPressed: _sendVerificationEmail,
                                  child: const Text('Verify'),
                                )
                              : null,
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.phone, color: Colors.purple),
                          title: const Text('Phone Number'),
                          subtitle: Text(
                            _user?.phoneNumber ?? 'Not set',
                            style: TextStyle(
                              color: _user?.phoneNumber == null
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () {
                              // TODO: Implement phone number editing
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Phone number editing coming soon')),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Account Settings Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Account Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.lock, color: Colors.red),
                          title: const Text('Change Password'),
                          onTap: () {
                            // TODO: Implement password change
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Password change functionality coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.security, color: Colors.blue),
                          title: const Text('Privacy & Security'),
                          onTap: () {
                            // TODO: Implement privacy settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Privacy settings coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.notifications, color: Colors.orange),
                          title: const Text('Notifications'),
                          onTap: () {
                            // TODO: Implement notification settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Notification settings coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // App Settings Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.color_lens, color: Colors.purple),
                          title: const Text('Theme'),
                          subtitle: const Text('System default'),
                          onTap: () {
                            // TODO: Implement theme settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Theme settings coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.language, color: Colors.green),
                          title: const Text('Language'),
                          subtitle: const Text('English'),
                          onTap: () {
                            // TODO: Implement language settings
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Language settings coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.storage, color: Colors.grey),
                          title: const Text('Data & Storage'),
                          onTap: () {
                            // TODO: Implement data management
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Data management coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Support Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ListTile(
                          leading: const Icon(Icons.help, color: Colors.blue),
                          title: const Text('Help & Support'),
                          onTap: () {
                            // TODO: Implement help center
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Help center coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.bug_report, color: Colors.red),
                          title: const Text('Report a Bug'),
                          onTap: () {
                            // TODO: Implement bug reporting
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Bug reporting coming soon')),
                            );
                          },
                        ),
                        const Divider(),
                        ListTile(
                          leading: const Icon(Icons.star, color: Colors.orange),
                          title: const Text('Rate the App'),
                          onTap: () {
                            // TODO: Implement app rating
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('App rating coming soon')),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Logout Button
                Card(
                  color: Colors.red[50],
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red[700]),
                    title: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      _showLogoutConfirmationDialog();
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // App Info
                Center(
                  child: Text(
                    'INVOTRACK v1.0.0',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    '© 2025 Miftah Software',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
    );
  }

  void _showLogoutConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                _signOut();
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}