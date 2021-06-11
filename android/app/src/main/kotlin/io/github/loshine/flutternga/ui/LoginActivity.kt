package io.github.loshine.flutternga.ui

import android.annotation.SuppressLint
import android.os.Build
import android.os.Bundle
import android.webkit.ConsoleMessage
import android.webkit.CookieManager
import android.webkit.WebChromeClient
import android.webkit.WebViewClient
import androidx.appcompat.app.AppCompatActivity
import io.github.loshine.flutternga.databinding.ActivityLoginBinding
import io.github.loshine.flutternga.plugins.login.CookiesEventHandler
import java.lang.ref.WeakReference

class LoginActivity : AppCompatActivity() {

    private lateinit var viewBinding: ActivityLoginBinding

    @SuppressLint("SetJavaScriptEnabled")
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        viewBinding = ActivityLoginBinding.inflate(layoutInflater)
        setContentView(viewBinding.root)

        setSupportActionBar(viewBinding.toolbar)
        viewBinding.toolbar.setNavigationOnClickListener { finish() }

        viewBinding.webView.webChromeClient = LoginWebChromeClient(this)
        viewBinding.webView.webViewClient = LoginWebViewClient()
        viewBinding.webView.settings.javaScriptEnabled = true
        viewBinding.webView.settings.javaScriptCanOpenWindowsAutomatically = true

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(null)
        } else {
            @Suppress("DEPRECATION")
            CookieManager.getInstance().removeAllCookie()
        }
        viewBinding.webView.loadUrl("https://bbs.nga.cn/nuke.php?__lib=login&__act=account&login")
    }

    override fun onResume() {
        super.onResume()
        viewBinding.webView.onResume()
    }

    override fun onPause() {
        super.onPause()
        viewBinding.webView.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        viewBinding.webView.destroy()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            CookieManager.getInstance().removeAllCookies(null)
        } else {
            @Suppress("DEPRECATION")
            CookieManager.getInstance().removeAllCookie()
        }
    }

    override fun onBackPressed() {
        if (viewBinding.webView.canGoBack()) {
            viewBinding.webView.goBack()
        } else {
            super.onBackPressed()
        }
    }

    class LoginWebViewClient : WebViewClient()

    class LoginWebChromeClient(activity: AppCompatActivity) : WebChromeClient() {

        private val activityRef: WeakReference<AppCompatActivity> = WeakReference(activity)

        override fun onConsoleMessage(consoleMessage: ConsoleMessage?): Boolean {
            consoleMessage?.let {
                val message = it.message()
                if (message.startsWith("loginSuccess : ")) {
                    val json = message.substring("loginSuccess : ".length)
                    activityRef.get()?.let { activity ->
                        CookiesEventHandler.onCookiesChanges(json)
                        activity.finish()
                    }
                }
            }
            return super.onConsoleMessage(consoleMessage)
        }
    }
}
