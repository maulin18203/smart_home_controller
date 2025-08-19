import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ThemeSelectionModal extends StatefulWidget {
  final String currentTheme;
  final Function(String theme) onThemeChanged;

  const ThemeSelectionModal({
    Key? key,
    required this.currentTheme,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  State<ThemeSelectionModal> createState() => _ThemeSelectionModalState();
}

class _ThemeSelectionModalState extends State<ThemeSelectionModal> {
  late String _selectedTheme;

  final List<Map<String, dynamic>> _themeOptions = [
    {
      'value': 'light',
      'title': 'Light Mode',
      'subtitle': 'Clean and bright interface',
      'icon': 'light_mode',
    },
    {
      'value': 'dark',
      'title': 'Dark Mode',
      'subtitle': 'Easy on the eyes in low light',
      'icon': 'dark_mode',
    },
    {
      'value': 'system',
      'title': 'System Default',
      'subtitle': 'Follows your device settings',
      'icon': 'settings_brightness',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Theme Selection',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: Theme.of(context).colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          ..._themeOptions.map((option) => Container(
                margin: EdgeInsets.only(bottom: 2.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedTheme == option['value']
                        ? AppTheme.secondaryLight
                        : Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: _selectedTheme == option['value'] ? 2 : 1,
                  ),
                ),
                child: RadioListTile<String>(
                  value: option['value'],
                  groupValue: _selectedTheme,
                  onChanged: (value) {
                    setState(() => _selectedTheme = value!);
                  },
                  title: Row(
                    children: [
                      Container(
                        width: 10.w,
                        height: 10.w,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: CustomIconWidget(
                            iconName: option['icon'],
                            color: AppTheme.secondaryLight,
                            size: 20,
                          ),
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option['title'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            Text(
                              option['subtitle'],
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  activeColor: AppTheme.secondaryLight,
                ),
              )),
          SizedBox(height: 2.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onThemeChanged(_selectedTheme);
                Navigator.of(context).pop();
              },
              child: const Text('Apply Theme'),
            ),
          ),
        ],
      ),
    );
  }
}
