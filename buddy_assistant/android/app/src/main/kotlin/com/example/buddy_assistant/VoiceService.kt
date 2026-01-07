package com.example.buddy_assistant

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import org.vosk.Model
import org.vosk.Recognizer
import org.vosk.android.RecognitionListener
import org.vosk.android.SpeechService
import org.vosk.android.StorageService
import java.io.IOException

class VoiceService : Service(), RecognitionListener {

    private var speechService: SpeechService? = null
    private var model: Model? = null
    private val CHANNEL_ID = "BuddyVoiceService"

    override fun onCreate() {
        super.onCreate()
         // Load model async
        StorageService.unpack(this, "model-en-us", "model",
            { model: Model ->
                this.model = model
                startRecognition()
            },
            { exception: IOException ->
                // Handle error - maybe notify user via broadcast
            }
        )
    }

    private fun startRecognition() {
        if (model == null) return
        
        // Wake-word only grammar initially to save battery/cpu? 
        // Vosk grammar: recognizer.setGrammar("[\"hey buddy\", \"[unk]\"]")
        // For now, full recognition is safer for "hey buddy call mom" one-shots.
        
        val recognizer = Recognizer(model, 16000.0f)
        speechService = SpeechService(recognizer, 16000.0f)
        speechService?.addListener(this)
        speechService?.startListening()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        createNotificationChannel()
        
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Buddy is Listening")
            .setContentText("Say 'Hey Buddy'...")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)
        
        // Ensure we are listening
        if (speechService != null) {
            speechService?.startListening()
        }
        
        return START_STICKY
    }
    
    // Vosk Callbacks
    override fun onResult(hypothesis: String) {
        // hypothesis is JSON: {"text": "..."}
        // We parse manually to avoid dependencies like Gson
        val text = parseVoskJson(hypothesis)
        if (text.isNotEmpty()) {
            handleVoiceCommand(text)
        }
    }

    override fun onPartialResult(hypothesis: String) {
        // Used for faster wake-word detection if needed
        val text = parseVoskJson(hypothesis)
        if (text.contains("hey buddy")) {
            // Wake word detected potentially
        }
    }

    override fun onFinalResult(hypothesis: String) {
         val text = parseVoskJson(hypothesis)
        if (text.isNotEmpty()) {
            handleVoiceCommand(text)
        }
    }

    override fun onError(exception: Exception) {
        // Restart?
    }

    override fun onTimeout() {
        // Restart?
    }
    
    private fun parseVoskJson(json: String): String {
        // Simple string manipulation to extract "text" value
        // Pattern: "text" : "value"
        val start = json.indexOf(": \"")
        if (start == -1) return ""
        val end = json.indexOf("\"", start + 3)
        if (end == -1) return ""
        return json.substring(start + 3, end)
    }

    private fun handleVoiceCommand(text: String) {
        if (text.contains("hey buddy")) {
            // Wake word detected!
            // Forward to Flutter via broadcast or launch activity
            sendBroadcastToFlutter(text)
            
            // Or Launch Activity if it's a critical command
            bringAppToFront()
        }
    }

    private fun sendBroadcastToFlutter(text: String) {
        // Note: Standard Broadcasts don't reach Flutter easily without a Receiver in Flutter.
        // It's easier to just launch the activity which will connect the engine.
    }
    
    private fun bringAppToFront() {
        val intent = Intent(this, MainActivity::class.java)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        intent.addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP) // Don't recreate if top
        // Pass the command
        startActivity(intent)
        
        // Wait, passing data to already running activity?
        // MethodChannel "com.example.buddy.event" can be invoked if engine is running?
        // Only if we bind to the activity's engine.
        // For simplicity: We launch activity. The activity (in onResume or distinct intent) handles it.
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Buddy Foreground Service",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }
    
    override fun onDestroy() {
        super.onDestroy()
        speechService?.stop()
        speechService?.shutdown()
    }
}
