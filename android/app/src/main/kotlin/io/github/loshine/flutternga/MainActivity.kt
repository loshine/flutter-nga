package io.github.loshine.flutternga

import android.app.UiModeManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            DYNAMIC_COLOR_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getAccentColor" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        result.success(getColor(android.R.color.system_accent1_500))
                    } else {
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            NATIVE_THEME_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setNightMode" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val mode = when (call.arguments as? String) {
                            "light" -> UiModeManager.MODE_NIGHT_NO
                            "dark" -> UiModeManager.MODE_NIGHT_YES
                            else -> UiModeManager.MODE_NIGHT_AUTO
                        }
                        getSystemService(UiModeManager::class.java)
                            ?.setApplicationNightMode(mode)
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    companion object {
        private const val DYNAMIC_COLOR_CHANNEL =
            "io.github.loshine.flutternga/dynamic_color"
        private const val NATIVE_THEME_CHANNEL =
            "io.github.loshine.flutternga/native_theme"
    }
}
