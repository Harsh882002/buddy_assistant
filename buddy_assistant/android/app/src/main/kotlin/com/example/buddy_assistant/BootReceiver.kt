package com.example.buddy_assistant

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.example.buddy_assistant.VoiceService

class BootReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            val serviceIntent = Intent(context, VoiceService::class.java)
            context.startForegroundService(serviceIntent)
        }
    }
}
