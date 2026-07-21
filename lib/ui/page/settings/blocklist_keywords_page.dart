import 'package:flutter/material.dart';
import 'package:flutter_nga/providers/settings/blocklist_settings_provider.dart';
import 'package:flutter_nga/utils/code_utils.dart' as code_utils;
import 'package:flutter_nga/utils/app_toast.dart';
import 'package:flutter_nga/utils/hooks/easy_refresh_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'blocklist_edit_dialog.dart';

class BlocklistKeywordsPage extends HookConsumerWidget {
  const BlocklistKeywordsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    usePostFrameEffect(() {
      ref.read(blocklistSettingsProvider.notifier).load();
    });

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
        onPressed: () => _showAddDialog(context, notifier),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _deleteAll(BlocklistSettingsNotifier notifier) async {
    try {
      AppToast.success(await notifier.deleteAllWords());
    } catch (e) {
      AppToast.error(e);
    }
  }

  Future<void> _delete(
    BlocklistSettingsNotifier notifier,
    String word,
  ) async {
    try {
      AppToast.success(await notifier.deleteWord(word));
    } catch (e) {
      AppToast.error(e);
    }
  }

  Future<void> _add(
    BlocklistSettingsNotifier notifier,
    String word,
  ) async {
    try {
      AppToast.success(await notifier.addWord(word));
    } catch (e) {
      AppToast.error(e);
    }
  }

  void _showAddDialog(
    BuildContext context,
    BlocklistSettingsNotifier notifier,
  ) {
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
