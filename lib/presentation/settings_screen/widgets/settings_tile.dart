import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String iconName;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isDestructive;
  final bool showDivider;

  const SettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.iconName,
    this.trailing,
    this.onTap,
    this.isDestructive = false,
    this.showDivider = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          leading: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppTheme.errorLight.withValues(alpha: 0.1)
                  : AppTheme.secondaryLight.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: CustomIconWidget(
                iconName: iconName,
                color: isDestructive
                    ? AppTheme.errorLight
                    : AppTheme.secondaryLight,
                size: 20,
              ),
            ),
          ),
          title: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDestructive ? AppTheme.errorLight : null,
                  fontWeight: FontWeight.w500,
                ),
          ),
          subtitle: subtitle != null
              ? Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                )
              : null,
          trailing: trailing ??
              (onTap != null
                  ? CustomIconWidget(
                      iconName: 'chevron_right',
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18,
                    )
                  : null),
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 18.w,
            endIndent: 4.w,
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
