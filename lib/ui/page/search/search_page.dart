import 'package:cupertino_ui/cupertino_ui.dart' show CupertinoSearchTextField;
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
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

class SearchPage extends HookConsumerWidget {
  final int? fid;

  const SearchPage({this.fid, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useTextEditingController();
    final focusNode = useFocusNode();
    final inputVisible = ref.watch(inputDeletionStatusProvider);
    final searchOptions = ref.watch(searchOptionsProvider(fid));
    final searchOptionsNotifier = ref.read(searchOptionsProvider(fid).notifier);
    final colorScheme = Theme.of(context).colorScheme;

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
      FIRST_RADIO_FORUM => '搜索版块名称...',
      FIRST_RADIO_USER =>
        searchOptions.userRadio == USER_RADIO_UID ? '输入用户 ID...' : '输入用户名...',
      _ => '搜索主题关键词...',
    };

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
                    keyboardType:
                        searchOptions.firstRadio == FIRST_RADIO_USER &&
                            searchOptions.userRadio == USER_RADIO_UID
                        ? TextInputType.number
                        : TextInputType.text,
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
                    keyboardType:
                        searchOptions.firstRadio == FIRST_RADIO_USER &&
                            searchOptions.userRadio == USER_RADIO_UID
                        ? TextInputType.number
                        : TextInputType.text,
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
      body: _buildBody(context, searchOptions, searchOptionsNotifier),
    );
  }

  Widget _buildBody(
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
            child: AppSegmentedControl<int>(
              segments: [
                const AppSegment(
                  value: FIRST_RADIO_TOPIC,
                  label: '主题',
                  icon: Icons.article_outlined,
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
            ),
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
              child: context.isAppleStyle
                  ? Row(
                      children: [
                        Expanded(
                          child: Text(
                            '包括正文',
                            style: textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        AppSwitch(
                          value: state.content,
                          onChanged: notifier.checkContent,
                        ),
                      ],
                    )
                  : Wrap(
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
    String text,
    SearchOptionsState state,
    int? fid,
  ) {
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
