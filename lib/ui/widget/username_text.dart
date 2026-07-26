import 'package:flutter/material.dart';
import 'package:flutter_nga/utils/name_utils.dart' as name_utils;
import 'package:flutter_nga/utils/route.dart';

class UsernameText extends StatelessWidget {
  const UsernameText({
    required this.username,
    this.uid,
    this.suffix = '',
    this.style,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    super.key,
  });

  final String username;
  final int? uid;
  final String suffix;
  final TextStyle? style;
  final int maxLines;
  final TextOverflow overflow;

  bool get _isAnonymous => username.startsWith('#anony_');

  bool get _hasValidUid => uid != null && uid! > 0;

  bool get _canNavigate => username.isNotEmpty && !_isAnonymous;

  String get _colorSeed => _hasValidUid ? '$uid' : username;

  @override
  Widget build(BuildContext context) {
    final displayName = name_utils.getShowName(username);
    final visibleText = '$displayName$suffix';
    final nameParts = _UsernameParts.from(
      displayName,
      highlightLastFour: username.startsWith('UID:'),
    );
    final textStyle = DefaultTextStyle.of(context).style.merge(style);
    final colors = _UsernameColors.fromSeed(
      _colorSeed,
      Theme.of(context).brightness,
    );
    final onTap = _canNavigate ? () => _navigateToUser(context) : null;

    final text = Text.rich(
      TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: nameParts.leading),
          if (nameParts.highlighted.isNotEmpty)
            WidgetSpan(
              alignment: PlaceholderAlignment.baseline,
              baseline: TextBaseline.alphabetic,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  nameParts.highlighted,
                  style: textStyle.copyWith(
                    color: colors.foreground,
                    fontWeight: textStyle.fontWeight ?? FontWeight.w600,
                  ),
                ),
              ),
            ),
          TextSpan(text: '${nameParts.trailing}$suffix'),
        ],
      ),
      maxLines: maxLines,
      overflow: overflow,
    );

    return Semantics(
      label: visibleText,
      link: _canNavigate,
      onTap: onTap,
      child: ExcludeSemantics(
        child: onTap == null
            ? text
            : Material(
                color: Colors.transparent,
                child: InkWell(onTap: onTap, child: text),
              ),
      ),
    );
  }

  void _navigateToUser(BuildContext context) {
    if (_hasValidUid) {
      Routes.navigateTo(
        context,
        Routes.USER,
        queryParams: {'uid': '$uid'},
      );
      return;
    }

    Routes.navigateTo(
      context,
      Routes.USER,
      queryParams: {'name': username},
    );
  }
}

class _UsernameColors {
  const _UsernameColors(this.background, this.foreground);

  final Color background;
  final Color foreground;

  factory _UsernameColors.fromSeed(String seed, Brightness brightness) {
    final hue = _stableHash(seed) % 360;
    final seedColor = HSLColor.fromAHSL(1, hue.toDouble(), 0.56, 0.5).toColor();
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return _UsernameColors(scheme.primary, scheme.onPrimary);
  }
}

class _UsernameParts {
  const _UsernameParts({
    required this.leading,
    required this.highlighted,
    required this.trailing,
  });

  final String leading;
  final String highlighted;
  final String trailing;

  factory _UsernameParts.from(
    String displayName, {
    required bool highlightLastFour,
  }) {
    final characters = displayName.characters;
    if (!highlightLastFour) {
      return _UsernameParts(
        leading: '',
        highlighted: characters.take(1).toString(),
        trailing: characters.skip(1).toString(),
      );
    }

    final nickname = characters.skip('UID:'.length);
    final highlightedLength = nickname.length > 4 ? 4 : nickname.length;
    return _UsernameParts(
      leading:
          characters.take(characters.length - highlightedLength).toString(),
      highlighted:
          nickname.skip(nickname.length - highlightedLength).toString(),
      trailing: '',
    );
  }
}

int _stableHash(String value) {
  var hash = 0x811c9dc5;
  for (final codeUnit in value.codeUnits) {
    hash ^= codeUnit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash;
}
