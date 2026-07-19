import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'blocklist_edit_dialog.dart';

class BlocklistKeywordsPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<BlocklistKeywordsPage> createState() =>
      _BlocklistKeywordsPageState();
}

class _BlocklistKeywordsPageState extends ConsumerState<BlocklistKeywordsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blocklistSettingsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blocklistSettingsProvider);
    final notifier = ref.read(blocklistSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text("屏蔽关键词"),
        actions: [
          IconButton(
            onPressed: () => _deleteAll(notifier),
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
            tooltip: "删除所有屏蔽关键词",
          ),
        ],
      ),
      body: ListView(
        children: state.blockWordList
            .map((e) => ListTile(
                  title: Text(code_utils.unescapeHtml(e)),
                  trailing: Icon(Icons.delete),
                  onTap: () => _delete(notifier, e),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: "添加屏蔽关键词",
        onPressed: () => _showAddDialog(notifier),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteAll(BlocklistSettingsNotifier notifier) async {
    try {
      AppToast.success(await notifier.deleteAllWords());
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Future<void> _delete(
    BlocklistSettingsNotifier notifier,
    String word,
  ) async {
    try {
      AppToast.success(await notifier.deleteWord(word));
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  Future<void> _add(
    BlocklistSettingsNotifier notifier,
    String word,
  ) async {
    try {
      AppToast.success(await notifier.addWord(word));
    } catch (e) {
      AppToast.error(e.toString());
    }
  }

  void _showAddDialog(BlocklistSettingsNotifier notifier) {
    showDialog(
        context: context,
        builder: (_) {
          return BlocklistEditDialog(
            title: "添加屏蔽词语",
            inputHint: "需要屏蔽的关键词",
            callback: (word) => _add(notifier, word),
          );
        });
  }
}
