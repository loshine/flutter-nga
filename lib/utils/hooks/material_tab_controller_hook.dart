import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';

/// flutter_hooks 的内置 hook 返回 Flutter SDK 的旧版 TabController。
TabController useMaterialTabController({
  required int initialLength,
  int initialIndex = 0,
  List<Object?>? keys,
}) {
  final vsync = useSingleTickerProvider(keys: keys);
  final controller = useMemoized(
    () => TabController(
      length: initialLength,
      initialIndex: initialIndex,
      vsync: vsync,
    ),
    keys ?? const [],
  );
  useEffect(() => controller.dispose, [controller]);
  return controller;
}
