import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_nga/providers/search/input_deletion_status_provider.dart';
import 'package:flutter_nga/providers/search/search_options_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchPage extends HookConsumerWidget {
  final int? fid;

  const SearchPage({this.fid, super.key});

  /// M3 SearchBar 推荐高度
  static const double _searchBarHeight = 56.0;

  /// M3 SearchBar 推荐圆角
  static const double _searchBarRadius = 28.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchQuery = useTextEditingController();
    final focusNode = useFocusNode();
    final isFocused = useState(false);
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

      void focusListener() {
        isFocused.value = focusNode.hasFocus;
      }

      searchQuery.addListener(textListener);
      focusNode.addListener(focusListener);
      return () {
        searchQuery.removeListener(textListener);
        focusNode.removeListener(focusListener);
      };
    }, []);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _buildSearchBar(
          context: context,
          controller: searchQuery,
          focusNode: focusNode,
          isFocused: isFocused.value,
          inputVisible: inputVisible,
          colorScheme: colorScheme,
          searchOptions: searchOptions,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索',
            onPressed: () =>
                _onSearch(context, searchQuery.text, searchOptions, fid),
          ),
        ],
      ),
      body: _buildBody(context, ref, searchOptions, searchOptionsNotifier),
    );
  }

  /// M3 风格的搜索输入框
  Widget _buildSearchBar({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isFocused,
    required bool inputVisible,
    required ColorScheme colorScheme,
    required SearchOptionsState searchOptions,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      height: _searchBarHeight,
      margin: const EdgeInsets.only(right: Dimen.spacingS),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(_searchBarRadius),
        // 焦点状态边框
        border: isFocused
            ? Border.all(
                color: colorScheme.primary,
                width: 2,
              )
            : null,
      ),
      child: Row(
        children: [
          // 搜索图标
          Padding(
            padding: const EdgeInsets.only(left: Dimen.spacingL),
            child: Icon(
              Icons.search,
              size: Dimen.iconMedium,
              color: isFocused
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
          // 输入框
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.search,
              onSubmitted: (text) =>
                  _onSearch(context, text, searchOptions, fid),
              maxLines: 1,
              style: textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface,
              ),
              cursorColor: colorScheme.primary,
              decoration: InputDecoration(
                hintText: '搜索...',
                hintStyle: textTheme.bodyLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Dimen.spacingM,
                  vertical: Dimen.spacingL,
                ),
                isDense: true,
              ),
            ),
          ),
          // 清除按钮
          if (inputVisible)
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => WidgetsBinding.instance
                    .addPostFrameCallback((_) => controller.clear()),
                borderRadius: BorderRadius.circular(_searchBarRadius),
                child: Padding(
                  padding: const EdgeInsets.all(Dimen.spacingM),
                  child: Icon(
                    Icons.close,
                    size: Dimen.iconMedium,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            const SizedBox(width: Dimen.spacingL),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    SearchOptionsState state,
    SearchOptionsNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(Dimen.spacingL),
      children: [
        // 搜索类型分组
        _buildOptionSection(
          context: context,
          title: '搜索类型',
          colorScheme: colorScheme,
          textTheme: textTheme,
          child: Wrap(
            spacing: Dimen.spacingS,
            runSpacing: Dimen.spacingS,
            children: [
              ChoiceChip(
                label: const Text('主题'),
                selected: state.firstRadio == FIRST_RADIO_TOPIC,
                onSelected: (_) => notifier.checkFirstRadio(FIRST_RADIO_TOPIC),
              ),
              ChoiceChip(
                label: const Text('版块'),
                selected: state.firstRadio == FIRST_RADIO_FORUM,
                onSelected: (_) => notifier.checkFirstRadio(FIRST_RADIO_FORUM),
              ),
              ChoiceChip(
                label: const Text('用户'),
                selected: state.firstRadio == FIRST_RADIO_USER,
                onSelected: (_) => notifier.checkFirstRadio(FIRST_RADIO_USER),
              ),
            ],
          ),
        ),

        // 主题搜索选项
        if (state.firstRadio == FIRST_RADIO_TOPIC) ...[
          if (fid != null)
            _buildOptionSection(
              context: context,
              title: '搜索范围',
              colorScheme: colorScheme,
              textTheme: textTheme,
              child: Wrap(
                spacing: Dimen.spacingS,
                runSpacing: Dimen.spacingS,
                children: [
                  ChoiceChip(
                    label: const Text('当前版块'),
                    selected: state.topicRadio == TOPIC_RADIO_CURRENT_FORUM,
                    onSelected: (_) =>
                        notifier.checkTopicRadio(TOPIC_RADIO_CURRENT_FORUM),
                  ),
                  ChoiceChip(
                    label: const Text('全部版块'),
                    selected: state.topicRadio == TOPIC_RADIO_ALL_FORUM,
                    onSelected: (_) =>
                        notifier.checkTopicRadio(TOPIC_RADIO_ALL_FORUM),
                  ),
                ],
              ),
            ),
          _buildOptionSection(
            context: context,
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
                  onSelected: (selected) => notifier.checkContent(selected),
                ),
              ],
            ),
          ),
        ],

        // 用户搜索选项
        if (state.firstRadio == FIRST_RADIO_USER)
          _buildOptionSection(
            context: context,
            title: '搜索方式',
            colorScheme: colorScheme,
            textTheme: textTheme,
            child: Wrap(
              spacing: Dimen.spacingS,
              runSpacing: Dimen.spacingS,
              children: [
                ChoiceChip(
                  label: const Text('用户名'),
                  selected: state.userRadio == USER_RADIO_NAME,
                  onSelected: (_) => notifier.checkUserRadio(USER_RADIO_NAME),
                ),
                ChoiceChip(
                  label: const Text('用户ID'),
                  selected: state.userRadio == USER_RADIO_UID,
                  onSelected: (_) => notifier.checkUserRadio(USER_RADIO_UID),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// 构建搜索选项分组卡片
  Widget _buildOptionSection({
    required BuildContext context,
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
                color: colorScheme.onSurfaceVariant,
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
      BuildContext context, String text, SearchOptionsState state, int? fid) {
    if (state.firstRadio == FIRST_RADIO_TOPIC) {
      if (fid == null) {
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
