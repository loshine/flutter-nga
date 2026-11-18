import 'package:flutter/foundation.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

/// 列表页首次加载的结果，配合 `ListStatusSwitcher` 展示空状态 / 错误状态。
class ListLoadStatus extends ChangeNotifier {
  bool _loaded = false;
  Object? _error;

  /// 至少成功加载过一次
  bool get loaded => _loaded;

  /// 列表为空时最近一次加载的错误；成功加载后清空
  Object? get error => _error;

  void succeed() {
    if (_loaded && _error == null) return;
    _loaded = true;
    _error = null;
    notifyListeners();
  }

  /// 记录一次加载失败。
  ///
  /// 列表还没有数据时把错误交给页面展示并返回 true；已有数据时返回 false，
  /// 由调用方保留原有的 toast 提示。
  bool fail(Object error, {required bool hasData}) {
    if (hasData) return false;
    _error = error;
    notifyListeners();
    return true;
  }
}

/// 创建随 hook 生命周期释放的 [ListLoadStatus]，状态变化时重建。
ListLoadStatus useListLoadStatus() {
  final status = useMemoized(ListLoadStatus.new);
  useEffect(() => status.dispose, [status]);
  useListenable(status);
  return status;
}
