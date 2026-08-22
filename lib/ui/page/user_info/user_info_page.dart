import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:flutter_nga/providers/user/user_info_provider.dart';
import 'package:flutter_nga/ui/widget/avatar_widget.dart';
import 'package:flutter_nga/ui/widget/info_widget.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:flutter_nga/utils/route.dart';

final _registerDateFormat = DateFormat('yyyy-MM-dd');

/// 用户主页：头部展示用户组与统计，入口卡直达发布的主题/回复
class UserInfoPage extends StatefulHookConsumerWidget {
  final String? username;
  final String? uid;

  const UserInfoPage({this.username, this.uid, super.key});

  @override
  ConsumerState<UserInfoPage> createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  @override
  Widget build(BuildContext context) {
    usePostFrameEffect(() {
      final notifier = ref.read(userInfoProvider.notifier);
      if (widget.uid != null) {
        notifier.loadByUid(widget.uid).catchError((err) {
          AppToast.error(err);
          return ref.read(userInfoProvider);
        });
      } else if (widget.username != null) {
        notifier.loadByName(widget.username).catchError((err) {
          AppToast.error(err);
          return ref.read(userInfoProvider);
        });
      }
    }, [widget.uid, widget.username]);

    final userInfo = ref.watch(userInfoProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(userInfo.username ?? ""),
          ),
          SliverToBoxAdapter(
            child: _HeaderCard(userInfo: userInfo),
          ),
          SliverToBoxAdapter(
            child: _EntryGroup(
              title: '发布',
              children: [
                _EntryTile(
                  icon: Icons.article_outlined,
                  colorIndex: 0,
                  title: '发布的主题',
                  subtitle: '查看该用户发布的主题',
                  onTap: () => _navigateToList(userInfo, Routes.USER_TOPICS),
                ),
                _EntryTile(
                  icon: Icons.chat_bubble_outline,
                  colorIndex: 1,
                  title: '发布的回复',
                  subtitle: '查看该用户发布的回复',
                  onTap: () => _navigateToList(userInfo, Routes.USER_REPLIES),
                ),
              ],
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(_getBodyWidgets(userInfo)),
          ),
        ],
      ),
    );
  }

  void _navigateToList(UserInfoState userInfo, String route) {
    Routes.navigateTo(
      context,
      "$route?uid=${userInfo.uid}&username=${code_utils.encodeParam(userInfo.username ?? "")}",
    );
  }

  List<Widget> _getBodyWidgets(UserInfoState userInfo) {
    final widgets = <Widget>[
      _SectionCard(
        title: '签名',
        children: [Html(data: userInfo.signature ?? "")],
      ),
      _SectionCard(
        title: '声望',
        subtitle: '表示与 论坛/某版面/某用户 的关系',
        children: _getReputationWidgets(userInfo),
      ),
      _SectionCard(
        title: '管理权限',
        subtitle: '在以下版面担任版主',
        children: _getAdminForumWidgets(userInfo),
      ),
    ];

    if (userInfo.personalForum != null && userInfo.personalForum!.isNotEmpty) {
      widgets.add(_SectionCard(
        title: '个人版面',
        subtitle: '个人版面是由用户自己管理的版面',
        children: [
          Builder(builder: (context) {
            final entry = userInfo.personalForum!.entries.toList()[0];
            return GestureDetector(
              onTap: () => Routes.navigateTo(
                context,
                Routes.FORUM_DETAIL,
                  queryParams: {"fid": "${entry.key}", "name": entry.value},
              ),
              child: Text(
                "[${entry.value}]",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }),
        ],
      ));
    }

    widgets.add(const SizedBox(height: 40));
    return widgets;
  }

  List<Widget> _getAdminForumWidgets(UserInfoState userInfo) {
    if (userInfo.moderatorForums != null &&
        userInfo.moderatorForums!.isNotEmpty) {
      return userInfo.moderatorForums!.entries
          .map(
            (entry) => Builder(
              builder: (context) => GestureDetector(
                onTap: () => Routes.navigateTo(
                  context,
                  Routes.FORUM_DETAIL,
                  queryParams: {"fid": "${entry.key}", "name": entry.value},
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: Dimen.spacingXS),
                  child: Text(
                    "[${entry.value}]",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList();
    }
    return [const InfoWidget(title: "", subTitle: "无管理版块")];
  }

  List<Widget> _getReputationWidgets(UserInfoState userInfo) {
    if (userInfo.reputationMap == null) return [];
    return userInfo.reputationMap!.entries
        .map((entry) => InfoWidget(
              title: "${entry.key}: ",
              subTitle: entry.value,
            ))
        .toList();
  }
}

/// 头部卡片：头像、用户名、用户组与威望/财富/注册时间统计
class _HeaderCard extends StatelessWidget {
  final UserInfoState userInfo;

  const _HeaderCard({required this.userInfo});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Material(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(Dimen.radiusL),
        child: Padding(
          padding: const EdgeInsets.all(Dimen.spacingL),
          child: Column(
            children: [
              Row(
                children: [
                  AvatarWidget(userInfo.avatar, size: 64),
                  const SizedBox(width: Dimen.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userInfo.username ?? "",
                          style: textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: Dimen.spacingXS),
                        Row(
                          children: [
                            if (!code_utils.isStringEmpty(userInfo.group)) ...[
                              _GroupChip(label: userInfo.group!),
                              const SizedBox(width: Dimen.spacingS),
                            ],
                            Text(
                              'UID: ${userInfo.uid ?? '-'}',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Dimen.spacingL),
              Divider(height: 1, color: colorScheme.outlineVariant),
              const SizedBox(height: Dimen.spacingM),
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      label: '威望',
                      value: _formatFame(userInfo.fame),
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: '财富',
                      value: _formatMoney(userInfo.money),
                    ),
                  ),
                  Expanded(
                    child: _StatItem(
                      label: '注册时间',
                      value: _formatRegisterDate(userInfo.registerDate),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatFame(int? fame) {
    final value = fame ?? 0;
    return value % 10 == 0 ? '${value ~/ 10}' : '${value / 10}';
  }

  /// 财富以铜为单位存储，统计行空间有限，按量级压缩显示
  String _formatMoney(int? money) {
    final value = money ?? 0;
    if (value >= 10000) {
      final gold = value / 10000;
      return gold == gold.truncate()
          ? '${gold.truncate()}金'
          : '${gold.toStringAsFixed(1)}金';
    } else if (value >= 100) {
      return '${value ~/ 100}银';
    } else {
      return '$value铜';
    }
  }

  String _formatRegisterDate(int? registerDate) {
    if (registerDate == null) return '-';
    return _registerDateFormat.format(
        DateTime.fromMillisecondsSinceEpoch(registerDate * 1000));
  }
}

/// 用户组标签
class _GroupChip extends StatelessWidget {
  final String label;

  const _GroupChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimen.spacingS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Dimen.radiusFull),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// 头部卡片统计项
class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// 入口分组：组内条目包裹在一张圆角卡片中，呈分组列表样式
class _EntryGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _EntryGroup({required this.title, required this.children});

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Material(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(Dimen.radiusL),
            clipBehavior: Clip.antiAlias,
            child: Column(children: _buildItems(colorScheme)),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildItems(ColorScheme colorScheme) {
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) {
        items.add(Divider(
          height: 1,
          indent: 72,
          endIndent: 16,
          color: colorScheme.outlineVariant,
        ));
      }
      items.add(children[i]);
    }
    return items;
  }
}

/// 入口项，图标容器颜色按 [colorIndex] 在三组容器色间循环
class _EntryTile extends StatelessWidget {
  final IconData icon;
  final int colorIndex;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _EntryTile({
    required this.icon,
    required this.colorIndex,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final containerColors = [
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
      colorScheme.tertiaryContainer,
    ];
    final contentColors = [
      colorScheme.onPrimaryContainer,
      colorScheme.onSecondaryContainer,
      colorScheme.onTertiaryContainer,
    ];
    final index = colorIndex % containerColors.length;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: containerColors[index],
                borderRadius: BorderRadius.circular(Dimen.radiusFull),
              ),
              child: Icon(
                icon,
                color: contentColors[index],
                size: Dimen.iconSmall,
              ),
            ),
            const SizedBox(width: Dimen.spacingL),
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
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

/// 信息分组卡片：M3 圆角卡片 + 分组标题与可选说明
class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(Dimen.radiusL),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(Dimen.spacingL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: Dimen.spacingXS),
                  Text(
                    subtitle!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: Dimen.spacingS),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
