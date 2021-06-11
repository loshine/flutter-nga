package io.github.loshine.flutternga.plugins.login

import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.launch

object CookiesEventHandler {

    private val job = Job()
    private val coroutineScope = CoroutineScope(Dispatchers.Main + job)
    private val channel = Channel<String>()

    fun init(eventSink: EventChannel.EventSink) {
        coroutineScope.launch {
            for (message in channel) {
                eventSink.success(message)
            }
        }
    }

    fun dispose() {
        channel.cancel()
        job.cancel()
    }

    fun onCookiesChanges(cookies: String) {
        coroutineScope.launch { channel.send(cookies) }
    }
}