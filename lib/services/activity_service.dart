import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class ActivityService {
  static ActivityService? _instance;
  static ActivityService get instance => _instance ??= ActivityService._();

  ActivityService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get user activity logs
  Future<List<Map<String, dynamic>>> getUserActivityLogs({
    int limit = 50,
    int offset = 0,
    String? activityType,
    String? deviceId,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _client
          .from('activity_logs')
          .select('*, devices(name, device_type)')
          .eq('user_id', user.id);

      if (activityType != null) {
        query = query.eq('activity_type', activityType);
      }

      if (deviceId != null) {
        query = query.eq('device_id', deviceId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch activity logs: $error');
    }
  }

  // Get activity logs count
  Future<int> getActivityLogsCount({
    String? activityType,
    String? deviceId,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _client.from('activity_logs').select().eq('user_id', user.id);

      if (activityType != null) {
        query = query.eq('activity_type', activityType);
      }

      if (deviceId != null) {
        query = query.eq('device_id', deviceId);
      }

      final response = await query.count();
      return response.count ?? 0;
    } catch (error) {
      throw Exception('Failed to get activity count: $error');
    }
  }

  // Get activity statistics
  Future<Map<String, dynamic>> getActivityStatistics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      var query = _client.from('activity_logs').select().eq('user_id', user.id);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final allActivities = await query;

      final stats = <String, int>{};
      int totalActivities = 0;

      for (final activity in allActivities) {
        final type = activity['activity_type'] as String;
        stats[type] = (stats[type] ?? 0) + 1;
        totalActivities++;
      }

      return {
        'total_activities': totalActivities,
        'activity_breakdown': stats,
        'period_start': startDate?.toIso8601String(),
        'period_end': endDate?.toIso8601String(),
      };
    } catch (error) {
      throw Exception('Failed to get activity statistics: $error');
    }
  }

  // Log user activity
  Future<void> logUserActivity({
    required String activityType,
    required String description,
    String? deviceId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) return;

      await _client.from('activity_logs').insert({
        'user_id': user.id,
        'device_id': deviceId,
        'activity_type': activityType,
        'description': description,
        'metadata': metadata ?? {},
      });
    } catch (error) {
      print('Failed to log user activity: $error');
    }
  }

  // Subscribe to activity changes
  RealtimeChannel subscribeToActivityLogs(
      void Function(Map<String, dynamic>) onActivityChange) {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _client
        .channel('public:activity_logs')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'activity_logs',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => onActivityChange(payload.newRecord),
        )
        .subscribe();
  }
}
