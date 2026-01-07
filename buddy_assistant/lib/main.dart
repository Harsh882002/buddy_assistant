import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'permission_manager.dart';
import 'debug_logger.dart';
import 'system_control.dart';
import 'intent_parser.dart';
import 'model_validator.dart';
import 'gemini_service.dart';

void main() {
  runApp(const BuddyApp());
}

class BuddyApp extends StatelessWidget {
  const BuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Buddy',
      theme: ThemeData.dark(),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final IntentParser _intentParser = IntentParser();
  static const MethodChannel _voiceEventChannel = MethodChannel('com.example.buddy.event');

  bool _isServiceRunning = false;
  String _status = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initSequence();
    _setupEventChannel();
  }

  Future<void> _initSequence() async {
    setState(() => _status = "Checking Permissions...");
    bool permissionsGranted = await PermissionManager().requestAllPermissions();
    
    if (!permissionsGranted) {
      setState(() => _status = "Permissions missing!");
      return;
    }

    setState(() => _status = "Checking Model...");
    bool modelExists = await ModelValidator.checkModelExists();
    if (!modelExists) {
       DebugLogger().log("WARNING: Vosk model missing?");
    }

    await GeminiService().init();

    setState(() => _status = "Ready. Tap to Start.");
  }
  
  void _setupEventChannel() {
    _voiceEventChannel.setMethodCallHandler((call) async {
       switch (call.method) {
         case "onSpeechResult":
            final String text = call.arguments;
            DebugLogger().log("Heard: $text");
            _intentParser.process(text);
            break;
         case "onWakeWord":
            DebugLogger().log("Wake Word Detected!");
            // UI Visual feedback
            break;
       }
    });
  }

  Future<void> _startService() async {
    if (await PermissionManager().hasCriticalPermissions()) {
      await SystemControl.startService();
      setState(() => _isServiceRunning = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buddy Alpha")),
      body: Column(
        children: [
          StatusHeader(status: _status, isRunning: _isServiceRunning),
          Expanded(child: LogViewer()),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _startService, 
              icon: const Icon(Icons.mic), 
              label: const Text("Start Listening")
            ),
          )
        ],
      ),
    );
  }
}

class StatusHeader extends StatelessWidget {
  final String status;
  final bool isRunning;
  const StatusHeader({super.key, required this.status, required this.isRunning});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: isRunning ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
      width: double.infinity,
      child: Column(
        children: [
          Text(status, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          if (isRunning) ...[
             const SizedBox(height: 10),
             const Text("Listening for 'Hey Buddy'...", style: TextStyle(color: Colors.greenAccent))
          ]
        ],
      ),
    );
  }
}

class LogViewer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DebugLogger(),
      builder: (context, _) {
        final logs = DebugLogger().logs;
        return ListView.builder(
          itemCount: logs.length,
          itemBuilder: (ctx, i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            child: Text(logs[i], style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        );
      },
    );
  }
}
