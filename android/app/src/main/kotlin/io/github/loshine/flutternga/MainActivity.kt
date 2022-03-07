package io.github.loshine.flutternga

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.github.loshine.flutternga.plugins.login.FlutterCookiesPlugin
import io.github.loshine.flutternga.plugins.login.FlutterGallerySaverPlugin
import io.github.loshine.flutternga.plugins.login.FlutterLoginPlugin

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        FlutterLoginPlugin.registerWith(flutterEngine, this)
        FlutterCookiesPlugin.registerWith(flutterEngine)
        FlutterGallerySaverPlugin.registerWith(flutterEngine)
    }
}
