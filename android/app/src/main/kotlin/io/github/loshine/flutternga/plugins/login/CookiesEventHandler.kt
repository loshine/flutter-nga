package io.github.loshine.flutternga.plugins.login

import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.LifecycleCoroutineScope
import androidx.lifecycle.lifecycleScope
import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch

object CookiesEventHandler {

    private val channel = Channel<String>()

    fun init(eventSink: EventChannel.EventSink, coroutineScope: LifecycleCoroutineScope) {
        coroutineScope.launch {
            for (message in channel) {
                eventSink.success(message)
            }
        }
    }

    fun dispose() {
        channel.cancel()
    }

    fun onCookiesChanges(activity: AppCompatActivity, cookies: String) {
        activity.lifecycleScope.launch { channel.send(cookies) }
    }
}