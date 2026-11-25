import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoAlertDialog, CupertinoDialogAction, CupertinoIcons;
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/data/data.dart';
import 'package:flutter_nga/providers/forum/favourite_forum_list_provider.dart';
import 'package:flutter_nga/providers/home/home_drawer_header_provider.dart';
import 'package:flutter_nga/providers/message/conversation_list_provider.dart';
import 'package:flutter_nga/providers/notification/notification_list_provider.dart';
import 'package:flutter_nga/providers/notification/unread_count_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/providers/topic/favourite_topic_list_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/import_cookies_dialog.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/route.dart';

/// 移动端登录页样式：NGA 登录页（`nuke.php?__lib=login`）外层页面把 `body` 与登录 iframe `#iff`
/// 限宽 350px 并居中、背景为灰色；在移动端覆盖为 100% 宽并改用表单背景色，让表单撑满屏幕。
/// 内页按自身宽度计算字号，须在 iframe 加载前生效，因此于文档开始时注入。
/// 同时在 [_loginPagePatchScript] 完成切换前隐藏 iframe，避免闪现扫码界面。
const _mobileLoginPageStyleScript = r'''
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

/// NGA 登录表单本身的米黄色底色。
const _loginFormBgColor = Color(0xFFFFF6DF);

/// 桌面端登录页样式：保持 NGA 网页原生的居中表单尺寸（不拉满全屏），
/// 外层底色统一为登录表单本身的米黄色 `rgb(255, 246, 223)` 使整页自然融合，
/// 并在切换完成前隐藏 iframe 避免闪现。
const _desktopLoginPageStyleScript = r'''
(function () {
  if (!/[?&]__lib=login(&|$)/.test(location.search)) return;
  var style = document.createElement('style');
  style.textContent =
    'html, body { background: rgb(255, 246, 223) !important; margin: 0 !important; padding: 32px 0 !important; width: 100% !important; min-height: 100vh !important; box-sizing: border-box !important; display: flex !important; justify-content: center !important; align-items: flex-start !important; }' +
    '#iff { background: rgb(255, 246, 223) !important; border: none !important; }' +
    '#iff:not([data-fnga-ready]) { visibility: hidden; }';
  (document.head || document.documentElement).appendChild(style);
})();
''';

bool get _isDesktopLoginHost =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux);

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
        enhanceAutoFill(main);
        new w.MutationObserver(function () {
          hideLoginTitle(main);
          enhanceAutoFill(main);
        }).observe(main, { childList: true, subtree: true });
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

  // 为密码登录输入框补充标准 autocomplete 属性，便于系统「编辑 → 自动填充」与密码管理器识别
  function enhanceAutoFill(root) {
    var pwd = root.querySelector('input[type="password"]');
    if (!pwd) return;
    if (!pwd.getAttribute('autocomplete')) {
      pwd.setAttribute('autocomplete', 'current-password');
    }
    var inputs = root.querySelectorAll('input');
    for (var i = 0; i < inputs.length; i++) {
      var input = inputs[i];
      if (input === pwd) break;
      if (input.type === 'text' || input.type === 'email' || input.type === 'tel') {
        if (!input.getAttribute('autocomplete')) {
          input.setAttribute('autocomplete', 'username');
        }
        break;
      }
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
  const LoginPage({super.key, this.asDialog = false});

  /// 是否作为桌面居中模态弹窗展示
  final bool asDialog;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;

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
    final isApple = context.isAppleStyle;
    return AppScaffold(
      embedded: widget.asDialog,
      leading: IconButton(
        tooltip: widget.asDialog ? '关闭' : '返回',
        icon: Icon(
          widget.asDialog ? AppIcons.close(context) : AppIcons.back(context),
        ),
        onPressed: widget.asDialog ? () => Routes.pop(context) : _handleBack,
      ),
      title: const Text("登录"),
      actions: <Widget>[
        IconButton(
          tooltip: "导入 Cookies",
          onPressed: _showImportCookiesDialog,
          icon: Icon(
            isApple ? CupertinoIcons.doc_on_clipboard : Icons.cookie_outlined,
          ),
        ),
      ],
      body: ColoredBox(
        color: _loginFormBgColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            InAppWebView(
              initialSettings: InAppWebViewSettings(
                transparentBackground: true,
              ),
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
                  source: _isDesktopLoginHost
                      ? _desktopLoginPageStyleScript
                      : _mobileLoginPageStyleScript,
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
              onLoadStop: (_, _) {
                if (mounted && _isLoading) {
                  setState(() => _isLoading = false);
                }
              },
              onReceivedError: (_, _, _) {
                if (mounted && _isLoading) {
                  setState(() => _isLoading = false);
                }
              },
              onReceivedHttpError: (_, _, _) {
                if (mounted && _isLoading) {
                  setState(() => _isLoading = false);
                }
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
                  (
                    InAppWebViewController controller,
                    ConsoleMessage consoleMessage,
                  ) {
                    if (consoleMessage.message.startsWith("loginSuccess :")) {
                      final cookiesJson = consoleMessage.message.substring(
                        "loginSuccess : ".length,
                      );
                      _processCookieJson(cookiesJson);
                    }
                  },
            ),
            if (_isLoading)
              const ColoredBox(
                color: _loginFormBgColor,
                child: Center(child: AppActivityIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  void _notifyAccountChanged() {
    ref.read(accountSessionVersionProvider.notifier).bump();
    ref.read(unreadCountProvider.notifier).clear();
    ref.read(favouriteForumListProvider.notifier).onAccountChanged();
    ref.invalidate(conversationListProvider);
    ref.invalidate(notificationListProvider);
    ref.invalidate(favouriteTopicListProvider);
    unawaited(
      ref
          .read(homeDrawerHeaderProvider.notifier)
          .refresh()
          .then((_) {
            if (mounted) {
              return ref.read(unreadCountProvider.notifier).refresh();
            }
          })
          .catchError((_) {}),
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
      _notifyAccountChanged();
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
      builder: (dialogContext) {
        if (cancelable) {
          return M3ConfirmDialog(title: '提示', content: message);
        }
        if (dialogContext.isAppleStyle) {
          return CupertinoAlertDialog(
            title: const Text('提示'),
            content: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(message),
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(dialogContext).pop(true),
                child: const Text('确定'),
              ),
            ],
          );
        }
        return M3Dialog(
          title: '提示',
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('确定'),
            ),
          ],
        );
      },
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
      builder: (dialogContext) {
        final colorScheme = Theme.of(dialogContext).colorScheme;
        final isApple = dialogContext.isAppleStyle;
        return M3Dialog(
          title: title.isEmpty ? '请选择' : title,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 360),
            child: isApple
                ? ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, _) => Divider(
                      height: 0.5,
                      thickness: 0.5,
                      color: colorScheme.outlineVariant,
                    ),
                    itemBuilder: (_, index) {
                      final selected = index == selectedIndex;
                      return InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => Navigator.of(dialogContext).pop(index),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 11,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  options[index],
                                  style: TextStyle(
                                    color: selected
                                        ? colorScheme.primary
                                        : colorScheme.onSurface,
                                    fontWeight: selected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                              if (selected)
                                Icon(
                                  CupertinoIcons.check_mark,
                                  size: 16,
                                  color: colorScheme.primary,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : RadioGroup<int>(
                    groupValue: selectedIndex,
                    onChanged: (index) =>
                        Navigator.of(dialogContext).pop(index),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (_, index) => RadioListTile<int>(
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
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showImportCookiesDialog() async {
    final imported = await showDialog<bool>(
      context: context,
      builder: (_) =>
          ImportCookiesDialog(cookiesCallback: _saveImportedCookies),
    );
    if (imported == true && mounted) {
      AppToast.success("登录成功");
      Routes.pop(context);
    }
  }

  Future<void> _saveImportedCookies(String cookies) async {
    await Data().userRepository.saveLoginCookies(cookies);
    _notifyAccountChanged();
  }
}
