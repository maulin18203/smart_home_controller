import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class QuickActionsWidget extends StatelessWidget {
  final String deviceType;
  final Function(String) onActionTap;

  const QuickActionsWidget({
    Key? key,
    required this.deviceType,
    required this.onActionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildQuickActionsForDeviceType(),
        ],
      ),
    );
  }

  Widget _buildQuickActionsForDeviceType() {
    switch (deviceType.toLowerCase()) {
      case 'light':
        return _buildLightQuickActions();
      case 'thermostat':
        return _buildThermostatQuickActions();
      case 'outlet':
        return _buildOutletQuickActions();
      default:
        return _buildGenericQuickActions();
    }
  }

  Widget _buildLightQuickActions() {
    final actions = [
      {
        'name': 'Full Brightness',
        'icon': 'wb_sunny',
        'action': 'full_brightness'
      },
      {'name': 'Night Mode', 'icon': 'nights_stay', 'action': 'night_mode'},
      {'name': 'Reading Mode', 'icon': 'menu_book', 'action': 'reading_mode'},
    ];

    return _buildActionGrid(actions);
  }

  Widget _buildThermostatQuickActions() {
    final actions = [
      {'name': 'Comfort Mode', 'icon': 'home', 'action': 'comfort_mode'},
      {'name': 'Away Mode', 'icon': 'flight_takeoff', 'action': 'away_mode'},
      {'name': 'Sleep Mode', 'icon': 'bedtime', 'action': 'sleep_mode'},
    ];

    return _buildActionGrid(actions);
  }

  Widget _buildOutletQuickActions() {
    final actions = [
      {'name': 'Turn On 1H', 'icon': 'schedule', 'action': 'on_1h'},
      {'name': 'Turn On 3H', 'icon': 'schedule', 'action': 'on_3h'},
      {'name': 'Away Mode', 'icon': 'security', 'action': 'away_mode'},
    ];

    return _buildActionGrid(actions);
  }

  Widget _buildGenericQuickActions() {
    final actions = [
      {'name': 'Turn On', 'icon': 'power_settings_new', 'action': 'turn_on'},
      {'name': 'Turn Off', 'icon': 'power_off', 'action': 'turn_off'},
      {'name': 'Reset', 'icon': 'refresh', 'action': 'reset'},
    ];

    return _buildActionGrid(actions);
  }

  Widget _buildActionGrid(List<Map<String, String>> actions) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3.w,
        mainAxisSpacing: 2.h,
        childAspectRatio: 1.0,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return _buildActionButton(
          name: action['name']!,
          icon: action['icon']!,
          onTap: () => onActionTap(action['action']!),
        );
      },
    );
  }

  Widget _buildActionButton({
    required String name,
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color:
              AppTheme.lightTheme.colorScheme.secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: AppTheme.lightTheme.colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              name,
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
