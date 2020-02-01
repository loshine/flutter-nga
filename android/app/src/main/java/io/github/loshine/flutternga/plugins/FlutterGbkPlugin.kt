package io.github.loshine.flutternga.plugins

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.net.URLDecoder
import java.net.URLEncoder

class FlutterGbkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {

        const val CHANNEL = "io.github.loshine.flutternga.gbk/plugin"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterGbkPlugin()
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
        }
    }

    private var channel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "urlDecode" -> {
                val content: String = call.argument("content") ?: ""
                val string = URLDecoder.decode(content, "gbk")
                result.success(string)
            }
            "urlEncode" -> {
                val content: String = call.argument("content") ?: ""
                val string = URLEncoder.encode(content, "gbk")
                result.success(string)
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}