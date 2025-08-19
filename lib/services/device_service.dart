import 'package:supabase_flutter/supabase_flutter.dart';

import './auth_service.dart';
import './supabase_service.dart';

class DeviceService {
  static DeviceService? _instance;
  static DeviceService get instance => _instance ??= DeviceService._();

  DeviceService._();

  SupabaseClient get _client => SupabaseService.instance.client;

  // Get all user devices
  Future<List<Map<String, dynamic>>> getUserDevices() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('devices')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch devices: $error');
    }
  }

  // Get device by ID
  Future<Map<String, dynamic>?> getDevice(String deviceId) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client
          .from('devices')
          .select()
          .eq('id', deviceId)
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch device: $error');
    }
  }

  // Add new device
  Future<Map<String, dynamic>> addDevice({
    required String name,
    required String deviceType,
    String? location,
    Map<String, dynamic>? metadata,
    String? deviceIdentifier,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final deviceData = {
        'user_id': user.id,
        'name': name,
        'device_type': deviceType,
        'location': location,
        'metadata': metadata ?? {},
        'device_identifier': deviceIdentifier,
        'status': 'offline',
        'state': false,
      };

      final response =
          await _client.from('devices').insert(deviceData).select().single();

      // Log activity
      await _logActivity(
        deviceId: response['id'],
        activityType: 'device_add',
        description: '$name added to smart home',
      );

      return response;
    } catch (error) {
      throw Exception('Failed to add device: $error');
    }
  }

  // Toggle device state
  Future<void> toggleDevice(String deviceId, bool newState) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get current device state
      final currentDevice = await getDevice(deviceId);
      if (currentDevice == null) throw Exception('Device not found');

      // Update device
      await _client
          .from('devices')
          .update({
            'state': newState,
            'last_activity': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', deviceId)
          .eq('user_id', user.id);

      // Log activity
      await _logActivity(
        deviceId: deviceId,
        activityType: 'device_toggle',
        description:
            '${currentDevice['name']} turned ${newState ? 'ON' : 'OFF'}',
        metadata: {
          'previous_state': currentDevice['state'],
          'new_state': newState,
        },
      );
    } catch (error) {
      throw Exception('Failed to toggle device: $error');
    }
  }

  // Update device
  Future<void> updateDevice(
    String deviceId, {
    String? name,
    String? location,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (location != null) updates['location'] = location;
      if (metadata != null) updates['metadata'] = metadata;
      updates['updated_at'] = DateTime.now().toIso8601String();

      await _client
          .from('devices')
          .update(updates)
          .eq('id', deviceId)
          .eq('user_id', user.id);

      if (name != null) {
        await _logActivity(
          deviceId: deviceId,
          activityType: 'device_rename',
          description: 'Device renamed to $name',
        );
      }
    } catch (error) {
      throw Exception('Failed to update device: $error');
    }
  }

  // Remove device
  Future<void> removeDevice(String deviceId) async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get device name for logging
      final device = await getDevice(deviceId);
      final deviceName = device?['name'] ?? 'Unknown Device';

      // Delete device
      await _client
          .from('devices')
          .delete()
          .eq('id', deviceId)
          .eq('user_id', user.id);

      // Log activity (device_id will be null since device is deleted)
      await _logActivity(
        activityType: 'device_remove',
        description: '$deviceName removed from smart home',
      );
    } catch (error) {
      throw Exception('Failed to remove device: $error');
    }
  }

  // Get device count by status
  Future<Map<String, int>> getDeviceStatusCount() async {
    try {
      final user = AuthService.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final allDevices = await getUserDevices();

      final statusCount = <String, int>{
        'online': 0,
        'offline': 0,
        'maintenance': 0,
        'error': 0,
      };

      for (final device in allDevices) {
        final status = device['status'] as String;
        statusCount[status] = (statusCount[status] ?? 0) + 1;
      }

      return statusCount;
    } catch (error) {
      throw Exception('Failed to get device status count: $error');
    }
  }

  // Subscribe to device changes
  RealtimeChannel subscribeToDevices(
      void Function(Map<String, dynamic>) onDeviceChange) {
    final user = AuthService.instance.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _client
        .channel('public:devices')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'devices',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: user.id,
          ),
          callback: (payload) => onDeviceChange(payload.newRecord),
        )
        .subscribe();
  }

  // Private method to log activities
  Future<void> _logActivity({
    String? deviceId,
    required String activityType,
    required String description,
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
      // Don't throw error for logging failures
      print('Failed to log activity: $error');
    }
  }
}
