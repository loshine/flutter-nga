import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// Runs [effect] once after the first frame (or when [keys] change).
///
/// Replaces the common `initState` + `addPostFrameCallback` template.
/// Skips [effect] if the hook host has been unmounted.
void usePostFrameEffect(
  VoidCallback effect, [
  List<Object?> keys = const [],
]) {
  final context = useContext();
  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      effect();
    });
    return null;
  }, keys);
}

/// Triggers header refresh after the first frame so the indicator is visible.
///
/// Prefer this over calling `onRefresh` directly on first load; a bare
/// `onRefresh` finishes the task without ever entering the refreshing state.
void useInitialRefresh(
  EasyRefreshController controller, [
  List<Object?> keys = const [],
]) {
  usePostFrameEffect(() {
    controller.callRefresh();
  }, keys);
}

/// Creates an [EasyRefreshController] and disposes it with the hook scope.
EasyRefreshController useEasyRefreshController({
  bool controlFinishRefresh = true,
  bool controlFinishLoad = false,
}) {
  final controller = useMemoized(
    () => EasyRefreshController(
      controlFinishRefresh: controlFinishRefresh,
      controlFinishLoad: controlFinishLoad,
    ),
  );
  useEffect(() => controller.dispose, [controller]);
  return controller;
}

/// 已加载的数据全部被屏蔽过滤时自动加载下一页，避免列表空白且无法上拉。
///
/// [rawItems] 传入过滤前的列表（每次加载都会生成新列表），
/// 连续自动加载最多 [maxAttempts] 次，防止整个版块都命中屏蔽规则时无限翻页；
/// 出现可见数据或列表被清空（刷新）后重新计数。
void useAutoLoadWhenAllFiltered(
  EasyRefreshController controller, {
  required List<Object?> rawItems,
  required int visibleCount,
  required bool canLoadMore,
  int maxAttempts = 5,
}) {
  final attempts = useRef(0);
  usePostFrameEffect(() {
    if (rawItems.isEmpty || visibleCount > 0) {
      attempts.value = 0;
      return;
    }
    if (!canLoadMore || attempts.value >= maxAttempts) return;
    attempts.value++;
    controller.callLoad();
  }, [rawItems, visibleCount, canLoadMore]);
}
