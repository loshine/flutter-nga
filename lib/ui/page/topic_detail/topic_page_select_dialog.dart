import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_nga/ui/widget/m3_dialog.dart';
import 'package:flutter_nga/utils/dimen.dart';

typedef PageSelectedCallback = Function(bool, int);

class TopicPageSelectDialog extends StatefulWidget {
  final int currentPage;
  final int maxPage;
  final int maxFloor;
  final PageSelectedCallback? pageSelectedCallback;
  final bool embedded;

  const TopicPageSelectDialog({
    super.key,
    required this.maxPage,
    required this.maxFloor,
    required this.currentPage,
    this.pageSelectedCallback,
    this.embedded = false,
  });

  static Future<void> show(
    BuildContext context, {
    required int currentPage,
    required int maxPage,
    required int maxFloor,
    PageSelectedCallback? pageSelectedCallback,
  }) {
    return showM3SelectionSheet<void>(
      context: context,
      builder: (_) => TopicPageSelectDialog(
        currentPage: currentPage,
        maxPage: maxPage,
        maxFloor: maxFloor,
        pageSelectedCallback: pageSelectedCallback,
        embedded: true,
      ),
    );
  }

  @override
  State<TopicPageSelectDialog> createState() => _TopicPageSelectState();
}

class _TopicPageSelectState extends State<TopicPageSelectDialog> {
  late int _currentVal;
  late TextEditingController _inputController;
  bool _isPage = true;

  int get _maxVal {
    final raw = _isPage ? widget.maxPage : widget.maxFloor;
    return raw < 1 ? 1 : raw;
  }

  @override
  void initState() {
    super.initState();
    _currentVal = widget.currentPage.clamp(1, _maxVal);
    _inputController = TextEditingController(text: '$_currentVal');
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  void _setValue(int next, {bool updateText = true}) {
    final clamped = next.clamp(1, _maxVal);
    setState(() {
      _currentVal = clamped;
      if (updateText) {
        final text = '$clamped';
        _inputController.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  void _submit() {
    final parsed = int.tryParse(_inputController.text.trim());
    final target = (parsed ?? _currentVal).clamp(1, _maxVal);
    widget.pageSelectedCallback?.call(_isPage, target);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final maxVal = _maxVal;
    final unit = _isPage ? '页' : '楼';

    final body = SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24, widget.embedded ? 4 : 24, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "跳转",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            // 精确步进与数字直输，高楼帖无需反复微调滑块
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  tooltip: '减少',
                  icon: const Icon(Icons.remove),
                  onPressed: _currentVal > 1
                      ? () => _setValue(_currentVal - 1)
                      : null,
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 112,
                  child: TextField(
                    key: const ValueKey('page_jump_input'),
                    controller: _inputController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.go,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: textTheme.titleLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      prefixText: '第 ',
                      suffixText: ' $unit',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (text) {
                      final parsed = int.tryParse(text);
                      if (parsed != null) {
                        _setValue(parsed, updateText: false);
                      }
                    },
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton.filledTonal(
                  tooltip: '增加',
                  icon: const Icon(Icons.add),
                  onPressed: _currentVal < maxVal
                      ? () => _setValue(_currentVal + 1)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '共 $maxVal $unit',
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _currentVal.clamp(1, maxVal).toDouble(),
              min: 1,
              max: maxVal > 1 ? maxVal.toDouble() : 2.0,
              divisions: maxVal > 1 ? maxVal - 1 : 1,
              label: '第 $_currentVal $unit',
              onChanged: maxVal > 1
                  ? (double newValue) => _setValue(newValue.round())
                  : null,
            ),
            const SizedBox(height: 12),
            Center(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('页码'),
                    icon: Icon(Icons.pages),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('楼层'),
                    icon: Icon(Icons.layers),
                  ),
                ],
                selected: {_isPage},
                onSelectionChanged: (Set<bool> newSelection) {
                  _isPage = newSelection.first;
                  _setValue(_isPage ? widget.currentPage : 1);
                },
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("取消"),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                FilledButton(onPressed: _submit, child: const Text("确认")),
              ],
            ),
          ],
        ),
      ),
    );

    if (widget.embedded) return body;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: body,
      ),
    );
  }
}
