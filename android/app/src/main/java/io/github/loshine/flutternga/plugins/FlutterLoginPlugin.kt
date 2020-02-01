package io.github.loshine.flutternga.plugins

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import io.github.loshine.flutternga.ui.LoginActivity


class FlutterLoginPlugin
constructor(private val activity: Activity) : FlutterPlugin, MethodChannel.MethodCallHandler {

    companion object {

        const val CHANNEL = "io.github.loshine.flutternga.login/plugin"

        fun registerWith(registrar: PluginRegistry.Registrar) {
            val channel = MethodChannel(registrar.messenger(), CHANNEL)
            val instance = FlutterLoginPlugin(registrar.activity())
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
        }
    }

    private var channel: MethodChannel? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "start_login" -> {
                // 跳转到登录页
                val intent = Intent(activity, LoginActivity::class.java)
                activity.startActivity(intent)
                // 返回给 flutter 的参数
                result.success("success")
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL)
        // setMethodCallHandler在此通道上接收方法调用的回调
        channel?.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel?.setMethodCallHandler(null)
        channel = null
    }
}
