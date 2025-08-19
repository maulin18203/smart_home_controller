import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/auth_service.dart';
import '../../services/device_service.dart';
import './widgets/connectivity_status_widget.dart';
import './widgets/device_card_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/loading_skeleton_widget.dart';

class DeviceDashboard extends StatefulWidget {
  const DeviceDashboard({Key? key}) : super(key: key);

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  bool _isConnected = true;
  bool _isRefreshing = false;
  String _userName = 'User';
  int _currentTabIndex = 0;

  // Replace mock device data with real data from Supabase
  List<Map<String, dynamic>> _devices = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _initializeData();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });

      // Navigate to different screens based on tab
      switch (_tabController.index) {
        case 0:
          // Dashboard - already here
          break;
        case 1:
          Navigator.pushNamed(context, '/activity-logs-screen');
          break;
        case 2:
          Navigator.pushNamed(context, '/settings-screen');
          break;
      }
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final profile = await AuthService.instance.getUserProfile();
      if (mounted && profile != null) {
        setState(() {
          _userName = profile['full_name'] ?? 'User';
        });
      }
    } catch (e) {
      print('Failed to load user profile: $e');
    }
  }

  Future<void> _initializeData() async {
    try {
      // Load devices from Supabase
      final devices = await DeviceService.instance.getUserDevices();

      if (mounted) {
        setState(() {
          _devices = devices;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Failed to load devices: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Reload devices from Supabase
      final devices = await DeviceService.instance.getUserDevices();

      if (mounted) {
        setState(() {
          _devices = devices;
          _isRefreshing = false;
          _isConnected = true; // Connected if we successfully loaded data
        });
      }

      // Show refresh confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Device status updated',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isConnected = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to refresh: $e'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _toggleDevice(String deviceId, bool newState) async {
    try {
      // Update device in Supabase
      await DeviceService.instance.toggleDevice(deviceId, newState);

      // Update local state
      final deviceIndex =
          _devices.indexWhere((device) => device['id'] == deviceId);
      if (deviceIndex != -1) {
        setState(() {
          _devices[deviceIndex]['state'] = newState;
          _devices[deviceIndex]['last_activity'] =
              DateTime.now().toIso8601String();
        });

        // Show confirmation with undo option
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${_devices[deviceIndex]['name']} turned ${newState ? 'ON' : 'OFF'}',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
            ),
            backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            action: SnackBarAction(
              label: 'UNDO',
              textColor: Colors.white,
              onPressed: () {
                _toggleDevice(deviceId, !newState);
              },
            ),
          ),
        );

        // Provide haptic feedback
        HapticFeedback.selectionClick();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to toggle device: $e'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  void _showDeviceContextMenu(String deviceId) {
    final device = _devices.firstWhere((d) => (d['id'] as String) == deviceId);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                device['name'] as String,
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 2.h),
            _buildContextMenuItem(
              icon: 'info',
              title: 'Device Details',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/device-control-detail-screen');
              },
            ),
            _buildContextMenuItem(
              icon: 'edit',
              title: 'Rename Device',
              onTap: () {
                Navigator.pop(context);
                _showRenameDialog(deviceId);
              },
            ),
            _buildContextMenuItem(
              icon: 'history',
              title: 'View Activity',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/activity-logs-screen');
              },
            ),
            _buildContextMenuItem(
              icon: 'delete',
              title: 'Remove Device',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                _showRemoveDeviceDialog(deviceId);
              },
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem({
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.lightTheme.colorScheme.onSurface,
        size: 6.w,
      ),
      title: Text(
        title,
        style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
          color: isDestructive
              ? AppTheme.lightTheme.colorScheme.error
              : AppTheme.lightTheme.colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showQuickActions(String deviceId) {
    // Handle swipe right quick actions
    HapticFeedback.mediumImpact();
    _showDeviceContextMenu(deviceId);
  }

  void _showRenameDialog(String deviceId) {
    final device = _devices.firstWhere((d) => d['id'] == deviceId);
    final TextEditingController controller =
        TextEditingController(text: device['name'] as String);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Rename Device',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'Enter new device name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                try {
                  // Update device name in Supabase
                  await DeviceService.instance.updateDevice(
                    deviceId,
                    name: controller.text.trim(),
                  );

                  // Update local state
                  setState(() {
                    final deviceIndex =
                        _devices.indexWhere((d) => d['id'] == deviceId);
                    if (deviceIndex != -1) {
                      _devices[deviceIndex]['name'] = controller.text.trim();
                    }
                  });

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Device renamed successfully')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to rename device: $e')),
                  );
                }
              }
            },
            child: Text(
              'Save',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRemoveDeviceDialog(String deviceId) {
    final device = _devices.firstWhere((d) => d['id'] == deviceId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Remove Device',
          style: AppTheme.lightTheme.textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to remove "${device['name']}" from your smart home? This action cannot be undone.',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                // Remove device from Supabase
                await DeviceService.instance.removeDevice(deviceId);

                // Remove from local state
                setState(() {
                  _devices.removeWhere((d) => d['id'] == deviceId);
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Device removed successfully',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: AppTheme.lightTheme.colorScheme.error,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to remove device: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.colorScheme.error,
            ),
            child: Text(
              'Remove',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addDevice() {
    // Navigate to add device screen or show add device dialog
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: 60.h,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 10.w,
              height: 0.5.h,
              margin: EdgeInsets.symmetric(vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'Add New Device',
              style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4.h),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'add_circle_outline',
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      size: 20.w,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Device Setup Coming Soon',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      'ESP32 device pairing and configuration will be available in the next update.',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get _onlineDeviceCount {
    return _devices.where((device) => device['status'] == 'online').length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky Header with Greeting
            GreetingHeaderWidget(userName: _userName),

            // Connectivity Status
            ConnectivityStatusWidget(
              isConnected: _isConnected,
              deviceCount: _onlineDeviceCount,
            ),

            // Tab Bar
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor:
                    AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: AppTheme.lightTheme.textTheme.labelMedium,
                tabs: const [
                  Tab(text: 'Dashboard'),
                  Tab(text: 'Logs'),
                  Tab(text: 'Settings'),
                ],
              ),
            ),

            SizedBox(height: 2.h),

            // Main Content
            Expanded(
              child: _isLoading
                  ? const LoadingSkeletonWidget()
                  : _devices.isEmpty
                      ? EmptyStateWidget(onAddDevice: _addDevice)
                      : RefreshIndicator(
                          onRefresh: _refreshData,
                          color: AppTheme.lightTheme.colorScheme.secondary,
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _devices.length,
                            itemBuilder: (context, index) {
                              final device = _devices[index];
                              return DeviceCardWidget(
                                device: device,
                                onToggle: _toggleDevice,
                                onLongPress: _showDeviceContextMenu,
                                onSwipeRight: _showQuickActions,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: _devices.isNotEmpty
          ? FloatingActionButton(
              onPressed: _addDevice,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              child: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 6.w,
              ),
            )
          : null,
    );
  }
}
