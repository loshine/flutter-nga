import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/plugins/login.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/ui/widget/import_cookies_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/route.dart';

/// NGA 登录页（`nuke.php?__lib=login`）外层页面把 `body` 与登录 iframe `#iff`
/// 限宽 350px 并居中、背景为灰色；覆盖为 100% 宽并改用表单背景色，让表单撑满屏幕。
/// 内页按自身宽度计算字号，须在 iframe 加载前生效，因此于文档开始时注入。
/// 同时在 [_loginPagePatchScript] 完成切换前隐藏 iframe，避免闪现扫码界面。
const _loginPageStyleScript = r'''
(function () {
  if (!/[?&]__lib=login(&|$)/.test(location.search)) return;
  var style = document.createElement('style');
  style.textContent =
    'body, #iff { width: 100% !important; }' +
    'body { background: rgb(255, 246, 223) !important; }' +
    '#iff:not([data-fnga-ready]) { visibility: hidden; }';
  (document.head || document.documentElement).appendChild(style);
})();
''';

/// 调整 NGA 登录页的交互，于主框架 DOM 解析完成时注入：
///
/// - 禁止缩放。
/// - iframe（同源的 `account_copy.html`）按位掩码 `__client` 决定界面：网页环境
///   默认进入扫码登录。去掉 1024（扫码登录按钮）、加上 16384（禁用第三方登录），
///   再切到密码登录。`_qrLoginUI` 会在二维码库与 qrkey 异步加载完后再次调用自己
///   渲染扫码界面，所以先置空；扫码界面已渲染时点击其「使用密码登录」，顺带清掉
///   二维码轮询定时器。
/// - 切换完成后显示 iframe；iframe 内跳转（注册、找回密码后返回）在 `load` 时
///   重新处理。
/// - 隐藏与 AppBar 重复的「登录」标题；`<select>` 改由 `pickOption` handler 弹出
///   App 的选择对话框（网页 alert / confirm 由 `onJsAlert` / `onJsConfirm` 接管）。
const _loginPagePatchScript = r'''
(function () {
  if (!/[?&]__lib=login(&|$)/.test(location.search)) return;
  var iframe = document.getElementById('iff');
  if (!iframe || window.__fngaLoginPatch) return;
  window.__fngaLoginPatch = true;

  var viewport = document.querySelector('meta[name="viewport"]');
  if (!viewport) {
    viewport = document.createElement('meta');
    viewport.name = 'viewport';
    document.head.appendChild(viewport);
  }
  viewport.setAttribute('content',
    'width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no');

  function patchFrame() {
    var w = iframe.contentWindow;
    var d = w && w.document;
    if (!d || d.readyState === 'loading' || w.location.href === 'about:blank') return false;
    if (!w.__fngaPatched && typeof w._loginUI === 'function' && typeof w.__client === 'number') {
      w.__fngaPatched = true;
      enhanceSelects(d);
      var main = d.getElementById('main');
      if (main) {
        hideLoginTitle(main);
        new w.MutationObserver(function () { hideLoginTitle(main); })
          .observe(main, { childList: true });
      }
      w.__client = (w.__client | 16384) & ~1024;
      if (/^\?login(&|$)/.test(w.location.search)) {
        w._qrLoginUI = function () {};
        var toPassword = Array.prototype.find.call(
          d.querySelectorAll('#main a'),
          function (a) { return a.textContent.trim() === '使用密码登录'; }
        );
        if (toPassword) toPassword.click();
        else w._loginUI();
      }
    }
    return true;
  }

  // AppBar 已有「登录」标题，隐藏密码登录界面顶部的同名标题及其后的换行
  function hideLoginTitle(main) {
    var title = Array.prototype.find.call(
      main.querySelectorAll(':scope > div > span'),
      function (s) { return s.textContent.trim() === '登录'; }
    );
    if (!title) return;
    title.style.display = 'none';
    for (var n = title.nextElementSibling; n && n.tagName === 'BR'; n = n.nextElementSibling) {
      n.style.display = 'none';
    }
  }

  // 用 App 的选择对话框代替 <select> 的系统下拉框，选中后写回并触发 change
  function enhanceSelects(d) {
    function bridge() {
      var b = window.flutter_inappwebview;
      return b && b.callHandler ? b : null;
    }
    d.addEventListener('mousedown', function (e) {
      if (e.target.tagName === 'SELECT' && bridge()) e.preventDefault();
    }, true);
    d.addEventListener('click', function (e) {
      var select = e.target;
      var b = bridge();
      if (select.tagName !== 'SELECT' || select.disabled || !b) return;
      e.preventDefault();
      var options = Array.prototype.map.call(select.options, function (o) { return o.text; });
      var title = select.getAttribute('aria-label') || select.title || (select.id === 'type' ? '账号类型' : '');
      b.callHandler('pickOption', title, options, select.selectedIndex).then(function (index) {
        if (typeof index !== 'number' || index < 0 || index === select.selectedIndex) return;
        select.selectedIndex = index;
        select.dispatchEvent(new Event('change', { bubbles: true }));
      });
    }, true);
  }

  function reveal() {
    iframe.setAttribute('data-fnga-ready', '');
  }

  var tries = 0;
  (function poll() {
    if (patchFrame() || ++tries >= 100) return reveal();
    setTimeout(poll, 50);
  })();
  iframe.addEventListener('load', function () {
    patchFrame();
    reveal();
  });
})();
''';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  InAppWebViewController? _webViewController;
  StreamSubscription<dynamic>? _cookieSubscription;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb && Platform.operatingSystem == 'ohos') {
      _cookieSubscription = Login.cookieStream.listen((event) {
        if (event is String) {
          _processCookieJson(event);
        }
      });
    }
  }

  @override
  void dispose() {
    _cookieSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 返回时先回退 WebView 历史（含 iframe 内的注册、找回密码等跳转），到底再关闭页面。
    // iframe 跳转不会触发 onUpdateVisitedHistory，因此每次返回都实时查询 canGoBack。
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: _buildScaffold(),
    );
  }

  Future<void> _handleBack() async {
    final controller = _webViewController;
    if (controller != null && await controller.canGoBack()) {
      await controller.goBack();
    } else if (mounted) {
      Routes.pop(context);
    }
  }

  Widget _buildScaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: _handleBack),
        title: Text("登录"),
        actions: <Widget>[
          if (!kIsWeb && Platform.operatingSystem == 'ohos')
            IconButton(
              tooltip: "原生登录",
              onPressed: _startNativeLogin,
              icon: const Icon(Icons.open_in_browser),
            ),
          IconButton(
            tooltip: "导入 Cookies",
            onPressed: _showImportCookiesDialog,
            icon: const Icon(Icons.cookie_outlined),
          ),
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: WebUri.uri(
            Uri.https(Data().domain, "nuke.php", {
              '__lib': 'login',
              '__act': 'account',
              'login': null,
            }),
          ),
        ),
        initialUserScripts: UnmodifiableListView([
          UserScript(
            source: _loginPageStyleScript,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
          ),
          UserScript(
            source: _loginPagePatchScript,
            injectionTime: UserScriptInjectionTime.AT_DOCUMENT_END,
          ),
        ]),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          controller.addJavaScriptHandler(
            handlerName: 'pickOption',
            callback: (args) => _pickOption(
              title: args[0] as String,
              options: [for (final option in args[1] as List) '$option'],
              selectedIndex: args[2] as int,
            ),
          );
        },
        onJsAlert: (controller, request) async {
          await _showWebMessage(request.message ?? '');
          return JsAlertResponse(
            handledByClient: true,
            action: JsAlertResponseAction.CONFIRM,
          );
        },
        onJsConfirm: (controller, request) async {
          final confirmed = await _showWebMessage(
            request.message ?? '',
            cancelable: true,
          );
          return JsConfirmResponse(
            handledByClient: true,
            action: confirmed
                ? JsConfirmResponseAction.CONFIRM
                : JsConfirmResponseAction.CANCEL,
          );
        },
        onConsoleMessage:
            (InAppWebViewController controller, ConsoleMessage consoleMessage) {
              if (consoleMessage.message.startsWith("loginSuccess :")) {
                final cookiesJson = consoleMessage.message.substring(
                  "loginSuccess : ".length,
                );
                _processCookieJson(cookiesJson);
              }
            },
      ),
    );
  }

  Future<void> _processCookieJson(String cookiesJson) async {
    try {
      final map = json.decode(cookiesJson) as Map;
      await Data().userRepository.saveLogin(
        map['uid'].toString(),
        map['token'],
        map['username'],
      );
      ref.read(favouriteForumListProvider.notifier).onAccountChanged();
      if (mounted) {
        AppToast.success("登录成功");
        Routes.pop(context);
      }
    } catch (error) {
      AppToast.error(error);
    }
  }

  /// 网页 alert / confirm；[cancelable] 为 true 时带「取消」，点外部关闭视为取消
  Future<bool> _showWebMessage(
    String message, {
    bool cancelable = false,
  }) async {
    if (!mounted) return false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('提示'),
        content: Text(message),
        actions: [
          if (cancelable)
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    return confirmed ?? !cancelable;
  }

  /// 网页 `<select>` 的选项对话框，返回选中的下标，取消时返回 null
  Future<int?> _pickOption({
    required String title,
    required List<String> options,
    required int selectedIndex,
  }) async {
    if (!mounted) return null;
    return showDialog<int>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: title.isEmpty ? null : Text(title),
          content: SizedBox(
            width: double.maxFinite,
            child: RadioGroup<int>(
              groupValue: selectedIndex,
              onChanged: (index) => Navigator.of(context).pop(index),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) => RadioListTile<int>(
                  title: Text(options[index]),
                  value: index,
                  activeColor: colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _startNativeLogin() async {
    try {
      await Login.startLogin();
    } catch (error) {
      AppToast.error(error);
    }
  }

  void _showImportCookiesDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return ImportCookiesDialog(cookiesCallback: _processCookiesString);
      },
    );
  }

  Future<void> _processCookiesString(String cookies) async {
    try {
      await Data().userRepository.saveLoginCookies(cookies);
      ref.read(favouriteForumListProvider.notifier).onAccountChanged();
      if (!mounted) return;
      AppToast.success("登录成功");
      Routes.pop(context);
    } catch (error, stack) {
      debugPrintStack(stackTrace: stack);
      AppToast.error(error);
    }
  }
}
