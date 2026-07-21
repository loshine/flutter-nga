import 'package:community_material_icon/community_material_icon.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:flutter_nga/data/entity/user.dart';
import 'package:flutter_nga/providers/user/account_list_provider.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:route_observer_mixin/route_observer_mixin.dart';

class AccountManagementPage extends ConsumerStatefulWidget {
  const AccountManagementPage({super.key});

  @override
  ConsumerState<AccountManagementPage> createState() =>
      _AccountManagementState();
}

class _AccountManagementState extends ConsumerState<AccountManagementPage>
    with RouteAware, RouteObserverMixin {
  final _refreshController = EasyRefreshController(
    controlFinishRefresh: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _onRefresh(ref.read(accountListProvider.notifier));
      }
    });
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountListProvider);
    final notifier = ref.read(accountListProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("账号管理"),
        actions: [
          IconButton(
            onPressed: () => _quitAll(notifier),
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            tooltip: "退出所有账号",
          ),
        ],
      ),
      body: EasyRefresh(
        controller: _refreshController,
        onRefresh: () => _onRefresh(notifier),
        child: ListView.builder(
          itemCount: state.list.length,
          itemBuilder: (context, position) => Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _setDefault(notifier, state.list[position]),
              onLongPress: () =>
                  _showDeleteDialog(notifier, state.list[position]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      state.list[position].nickname,
                      style: TextStyle(
                          color: state.list[position].enabled
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodyLarge?.color),
                    ),
                    subtitle: Text(
                      "UID:${state.list[position].uid}",
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color),
                    ),
                    trailing: Icon(
                      CommunityMaterialIcons.check,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  Divider(height: 1),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "添加账号",
        onPressed: () => Routes.navigateTo(context, Routes.LOGIN),
        child: Icon(Icons.add),
      ),
    );
  }

  @override
  void didPopNext() {
    _refreshController.callRefresh();
  }

  Future<void> _onRefresh(AccountListNotifier notifier) async {
    try {
      await notifier.refresh();
      if (!mounted) return;
      _refreshController.finishRefresh();
    } catch (_) {
      if (!mounted) return;
      _refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  void _quitAll(AccountListNotifier notifier) async {
    await notifier.quitAll();
    AppToast.success("成功");
    if (mounted) {
      Routes.navigateTo(context, Routes.HOME, clearStack: true);
    }
  }

  void _setDefault(AccountListNotifier notifier, CacheUser user) {
    notifier.setDefault(user).then((_) => _refreshController.callRefresh());
  }

  void _showDeleteDialog(AccountListNotifier notifier, CacheUser user) {
    showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            title: Text("提示"),
            content: Text("是否删除该登录用户"),
            actions: <Widget>[
              TextButton(
                onPressed: () => Routes.pop(context),
                child: Text("取消"),
              ),
              TextButton(
                onPressed: () {
                  Routes.pop(context);
                  notifier
                      .delete(user)
                      .then((_) => _refreshController.callRefresh());
                },
                child: Text("确认"),
              ),
            ],
          );
        });
  }
}
