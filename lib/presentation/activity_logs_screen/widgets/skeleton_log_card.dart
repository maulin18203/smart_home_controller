import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class SkeletonLogCard extends StatefulWidget {
  const SkeletonLogCard({Key? key}) : super(key: key);

  @override
  State<SkeletonLogCard> createState() => _SkeletonLogCardState();
}

class _SkeletonLogCardState extends State<SkeletonLogCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Device Icon Skeleton
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: _animation.value * 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Device Name and Status Row
                      Row(
                        children: [
                          // Device Name Skeleton
                          Container(
                            width: 30.w,
                            height: 2.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: _animation.value * 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Spacer(),
                          // Status Badge Skeleton
                          Container(
                            width: 15.w,
                            height: 2.5.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: _animation.value * 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 1.h),

                      // Action Description Skeleton
                      Container(
                        width: 50.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: _animation.value * 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Container(
                        width: 35.w,
                        height: 1.5.h,
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: _animation.value * 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: 1.h),

                      // Timestamp and User Row
                      Row(
                        children: [
                          // Timestamp Skeleton
                          Container(
                            width: 20.w,
                            height: 1.2.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: _animation.value * 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          SizedBox(width: 3.w),
                          // User Skeleton
                          Container(
                            width: 15.w,
                            height: 1.2.h,
                            decoration: BoxDecoration(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: _animation.value * 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
