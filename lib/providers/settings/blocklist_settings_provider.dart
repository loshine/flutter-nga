import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_nga/data/core/app_preferences.dart';
import 'package:flutter_nga/data/entity/block.dart';
import 'package:flutter_nga/data/entity/topic.dart';
import 'package:flutter_nga/data/entity/topic_detail.dart';
import 'package:flutter_nga/providers/core/repository_providers.dart';

enum BlockMode { COLLAPSE, PAINT, ALPHA, DELETE_LINE, GONE }

extension BlockModeExtension on BlockMode {
  String get name {
    switch (this) {
      case BlockMode.COLLAPSE:
        return "折叠";
      case BlockMode.PAINT:
        return "涂抹";
      case BlockMode.ALPHA:
        return "淡化";
      case BlockMode.DELETE_LINE:
        return "删除线";
      case BlockMode.GONE:
        return "隐藏";
    }
  }
}

class BlocklistSettingsState {
  final bool clientBlockEnabled;
  final bool listBlockEnabled;
  final bool detailsBlockEnabled;
  final BlockMode blockMode;
  final List<String> blockUserList;
  final List<String> blockWordList;

  const BlocklistSettingsState({
    this.clientBlockEnabled = false,
    this.listBlockEnabled = true,
    this.detailsBlockEnabled = true,
    this.blockMode = BlockMode.COLLAPSE,
    this.blockUserList = const [],
    this.blockWordList = const [],
  });

  BlocklistSettingsState copyWith({
    bool? clientBlockEnabled,
    bool? listBlockEnabled,
    bool? detailsBlockEnabled,
    BlockMode? blockMode,
    List<String>? blockUserList,
    List<String>? blockWordList,
  }) {
    return BlocklistSettingsState(
      clientBlockEnabled: clientBlockEnabled ?? this.clientBlockEnabled,
      listBlockEnabled: listBlockEnabled ?? this.listBlockEnabled,
      detailsBlockEnabled: detailsBlockEnabled ?? this.detailsBlockEnabled,
      blockMode: blockMode ?? this.blockMode,
      blockUserList: blockUserList ?? this.blockUserList,
      blockWordList: blockWordList ?? this.blockWordList,
    );
  }
}

class BlocklistSettingsNotifier extends Notifier<BlocklistSettingsState> {
  SharedPreferencesWithCache? _prefs;
  Timer? _syncTimer;
  final _pendingUsers = <String, int>{};
  final _pendingWords = <String, int>{};
  final _queuedUserCommits = <String, int>{};
  final _queuedWordCommits = <String, int>{};
  Future<void> _writeTail = Future<void>.value();

  bool get hasPendingUserDeletion => _pendingUsers.isNotEmpty;
  bool get hasPendingWordDeletion => _pendingWords.isNotEmpty;

