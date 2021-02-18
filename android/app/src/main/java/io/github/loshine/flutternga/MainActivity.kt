package io.github.loshine.flutternga

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.github.loshine.flutternga.plugins.FlutterCookiesPlugin
import io.github.loshine.flutternga.plugins.FlutterGbkPlugin
import io.github.loshine.flutternga.plugins.FlutterJsonPlugin
import io.github.loshine.flutternga.plugins.FlutterLoginPlugin


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(FlutterCookiesPlugin())
        flutterEngine.plugins.add(FlutterGbkPlugin())
        flutterEngine.plugins.add(FlutterJsonPlugin())
        flutterEngine.plugins.add(FlutterLoginPlugin(this))
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
