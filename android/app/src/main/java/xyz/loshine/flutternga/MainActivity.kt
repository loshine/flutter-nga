package xyz.loshine.flutternga

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import xyz.loshine.flutternga.plugins.FlutterCookiesPlugin
import xyz.loshine.flutternga.plugins.FlutterLoginPlugin

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(this)

        FlutterLoginPlugin.registerWith(registrarFor(FlutterLoginPlugin.CHANNEL))
        FlutterCookiesPlugin.registerWith(registrarFor(FlutterCookiesPlugin.CHANNEL))
    }

}
