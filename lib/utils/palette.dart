import 'dart:ui';

import 'package:flutter/material.dart';

/// 调色板
class Palette {
  static final colorPrimary = Colors.brown;
  static final colorDarkPrimary = Colors.teal;
  static final colorBackground = Color(0xFFFFF9E3);
  static final colorDivider = Color(0xFFBDBDBD);
  static final colorIcon = Colors.black45;
  static final colorSplash = Colors.black12;
  static final colorHighlight = Colors.black12;

  static final colorTextPrimary = Colors.black87;
  static final colorTextSecondary = Colors.black54;
  static final colorTextHintWhite = Colors.white54;
  static final colorTextSubTitle = Color(0xFF591804);
  static final colorTextLock = Color(0xFFC58080);
  static final colorTextAssemble = Color(0xFFA0B4F0);

  static final colorWhite = Colors.white;

  static final _colorThumbBackground = Color(0xFFE0C19E);

  static final _colorQuoteBackground = Color(0xFFF9EFD6);
  static final _colorAlbumBorder = Color(0xFF91B262);
  static final _colorAlbumBackground = Color(0xFFd6dcae);

  static Color getColorThumbBackground(BuildContext context) {
    return isDark(context) ? Colors.white24 : _colorThumbBackground;
  }

  static Color getColorQuoteBackground(BuildContext context) {
    return isDark(context) ? Colors.white24 : _colorQuoteBackground;
  }

  static Color getColorAlbumBorder(BuildContext context) {
    return isDark(context) ? Palette.colorDivider : _colorAlbumBorder;
  }

  static Color getColorAlbumBackground(BuildContext context) {
    return isDark(context) ? Colors.white24 : _colorAlbumBackground;
  }

  static Color? getColorUserInfoCard(BuildContext context) {
    return isDark(context) ? null : Color(0xFFF5E8CB);
  }

  static Color getColorTextSubtitle(BuildContext context) {
    return isDark(context) ? Colors.white : colorTextSubTitle;
  }

  static Color? getColorDrawerListTileBackground(BuildContext context) {
    return isDark(context) ? Colors.white70 : null;
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
