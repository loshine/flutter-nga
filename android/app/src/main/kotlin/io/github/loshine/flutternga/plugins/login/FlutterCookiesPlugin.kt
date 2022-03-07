package io.github.loshine.flutternga.plugins.login

import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel

class FlutterCookiesPlugin : EventChannel.StreamHandler {

    companion object {
        const val CHANNEL = "io.github.loshine.flutternga.cookies/plugin"

        fun registerWith(flutterEngine: FlutterEngine) {
            val channel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val instance = FlutterCookiesPlugin()
            channel.setStreamHandler(instance)
        }
    }

    override fun onListen(any: Any?, eventSink: EventChannel.EventSink) {
        CookiesEventHandler.init(eventSink)
    }

    override fun onCancel(any: Any?) {
        Log.i("FlutterCookiesPlugin", "FlutterCookiesPlugin:onCancel")
        CookiesEventHandler.dispose()
    }
}