import 'package:flutter/services.dart' show FlutterVersion;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/m3_settings_group.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/dimen.dart';

/// 应用信息 Provider
final appInfoProvider = FutureProvider<PackageInfo>((ref) async {
  return await PackageInfo.fromPlatform();
});

class AboutPage extends HookConsumerWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appInfoAsync = ref.watch(appInfoProvider);
    final mediaPadding = MediaQuery.paddingOf(context);

    return AppScaffold(
      title: const Text('关于'),
      body: appInfoAsync.when(
        loading: () => const Center(child: AppActivityIndicator()),
        error: (error, stack) => Center(child: Text('加载失败: $error')),
        data: (appInfo) {
          final brandHeader = Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.asset(
                  'images/launcher/icon_1024.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                appInfo.appName,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '版本 ${appInfo.version} (Build ${appInfo.buildNumber})',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '艾泽拉斯国家地理论坛客户端',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          );

          final copyright = Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  '© ${DateTime.now().year} ${appInfo.appName}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '本应用为第三方客户端，与 NGA 官方无关\n使用时请遵守论坛相关规定',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );

          final detailGroups = <Widget>[
            // 技术栈区
            const M3SettingsGroup(
              title: '技术栈',
              children: [
                // flutter run / build 会自动注入 FLUTTER_VERSION，无需手动维护版本号。
                M3SettingsInfoTile(
                  title: 'Flutter',
                  subtitle: FlutterVersion.version ?? '未知',
                  icon: Icons.flutter_dash,
                ),
                M3SettingsInfoTile(
                  title: '状态管理',
                  subtitle: 'Riverpod 3.x + flutter_hooks',
                  icon: Icons.timeline,
                ),
                M3SettingsInfoTile(
                  title: '路由',
                  subtitle: 'go_router',
                  icon: Icons.route,
                ),
                M3SettingsInfoTile(
                  title: '网络',
                  subtitle: 'Dio',
                  icon: Icons.cloud_outlined,
                ),
                M3SettingsInfoTile(
                  title: '本地存储',
                  subtitle: 'Sembast',
                  icon: Icons.storage_outlined,
                ),
              ],
            ),

            // 链接区
            M3SettingsGroup(
              title: '相关链接',
              children: [
                M3SettingsTile(
                  title: 'GitHub 仓库',
                  subtitle: '查看源代码、参与贡献',
                  icon: Icons.code,
                  trailingIcon: Icons.open_in_new,
                  onTap: () =>
                      _launchUrl('https://github.com/loshine/flutter-nga'),
                ),
                M3SettingsTile(
                  title: '问题反馈',
                  subtitle: '报告 Bug 或提出建议',
                  icon: Icons.bug_report_outlined,
                  trailingIcon: Icons.open_in_new,
                  onTap: () => _launchUrl(
                    'https://github.com/loshine/flutter-nga/issues',
                  ),
                ),
                M3SettingsTile(
                  title: 'NGA 官网',
                  subtitle: 'bbs.nga.cn',
                  icon: Icons.language,
                  trailingIcon: Icons.open_in_new,
                  onTap: () => _launchUrl('https://bbs.nga.cn'),
                ),
              ],
            ),

            // 其他信息区
            M3SettingsGroup(
              title: '其他信息',
              children: [
                M3SettingsTile(
                  title: '开源协议与许可',
                  subtitle: 'Apache License 2.0 · 查看第三方开源许可',
                  icon: Icons.description_outlined,
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: appInfo.appName,
                    applicationVersion:
                        '${appInfo.version} (Build ${appInfo.buildNumber})',
                    applicationIcon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          'images/launcher/icon_1024.png',
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ];

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= kExpandedBreakpoint;
              final basePadding = EdgeInsets.fromLTRB(
                mediaPadding.left,
                16,
                mediaPadding.right,
                24 + mediaPadding.bottom,
              );
              final padding = readableListPadding(
                constraints.maxWidth,
                base: basePadding,
                maxWidth: isWide ? 1080 : kReadableMaxWidth,
              );

              if (isWide) {
                return ListView(
                  padding: padding,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 320,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
                            child: Material(
                              color: colorScheme.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(
                                Dimen.radiusL,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: Dimen.spacingL,
                                  vertical: Dimen.spacingXXL,
                                ),
                                child: Column(
                                  children: [
                                    brandHeader,
                                    const SizedBox(height: Dimen.spacingXL),
                                    Divider(
                                      height: 1,
                                      color: colorScheme.outlineVariant,
                                    ),
                                    const SizedBox(height: Dimen.spacingL),
                                    copyright,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Dimen.spacingS),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: detailGroups,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }

              return ListView(
                padding: padding,
                children: [
                  Center(child: brandHeader),
                  const SizedBox(height: 16),
                  ...detailGroups,
                  const SizedBox(height: 24),
                  copyright,
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final uri = Uri.parse(urlString);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
