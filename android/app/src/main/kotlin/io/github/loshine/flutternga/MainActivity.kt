package io.github.loshine.flutternga

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.github.loshine.flutternga.plugins.FlutterGbkPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(FlutterGbkPlugin())
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }
}
