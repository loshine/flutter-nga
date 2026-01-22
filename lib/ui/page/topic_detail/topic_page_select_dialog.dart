import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/dimen.dart';
import 'package:flutter_nga/utils/route.dart';

typedef PageSelectedCallback = Function(bool, int);

class TopicPageSelectDialog extends StatefulWidget {
  final int currentPage;
  final int maxPage;
  final int maxFloor;
  final PageSelectedCallback? pageSelectedCallback;

  const TopicPageSelectDialog(
      {Key? key,
      required this.maxPage,
      required this.maxFloor,
      required this.currentPage,
      this.pageSelectedCallback})
      : super(key: key);

  @override
  _TopicPageSelectState createState() => _TopicPageSelectState();
}

class _TopicPageSelectState extends State<TopicPageSelectDialog> {
  int _currentVal = 1;
  bool _isPage = true;

  @override
  void initState() {
    _currentVal = widget.currentPage;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimen.radiusXL),
      ),
      backgroundColor: colorScheme.surfaceContainerHigh,
      child: Padding(
        padding: const EdgeInsets.all(24),
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
            Center(
              child: Text(
                "第 $_currentVal ${_isPage ? "页" : "楼"}",
                style: textTheme.titleLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _currentVal.toDouble(),
              min: 1,
              max: _isPage
                  ? widget.maxPage.toDouble()
                  : widget.maxFloor.toDouble(),
              divisions: _calcDivision(),
              onChanged: (double newValue) {
                setState(() {
                  _currentVal = newValue.round();
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<bool>(
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
                    setState(() {
                      _isPage = newSelection.first;
                      // Reset value when switching mode to avoid out of bounds or confusion
                      if (_isPage) {
                         _currentVal = widget.currentPage;
                      } else {
                         _currentVal = 1; 
                      }
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  child: const Text("取消"),
                  onPressed: () => Routes.pop(context),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  child: const Text("确认"),
                  onPressed: () {
                    widget.pageSelectedCallback?.call(_isPage, _currentVal);
                    Routes.pop(context);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calcDivision() {
    if (_isPage) {
      return widget.maxPage > 1 ? widget.maxPage - 1 : 1;
    } else {
      return widget.maxFloor > 1 ? widget.maxFloor - 1 : 1;
    }
  }
}