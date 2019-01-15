package xyz.loshine.flutternga.plugins

import android.app.Activity
import android.content.IntentFilter
import android.support.v4.content.LocalBroadcastManager
import android.util.Log
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.PluginRegistry
import xyz.loshine.flutternga.receiver.CookiesReceiver

class FlutterCookiesPlugin(private val activity: Activity) : EventChannel.StreamHandler {

    companion object {
        const val CHANNEL = "xyz.loshine.flutternga.cookies/plugin"
        const val FILTER = "xyz.loshine.flutternga.cookies"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = EventChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterCookiesPlugin(registrar.activity())
            channel.setStreamHandler(instance)
        }
    }

    private var receiver: CookiesReceiver? = null

    override fun onListen(any: Any?, eventSink: EventChannel.EventSink) {
        receiver = CookiesReceiver(eventSink)
        receiver?.let {
            LocalBroadcastManager.getInstance(activity).registerReceiver(it, IntentFilter(FILTER))
        }
    }

    override fun onCancel(any: Any?) {
        Log.i("FlutterCookiesPlugin", "FlutterCookiesPlugin:onCancel")
        activity.unregisterReceiver(receiver)
        receiver?.let {
            LocalBroadcastManager.getInstance(activity).unregisterReceiver(it)
        }
        receiver = null
    }
}