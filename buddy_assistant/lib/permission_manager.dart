import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'debug_logger.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.phone,
      Permission.sms,
      Permission.notification,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        DebugLogger().log("Permission denied: $permission");
        allGranted = false;
      }
    });
    
    // Battery Optimizations (Separate flow)
    await requestBatteryExemption();

    return allGranted;
  }

  Future<void> requestBatteryExemption() async {
    // We cannot directly request this permission via standard dialogs on some versions,
    // but we can check and ask strictly if needed.
    // For now, we try to ignore it if possible.
    if (await Permission.ignoreBatteryOptimizations.isDenied) {
      DebugLogger().log("Requesting battery exemption...");
      await Permission.ignoreBatteryOptimizations.request();
    }
  }

  /// Check if we have what we need to run services
  Future<bool> hasCriticalPermissions() async {
    return await Permission.microphone.isGranted && 
           await Permission.notification.isGranted;
  }
}
