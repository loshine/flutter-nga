import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/error_utils.dart';
import 'package:flutter_nga/utils/hooks/list_load_status.dart';
import 'package:flutter_nga/utils/route.dart';

/// 列表空状态 / 加载失败状态：图标 + 文案 + 可选操作按钮（默认重试，未登录时跳转登录）。
class ListStatusView extends StatelessWidget {
  const ListStatusView({
    super.key,
    required this.icon,
    required this.message,
    this.onRetry,
    this.actionLabel,
    this.onAction,
  }) : _isAuthError = false;

  /// 首次加载失败：展示错误原因；未登录错误展示「去登录」，其余错误展示「重试」。
  ListStatusView.error(Object error, {super.key, this.onRetry, this.onAction})
    : _isAuthError = isAuthRequiredError(error),
      icon = isAuthRequiredError(error)
          ? Icons.lock_outline
          : Icons.cloud_off_outlined,
      message = errorMessage(error, fallback: '加载失败'),
      actionLabel = isAuthRequiredError(error) ? '去登录' : '重试';

  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool _isAuthError;

  Future<void> _handleDefaultLogin(BuildContext context) async {
    await Routes.navigateTo(context, Routes.LOGIN);
    if (context.mounted) {
      onRetry?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final VoidCallback? effectiveAction = _isAuthError
        ? (onAction ?? () => _handleDefaultLogin(context))
        : (onAction ?? onRetry);
    final label = actionLabel ?? (_isAuthError ? '去登录' : '重试');

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
            if (effectiveAction != null) ...[
              const SizedBox(height: Dimen.spacingL),
              if (_isAuthError)
                FilledButton.icon(
                  onPressed: effectiveAction,
                  icon: const Icon(Icons.login),
                  label: Text(label),
                )
              else
                FilledButton.tonal(
                  onPressed: effectiveAction,
                  child: Text(label),
                ),
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
/// - 首次加载失败（[ListLoadStatus.error] 非空且无数据）：显示错误与重试/去登录；
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
    this.onLogin,
    required this.child,
  });

  final ListLoadStatus status;
  final bool isEmpty;
  final String emptyMessage;
  final IconData emptyIcon;
  final VoidCallback? onRetry;
  final VoidCallback? onLogin;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!isEmpty) return child;
    final error = status.error;
    final Widget view;
    if (error != null) {
      view = ListStatusView.error(error, onRetry: onRetry, onAction: onLogin);
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
