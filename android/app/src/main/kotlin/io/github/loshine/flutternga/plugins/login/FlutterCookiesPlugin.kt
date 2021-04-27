package io.github.loshine.flutternga.plugins.login

import android.util.Log
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.lifecycleScope
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel

class FlutterCookiesPlugin(lifecycleOwner: LifecycleOwner) : FlutterPlugin, EventChannel.StreamHandler {

    companion object {
        const val CHANNEL = "io.github.loshine.flutternga.cookies/plugin"
        const val FILTER = "io.github.loshine.flutternga.cookies"

        fun registerWith(flutterEngine: FlutterEngine, lifecycleOwner: LifecycleOwner) {
            val channel = EventChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val instance = FlutterCookiesPlugin(lifecycleOwner)
            channel.setStreamHandler(instance)
        }
    }

    private val coroutineScope = lifecycleOwner.lifecycleScope
    private var channel: EventChannel? = null

    override fun onListen(any: Any?, eventSink: EventChannel.EventSink) {
        CookiesEventHandler.init(eventSink, coroutineScope)
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