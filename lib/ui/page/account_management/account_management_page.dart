import 'package:easy_refresh/easy_refresh.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/user/account_list_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_action_menu.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/list_status_view.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/route_observer.dart';

class AccountManagementPage extends StatefulHookConsumerWidget {
  const AccountManagementPage({super.key, this.embedded = false});

  /// 是否作为大屏双栏设置页的右侧内嵌面板展示
  final bool embedded;

  @override
  ConsumerState<AccountManagementPage> createState() =>
      _AccountManagementState();
}

class _AccountManagementState extends ConsumerState<AccountManagementPage>
    with RouteAwareSubscription {
  late EasyRefreshController _refreshController;

  @override
  Widget build(BuildContext context) {
    _refreshController = useEasyRefreshController();
    final state = ref.watch(accountListProvider);
    final notifier = ref.read(accountListProvider.notifier);

    Future<void> onRefresh() async {
      try {
        await notifier.refresh();
        if (!mounted) return;
        _refreshController.finishRefresh();
      } catch (_) {
        if (!mounted) return;
        _refreshController.finishRefresh(IndicatorResult.fail);
      }
    }

    useInitialRefresh(_refreshController);

    return AppScaffold(
      embedded: widget.embedded,
      title: const Text("账号管理"),
      actions: [
        IconButton(
          onPressed: state.list.isEmpty
              ? null
              : () => _confirmQuitAll(notifier),
          icon: Icon(AppIcons.delete(context)),
          tooltip: "退出所有账号",
        ),
      ],
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: onRefresh,
        child: state.list.isEmpty
            ? const CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ListStatusView(
                      icon: Icons.person_outline,
                      message: '暂未登录账号',
                    ),
                  ),
                ],
              )
            : ReadableListPadding(
                builder: (context, padding) => ListView.builder(
                  padding: padding,
                  itemCount: state.list.length,
                  itemBuilder: (context, position) {
                    final user = state.list[position];
                    return _AccountItem(
                      key: ValueKey(user.uid),
                      user: user,
                      onSetDefault: () => _setDefault(notifier, user),
                      onDelete: () =>
                          _confirmDelete(notifier, state.list, user),
                    );
                  },
                ),
              ),
      ),
      primaryAction: AppPrimaryAction(
        tooltip: "添加账号",
        onPressed: () => Routes.navigateTo(context, Routes.LOGIN),
        icon: const Icon(Icons.add),
        appleIcon: Icon(AppIcons.add(context)),
      ),
    );
  }

  @override
  void didPopNext() {
    _refreshController.callRefresh();
  }

  void _confirmQuitAll(AccountListNotifier notifier) {
    showDialog(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: "退出所有账号",
        content: "将退出并移除本机保存的全部账号，此操作不可恢复。",
        confirmText: "全部退出",
        destructive: true,
        onConfirm: () => _quitAll(notifier),
      ),
    );
  }

  Future<void> _quitAll(AccountListNotifier notifier) async {
    try {
      await notifier.quitAll();
      if (!mounted) return;
      await notifier.refresh();
      AppToast.success("已退出所有账号");
    } catch (err) {
      AppToast.error(err);
    }
  }

  void _setDefault(AccountListNotifier notifier, CacheUser user) {
    notifier.setDefault(user).then((_) => _refreshController.callRefresh());
  }

  /// 删除只移除本机保存的登录信息，不会让服务端会话失效，所以文案不说「退出登录」。
  void _confirmDelete(
    AccountListNotifier notifier,
    List<CacheUser> accounts,
    CacheUser user,
  ) {
    showDialog(
      context: context,
      builder: (_) => M3ConfirmDialog(
        title: "删除账号",
        content: deleteAccountMessage(accounts, user),
        confirmText: "删除",
        destructive: true,
        onConfirm: () => notifier
            .delete(user)
            .then((_) => _refreshController.callRefresh())
            .catchError((err) => AppToast.error(err)),
      ),
    );
  }
}

/// 删除账号确认文案：区分普通账号、默认账号与最后一个账号。
@visibleForTesting
String deleteAccountMessage(List<CacheUser> accounts, CacheUser user) {
  final others = accounts.where((u) => u.uid != user.uid).toList();
  final base = "删除「${user.nickname}」在本机保存的登录信息，之后需要重新登录才能使用该账号。";
  if (others.isEmpty) return "$base\n删除后将处于未登录状态。";
  if (user.enabled) return "$base\n将自动切换到「${others.first.nickname}」。";
  return base;
}

/// 账号条目：点击设为默认；行尾菜单与长按提供「设为默认 / 删除」。
class _AccountItem extends StatefulWidget {
  const _AccountItem({
    super.key,
    required this.user,
    required this.onSetDefault,
    required this.onDelete,
  });

  final CacheUser user;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  State<_AccountItem> createState() => _AccountItemState();
}

class _AccountItemState extends State<_AccountItem> {
  final _menuKey = GlobalKey<AppMoreMenuButtonState<String>>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = widget.user;
    return Column(
      children: [
        ListTile(
          onTap: widget.onSetDefault,
          onLongPress: () => _menuKey.currentState?.showMenu(),
          // 只有默认账号显示选中标记
          leading: Icon(
            user.enabled ? Icons.check_circle : Icons.circle_outlined,
            color: user.enabled ? colorScheme.primary : colorScheme.outline,
            semanticLabel: user.enabled ? '当前账号' : null,
          ),
          title: Text(
            user.nickname,
            style: TextStyle(
              color: user.enabled
                  ? colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          subtitle: Text(
            "UID:${user.uid}",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          trailing: AppMoreMenuButton<String>(
            key: _menuKey,
            tooltip: '更多操作',
            onSelected: (action) =>
                action == 'default' ? widget.onSetDefault() : widget.onDelete(),
            actions: [
              if (!user.enabled)
                AppMenuAction(
                  value: 'default',
                  label: '设为默认',
                  icon: AppIcons.check(context),
                ),
              AppMenuAction(
                value: 'delete',
                label: '删除',
                icon: AppIcons.delete(context),
                destructive: true,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
