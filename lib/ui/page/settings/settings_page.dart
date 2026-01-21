import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/theme_provider.dart';
import 'package:flutter_nga/ui/widget/theme_selection_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsPage> createState() => _SettingsState();
}

class _SettingsState extends ConsumerState<SettingsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(themeProvider.notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("设置")),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SettingsGroup(
            title: "账户",
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                title: "账号管理",
                subtitle: "管理您的账号",
                onTap: () => Routes.navigateTo(context, Routes.ACCOUNT_MANAGEMENT),
              ),
            ],
          ),
          _SettingsGroup(
            title: "外观",
            children: [
              _SettingsTile(
                icon: Icons.palette_outlined,
                title: "主题模式",
                subtitle: "当前: ${themeState.modeName}",
                onTap: _showThemeSelectionDialog,
              ),
              _SettingsTile(
                icon: Icons.text_fields,
                title: "界面设置",
                subtitle: "文字大小等界面元素",
                onTap: () => Routes.navigateTo(context, Routes.INTERFACE_SETTINGS),
              ),
            ],
          ),
          _SettingsGroup(
            title: "内容",
            children: [
              _SettingsTile(
                icon: Icons.block_outlined,
                title: "屏蔽设置",
                subtitle: "屏蔽用户、关键词",
                onTap: () => Routes.navigateTo(context, Routes.BLOCKLIST_SETTINGS),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showThemeSelectionDialog() {
    showDialog(
      context: context,
      builder: (_) => const ThemeSelectionDialog(),
    );
  }
}

/// 设置分组
class _SettingsGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: textTheme.titleSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

/// 设置项
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(Dimen.radiusM),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Dimen.radiusM),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(Dimen.radiusS),
                  ),
                  child: Icon(
                    icon,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: colorScheme.onSurfaceVariant,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
