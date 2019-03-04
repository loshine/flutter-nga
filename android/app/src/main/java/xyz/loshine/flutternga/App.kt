package xyz.loshine.flutternga

import com.orhanobut.logger.AndroidLogAdapter
import com.orhanobut.logger.Logger
import io.flutter.app.FlutterApplication

class App : FlutterApplication() {
    override fun onCreate() {
        super.onCreate()
        Logger.addLogAdapter(AndroidLogAdapter())
    }
}