import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'debug_logger.dart';

class GeminiService {
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  GeminiService._internal();

  GenerativeModel? _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  Future<void> init() async {
    try {
      final configString = await rootBundle.loadString('assets/buddy_config.json');
      final Map<String, dynamic> config = json.decode(configString);
      final String? apiKey = config['gemini_api_key'];

      if (apiKey != null && apiKey != "YOUR_API_KEY_HERE" && apiKey.isNotEmpty) {
        _model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
        _chat = _model!.startChat();
        _isInitialized = true;
        DebugLogger().log("Gemini AI Initialized");
      } else {
        DebugLogger().log("Gemini API Key missing in config");
      }
    } catch (e) {
      DebugLogger().log("Gemini Init Error: $e");
    }
  }

  Future<String?> askAI(String prompt) async {
    if (!_isInitialized || _chat == null) {
      return "I'm not connected to the AI brain yet. Please check your API key.";
    }

    try {
      DebugLogger().log("Asking Gemini: $prompt");
      final response = await _chat!.sendMessage(Content.text(prompt));
      final text = response.text;
      
      if (text != null) {
        // Cleanup response for TTS (remove markdown, etc if needed)
        // For now, raw text is fine
        return text;
      }
      return "I didn't get a response.";
    } catch (e) {
      DebugLogger().log("Gemini Error: $e");
      return "I had trouble thinking. Ask me later.";
    }
  }
}
