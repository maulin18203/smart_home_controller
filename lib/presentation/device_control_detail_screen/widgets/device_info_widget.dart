import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceInfoWidget extends StatelessWidget {
  final Map<String, dynamic> deviceInfo;

  const DeviceInfoWidget({
    Key? key,
    required this.deviceInfo,
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
            'Device Information',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildInfoRow(
            'Connection Status',
            _getConnectionStatus(),
            _getConnectionIcon(),
            _getConnectionColor(),
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Signal Strength',
            _getSignalStrength(),
            'signal_wifi_4_bar',
            _getSignalColor(),
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Firmware Version',
            deviceInfo['firmwareVersion']?.toString() ?? 'v1.2.3',
            'system_update',
            AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Uptime',
            _getUptime(),
            'schedule',
            AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 2.h),
          _buildInfoRow(
            'Device ID',
            deviceInfo['deviceId']?.toString() ?? 'ESP32-001',
            'fingerprint',
            AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, String icon, Color iconColor) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: CustomIconWidget(
              iconName: icon,
              color: iconColor,
              size: 16,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getConnectionStatus() {
    final isConnected = deviceInfo['isConnected'] as bool? ?? true;
    return isConnected ? 'Connected' : 'Disconnected';
  }

  String _getConnectionIcon() {
    final isConnected = deviceInfo['isConnected'] as bool? ?? true;
    return isConnected ? 'wifi' : 'wifi_off';
  }

  Color _getConnectionColor() {
    final isConnected = deviceInfo['isConnected'] as bool? ?? true;
    return isConnected ? AppTheme.successLight : AppTheme.errorLight;
  }

  String _getSignalStrength() {
    final signalStrength = deviceInfo['signalStrength'] as int? ?? 85;
    if (signalStrength >= 80) return 'Excellent ($signalStrength%)';
    if (signalStrength >= 60) return 'Good ($signalStrength%)';
    if (signalStrength >= 40) return 'Fair ($signalStrength%)';
    return 'Poor ($signalStrength%)';
  }

  Color _getSignalColor() {
    final signalStrength = deviceInfo['signalStrength'] as int? ?? 85;
    if (signalStrength >= 80) return AppTheme.successLight;
    if (signalStrength >= 60) return AppTheme.lightTheme.colorScheme.secondary;
    if (signalStrength >= 40) return AppTheme.warningLight;
    return AppTheme.errorLight;
  }

  String _getUptime() {
    final uptimeHours = deviceInfo['uptimeHours'] as int? ?? 72;
    if (uptimeHours < 24) {
      return '${uptimeHours}h';
    } else {
      final days = uptimeHours ~/ 24;
      final hours = uptimeHours % 24;
      return '${days}d ${hours}h';
    }
  }
}
