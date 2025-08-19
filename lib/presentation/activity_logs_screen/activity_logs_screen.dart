import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet.dart';
import './widgets/filter_chip_widget.dart';
import './widgets/log_entry_card.dart';
import './widgets/search_overlay_widget.dart';
import './widgets/skeleton_log_card.dart';

class ActivityLogsScreen extends StatefulWidget {
  const ActivityLogsScreen({Key? key}) : super(key: key);

  @override
  State<ActivityLogsScreen> createState() => _ActivityLogsScreenState();
}

class _ActivityLogsScreenState extends State<ActivityLogsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _showSearchOverlay = false;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};

  // Mock data for activity logs
  final List<Map<String, dynamic>> _allLogs = [
    {
      "id": 1,
      "deviceName": "Living Room Light",
      "deviceType": "light",
      "action": "Turned on via mobile app",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(minutes: 30)),
      "user": "John Doe",
    },
    {
      "id": 2,
      "deviceName": "Bedroom Fan",
      "deviceType": "fan",
      "action": "Turned off automatically (scheduled)",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(hours: 2)),
      "user": "System",
    },
    {
      "id": 3,
      "deviceName": "Kitchen AC",
      "deviceType": "ac",
      "action": "Temperature set to 22°C",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(hours: 4)),
      "user": "Jane Smith",
    },
    {
      "id": 4,
      "deviceName": "Front Door Lock",
      "deviceType": "door",
      "action": "Failed to unlock - connection timeout",
      "status": "failed",
      "timestamp": DateTime.now().subtract(Duration(hours: 6)),
      "user": "John Doe",
    },
    {
      "id": 5,
      "deviceName": "Security Camera",
      "deviceType": "camera",
      "action": "Motion detection activated",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(hours: 8)),
      "user": "System",
    },
    {
      "id": 6,
      "deviceName": "Living Room Thermostat",
      "deviceType": "thermostat",
      "action": "Schedule updated for weekend",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(days: 1, hours: 2)),
      "user": "Jane Smith",
    },
    {
      "id": 7,
      "deviceName": "Garage Light",
      "deviceType": "light",
      "action": "Turned on via voice command",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(days: 1, hours: 5)),
      "user": "John Doe",
    },
    {
      "id": 8,
      "deviceName": "Bedroom AC",
      "deviceType": "ac",
      "action": "Failed to start - device offline",
      "status": "failed",
      "timestamp": DateTime.now().subtract(Duration(days: 2, hours: 1)),
      "user": "System",
    },
    {
      "id": 9,
      "deviceName": "Kitchen Light",
      "deviceType": "light",
      "action": "Dimmed to 50% brightness",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(days: 2, hours: 3)),
      "user": "Guest",
    },
    {
      "id": 10,
      "deviceName": "Patio Fan",
      "deviceType": "fan",
      "action": "Speed adjusted to medium",
      "status": "success",
      "timestamp": DateTime.now().subtract(Duration(days: 3, hours: 2)),
      "user": "Jane Smith",
    },
  ];

  List<Map<String, dynamic>> _filteredLogs = [];
  int _currentPage = 0;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _filteredLogs = List.from(_allLogs);
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _isLoading = false;
      _currentPage = 0;
    });
  }

  Future<void> _loadMoreData() async {
    if (_isLoadingMore ||
        _filteredLogs.length <= (_currentPage + 1) * _pageSize) return;

    setState(() => _isLoadingMore = true);

    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _isLoadingMore = false;
      _currentPage++;
    });
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);

    // Simulate refresh
    await Future.delayed(Duration(milliseconds: 1000));

    setState(() {
      _isLoading = false;
      _currentPage = 0;
      _filteredLogs = List.from(_allLogs);
    });
  }

  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
      _showSearchOverlay = false;
    });
    _applyFilters();
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_allLogs);

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((log) {
        final deviceName = (log['deviceName'] as String? ?? '').toLowerCase();
        final action = (log['action'] as String? ?? '').toLowerCase();
        final query = _searchQuery.toLowerCase();

        if (query == 'today') {
          final logDate = log['timestamp'] as DateTime? ?? DateTime.now();
          return DateTime.now().difference(logDate).inDays == 0;
        } else if (query == 'yesterday') {
          final logDate = log['timestamp'] as DateTime? ?? DateTime.now();
          return DateTime.now().difference(logDate).inDays == 1;
        }

        return deviceName.contains(query) || action.contains(query);
      }).toList();
    }

    // Apply other filters
    if (_activeFilters['deviceType'] != null &&
        _activeFilters['deviceType'] != 'All Devices') {
      filtered = filtered
          .where((log) =>
              (log['deviceType'] as String? ?? '').toLowerCase() ==
              (_activeFilters['deviceType'] as String).toLowerCase())
          .toList();
    }

    if (_activeFilters['status'] != null &&
        _activeFilters['status'] != 'All Status') {
      filtered = filtered
          .where((log) =>
              (log['status'] as String? ?? '').toLowerCase() ==
              (_activeFilters['status'] as String).toLowerCase())
          .toList();
    }

    if (_activeFilters['dateRange'] != null) {
      final dateRange = _activeFilters['dateRange'] as DateTimeRange;
      filtered = filtered.where((log) {
        final logDate = log['timestamp'] as DateTime? ?? DateTime.now();
        return logDate.isAfter(dateRange.start.subtract(Duration(days: 1))) &&
            logDate.isBefore(dateRange.end.add(Duration(days: 1)));
      }).toList();
    }

    setState(() {
      _filteredLogs = filtered;
      _currentPage = 0;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() => _activeFilters = filters);
          _applyFilters();
        },
      ),
    );
  }

  Future<void> _exportLogs() async {
    try {
      final csvContent = _generateCSV(_filteredLogs);
      final fileName =
          'activity_logs_${DateTime.now().millisecondsSinceEpoch}.csv';

      if (kIsWeb) {
        final bytes = utf8.encode(csvContent);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute("download", fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // For mobile platforms, you would typically use path_provider
        // This is a simplified version
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export functionality available on web platform'),
            backgroundColor: AppTheme.warningLight,
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logs exported successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export logs'),
          backgroundColor: AppTheme.lightTheme.colorScheme.error,
        ),
      );
    }
  }

  String _generateCSV(List<Map<String, dynamic>> logs) {
    final buffer = StringBuffer();
    buffer.writeln('Device Name,Device Type,Action,Status,Timestamp,User');

    for (final log in logs) {
      final deviceName = log['deviceName'] ?? '';
      final deviceType = log['deviceType'] ?? '';
      final action = log['action'] ?? '';
      final status = log['status'] ?? '';
      final timestamp = log['timestamp']?.toString() ?? '';
      final user = log['user'] ?? '';

      buffer.writeln(
          '"$deviceName","$deviceType","$action","$status","$timestamp","$user"');
    }

    return buffer.toString();
  }

  void _shareLogEntry(Map<String, dynamic> log) {
    final deviceName = log['deviceName'] ?? 'Unknown Device';
    final action = log['action'] ?? 'Unknown Action';
    final timestamp = log['timestamp']?.toString() ?? 'Unknown Time';

    final shareText = 'Device: $deviceName\nAction: $action\nTime: $timestamp';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log entry copied to clipboard'),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
      ),
    );
  }

  void _reportIssue(Map<String, dynamic> log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Report Issue'),
        content: Text('Report an issue with this log entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Issue reported successfully'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                ),
              );
            },
            child: Text('Report'),
          ),
        ],
      ),
    );
  }

  void _viewDeviceDetails(Map<String, dynamic> log) {
    Navigator.pushNamed(context, '/device-control-detail-screen');
  }

  List<Map<String, dynamic>> get _displayedLogs {
    final endIndex = (_currentPage + 1) * _pageSize;
    return _filteredLogs.take(endIndex.clamp(0, _filteredLogs.length)).toList();
  }

  int get _activeFilterCount {
    int count = 0;
    if (_searchQuery.isNotEmpty) count++;
    if (_activeFilters['deviceType'] != null &&
        _activeFilters['deviceType'] != 'All Devices') count++;
    if (_activeFilters['status'] != null &&
        _activeFilters['status'] != 'All Status') count++;
    if (_activeFilters['dateRange'] != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.lightTheme.colorScheme.shadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Activity Logs',
                        style: AppTheme.lightTheme.textTheme.headlineSmall
                            ?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        onPressed: () =>
                            setState(() => _showSearchOverlay = true),
                        icon: CustomIconWidget(
                          iconName: 'search',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                      IconButton(
                        onPressed: _exportLogs,
                        icon: CustomIconWidget(
                          iconName: 'file_download',
                          color: AppTheme.lightTheme.colorScheme.onSurface,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ),

                // Filter Chips
                if (_activeFilterCount > 0 || _searchQuery.isNotEmpty)
                  Container(
                    height: 8.h,
                    padding: EdgeInsets.symmetric(vertical: 1.h),
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      children: [
                        if (_searchQuery.isNotEmpty)
                          FilterChipWidget(
                            label: 'Search: $_searchQuery',
                            count: 0,
                            isSelected: true,
                            onTap: () {},
                            onRemove: () {
                              setState(() => _searchQuery = '');
                              _applyFilters();
                            },
                          ),
                        if (_activeFilters['deviceType'] != null)
                          FilterChipWidget(
                            label: _activeFilters['deviceType'],
                            count: 0,
                            isSelected: true,
                            onTap: () {},
                            onRemove: () {
                              setState(
                                  () => _activeFilters.remove('deviceType'));
                              _applyFilters();
                            },
                          ),
                        if (_activeFilters['status'] != null)
                          FilterChipWidget(
                            label: _activeFilters['status'],
                            count: 0,
                            isSelected: true,
                            onTap: () {},
                            onRemove: () {
                              setState(() => _activeFilters.remove('status'));
                              _applyFilters();
                            },
                          ),
                        FilterChipWidget(
                          label: 'Filter',
                          count: _activeFilterCount,
                          isSelected: false,
                          onTap: _showFilterBottomSheet,
                        ),
                      ],
                    ),
                  ),

                // Content
                Expanded(
                  child: _isLoading
                      ? ListView.builder(
                          itemCount: 5,
                          itemBuilder: (context, index) => SkeletonLogCard(),
                        )
                      : _filteredLogs.isEmpty
                          ? EmptyStateWidget(
                              title: _searchQuery.isNotEmpty
                                  ? 'No Results Found'
                                  : 'No Activity Logs',
                              subtitle: _searchQuery.isNotEmpty
                                  ? 'Try adjusting your search terms or filters'
                                  : 'Your device activity will appear here once you start using your smart home devices',
                              actionText: _searchQuery.isNotEmpty
                                  ? 'Clear Search'
                                  : 'Go to Dashboard',
                              isSearchResult: _searchQuery.isNotEmpty,
                              onAction: () {
                                if (_searchQuery.isNotEmpty) {
                                  setState(() {
                                    _searchQuery = '';
                                    _activeFilters.clear();
                                  });
                                  _applyFilters();
                                } else {
                                  Navigator.pushNamed(
                                      context, '/device-dashboard');
                                }
                              },
                            )
                          : RefreshIndicator(
                              onRefresh: _refreshData,
                              color: AppTheme.lightTheme.colorScheme.secondary,
                              child: ListView.builder(
                                controller: _scrollController,
                                itemCount: _displayedLogs.length +
                                    (_isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == _displayedLogs.length) {
                                    return Padding(
                                      padding: EdgeInsets.all(4.w),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: AppTheme
                                              .lightTheme.colorScheme.secondary,
                                        ),
                                      ),
                                    );
                                  }

                                  final log = _displayedLogs[index];
                                  return LogEntryCard(
                                    logEntry: log,
                                    onShare: () => _shareLogEntry(log),
                                    onReport: () => _reportIssue(log),
                                    onViewDevice: () => _viewDeviceDetails(log),
                                  );
                                },
                              ),
                            ),
                ),
              ],
            ),
          ),

          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.pushNamed(context, '/device-dashboard');
                      break;
                    case 1:
                      Navigator.pushNamed(
                          context, '/device-control-detail-screen');
                      break;
                    case 2:
                      // Current screen - Activity Logs
                      break;
                    case 3:
                      Navigator.pushNamed(context, '/settings-screen');
                      break;
                  }
                },
                tabs: [
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'dashboard',
                      color: _tabController.index == 0
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    text: 'Dashboard',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'tune',
                      color: _tabController.index == 1
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    text: 'Control',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'history',
                      color: _tabController.index == 2
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    text: 'Logs',
                  ),
                  Tab(
                    icon: CustomIconWidget(
                      iconName: 'settings',
                      color: _tabController.index == 3
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      size: 24,
                    ),
                    text: 'Settings',
                  ),
                ],
              ),
            ),
          ),

          // Search Overlay
          if (_showSearchOverlay)
            SearchOverlayWidget(
              initialQuery: _searchQuery,
              onSearch: _performSearch,
              onClose: () => setState(() => _showSearchOverlay = false),
            ),
        ],
      ),
    );
  }
}