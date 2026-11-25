import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/adaptive_layout.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';

class _PackageLicenseGroup {
  const _PackageLicenseGroup({required this.package, required this.entries});

  final String package;
  final List<List<LicenseParagraph>> entries;
}

/// 平台自适应开源许可页：复用 [AppScaffold] 与 [MasterDetailLayout]，
/// 保持 Apple / Material 视觉统一并正确避让 macOS 红绿灯与各端安全区。
class OpenSourceLicensePage extends HookWidget {
  const OpenSourceLicensePage({
    super.key,
    required this.applicationName,
    required this.applicationVersion,
    this.asDialog = false,
    @visibleForTesting this.licenseStream,
  });

  final String applicationName;
  final String applicationVersion;

  /// 为 true 时以弹窗内嵌模式展示（左上角显示关闭按钮，不重复预留红绿灯安全区）。
  final bool asDialog;

  /// 测试用自定义许可流，默认读取 [LicenseRegistry.licenses]。
  final Stream<LicenseEntry>? licenseStream;

  static Future<void> show(
    BuildContext context, {
    required String applicationName,
    required String applicationVersion,
    bool asDialog = false,
  }) {
    if (asDialog) {
      final colorScheme = Theme.of(context).colorScheme;
      return showDialog<void>(
        context: context,
        builder: (sheetContext) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 880, maxHeight: 620),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                    width: 0.5,
                  ),
                ),
                child: MediaQuery.removePadding(
                  context: sheetContext,
                  removeTop: true,
                  removeBottom: true,
                  removeLeft: true,
                  removeRight: true,
                  child: OpenSourceLicensePage(
                    applicationName: applicationName,
                    applicationVersion: applicationVersion,
                    asDialog: true,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        builder: (_) => OpenSourceLicensePage(
          applicationName: applicationName,
          applicationVersion: applicationVersion,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupsFuture = useMemoized(
      () => _loadGroups(licenseStream ?? LicenseRegistry.licenses),
      [licenseStream],
    );
    final snapshot = useFuture(groupsFuture);
    final selectedIndex = useState(0);
    final query = useState('');
    final searchController = useTextEditingController();

    final isApple = context.isAppleStyle;
    final isMac = context.isMacDesktopAppleStyle;
    final colorScheme = Theme.of(context).colorScheme;

    final allGroups = snapshot.data ?? const <_PackageLicenseGroup>[];
    final trimmedQuery = query.value.trim().toLowerCase();
    final filtered = trimmedQuery.isEmpty
        ? allGroups
        : [
            for (final g in allGroups)
              if (g.package.toLowerCase().contains(trimmedQuery)) g,
          ];

    final effectiveIndex = filtered.isEmpty
        ? -1
        : selectedIndex.value.clamp(0, filtered.length - 1);

    final Widget leadingButton = IconButton(
      tooltip: asDialog ? '关闭' : '返回',
      icon: Icon(
        asDialog ? AppIcons.close(context) : AppIcons.back(context),
        size: isMac ? 16 : null,
      ),
      onPressed: () => Navigator.of(context).maybePop(),
    );

    Widget buildBody(bool isTwoPane) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: AppActivityIndicator());
      }
      if (snapshot.hasError) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '加载开源许可失败',
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
          ),
        );
      }

      final searchField = Padding(
        padding: EdgeInsets.fromLTRB(
          isMac ? 10 : 12,
          10,
          isMac ? 10 : 12,
          isMac ? 6 : 8,
        ),
        child: TextField(
          controller: searchController,
          onChanged: (v) => query.value = v,
          style: TextStyle(fontSize: isMac ? 13 : 14),
          decoration: InputDecoration(
            hintText: '筛选 ${allGroups.length} 个依赖包…',
            isDense: true,
            prefixIcon: Icon(AppIcons.search(context), size: isMac ? 15 : 18),
            prefixIconConstraints: BoxConstraints(
              minWidth: isMac ? 32 : 38,
              minHeight: isMac ? 32 : 38,
            ),
            suffixIcon: query.value.isNotEmpty
                ? IconButton(
                    tooltip: '清除',
                    icon: Icon(AppIcons.close(context), size: 15),
                    onPressed: () {
                      searchController.clear();
                      query.value = '';
                    },
                  )
                : null,
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isApple ? 8 : 20),
              borderSide: isApple
                  ? BorderSide(color: colorScheme.outlineVariant, width: 0.5)
                  : BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isApple ? 8 : 20),
              borderSide: isApple
                  ? BorderSide(color: colorScheme.outlineVariant, width: 0.5)
                  : BorderSide.none,
            ),
          ),
        ),
      );

      final appSummary = Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Text(
          '$applicationName $applicationVersion · Powered by Flutter',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isMac ? 11.5 : 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          searchField,
          appSummary,
          Divider(
            height: isApple ? 0.5 : 1,
            thickness: isApple ? 0.5 : 1,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      '未找到匹配的依赖包',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.only(
                      top: isMac ? 4 : 0,
                      bottom: 16 + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final group = filtered[index];
                      final selected = isTwoPane && index == effectiveIndex;
                      return _LicensePackageTile(
                        group: group,
                        selected: selected,
                        onTap: () {
                          if (isTwoPane) {
                            selectedIndex.value = index;
                          } else {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => _LicenseDetailPage(
                                  group: group,
                                  embedded: false,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      );
    }

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () =>
            Navigator.of(context).maybePop(),
      },
      child: Focus(
        autofocus: true,
        child: MasterDetailLayout(
          masterBuilder: (context, isTwoPane) => AppScaffold(
            embedded: asDialog,
            leading: leadingButton,
            title: const Text('开源协议与许可'),
            body: buildBody(isTwoPane),
          ),
          detailBuilder: (context) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: AppActivityIndicator());
            }
            if (effectiveIndex < 0) {
              return const MasterDetailEmptyPlaceholder(
                icon: Icons.description_outlined,
                title: '选择一个依赖包查看许可详情',
              );
            }
            return _LicenseDetailPage(
              key: ValueKey(filtered[effectiveIndex].package),
              group: filtered[effectiveIndex],
              embedded: true,
            );
          },
        ),
      ),
    );
  }

  static Future<List<_PackageLicenseGroup>> _loadGroups(
    Stream<LicenseEntry> stream,
  ) async {
    final byPackage = <String, List<List<LicenseParagraph>>>{};
    await for (final entry in stream) {
      final paragraphs = entry.paragraphs.toList(growable: false);
      for (final pkg in entry.packages) {
        byPackage.putIfAbsent(pkg, () => []).add(paragraphs);
      }
    }
    final names = byPackage.keys.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return [
      for (final name in names)
        _PackageLicenseGroup(package: name, entries: byPackage[name]!),
    ];
  }
}

