package io.github.loshine.flutternga.plugins.login

import android.app.Activity
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.github.loshine.flutternga.ui.LoginActivity
import java.lang.ref.WeakReference


class FlutterLoginPlugin : MethodChannel.MethodCallHandler, ActivityAware {

    companion object {

        const val CHANNEL = "io.github.loshine.flutternga.login/plugin"

        fun registerWith(flutterEngine: FlutterEngine, activity: Activity) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            val instance = FlutterLoginPlugin()
            // setMethodCallHandler在此通道上接收方法调用的回调
            channel.setMethodCallHandler(instance)
            instance.activityRef = WeakReference(activity)
        }
    }

    private var activityRef: WeakReference<Activity>? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // 通过 MethodCall 可以获取参数和方法名
        when (call.method) {
            "start_login" -> {
                Log.d("activity", "$activityRef")
                activityRef?.get()?.let {
                    // 跳转到登录页
                    val intent = Intent(it, LoginActivity::class.java)
                    it.startActivity(intent)
                    // 返回给 flutter 的参数
                    result.success("success")
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityRef = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityRef = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityRef = WeakReference(binding.activity)
    }

    override fun onDetachedFromActivity() {
        activityRef = null
    }
}