  /// 串行化提交到服务端的写请求，避免并发提交导致旧快照覆盖新结果。
  Future<T> _enqueueWrite<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _writeTail = _writeTail.then((_) async {
      try {
        completer.complete(await action());
      } catch (err, st) {
        completer.completeError(err, st);
      }
    });
    return completer.future;
  }

  /// 构造应提交给服务端的名单：将仍处于撤销窗口或排在后面的待删项按逆序插回，
  /// 确保本次提交不会顺带删掉其他尚未确认删除的条目。
  List<String> _listWithPending(
    List<String> current,
    Map<String, int> pending,
    Map<String, int> queued,
  ) {
    if (pending.isEmpty && queued.isEmpty) return current;
    final result = [...current];
    final combined = [...queued.entries, ...pending.entries].reversed;
    for (final entry in combined) {
      if (result.contains(entry.key)) continue;
      final clamped = entry.value.clamp(0, result.length);
      result.insert(clamped, entry.key);
    }
    return result;
  }

  List<String> _serverUsers() =>
      _listWithPending(state.blockUserList, _pendingUsers, _queuedUserCommits);

  List<String> _serverWords() =>
      _listWithPending(state.blockWordList, _pendingWords, _queuedWordCommits);

  @override
  BlocklistSettingsState build() {
    ref.onDispose(() {
      _syncTimer?.cancel();
    });
    return const BlocklistSettingsState();
  }

  Future<SharedPreferencesWithCache> get _settings async {
    _prefs ??= await AppPreferences.instance();
    return _prefs!;
  }

  Future<void> init() async {
    final settings = await _settings;
    final clientBlockEnabled =
        settings.getBool(PrefsKeys.blocklistClientBlockEnabled) ?? false;
    final listBlockEnabled =
        settings.getBool(PrefsKeys.blocklistListBlockEnabled) ?? true;
    final detailsBlockEnabled =
        settings.getBool(PrefsKeys.blocklistDetailsBlockEnabled) ?? true;
    final blockModeIndex =
        settings.getInt(PrefsKeys.blocklistBlockMode) ??
        BlockMode.COLLAPSE.index;

    state = state.copyWith(
      clientBlockEnabled: clientBlockEnabled,
      listBlockEnabled: listBlockEnabled,
      detailsBlockEnabled: detailsBlockEnabled,
      blockMode: _getBlockModeByIndex(blockModeIndex),
    );
  }

  void loopSyncBlockList() {
    Future.delayed(Duration(), () async {
          debugPrint('定时任务');
          if (await ref.read(userRepositoryProvider).getDefaultUser() != null) {
            await load();
          }
        })
        .whenComplete(() {
          _syncTimer?.cancel();
          _syncTimer = Timer(Duration(minutes: 5), () => loopSyncBlockList());
        })
        .catchError((err) {
          debugPrint(err.toString());
        });
  }

  Future<void> setClientBlockEnabled(bool enabled) async {
    state = state.copyWith(clientBlockEnabled: enabled);
    final settings = await _settings;
    await settings.setBool(PrefsKeys.blocklistClientBlockEnabled, enabled);
  }

  Future<void> setListBlockEnabled(bool enabled) async {
    state = state.copyWith(listBlockEnabled: enabled);
    final settings = await _settings;
    await settings.setBool(PrefsKeys.blocklistListBlockEnabled, enabled);
  }

  Future<void> setDetailsBlockEnabled(bool enabled) async {
    state = state.copyWith(detailsBlockEnabled: enabled);
    final settings = await _settings;
    await settings.setBool(PrefsKeys.blocklistDetailsBlockEnabled, enabled);
  }

  Future<void> load() async {
    try {
      final blockInfo = await ref.read(userRepositoryProvider).getBlockInfo();
      final hiddenUsers = {..._pendingUsers.keys, ..._queuedUserCommits.keys};
      final hiddenWords = {..._pendingWords.keys, ..._queuedWordCommits.keys};
      state = state.copyWith(
        blockUserList: blockInfo.blockUserList
            .where((u) => !hiddenUsers.contains(u))
            .toList(),
        blockWordList: blockInfo.blockWordList
            .where((w) => !hiddenWords.contains(w))
            .toList(),
      );
    } catch (err) {
      rethrow;
    }
  }

  Future<String> addUser(String user) {
    return _enqueueWrite(() async {
      final submitUsers = <String>[..._serverUsers(), user];
      final content = await ref
          .read(userRepositoryProvider)
          .setBlockInfo(BlockInfoData(submitUsers, _serverWords()));
      if (ref.mounted && !state.blockUserList.contains(user)) {
        state = state.copyWith(blockUserList: [...state.blockUserList, user]);
      }
      return content;
    });
  }

  /// 先从本地列表移除，等待 [commitUserDeletion] 或 [undoUserDeletion]。
  void removeUserLocally(String user) {
    final index = state.blockUserList.indexOf(user);
    if (index < 0) return;
    _pendingUsers[user] = index;
    state = state.copyWith(
      blockUserList: [...state.blockUserList]..removeAt(index),
    );
  }

  /// 撤销屏蔽用户移除，按原位插回。
  void undoUserDeletion(String user) {
    final index = _pendingUsers.remove(user);
    if (index == null) return;
    _restoreUser(user, index);
  }

  /// 提交待删屏蔽用户到服务端；失败时插回列表并抛出错误。
  Future<String?> commitUserDeletion(String user) async {
    final index = _pendingUsers.remove(user);
    if (index == null) return null;
    _queuedUserCommits[user] = index;
    return _enqueueWrite(() async {
      _queuedUserCommits.remove(user);
      try {
        return await ref
            .read(userRepositoryProvider)
            .setBlockInfo(BlockInfoData(_serverUsers(), _serverWords()));
      } catch (err) {
        if (ref.mounted) _restoreUser(user, index);
        rethrow;
      }
    });
  }

  /// 离开页面时立即提交全部待删屏蔽用户。
  Future<Object?> commitAllPendingUserDeletions() async {
    Object? firstError;
    for (final user in [..._pendingUsers.keys]) {
      try {
        await commitUserDeletion(user);
      } catch (err) {
        firstError ??= err;
      }
    }
    return firstError;
  }

  void _restoreUser(String user, int index) {
    if (state.blockUserList.contains(user)) return;
    final clamped = index.clamp(0, state.blockUserList.length);
    state = state.copyWith(
      blockUserList: [...state.blockUserList]..insert(clamped, user),
    );
  }

  Future<String> deleteUser(String user) {
    return _enqueueWrite(() async {
      final submitUsers = _serverUsers().where((e) => e != user).toList();
      final content = await ref
          .read(userRepositoryProvider)
          .setBlockInfo(BlockInfoData(submitUsers, _serverWords()));
      if (ref.mounted) {
        state = state.copyWith(
          blockUserList: state.blockUserList.where((e) => e != user).toList(),
        );
      }
      return content;
    });
  }

  Future<String> deleteAllUsers() {
    _pendingUsers.clear();
    _queuedUserCommits.clear();
    return _enqueueWrite(() async {
      final content = await ref
          .read(userRepositoryProvider)
          .setBlockInfo(BlockInfoData(const [], _serverWords()));
      if (ref.mounted) {
        state = state.copyWith(blockUserList: []);
      }
      return content;
    });
  }

  Future<String> addWord(String word) {
    return _enqueueWrite(() async {
      final submitWords = <String>[..._serverWords(), word];
      final content = await ref
          .read(userRepositoryProvider)
          .setBlockInfo(BlockInfoData(_serverUsers(), submitWords));
      if (ref.mounted && !state.blockWordList.contains(word)) {
        state = state.copyWith(blockWordList: [...state.blockWordList, word]);
      }
      return content;
    });
  }

  /// 先从本地列表移除，等待 [commitWordDeletion] 或 [undoWordDeletion]。
  void removeWordLocally(String word) {
    final index = state.blockWordList.indexOf(word);
    if (index < 0) return;
    _pendingWords[word] = index;
    state = state.copyWith(
      blockWordList: [...state.blockWordList]..removeAt(index),
    );
  }

  /// 撤销屏蔽关键词移除，按原位插回。
  void undoWordDeletion(String word) {
    final index = _pendingWords.remove(word);
    if (index == null) return;
    _restoreWord(word, index);
  }

  /// 提交待删屏蔽关键词到服务端；失败时插回列表并抛出错误。
  Future<String?> commitWordDeletion(String word) async {
    final index = _pendingWords.remove(word);
    if (index == null) return null;
    _queuedWordCommits[word] = index;
    return _enqueueWrite(() async {
      _queuedWordCommits.remove(word);
      try {
        return await ref
            .read(userRepositoryProvider)
            .setBlockInfo(BlockInfoData(_serverUsers(), _serverWords()));
      } catch (err) {
        if (ref.mounted) _restoreWord(word, index);
        rethrow;
      }
    });
  }

  /// 离开页面时立即提交全部待删屏蔽关键词。
  Future<Object?> commitAllPendingWordDeletions() async {
    Object? firstError;
    for (final word in [..._pendingWords.keys]) {
      try {
        await commitWordDeletion(word);
      } catch (err) {
        firstError ??= err;
      }
    }
    return firstError;
  }

  void _restoreWord(String word, int index) {
    if (state.blockWordList.contains(word)) return;
    final clamped = index.clamp(0, state.blockWordList.length);
    state = state.copyWith(
      blockWordList: [...state.blockWordList]..insert(clamped, word),
    );
  }

  Future<String> deleteWord(String word) {
    return _enqueueWrite(() async {
      final submitWords = _serverWords().where((e) => e != word).toList();
      final content = await ref
          .read(userRepositoryProvider)
          .setBlockInfo(BlockInfoData(_serverUsers(), submitWords));
      if (ref.mounted) {
        state = state.copyWith(
          blockWordList: state.blockWordList.where((e) => e != word).toList(),
        );
      }
      return content;
    });
  }

  Future<String> deleteAllWords() {
    _pendingWords.clear();
    _queuedWordCommits.clear();
    return _enqueueWrite(() async {
      final content = await ref
          .read(userRepositoryProvider)
          .setBlockInfo(BlockInfoData(_serverUsers(), const []));
      if (ref.mounted) {
        state = state.copyWith(blockWordList: []);
      }
      return content;
    });
  }

  Future<void> updateBlockMode(BlockMode mode) async {
    final settings = await _settings;
    await settings.setInt(PrefsKeys.blocklistBlockMode, mode.index);
    state = state.copyWith(blockMode: mode);
  }

  BlockMode _getBlockModeByIndex(int index) {
    switch (index) {
      case 0:
        return BlockMode.COLLAPSE;
      case 1:
        return BlockMode.PAINT;
      case 2:
        return BlockMode.ALPHA;
      case 3:
        return BlockMode.DELETE_LINE;
      case 4:
        return BlockMode.GONE;
      default:
        return BlockMode.COLLAPSE;
    }
  }
}

