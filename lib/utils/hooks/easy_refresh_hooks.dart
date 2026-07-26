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
