import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FilterBottomSheet extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheet({
    Key? key,
    required this.currentFilters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, dynamic> _filters;
  DateTimeRange? _selectedDateRange;

  final List<String> _deviceTypes = [
    'All Devices',
    'Light',
    'Fan',
    'AC',
    'Door',
    'Camera',
    'Thermostat',
  ];

  final List<String> _actionTypes = [
    'All Actions',
    'Turned On',
    'Turned Off',
    'Scheduled',
    'Automated',
    'Manual Control',
  ];

  final List<String> _statusTypes = [
    'All Status',
    'Success',
    'Failed',
    'Pending',
  ];

  final List<String> _users = [
    'All Users',
    'John Doe',
    'Jane Smith',
    'System',
    'Guest',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    if (_filters['dateRange'] != null) {
      _selectedDateRange = _filters['dateRange'] as DateTimeRange;
    }
  }

  void _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _selectedDateRange,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: AppTheme.lightTheme.colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _filters['dateRange'] = picked;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
      _filters.remove('dateRange');
    });
  }

  void _applyFilters() {
    widget.onApplyFilters(_filters);
    Navigator.pop(context);
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _selectedDateRange = null;
    });
  }

  String _formatDateRange(DateTimeRange range) {
    return '${range.start.day}/${range.start.month}/${range.start.year} - ${range.end.day}/${range.end.month}/${range.end.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 2.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant
                  .withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                Text(
                  'Filter Logs',
                  style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Range Filter
                  _buildFilterSection(
                    'Date Range',
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CustomIconWidget(
                            iconName: 'date_range',
                            color: AppTheme.lightTheme.colorScheme.secondary,
                            size: 24,
                          ),
                          title: Text(
                            _selectedDateRange != null
                                ? _formatDateRange(_selectedDateRange!)
                                : 'Select date range',
                            style: AppTheme.lightTheme.textTheme.bodyMedium,
                          ),
                          trailing: _selectedDateRange != null
                              ? GestureDetector(
                                  onTap: _clearDateRange,
                                  child: CustomIconWidget(
                                    iconName: 'clear',
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                    size: 20,
                                  ),
                                )
                              : null,
                          onTap: _selectDateRange,
                        ),
                      ],
                    ),
                  ),

                  // Device Type Filter
                  _buildFilterSection(
                    'Device Type',
                    child: _buildChipGroup(_deviceTypes, 'deviceType'),
                  ),

                  // Action Type Filter
                  _buildFilterSection(
                    'Action Type',
                    child: _buildChipGroup(_actionTypes, 'actionType'),
                  ),

                  // Status Filter
                  _buildFilterSection(
                    'Status',
                    child: _buildChipGroup(_statusTypes, 'status'),
                  ),

                  // User Filter
                  _buildFilterSection(
                    'User',
                    child: _buildChipGroup(_users, 'user'),
                  ),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: Text(
                  'Apply Filters',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(String title, {required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2.h),
        child,
        SizedBox(height: 3.h),
      ],
    );
  }

  Widget _buildChipGroup(List<String> options, String filterKey) {
    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: options.map((option) {
        final isSelected = _filters[filterKey] == option;
        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _filters[filterKey] = option;
              } else {
                _filters.remove(filterKey);
              }
            });
          },
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          selectedColor: AppTheme.lightTheme.colorScheme.secondary,
          checkmarkColor: AppTheme.lightTheme.colorScheme.onSecondary,
          labelStyle: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.onSecondary
                : AppTheme.lightTheme.colorScheme.onSurface,
          ),
          side: BorderSide(
            color: isSelected
                ? AppTheme.lightTheme.colorScheme.secondary
                : AppTheme.lightTheme.colorScheme.outline,
          ),
        );
      }).toList(),
    );
  }
}