final blocklistSettingsProvider =
    NotifierProvider<BlocklistSettingsNotifier, BlocklistSettingsState>(
      BlocklistSettingsNotifier.new,
    );

/// 屏蔽判定结果：组合开关、屏蔽模式与匹配规则，UI 只按返回的 [BlockMode] 渲染
class BlockFilter {
  BlockFilter({
    required this.mode,
    required this.listEnabled,
    required this.detailsEnabled,
    required this.matcher,
  });

  factory BlockFilter.fromSettings(BlocklistSettingsState state) {
    final matcher = BlockMatcher(
      users: state.blockUserList,
      words: state.blockWordList,
    );
    return BlockFilter(
      mode: state.blockMode,
      listEnabled: state.clientBlockEnabled && state.listBlockEnabled,
      detailsEnabled: state.clientBlockEnabled && state.detailsBlockEnabled,
      matcher: matcher,
    );
  }

  final BlockMode mode;
  final bool listEnabled;
  final bool detailsEnabled;
  final BlockMatcher matcher;

  /// 主题被屏蔽时返回展示模式，否则返回 null
  BlockMode? topicMode(Topic topic) {
    if (!listEnabled || matcher.isEmpty) return null;
    return matcher.matchesTopic(topic) ? mode : null;
  }

  /// 楼层被屏蔽时返回展示模式，否则返回 null
  BlockMode? replyMode(Reply reply, {String? username}) {
    if (!detailsEnabled || matcher.isEmpty) return null;
    return matcher.matchesReply(reply, username: username) ? mode : null;
  }

  /// 隐藏模式下直接移除被屏蔽的主题，避免列表中残留零高度条目
  List<Topic> visibleTopics(List<Topic> topics) {
    if (mode != BlockMode.GONE) return topics;
    return topics.where((topic) => topicMode(topic) == null).toList();
  }
}

final blockFilterProvider = Provider<BlockFilter>((ref) {
  return BlockFilter.fromSettings(ref.watch(blocklistSettingsProvider));
});
