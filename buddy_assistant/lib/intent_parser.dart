import 'system_control.dart';
import 'debug_logger.dart';
import 'gemini_service.dart';

class IntentParser {
  // Context memory
  String? _lastContact;
  String? _lastApp;

  // Hardcoded contacts for demo (loaded from config in real app)
  final Map<String, String> _contacts = {
    'bhai': '7499319699',
    'papa': '5555678',
    'emergency': '100'
  };

  void process(String text) {
    String input = text.toLowerCase().trim();
    DebugLogger().log("Processing: $input");

    if (input.isEmpty) return;

    if (input.contains("flashlight on")) {
      SystemControl.toggleFlashlight(true);
      SystemControl.speak("Flashlight on");
    } 
    else if (input.contains("flashlight off")) {
      SystemControl.toggleFlashlight(false);
      SystemControl.speak("Flashlight off");
    }
    else if (input.startsWith("call")) {
      _handleCall(input);
    }
    else if (input.contains("open")) {
      _handleAppLaunch(input);
    }
    else if (input.contains("time")) {
       final time = DateTime.now();
       SystemControl.speak("It is ${time.hour}:${time.minute}");
    }
    else {
      DebugLogger().log("Unknown intent: $input");
      _handleAIFallback(input);
    }
  }

  Future<void> _handleAIFallback(String input) async {
    SystemControl.speak("Let me think...");
    final response = await GeminiService().askAI(input);
    if (response != null) {
      DebugLogger().log("AI Response: $response");
      SystemControl.speak(response);
    }
  }

  void _handleCall(String input) {
    // "Call mom"
    String? name;
    for (var contact in _contacts.keys) {
      if (input.contains(contact)) {
        name = contact;
        break;
      }
    }

    if (name != null) {
      _lastContact = _contacts[name];
      SystemControl.makeCall(_lastContact!);
      SystemControl.speak("Calling $name");
    } else {
      SystemControl.speak("Who do you want to call?");
    }
  }

  void _handleAppLaunch(String input) {
    // Very basic mapping
    if (input.contains("spotify")) {
      SystemControl.launchApp("com.spotify.music");
    } else if (input.contains("youtube")) {
      SystemControl.launchApp("com.google.android.youtube");
    } 
     else if (input.contains("whatsapp")) {
      SystemControl.launchApp("com.whatsapp");
    }
  }
}
