package xyz.loshine.flutternga.receiver

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.EventChannel

class CookiesReceiver(private val events: EventChannel.EventSink) : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val cookies = intent.getStringExtra("cookies")
        events.success(cookies)
    }

}