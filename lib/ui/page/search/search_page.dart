import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoIcons, CupertinoSearchTextField;
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'package:flutter_nga/providers/search/input_deletion_status_provider.dart';
import 'package:flutter_nga/providers/search/search_options_provider.dart';
import 'package:flutter_nga/providers/settings/design_style_provider.dart';
import 'package:flutter_nga/ui/widget/adaptive/adaptive_controls.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_icons.dart';
import 'package:flutter_nga/ui/widget/adaptive/app_scaffold.dart';
import 'package:flutter_nga/ui/widget/readable_width.dart';
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class SearchPage extends HookConsumerWidget {
  final int? fid;

  /// 是否作为桌面端 Spotlight 式居中弹窗呈现。
  final bool asDialog;

  const SearchPage({this.fid, this.asDialog = false, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useTextEditingController();
    final focusNode = useFocusNode();
    final inputVisible = ref.watch(inputDeletionStatusProvider);
    final searchOptions = ref.watch(searchOptionsProvider(fid));
    final searchOptionsNotifier = ref.read(searchOptionsProvider(fid).notifier);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    useEffect(() {
      void textListener() {
        ref
            .read(inputDeletionStatusProvider.notifier)
            .setVisible(searchQuery.text.isNotEmpty);
      }

      searchQuery.addListener(textListener);
      return () => searchQuery.removeListener(textListener);
    }, []);

    final hintText = switch (searchOptions.firstRadio) {
      FIRST_RADIO_FORUM => '搜索版块名称…',
      FIRST_RADIO_USER =>
        searchOptions.userRadio == USER_RADIO_UID ? '输入用户 ID…' : '输入用户名…',
      _ => '搜索主题关键词…',
    };

    final keyboardType =
        searchOptions.firstRadio == FIRST_RADIO_USER &&
            searchOptions.userRadio == USER_RADIO_UID
        ? TextInputType.number
        : TextInputType.text;

    if (asDialog) {
      return _buildDesktopSpotlightDialog(
        context,
        searchQuery: searchQuery,
        focusNode: focusNode,
        inputVisible: inputVisible,
        hintText: hintText,
        keyboardType: keyboardType,
        state: searchOptions,
        notifier: searchOptionsNotifier,
        colorScheme: colorScheme,
        textTheme: textTheme,
      );
    }

    final hasBackButton =
        ModalRoute.of(context)?.impliesAppBarDismissal ?? false;

    final isApple = context.isAppleStyle;

    return AppScaffold(
      toolbarHeight: isApple ? 54 : 68,
      titleSpacing: 0,
      centerTitle: false,
      title: Padding(
        padding: EdgeInsets.only(
          left: isApple
              ? 0
              : (hasBackButton ? Dimen.spacingXS : Dimen.spacingL),
          right: isApple ? 0 : Dimen.spacingL,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: kReadableMaxWidth),
            child: isApple
                ? CupertinoSearchTextField(
                    controller: searchQuery,
                    focusNode: focusNode,
                    autofocus: true,
                    placeholder: hintText,
                    keyboardType: keyboardType,
                    onSubmitted: (text) =>
                        _onSearch(context, text, searchOptions, fid),
                  )
                : SearchBar(
                    controller: searchQuery,
                    focusNode: focusNode,
                    autoFocus: true,
                    hintText: hintText,
                    elevation: const WidgetStatePropertyAll(0),
                    backgroundColor: WidgetStatePropertyAll(
                      colorScheme.surfaceContainerHigh,
                    ),
                    constraints: const BoxConstraints(
                      minHeight: 48,
                      maxHeight: 52,
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.only(left: 16, right: 4),
                    ),
                    textInputAction: TextInputAction.search,
                    keyboardType: keyboardType,
                    onSubmitted: (text) =>
                        _onSearch(context, text, searchOptions, fid),
                    trailing: [
                      if (inputVisible)
                        IconButton(
                          tooltip: '清除',
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            searchQuery.clear();
                            focusNode.requestFocus();
                          },
                        ),
                      IconButton(
                        tooltip: '搜索',
                        icon: const Icon(Icons.search),
                        onPressed: () => _onSearch(
                          context,
                          searchQuery.text,
                          searchOptions,
                          fid,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
      actions: isApple
          ? [
              TextButton(
                onPressed: () =>
                    _onSearch(context, searchQuery.text, searchOptions, fid),
                child: const Text('搜索'),
              ),
            ]
          : null,
      body: isApple
          ? _buildAppleBody(context, searchOptions, searchOptionsNotifier)
          : _buildMaterialBody(context, searchOptions, searchOptionsNotifier),
    );
  }

  /// 桌面端 Spotlight 风格居中搜索面板：顶部大号输入行 + 紧凑分组选项，无冗余全屏留白。
  Widget _buildDesktopSpotlightDialog(
    BuildContext context, {
    required TextEditingController searchQuery,
    required FocusNode focusNode,
    required bool inputVisible,
    required String hintText,
    required TextInputType keyboardType,
    required SearchOptionsState state,
    required SearchOptionsNotifier notifier,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final modeHint = switch (state.firstRadio) {
      FIRST_RADIO_FORUM => '按关键词匹配 NGA 版块名称，点击结果直达版块',
      FIRST_RADIO_USER =>
        state.userRadio == USER_RADIO_UID
            ? '输入纯数字 UID 查看对应用户主页'
            : '输入完整用户名查看对应用户主页',
      _ =>
        (fid != null && state.topicRadio == TOPIC_RADIO_CURRENT_FORUM)
            ? '在当前版块内搜索${state.content ? '标题与正文' : '主题标题'}'
            : '在全站范围内搜索${state.content ? '标题与正文' : '主题标题'}',
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 顶部 Spotlight 搜索输入行
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Icon(
                AppIcons.search(context),
                size: 19,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: searchQuery,
                  focusNode: focusNode,
                  autofocus: true,
                  keyboardType: keyboardType,
                  textInputAction: TextInputAction.search,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    filled: false,
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 6),
                    hintText: hintText,
                    hintStyle: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant.withValues(
                        alpha: 0.65,
                      ),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  onSubmitted: (text) => _onSearch(context, text, state, fid),
                ),
              ),
              if (inputVisible)
                IconButton(
                  tooltip: '清除',
                  icon: Icon(
                    context.isAppleStyle
                        ? CupertinoIcons.clear_circled_solid
                        : Icons.cancel,
                    size: 16,
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                  onPressed: () {
                    searchQuery.clear();
                    focusNode.requestFocus();
                  },
                ),
              const SizedBox(width: 6),
              FilledButton(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () =>
                    _onSearch(context, searchQuery.text, state, fid),
                child: const Text('搜索'),
              ),
            ],
          ),
        ),
        Divider(height: 0.5, thickness: 0.5, color: colorScheme.outlineVariant),
        // 选项内容区
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(context, state, notifier),
              const SizedBox(height: 12),
              _buildAppleOptionsCard(
                context,
                state: state,
                notifier: notifier,
                colorScheme: colorScheme,
                textTheme: textTheme,
                modeHint: modeHint,
              ),
            ],
          ),
        ),
        // 底部轻提示栏
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            border: Border(
              top: BorderSide(color: colorScheme.outlineVariant, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  modeHint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Text(
                'Enter 搜索 · Esc 关闭',
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(
    BuildContext context,
    SearchOptionsState state,
    SearchOptionsNotifier notifier,
  ) {
    return AppSegmentedControl<int>(
      segments: [
        AppSegment(
          value: FIRST_RADIO_TOPIC,
          label: '主题',
          icon: AppIcons.article(context),
        ),
        AppSegment(
          value: FIRST_RADIO_FORUM,
          label: '版块',
          icon: AppIcons.forum(context),
        ),
        AppSegment(
          value: FIRST_RADIO_USER,
          label: '用户',
          icon: AppIcons.person(context),
        ),
      ],
      selected: state.firstRadio,
      onChanged: notifier.checkFirstRadio,
    );
  }

  Widget _buildAppleOptionsCard(
    BuildContext context, {
    required SearchOptionsState state,
    required SearchOptionsNotifier notifier,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String modeHint,
  }) {
    final rows = <Widget>[];
    if (state.firstRadio == FIRST_RADIO_TOPIC) {
      if (fid != null) {
        rows.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Text(
                  '搜索范围',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 196,
                  child: AppSegmentedControl<int>(
                    segments: const [
                      AppSegment(
                        value: TOPIC_RADIO_CURRENT_FORUM,
                        label: '当前版块',
                      ),
                      AppSegment(value: TOPIC_RADIO_ALL_FORUM, label: '全部版块'),
                    ],
                    selected: state.topicRadio,
                    onChanged: notifier.checkTopicRadio,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '包括正文',
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '同时匹配帖子正文内容，默认仅搜索标题',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              AppSwitch(value: state.content, onChanged: notifier.checkContent),
            ],
          ),
        ),
      );
    } else if (state.firstRadio == FIRST_RADIO_USER) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Text(
                '搜索方式',
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 196,
                child: AppSegmentedControl<int>(
                  segments: const [
                    AppSegment(value: USER_RADIO_NAME, label: '用户名'),
                    AppSegment(value: USER_RADIO_UID, label: '用户ID'),
                  ],
                  selected: state.userRadio,
                  onChanged: notifier.checkUserRadio,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(
                AppIcons.forum(context),
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  modeHint,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 0.5,
                thickness: 0.5,
                indent: 14,
                color: colorScheme.outlineVariant,
              ),
            rows[i],
          ],
        ],
      ),
    );
  }

  Widget _buildAppleBody(
    BuildContext context,
    SearchOptionsState state,
    SearchOptionsNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaPadding = MediaQuery.paddingOf(context);
    final modeHint = switch (state.firstRadio) {
      FIRST_RADIO_FORUM => '按关键词匹配 NGA 版块名称，点击结果直达版块',
      FIRST_RADIO_USER => '按用户名或 UID 查找用户主页',
      _ => '输入关键词开始搜索主题',
    };

    return ReadableListPadding(
      padding: EdgeInsets.fromLTRB(
        Dimen.spacingL + mediaPadding.left,
        Dimen.spacingL,
        Dimen.spacingL + mediaPadding.right,
        Dimen.spacingL + mediaPadding.bottom,
      ),
      builder: (context, padding) => ListView(
        padding: padding,
        children: [
          _buildTypeSelector(context, state, notifier),
          const SizedBox(height: Dimen.spacingL),
          _buildAppleOptionsCard(
            context,
            state: state,
            notifier: notifier,
            colorScheme: colorScheme,
            textTheme: textTheme,
            modeHint: modeHint,
          ),
        ],
      ),
    );
  }

  Widget _buildMaterialBody(
    BuildContext context,
    SearchOptionsState state,
    SearchOptionsNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaPadding = MediaQuery.paddingOf(context);

    return ReadableListPadding(
      padding: EdgeInsets.fromLTRB(
        Dimen.spacingL + mediaPadding.left,
        Dimen.spacingL,
        Dimen.spacingL + mediaPadding.right,
        Dimen.spacingL + mediaPadding.bottom,
      ),
      builder: (context, padding) => ListView(
        padding: padding,
        children: [
          // 搜索类型分组
          _buildOptionSection(
            title: '搜索类型',
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: _buildTypeSelector(context, state, notifier),
          ),

          // 主题搜索选项
          if (state.firstRadio == FIRST_RADIO_TOPIC) ...[
            if (fid != null)
              _buildOptionSection(
                title: '搜索范围',
                colorScheme: colorScheme,
                textTheme: textTheme,
                child: AppSegmentedControl<int>(
                  segments: const [
                    AppSegment(value: TOPIC_RADIO_CURRENT_FORUM, label: '当前版块'),
                    AppSegment(value: TOPIC_RADIO_ALL_FORUM, label: '全部版块'),
                  ],
                  selected: state.topicRadio,
                  onChanged: notifier.checkTopicRadio,
                ),
              ),
            _buildOptionSection(
              title: '搜索选项',
              colorScheme: colorScheme,
              textTheme: textTheme,
              child: Wrap(
                spacing: Dimen.spacingS,
                runSpacing: Dimen.spacingS,
                children: [
                  FilterChip(
                    label: const Text('包括正文'),
                    selected: state.content,
                    onSelected: notifier.checkContent,
                  ),
                ],
              ),
            ),
          ],

          // 用户搜索选项
          if (state.firstRadio == FIRST_RADIO_USER)
            _buildOptionSection(
              title: '搜索方式',
              colorScheme: colorScheme,
              textTheme: textTheme,
              child: AppSegmentedControl<int>(
                segments: const [
                  AppSegment(value: USER_RADIO_NAME, label: '用户名'),
                  AppSegment(value: USER_RADIO_UID, label: '用户ID'),
                ],
                selected: state.userRadio,
                onChanged: notifier.checkUserRadio,
              ),
            ),
        ],
      ),
    );
  }

  /// 构建搜索选项分组卡片
  Widget _buildOptionSection({
    required String title,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: Dimen.spacingM),
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
            const SizedBox(height: Dimen.spacingM),
            child,
          ],
        ),
      ),
    );
  }

  void _onSearch(
    BuildContext context,
    String rawText,
    SearchOptionsState state,
    int? fid,
  ) {
    final text = rawText.trim();
    if (text.isEmpty) {
      AppToast.warning('请输入搜索关键词');
      return;
    }
    if (state.firstRadio == FIRST_RADIO_TOPIC) {
      final useCurrentForum =
          fid != null && state.topicRadio == TOPIC_RADIO_CURRENT_FORUM;
      if (!useCurrentForum) {
        Routes.navigateTo(
          context,
          "${Routes.SEARCH_TOPIC_LIST}?keyword=${code_utils.encodeParam(text)}&content=${state.content ? 1 : 0}",
        );
      } else {
        Routes.navigateTo(
          context,
          "${Routes.SEARCH_TOPIC_LIST}?keyword=${code_utils.encodeParam(text)}&fid=$fid&content=${state.content ? 1 : 0}",
        );
      }
    } else if (state.firstRadio == FIRST_RADIO_FORUM) {
      Routes.navigateTo(
        context,
        "${Routes.SEARCH_FORUM}?keyword=${code_utils.encodeParam(text)}",
      );
    } else if (state.firstRadio == FIRST_RADIO_USER) {
      if (state.userRadio == USER_RADIO_NAME) {
        Routes.navigateTo(
          context,
          "${Routes.USER}?name=${code_utils.encodeParam(text)}",
        );
      } else {
        Routes.navigateTo(context, "${Routes.USER}?uid=$text");
      }
    }
  }
}
