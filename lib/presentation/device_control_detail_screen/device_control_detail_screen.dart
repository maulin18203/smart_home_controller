import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/device_controls_widget.dart';
import './widgets/device_info_widget.dart';
import './widgets/device_status_card_widget.dart';
import './widgets/quick_actions_widget.dart';
import './widgets/recent_activity_widget.dart';

class DeviceControlDetailScreen extends StatefulWidget {
  const DeviceControlDetailScreen({Key? key}) : super(key: key);

  @override
  State<DeviceControlDetailScreen> createState() =>
      _DeviceControlDetailScreenState();
}

class _DeviceControlDetailScreenState extends State<DeviceControlDetailScreen> {
  // Mock device data - in real app this would come from Firebase
  final Map<String, dynamic> mockDevice = {
    "id": "ESP32-001",
    "name": "Living Room Light",
    "type": "light",
    "state": true,
    "isOnline": true,
    "lastActivity": "2 minutes ago",
    "settings": {
      "brightness": 75.0,
      "temperature": 22.0,
      "timer": 0,
    },
    "deviceInfo": {
      "isConnected": true,
      "signalStrength": 85,
      "firmwareVersion": "v2.1.4",
      "uptimeHours": 168,
      "deviceId": "ESP32-001",
    }
  };

  final List<Map<String, dynamic>> mockActivities = [
    {
      "action": "brightness_changed",
      "timestamp": "5 min ago",
      "user": "John Doe",
    },
    {
      "action": "turned_on",
      "timestamp": "15 min ago",
      "user": "Sarah Smith",
    },
    {
      "action": "timer_set",
      "timestamp": "1 hour ago",
      "user": "John Doe",
    },
    {
      "action": "turned_off",
      "timestamp": "2 hours ago",
      "user": "System",
    },
    {
      "action": "connected",
      "timestamp": "3 hours ago",
      "user": "System",
    },
  ];

  bool _isLoading = false;
  late Map<String, dynamic> _deviceData;
  late List<Map<String, dynamic>> _activities;

  @override
  void initState() {
    super.initState();
    _deviceData = Map.from(mockDevice);
    _activities = List.from(mockActivities);
    _simulateRealTimeUpdates();
  }

  void _simulateRealTimeUpdates() {
    // Simulate real-time Firebase updates
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _deviceData['lastActivity'] = 'Just now';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    DeviceStatusCardWidget(
                      deviceName: _deviceData['name'] as String,
                      isOnline: _deviceData['isOnline'] as bool,
                      deviceState: _deviceData['state'] as bool,
                      lastActivity: _deviceData['lastActivity'] as String,
                      onToggle: _handleDeviceToggle,
                      isLoading: _isLoading,
                    ),
                    DeviceControlsWidget(
                      deviceType: _deviceData['type'] as String,
                      deviceSettings:
                          _deviceData['settings'] as Map<String, dynamic>,
                      onSettingChanged: _handleSettingChanged,
                    ),
                    QuickActionsWidget(
                      deviceType: _deviceData['type'] as String,
                      onActionTap: _handleQuickAction,
                    ),
                    DeviceInfoWidget(
                      deviceInfo:
                          _deviceData['deviceInfo'] as Map<String, dynamic>,
                    ),
                    RecentActivityWidget(
                      activities: _activities,
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'arrow_back',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              _deviceData['name'] as String,
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: _showDeviceSettings,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'settings',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: _shareDevice,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'share',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleDeviceToggle() {
    if (_isLoading) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isLoading = true;
    });

    // Simulate Firebase command
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() {
          _deviceData['state'] = !(_deviceData['state'] as bool);
          _deviceData['lastActivity'] = 'Just now';
          _isLoading = false;
        });

        // Add activity log
        _activities.insert(0, {
          "action": (_deviceData['state'] as bool) ? "turned_on" : "turned_off",
          "timestamp": "Just now",
          "user": "You",
        });