class _LicensePackageTile extends StatelessWidget {
  const _LicensePackageTile({
    required this.group,
    required this.selected,
    required this.onTap,
  });

  final _PackageLicenseGroup group;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;
    final isMac = context.isMacDesktopAppleStyle;
    final subtitle = '${group.entries.length} 份许可';

    if (isApple) {
      final selectedBg = colorScheme.primary.withValues(
        alpha: Theme.of(context).brightness == Brightness.dark ? 0.22 : 0.14,
      );
      final row = Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMac ? 10 : 16,
          vertical: isMac ? 7 : 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.package,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMac ? 13 : 15,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isMac ? 11.5 : 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (!isMac)
              Icon(
                AppIcons.chevronRight(context),
                size: 16,
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.65),
              ),
          ],
        ),
      );

      if (isMac) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
          child: Material(
            color: selected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
            clipBehavior: Clip.antiAlias,
            child: InkWell(onTap: onTap, child: row),
          ),
        );
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: selected ? selectedBg : Colors.transparent,
            child: InkWell(onTap: onTap, child: row),
          ),
          Divider(
            height: 0.5,
            thickness: 0.5,
            indent: 16,
            color: colorScheme.outlineVariant,
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: selected
              ? colorScheme.secondaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: DecoratedBox(
              decoration: selected
                  ? BoxDecoration(
                      border: Border(
                        left: BorderSide(color: colorScheme.primary, width: 3),
                      ),
                    )
                  : const BoxDecoration(),
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.fromLTRB(
                  selected ? 13 : 16,
                  2,
                  16,
                  2,
                ),
                title: Text(
                  group.package,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(subtitle),
              ),
            ),
          ),
        ),
        Divider(
          height: 1,
          thickness: 1,
          color: colorScheme.surfaceContainerHighest,
        ),
      ],
    );
  }
}

class _LicenseDetailPage extends StatelessWidget {
  const _LicenseDetailPage({
    super.key,
    required this.group,
    required this.embedded,
  });

  final _PackageLicenseGroup group;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isApple = context.isAppleStyle;

    return AppScaffold(
      embedded: embedded,
      title: Text(group.package),
      body: SelectionArea(
        child: ReadableListPadding(
          builder: (context, padding) => ListView.separated(
            padding: padding + const EdgeInsets.symmetric(vertical: 16),
            itemCount: group.entries.length,
            separatorBuilder: (_, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Divider(
                height: isApple ? 0.5 : 1,
                thickness: isApple ? 0.5 : 1,
                color: colorScheme.outlineVariant,
              ),
            ),
            itemBuilder: (context, index) {
              final paragraphs = group.entries[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final paragraph in paragraphs)
                      Padding(
                        padding: EdgeInsets.only(
                          top: 6,
                          left: paragraph.indent > 0
                              ? paragraph.indent * 16.0
                              : 0,
                        ),
                        child: Text(
                          paragraph.text,
                          textAlign:
                              paragraph.indent ==
                                  LicenseParagraph.centeredIndent
                              ? TextAlign.center
                              : TextAlign.start,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.55,
                            fontWeight:
                                paragraph.indent ==
                                    LicenseParagraph.centeredIndent
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
