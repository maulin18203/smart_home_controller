import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/activity_service.dart';
import '../../services/auth_service.dart';
import './widgets/confirmation_dialog.dart';
import './widgets/profile_edit_modal.dart';
import './widgets/settings_section.dart';
import './widgets/settings_tile.dart';
import './widgets/theme_selection_modal.dart';
import './widgets/toggle_settings_tile.dart';
import './widgets/user_profile_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Replace mock user data with real user profile
  Map<String, dynamic>? _userData;
  bool _isLoadingProfile = true;

  // Settings state
  bool _deviceStatusAlerts = true;
  bool _activitySummaries = true;
  bool _securityNotifications = true;
  bool _marketingPreferences = false;
  bool _twoFactorAuth = false;
  bool _offlineMode = false;
  String _selectedTheme = 'system';
  String _selectedLanguage = 'English';
  String _measurementUnits = 'Metric';
  int _connectedDevicesCount = 12;
  bool _isFirebaseConnected = true;

  // Mock credentials for authentication
  final Map<String, String> _mockCredentials = {
    "email": "admin@smarthome.com",
    "password": "SmartHome123!",
    "phone": "+1234567890",
  };

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (mounted) {
        setState(() {
          _userData = profile ??
              {
                "full_name": "Unknown User",
                "email": AuthService.instance.currentUser?.email ??
                    "unknown@email.com",
                "avatar_url": null,
              };
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userData = {
            "full_name": "Unknown User",
            "email":
                AuthService.instance.currentUser?.email ?? "unknown@email.com",
            "avatar_url": null,
          };
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _showProfileEditModal() {
    if (_userData == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProfileEditModal(
        currentName: _userData!["full_name"] ?? "",
        currentEmail: _userData!["email"] ?? "",
        currentAvatarUrl: _userData!["avatar_url"],
        onSave: (name, email, avatarUrl) async {
          try {
            // Update profile in Supabase
            await AuthService.instance.updateUserProfile(
              fullName: name,
              avatarUrl: avatarUrl,
            );

            // Reload profile data
            await _loadUserProfile();

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile updated successfully')),
              );
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update profile: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showThemeSelectionModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ThemeSelectionModal(
        currentTheme: _selectedTheme,
        onThemeChanged: (theme) {
          setState(() => _selectedTheme = theme);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Theme changed to ${theme.replaceFirst(theme[0], theme[0].toUpperCase())}')),
          );
        },
      ),
    );
  }

  void _showConfirmationDialog({
    required String title,
    required String message,
    required VoidCallback onConfirm,
    bool isDestructive = false,
    String confirmText = 'Confirm',
  }) {
    showDialog(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        onConfirm: onConfirm,
        isDestructive: isDestructive,
      ),
    );
  }

  void _handleSignOut() {
    _showConfirmationDialog(
      title: 'Sign Out',
      message:
          'Are you sure you want to sign out? You will need to sign in again to access your devices.',
      confirmText: 'Sign Out',
      isDestructive: true,
      onConfirm: () async {
        try {
          // Log logout activity
          await ActivityService.instance.logUserActivity(
            activityType: 'user_logout',
            description: 'User logged out',
            metadata: {
              'logout_method': 'manual',
              'timestamp': DateTime.now().toIso8601String(),
            },
          );

          // Sign out with Supabase
          await AuthService.instance.signOut();

          // Navigate to login screen
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
                context, '/login-screen', (route) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signed out successfully')),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sign out failed: $e')),
            );
          }
        }
      },
    );
  }

  void _handleDeleteAccount() {
    _showConfirmationDialog(
      title: 'Delete Account',
      message:
          'This action cannot be undone. All your data, devices, and settings will be permanently deleted.',
      confirmText: 'Delete Account',
      isDestructive: true,
      onConfirm: () {
        Navigator.pushNamedAndRemoveUntil(
            context, '/login-screen', (route) => false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted successfully')),
        );
      },
    );
  }

  void _exportData() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preparing data export...')),
    );

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Data exported successfully. Check your downloads.')),
      );
    }
  }

  void _showPasswordChangeDialog() {
    final TextEditingController currentPasswordController =
        TextEditingController();
    final TextEditingController newPasswordController = TextEditingController();
    final TextEditingController confirmPasswordController =
        TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Change Password'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: currentPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Current Password',
                  hintText: 'Enter current password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: newPasswordController,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  hintText: 'Enter new password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: confirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  hintText: 'Confirm new password',
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (currentPasswordController.text !=
                          _mockCredentials["password"]) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Current password is incorrect')),
                        );
                        return;
                      }

                      if (newPasswordController.text !=
                          confirmPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('New passwords do not match')),
                        );
                        return;
                      }

                      setDialogState(() => isLoading = true);
                      await Future.delayed(const Duration(seconds: 1));

                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Password changed successfully')),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: SafeArea(
        child: _isLoadingProfile
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // User Profile Section - now using real data
                    UserProfileSection(
                      userName: _userData?["full_name"] ?? "Unknown User",
                      userEmail: _userData?["email"] ?? "unknown@email.com",
                      avatarUrl: _userData?["avatar_url"],
                      onEditProfile: _showProfileEditModal,
                    ),

                    SizedBox(height: 2.h),

                    // Account Section
                    SettingsSection(
                      title: 'Account',
                      children: [
                        SettingsTile(
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          iconName: 'lock',
                          onTap: _showPasswordChangeDialog,
                        ),
                        SettingsTile(
                          title: 'Email',
                          subtitle: _userData?["email"] ?? "unknown@email.com",
                          iconName: 'email',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Email update coming soon')),
                            );
                          },
                        ),
                        ToggleSettingsTile(
                          title: 'Two-Factor Authentication',
                          subtitle: 'Add an extra layer of security',
                          iconName: 'security',
                          value: _twoFactorAuth,
                          onChanged: (value) =>
                              setState(() => _twoFactorAuth = value),
                        ),
                        SettingsTile(
                          title: 'Sign Out',
                          iconName: 'logout',
                          onTap: _handleSignOut,
                          isDestructive: true,
                          showDivider: false,
                        ),
                      ],
                    ),

                    // Notifications Section
                    SettingsSection(
                      title: 'Notifications',
                      children: [
                        ToggleSettingsTile(
                          title: 'Device Status Alerts',
                          subtitle:
                              'Get notified when devices go online/offline',
                          iconName: 'notifications',
                          value: _deviceStatusAlerts,
                          onChanged: (value) =>
                              setState(() => _deviceStatusAlerts = value),
                        ),
                        ToggleSettingsTile(
                          title: 'Activity Summaries',
                          subtitle: 'Daily and weekly activity reports',
                          iconName: 'assessment',
                          value: _activitySummaries,
                          onChanged: (value) =>
                              setState(() => _activitySummaries = value),
                        ),
                        ToggleSettingsTile(
                          title: 'Security Notifications',
                          subtitle: 'Alerts for security events',
                          iconName: 'shield',
                          value: _securityNotifications,
                          onChanged: (value) =>
                              setState(() => _securityNotifications = value),
                        ),
                        ToggleSettingsTile(
                          title: 'Marketing Preferences',
                          subtitle: 'Product updates and promotions',
                          iconName: 'campaign',
                          value: _marketingPreferences,
                          onChanged: (value) =>
                              setState(() => _marketingPreferences = value),
                          showDivider: false,
                        ),
                      ],
                    ),

                    // App Preferences Section
                    SettingsSection(
                      title: 'App Preferences',
                      children: [
                        SettingsTile(
                          title: 'Theme',
                          subtitle: _selectedTheme.replaceFirst(
                              _selectedTheme[0],
                              _selectedTheme[0].toUpperCase()),
                          iconName: 'palette',
                          onTap: _showThemeSelectionModal,
                        ),
                        SettingsTile(
                          title: 'Language',
                          subtitle: _selectedLanguage,
                          iconName: 'language',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Language selection coming soon')),
                            );
                          },
                        ),
                        SettingsTile(
                          title: 'Measurement Units',
                          subtitle: _measurementUnits,
                          iconName: 'straighten',
                          onTap: () {
                            setState(() {
                              _measurementUnits = _measurementUnits == 'Metric'
                                  ? 'Imperial'
                                  : 'Metric';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      'Units changed to $_measurementUnits')),
                            );
                          },
                          showDivider: false,
                        ),
                      ],
                    ),

                    // Device Management Section
                    SettingsSection(
                      title: 'Device Management',
                      children: [
                        SettingsTile(
                          title: 'Manage Devices',
                          subtitle: '$_connectedDevicesCount devices connected',
                          iconName: 'devices',
                          onTap: () =>
                              Navigator.pushNamed(context, '/device-dashboard'),
                          showDivider: false,
                        ),
                      ],
                    ),

                    // Data and Privacy Section
                    SettingsSection(
                      title: 'Data & Privacy',
                      children: [
                        SettingsTile(
                          title: 'Export Data',
                          subtitle: 'Download your data',
                          iconName: 'download',
                          onTap: _exportData,
                        ),
                        SettingsTile(
                          title: 'Privacy Policy',
                          iconName: 'privacy_tip',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Opening privacy policy...')),
                            );
                          },
                        ),
                        SettingsTile(
                          title: 'Terms of Service',
                          iconName: 'description',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Opening terms of service...')),
                            );
                          },
                        ),
                        SettingsTile(
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          iconName: 'delete_forever',
                          onTap: _handleDeleteAccount,
                          isDestructive: true,
                          showDivider: false,
                        ),
                      ],
                    ),

                    // Support Section
                    SettingsSection(
                      title: 'Support',
                      children: [
                        SettingsTile(
                          title: 'Help Center',
                          subtitle: 'FAQs and troubleshooting',
                          iconName: 'help',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Opening help center...')),
                            );
                          },
                        ),
                        SettingsTile(
                          title: 'Contact Support',
                          subtitle: 'Get help from our team',
                          iconName: 'support_agent',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Opening contact support...')),
                            );
                          },
                        ),
                        SettingsTile(
                          title: 'App Version',
                          subtitle: 'v1.2.3 (Build 456)',
                          iconName: 'info',
                          showDivider: false,
                        ),
                      ],
                    ),

                    // Advanced Settings Section
                    SettingsSection(
                      title: 'Advanced',
                      children: [
                        SettingsTile(
                          title: 'Supabase Connection',
                          subtitle: AuthService.instance.isLoggedIn
                              ? 'Connected'
                              : 'Disconnected',
                          iconName: 'cloud',
                          trailing: Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: BoxDecoration(
                              color: AuthService.instance.isLoggedIn
                                  ? AppTheme.successLight
                                  : AppTheme.errorLight,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        ToggleSettingsTile(
                          title: 'Offline Mode',
                          subtitle: 'Use app without internet connection',
                          iconName: 'offline_bolt',
                          value: _offlineMode,
                          onChanged: (value) =>
                              setState(() => _offlineMode = value),
                        ),
                        SettingsTile(
                          title: 'Debug Options',
                          subtitle: 'Advanced troubleshooting tools',
                          iconName: 'bug_report',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Debug options available for developers')),
                            );
                          },
                          showDivider: false,
                        ),
                      ],
                    ),

                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 4, // Settings tab active
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                  context, '/device-dashboard', (route) => false);
              break;
            case 1:
              Navigator.pushNamed(context, '/device-control-detail-screen');
              break;
            case 2:
              Navigator.pushNamed(context, '/activity-logs-screen');
              break;
            case 3:
              Navigator.pushNamed(context, '/device-dashboard');
              break;
            case 4:
              // Already on settings screen
              break;
          }
        },
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'home', color: AppTheme.textSecondaryLight, size: 24),
            activeIcon: CustomIconWidget(
                iconName: 'home', color: AppTheme.secondaryLight, size: 24),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'tune', color: AppTheme.textSecondaryLight, size: 24),
            activeIcon: CustomIconWidget(
                iconName: 'tune', color: AppTheme.secondaryLight, size: 24),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'history',
                color: AppTheme.textSecondaryLight,
                size: 24),
            activeIcon: CustomIconWidget(
                iconName: 'history', color: AppTheme.secondaryLight, size: 24),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'devices',
                color: AppTheme.textSecondaryLight,
                size: 24),
            activeIcon: CustomIconWidget(
                iconName: 'devices', color: AppTheme.secondaryLight, size: 24),
            label: 'Devices',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
                iconName: 'settings',
                color: AppTheme.textSecondaryLight,
                size: 24),
            activeIcon: CustomIconWidget(
                iconName: 'settings', color: AppTheme.secondaryLight, size: 24),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
