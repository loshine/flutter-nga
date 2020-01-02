package xyz.loshine.flutternga.plugins

import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry
import xyz.loshine.flutternga.event.CookiesEventHandler

class FlutterCookiesPlugin : FlutterPlugin, EventChannel.StreamHandler {

    companion object {
        const val CHANNEL = "xyz.loshine.flutternga.cookies/plugin"
        const val FILTER = "xyz.loshine.flutternga.cookies"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = EventChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterCookiesPlugin()
            channel.setStreamHandler(instance)
        }
    }

    private var channel: EventChannel? = null

    override fun onListen(any: Any?, eventSink: EventChannel.EventSink) {
        CookiesEventHandler.init(eventSink)
    }

    override fun onCancel(any: Any?) {
        Log.i("FlutterCookiesPlugin", "FlutterCookiesPlugin:onCancel")
        CookiesEventHandler.dispose()
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = EventChannel(binding.binaryMessenger, CHANNEL)
        channel?.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setStreamHandler(null)
        channel = null
    }
}