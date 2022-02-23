package io.github.loshine.flutternga.plugins.login

import io.flutter.plugin.common.EventChannel
import kotlinx.coroutines.*
import kotlinx.coroutines.channels.Channel

object CookiesEventHandler {

    private val coroutineScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private val channel = Channel<String>()

    private var job: Job? = null

    fun init(eventSink: EventChannel.EventSink) {
        job = coroutineScope.launch {
            for (message in channel) {
                eventSink.success(message)
            }
        }
    }

    fun dispose() {
//        channel.cancel()
        job?.cancel()
    }

    fun onCookiesChanges(cookies: String) {
        coroutineScope.launch { channel.send(cookies) }
    }
}