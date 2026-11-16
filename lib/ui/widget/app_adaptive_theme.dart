import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/utils/theme_builder.dart';

/// 按 [themeProvider] 当前主题色构建 [AdaptiveTheme]。
///
/// 注意：[AdaptiveTheme] 只在 initState 时读取 light/dark，之后传入新主题不会
/// 生效（它的 didUpdateWidget 不处理这两个参数），运行期切换主题色必须调用
/// `AdaptiveTheme.of(context).setTheme`（见 [ThemeNotifier.setSeedColor]）。
/// 因此冷启动时 [themeProvider] 必须在首帧前就持有已保存的主题色，
/// 由 `main()` 通过 [ThemeNotifier.loadSaved] 预读并注入。
class AppAdaptiveTheme extends ConsumerWidget {
  const AppAdaptiveTheme({
    super.key,
    this.initialMode,
    required this.builder,
  });

  final AdaptiveThemeMode? initialMode;
  final AdaptiveThemeBuilder builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final seedColor = ref.watch(themeProvider.select((s) => s.seedColor));
    return AdaptiveTheme(
      light: ThemeBuilder.buildLightTheme(seedColor),
      dark: ThemeBuilder.buildDarkTheme(seedColor),
      initial: initialMode ?? AdaptiveThemeMode.light,
      builder: builder,
    );
  }
}