        // Show confirmation
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Device ${(_deviceData['state'] as bool) ? 'turned on' : 'turned off'} successfully',
              style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
            ),
            backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
            behavior: AppTheme.lightTheme.snackBarTheme.behavior,
            shape: AppTheme.lightTheme.snackBarTheme.shape,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _handleSettingChanged(String setting, dynamic value) {
    setState(() {
      (_deviceData['settings'] as Map<String, dynamic>)[setting] = value;
      _deviceData['lastActivity'] = 'Just now';
    });

    // Add activity log
    _activities.insert(0, {
      "action": "${setting}_changed",
      "timestamp": "Just now",
      "user": "You",
    });

    // Haptic feedback
    HapticFeedback.selectionClick();

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${setting.replaceAll('_', ' ').toUpperCase()} updated successfully',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleQuickAction(String action) {
    // Haptic feedback
    HapticFeedback.mediumImpact();

    switch (action) {
      case 'full_brightness':
        _handleSettingChanged('brightness', 100.0);
        break;
      case 'night_mode':
        _handleSettingChanged('brightness', 20.0);
        break;
      case 'reading_mode':
        _handleSettingChanged('brightness', 60.0);
        break;
      case 'comfort_mode':
        _handleSettingChanged('temperature', 22.0);
        break;
      case 'away_mode':
        _handleSettingChanged('temperature', 18.0);
        break;
      case 'sleep_mode':
        _handleSettingChanged('temperature', 20.0);
        break;
      case 'on_1h':
        _handleSettingChanged('timer', 60);
        break;
      case 'on_3h':
        _handleSettingChanged('timer', 180);
        break;
      case 'turn_on':
        if (!(_deviceData['state'] as bool)) {
          _handleDeviceToggle();
        }
        break;
      case 'turn_off':
        if (_deviceData['state'] as bool) {
          _handleDeviceToggle();
        }
        break;
      case 'reset':
        _resetDevice();
        break;
    }
  }

  void _resetDevice() {
    setState(() {
      _deviceData['settings'] = {
        "brightness": 50.0,
        "temperature": 22.0,
        "timer": 0,
      };
      _deviceData['lastActivity'] = 'Just now';
    });

    _activities.insert(0, {
      "action": "reset",
      "timestamp": "Just now",
      "user": "You",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Device settings reset to default',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDeviceSettings() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildSettingsBottomSheet(),
    );
  }

  Widget _buildSettingsBottomSheet() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 12.w,
            height: 0.5.h,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Text(
              'Device Settings',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 3.h),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              children: [
                _buildSettingsTile(
                  'Device Name',
                  'Change device name',
                  'edit',
                  () => _showRenameDialog(),
                ),
                _buildSettingsTile(
                  'Scheduling',
                  'Set up automated schedules',
                  'schedule',
                  () => _showSchedulingOptions(),
                ),
                _buildSettingsTile(
                  'Notifications',
                  'Configure device alerts',
                  'notifications',
                  () => _showNotificationSettings(),
                ),
                _buildSettingsTile(
                  'Factory Reset',
                  'Reset device to factory settings',
                  'restore',
                  () => _showFactoryResetDialog(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
      String title, String subtitle, String icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: AppTheme.lightTheme.colorScheme.secondary,
            size: 20,
          ),
        ),
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
          color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: CustomIconWidget(
        iconName: 'chevron_right',
        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  void _showRenameDialog() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Device rename feature coming soon',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _showSchedulingOptions() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Scheduling feature coming soon',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _showNotificationSettings() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notification settings coming soon',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }

  void _showFactoryResetDialog() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Factory Reset',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will reset the device to factory settings. All custom configurations will be lost. Continue?',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _performFactoryReset();
            },
            child: Text(
              'Reset',
              style: TextStyle(
                color: AppTheme.errorLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _performFactoryReset() {
    setState(() {
      _deviceData['settings'] = {
        "brightness": 50.0,
        "temperature": 22.0,
        "timer": 0,
      };
      _deviceData['state'] = false;
      _deviceData['lastActivity'] = 'Just now';
    });

    _activities.insert(0, {
      "action": "factory_reset",
      "timestamp": "Just now",
      "user": "You",
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Device factory reset completed',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _shareDevice() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Device sharing feature coming soon',
          style: AppTheme.lightTheme.snackBarTheme.contentTextStyle,
        ),
        backgroundColor: AppTheme.lightTheme.snackBarTheme.backgroundColor,
        behavior: AppTheme.lightTheme.snackBarTheme.behavior,
        shape: AppTheme.lightTheme.snackBarTheme.shape,
      ),
    );
  }
}
