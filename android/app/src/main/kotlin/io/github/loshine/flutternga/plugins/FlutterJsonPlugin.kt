package io.github.loshine.flutternga.plugins

import com.google.gson.Gson
import com.google.gson.JsonObject
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class FlutterJsonPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {

        const val CHANNEL = "io.github.loshine.flutternga.json/plugin"
        val gson = Gson()

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterJsonPlugin()
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
        }
    }

    private var channel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "decode" -> {
                try {
                    val jsonString = call.argument<String>("json")
                    val formattedJson = gson.toJson(gson.fromJson(jsonString, JsonObject::class.java))
                    // 返回给 flutter 的参数
                    result.success(formattedJson)
                } catch (e: Exception) {
                    result.error("Json Decode error", e.message, null)
                }
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