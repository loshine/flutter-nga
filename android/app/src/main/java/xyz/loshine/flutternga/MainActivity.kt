package xyz.loshine.flutternga

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import xyz.loshine.flutternga.plugins.FlutterCookiesPlugin
import xyz.loshine.flutternga.plugins.FlutterGbkPlugin
import xyz.loshine.flutternga.plugins.FlutterJsonPlugin
import xyz.loshine.flutternga.plugins.FlutterLoginPlugin


class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        flutterEngine.plugins.add(FlutterCookiesPlugin())
        flutterEngine.plugins.add(FlutterGbkPlugin())
        flutterEngine.plugins.add(FlutterJsonPlugin())
        flutterEngine.plugins.add(FlutterLoginPlugin(this))
    }
}
