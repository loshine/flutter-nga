package xyz.loshine.flutternga.plugins

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import java.nio.charset.Charset

class FlutterGbkPlugin : MethodChannel.MethodCallHandler {

    companion object {

        const val CHANNEL = "xyz.loshine.flutternga.gbk/plugin"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterGbkPlugin()
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "decode" -> {
                val byteArray = call.argument<ByteArray>("bytes") ?: byteArrayOf()
                val string = String(byteArray, Charset.forName("gbk"))
                // 返回给 flutter 的参数
                result.success(string)
            }
            else -> result.notImplemented()
        }
    }

}