package xyz.loshine.flutternga.plugins

import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry
import xyz.loshine.flutternga.event.CookiesEventHandler

class FlutterCookiesPlugin : EventChannel.StreamHandler {

    companion object {
        const val CHANNEL = "xyz.loshine.flutternga.cookies/plugin"
        const val FILTER = "xyz.loshine.flutternga.cookies"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = EventChannel(registrar.messenger(), CHANNEL)
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