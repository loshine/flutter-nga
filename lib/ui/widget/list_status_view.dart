import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/error_utils.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';

/// 列表空状态 / 加载失败状态：图标 + 文案 + 可选「重试」按钮。
class ListStatusView extends StatelessWidget {
  const ListStatusView({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
  });

  /// 首次加载失败：展示错误原因与重试按钮。
  ListStatusView.error(Object error, {super.key, this.onRetry})
    : icon = Icons.cloud_off_outlined,
      message = errorMessage(error, fallback: '加载失败');

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Dimen.spacingXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: Dimen.spacingL),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge
                  ?.copyWith(color: colorScheme.onSurfaceVariant),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Dimen.spacingL),
              FilledButton.tonal(onPressed: onRetry, child: const Text('重试')),
            ],
          ],
        ),
      ),
    );
  }
}

/// 在列表与空 / 错误状态之间切换，用作 `EasyRefresh` 的 child。
///
/// - 有数据：显示 [child]；
/// - 首次加载失败（[ListLoadStatus.error] 非空且无数据）：显示错误与重试；
/// - 加载完成但没有数据：显示 [emptyMessage]，同样可重试；
/// - 首次加载中：显示 [child]（空列表），由下拉刷新头提示进度。
///
/// 状态视图放在可滚动容器里并撑满剩余高度，仍可下拉刷新。
class ListStatusSwitcher extends StatelessWidget {
  const ListStatusSwitcher({
    super.key,
    required this.status,
    required this.isEmpty,
    required this.emptyMessage,
    this.emptyIcon = Icons.inbox_outlined,
    this.onRetry,
    required this.child,
  });

  final ListLoadStatus status;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) return child;
    final error = status.error;
    final Widget view;
    if (error != null) {
      view = ListStatusView.error(error, onRetry: onRetry);
    } else if (status.loaded) {
      view = ListStatusView(
        icon: emptyIcon,
        message: emptyMessage,
        onRetry: onRetry,
      );
    } else {
      return child;
    }
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: view)],
    );
  }
}
