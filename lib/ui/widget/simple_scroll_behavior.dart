import 'package:flutter/material.dart';

class SimpleScrollBehavior extends ScrollBehavior {
  @override
  Widget buildScrollbar(
      BuildContext context, Widget child, ScrollableDetails details) {
    // Don't show scrollbar for cleaner UI (especially on macOS TabBar)
    return child;
  }
}