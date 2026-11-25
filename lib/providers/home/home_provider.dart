import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final homeIndexProvider = NotifierProvider<HomeIndexNotifier, int>(
  HomeIndexNotifier.new,
);

class ForumGroupFabVisibleNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setVisible(bool visible) {
    state = visible;
  }
}

final forumGroupFabVisibleProvider =
    NotifierProvider<ForumGroupFabVisibleNotifier, bool>(
      ForumGroupFabVisibleNotifier.new,
    );

typedef WorkspaceMenuRouteHandler = bool Function(String path);

/// 协调 macOS 原生系统菜单（⌘1~⌘4、⌘,）与当前活跃的三栏工作区。
///
/// 不持有 UI 状态、不触发 rebuild；工作区挂载时注册，卸载时注销。
class WorkspaceMenuController {
  WorkspaceMenuRouteHandler? _handler;

  bool get hasHandler => _handler != null;

  void register(WorkspaceMenuRouteHandler handler) {
    _handler = handler;
  }

  void unregister(WorkspaceMenuRouteHandler handler) {
    if (identical(_handler, handler)) {
      _handler = null;
    }
  }

  bool dispatch(String path) => _handler?.call(path) ?? false;
}

final workspaceMenuControllerProvider = Provider<WorkspaceMenuController>(
  (_) => WorkspaceMenuController(),
);
