import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class DeviceCardWidget extends StatelessWidget {
  final Map<String, dynamic> device;
  final Function(String, bool) onToggle;
  final Function(String) onLongPress;
  final Function(String) onSwipeRight;

  const DeviceCardWidget({
    Key? key,
    required this.device,
    required this.onToggle,
    required this.onLongPress,
    required this.onSwipeRight,
  }) : super(key: key);

  String _getRelativeTime(String? timestamp) {
    if (timestamp == null) return 'Unknown';

    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} minutes ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hours ago';
      } else {
        return '${difference.inDays} days ago';
      }
    } catch (e) {
      return timestamp;
    }
  }

  Color _getDeviceColor(String deviceType, bool isActive) {
    switch (deviceType) {
      case 'light':
        return isActive ? Colors.amber : Colors.grey;
      case 'fan':
        return isActive ? Colors.cyan : Colors.grey;
      case 'lock':
        return isActive ? Colors.green : Colors.red;
      case 'thermostat':
        return isActive ? Colors.orange : Colors.grey;
      case 'device':
      default:
        return isActive ? AppTheme.secondaryLight : Colors.grey;
    }
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'light':
        return Icons.lightbulb;
      case 'fan':
        return Icons.ac_unit;
      case 'lock':
        return Icons.lock;
      case 'thermostat':
        return Icons.thermostat;
      case 'device':
      default:
        return Icons.power;
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceId = device['id'] as String;
    final name = device['name'] as String;
    final deviceType = device['device_type'] as String;
    final status = device['status'] as String;
    final state = device['state'] as bool;
    final lastActivity = _getRelativeTime(device['last_activity'] as String?);
    final isOnline = status == 'online';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: GestureDetector(
        onLongPress: () => onLongPress(deviceId),
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
            onSwipeRight(deviceId);
          }
        },
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.outline
                  .withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Device Icon
              Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: _getDeviceColor(deviceType, state && isOnline)
                      .withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getDeviceIcon(deviceType),
                  color: _getDeviceColor(deviceType, state && isOnline),
                  size: 6.w,
                ),
              ),

              SizedBox(width: 4.w),

              // Device Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: isOnline
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: isOnline
                                ? AppTheme.successLight
                                : AppTheme.errorLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          '• $lastActivity',
                          style:
                              AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Toggle Switch
              Switch.adaptive(
                value: state && isOnline,
                onChanged:
                    isOnline ? (value) => onToggle(deviceId, value) : null,
                activeColor: _getDeviceColor(deviceType, true),
                activeTrackColor:
                    _getDeviceColor(deviceType, true).withValues(alpha: 0.3),
                inactiveThumbColor: Colors.grey,
                inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
