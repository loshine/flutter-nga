package xyz.loshine.flutternga

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import xyz.loshine.flutternga.plugins.FlutterCookiesPlugin
import xyz.loshine.flutternga.plugins.FlutterGbkPlugin
import xyz.loshine.flutternga.plugins.FlutterJsonPlugin
import xyz.loshine.flutternga.plugins.FlutterLoginPlugin

class MainActivity : FlutterActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        GeneratedPluginRegistrant.registerWith(this)

        FlutterCookiesPlugin.registerWith(registrarFor(FlutterCookiesPlugin.CHANNEL))
        FlutterGbkPlugin.registerWith(registrarFor(FlutterGbkPlugin.CHANNEL))
        FlutterJsonPlugin.registerWith(registrarFor(FlutterJsonPlugin.CHANNEL))
        FlutterLoginPlugin.registerWith(registrarFor(FlutterLoginPlugin.CHANNEL))
    }

}
