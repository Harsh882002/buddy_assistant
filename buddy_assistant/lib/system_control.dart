import 'package:flutter/services.dart';
import 'debug_logger.dart';

class SystemControl {
  static const MethodChannel _channel = MethodChannel('com.example.buddy.control');

  static Future<void> toggleFlashlight(bool on) async {
    try {
      await _channel.invokeMethod('toggleFlashlight', {'on': on});
      DebugLogger().log("Flashlight ${on ? 'ON' : 'OFF'}");
    } catch (e) {
      DebugLogger().log("Error toggling flashlight: $e");
    }
  }

  static Future<void> makeCall(String number) async {
    try {
      await _channel.invokeMethod('makeCall', {'number': number});
      DebugLogger().log("Calling $number");
    } catch (e) {
      DebugLogger().log("Error making call: $e");
    }
  }

  static Future<void> sendSMS(String number, String message) async {
    try {
      await _channel.invokeMethod('sendSMS', {'number': number, 'message': message});
      DebugLogger().log("Sent SMS to $number");
    } catch (e) {
      DebugLogger().log("Error sending SMS: $e");
    }
  }
  
  static Future<void> launchApp(String packageName) async {
     try {
      await _channel.invokeMethod('launchApp', {'packageName': packageName});
      DebugLogger().log("Launching $packageName");
    } catch (e) {
      DebugLogger().log("Error launching app: $e");
    }
  }

  static Future<void> setVolume(int level) async {
    // level: 0-100
     try {
      await _channel.invokeMethod('setVolume', {'level': level});
    } catch (e) {
      DebugLogger().log("Error setting volume: $e");
    }
  }
  
  static Future<void> startService() async {
    try {
      await _channel.invokeMethod('startVoiceService');
      DebugLogger().log("Requested Service Start");
    } catch (e) {
       DebugLogger().log("Error starting service: $e");
    }
  }
  
  static Future<void> speak(String text) async {
     try {
      await _channel.invokeMethod('speak', {'text': text});
      DebugLogger().log("Speaking: $text");
    } catch (e) {
      DebugLogger().log("TTS Error: $e");
    }
  }
}
