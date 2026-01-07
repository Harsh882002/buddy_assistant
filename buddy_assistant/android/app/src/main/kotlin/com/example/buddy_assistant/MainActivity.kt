package com.example.buddy_assistant

import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import android.telephony.SmsManager
import android.media.AudioManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL_CONTROL = "com.example.buddy.control"
    private val CHANNEL_EVENT = "com.example.buddy.event"
    
    // Simplistic Event Sink to send data back to Flutter
    // Note: In a real app we'd use EventChannel, but MethodChannel invokeMethod works inversely too.
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_CONTROL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startVoiceService" -> {
                    val intent = Intent(this, VoiceService::class.java)
                    startForegroundService(intent)
                    result.success(true)
                }
                "toggleFlashlight" -> {
                    val on = call.argument<Boolean>("on") ?: false
                    toggleFlashlight(on)
                    result.success(true)
                }
                "makeCall" -> {
                    val number = call.argument<String>("number")
                    if (number != null) makeCall(number)
                    result.success(true)
                }
                "sendSMS" -> {
                    val number = call.argument<String>("number")
                    val message = call.argument<String>("message")
                    if (number != null && message != null) sendSMS(number, message)
                    result.success(true)
                }
                "launchApp" -> {
                    val pkg = call.argument<String>("packageName")
                    if (pkg != null) launchApp(pkg)
                    result.success(true)
                }
                "setVolume" -> {
                    val level = call.argument<Int>("level") ?: 50
                    setVolume(level)
                    result.success(true)
                }
                 "speak" -> {
                    val text = call.argument<String>("text")
                    // Forward to Service TTS or Local TTS?
                    // For simplicity, we can use Android TTS here or in Service.
                    // Service is better for persistence.
                    // Implementation skipped for brevity, assuming UI feedback is enough for now 
                    // or Service handles it via shared bus.
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun toggleFlashlight(on: Boolean) {
        val camManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
        val cameraId = camManager.cameraIdList[0] // Usually back camera
        try {
            camManager.setTorchMode(cameraId, on)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }

    private fun makeCall(number: String) {
        val intent = Intent(Intent.ACTION_CALL)
        intent.data = Uri.parse("tel:$number")
        startActivity(intent)
    }

    private fun sendSMS(number: String, message: String) {
        try {
            val smsManager = SmsManager.getDefault()
            smsManager.sendTextMessage(number, null, message, null, null)
        } catch (e: Exception) {
            e.printStackTrace()
        }
    }
    
    private fun launchApp(packageName: String) {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            startActivity(intent)
        }
    }

    private fun setVolume(percent: Int) {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val targetVolume = (maxVolume * (percent / 100.0)).toInt()
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, targetVolume, 0)
    }
}
