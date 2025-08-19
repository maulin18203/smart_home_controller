import 'package:flutter/material.dart';
import '../presentation/device_control_detail_screen/device_control_detail_screen.dart';
import '../presentation/device_dashboard/device_dashboard.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/activity_logs_screen/activity_logs_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String deviceControlDetail = '/device-control-detail-screen';
  static const String deviceDashboard = '/device-dashboard';
  static const String splash = '/splash-screen';
  static const String settings = '/settings-screen';
  static const String login = '/login-screen';
  static const String activityLogs = '/activity-logs-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    deviceControlDetail: (context) => const DeviceControlDetailScreen(),
    deviceDashboard: (context) => const DeviceDashboard(),
    splash: (context) => const SplashScreen(),
    settings: (context) => const SettingsScreen(),
    login: (context) => const LoginScreen(),
    activityLogs: (context) => const ActivityLogsScreen(),
    // TODO: Add your other routes here
  };
}
