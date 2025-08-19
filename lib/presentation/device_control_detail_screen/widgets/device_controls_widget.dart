import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DeviceControlsWidget extends StatefulWidget {
  final String deviceType;
  final Map<String, dynamic> deviceSettings;
  final Function(String, dynamic) onSettingChanged;

  const DeviceControlsWidget({
    Key? key,
    required this.deviceType,
    required this.deviceSettings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  State<DeviceControlsWidget> createState() => _DeviceControlsWidgetState();
}

class _DeviceControlsWidgetState extends State<DeviceControlsWidget> {
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
            'Device Controls',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          _buildControlsForDeviceType(),
        ],
      ),
    );
  }

  Widget _buildControlsForDeviceType() {
    switch (widget.deviceType.toLowerCase()) {
      case 'light':
        return _buildLightControls();
      case 'thermostat':
        return _buildThermostatControls();
      case 'outlet':
        return _buildOutletControls();
      default:
        return _buildGenericControls();
    }
  }

  Widget _buildLightControls() {
    final brightness =
        (widget.deviceSettings['brightness'] as num?)?.toDouble() ?? 50.0;

    return Column(
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'lightbulb_outline',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Brightness',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '${brightness.round()}%',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.0),
          ),
          child: Slider(
            value: brightness,
            min: 0,
            max: 100,
            divisions: 100,
            onChanged: (value) {
              widget.onSettingChanged('brightness', value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildThermostatControls() {
    final temperature =
        (widget.deviceSettings['temperature'] as num?)?.toDouble() ?? 22.0;

    return Column(
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'thermostat',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Temperature',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '${temperature.round()}°C',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.lightTheme.colorScheme.secondary,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildTemperatureButton(
              icon: 'remove',
              onTap: () {
                if (temperature > 16) {
                  widget.onSettingChanged('temperature', temperature - 1);
                }
              },
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${temperature.round()}°C',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            _buildTemperatureButton(
              icon: 'add',
              onTap: () {
                if (temperature < 30) {
                  widget.onSettingChanged('temperature', temperature + 1);
                }
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutletControls() {
    final timerMinutes = (widget.deviceSettings['timer'] as num?)?.toInt() ?? 0;

    return Column(
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'timer',
              color: AppTheme.lightTheme.colorScheme.onSurface,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Auto Turn Off Timer',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: [0, 15, 30, 60, 120].map((minutes) {
            final isSelected = timerMinutes == minutes;
            return GestureDetector(
              onTap: () => widget.onSettingChanged('timer', minutes),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.lightTheme.colorScheme.secondary
                      : AppTheme.lightTheme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.secondary
                        : AppTheme.lightTheme.colorScheme.outline,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  minutes == 0 ? 'Off' : '${minutes}m',
                  style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                    color: isSelected
                        ? AppTheme.lightTheme.colorScheme.onPrimary
                        : AppTheme.lightTheme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenericControls() {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'settings',
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            size: 20,
          ),
          SizedBox(width: 3.w),
          Text(
            'No additional controls available for this device type',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemperatureButton({
    required String icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
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
    );
  }
}
