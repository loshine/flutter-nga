package io.github.loshine.flutternga.ui

import android.annotation.SuppressLint
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.text.TextUtils
import android.webkit.CookieManager
import android.webkit.WebChromeClient
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import kotlinx.android.synthetic.main.activity_login.*
import io.github.loshine.flutternga.R
import io.github.loshine.flutternga.event.CookiesEventHandler
import io.github.loshine.flutternga.plugins.FlutterCookiesPlugin

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

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(null)
        } else {
            @Suppress("DEPRECATION")
            CookieManager.getInstance().removeAllCookie()
        }
        web_view.loadUrl("https://bbs.nga.cn/nuke.php?__lib=login&__act=account&login")
    }

    override fun onPause() {
        val cookieString = CookieManager.getInstance().getCookie(web_view.url)
        if (!TextUtils.isEmpty(cookieString)) {
            val intent = Intent()
            intent.action = FlutterCookiesPlugin.FILTER
            CookiesEventHandler.onCookiesChanges(cookieString)
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
