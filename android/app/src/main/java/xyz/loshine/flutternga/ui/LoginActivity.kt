package xyz.loshine.flutternga.ui

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Bundle
import androidx.localbroadcastmanager.content.LocalBroadcastManager
import androidx.appcompat.app.AppCompatActivity
import android.text.TextUtils
import android.webkit.CookieManager
import android.webkit.WebChromeClient
import android.webkit.WebViewClient
import kotlinx.android.synthetic.main.activity_login.*
import xyz.loshine.flutternga.R
import xyz.loshine.flutternga.plugins.FlutterCookiesPlugin

class LoginActivity : AppCompatActivity() {

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login)

        toolbar.setNavigationOnClickListener { finish() }

        web_view.webChromeClient = LoginWebChromeClient()
        web_view.webViewClient = LoginWebViewClient()
        web_view.settings.javaScriptEnabled = true
        web_view.settings.javaScriptCanOpenWindowsAutomatically = true

        web_view.loadUrl("https://bbs.nga.cn/nuke.php?__lib=login&__act=account&login")
    }

    override fun onPause() {
        val cookieString = CookieManager.getInstance().getCookie(web_view.url)
        if (!TextUtils.isEmpty(cookieString)) {
            val intent = Intent()
            intent.action = FlutterCookiesPlugin.FILTER
            intent.putExtra("cookies", cookieString)
            androidx.localbroadcastmanager.content.LocalBroadcastManager.getInstance(this).sendBroadcast(intent)
        }
        super.onPause()
    }

    override fun onBackPressed() {
        if (web_view.canGoBack()) {
            web_view.goBack()
        } else {
            super.onBackPressed()
        }
    }

    class LoginWebViewClient : WebViewClient()

    class LoginWebChromeClient : WebChromeClient()
}
