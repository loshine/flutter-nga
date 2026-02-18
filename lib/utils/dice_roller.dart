class DiceContext {
  final int authorId;
  final int topicId;
  final int postId;
  final int seedOffset;
  int? _rndSeed;

  DiceContext({
    required this.authorId,
    required this.topicId,
    required this.postId,
    this.seedOffset = 0,
  });

  int _ensureSeed() {
    if (_rndSeed != null && _rndSeed != 0) return _rndSeed!;
    var seed = authorId + topicId + postId;
    if (topicId > 10246184 || postId > 200188932) seed += seedOffset;
    if (seed == 0) seed = DateTime.now().millisecond % 10000;
    _rndSeed = seed;
    return seed;
  }

  int _nextSeed() {
    final current = _ensureSeed();
    final next = (current * 9301 + 49297) % 233280;
    _rndSeed = next;
    return next;
  }

  int nextRoll(int faces) {
    final seed = _nextSeed();
    return (seed * faces) ~/ 233280 + 1;
  }
}

class DiceResult {
  final String original;
  final String expanded;
  final String total;
  DiceResult({required this.original, required this.expanded, required this.total});
}

class DiceRoller {
  static final _pattern = RegExp(
    r'(\+)(\d{0,10})(?:(d)(\d{1,10}))?',
    caseSensitive: false,
  );

  static DiceResult roll(String expression, DiceContext context) {
    if (expression.trim().isEmpty) {
      return DiceResult(original: expression, expanded: '', total: 'ERROR');
    }
    final working = '+$expression';
    final matches = _pattern.allMatches(working).toList();
    final output = StringBuffer();
    var cursor = 0;
    var sum = 0;
    var hasError = false;

    for (final match in matches) {
      output.write(working.substring(cursor, match.start));
      final digitsToken = match.group(2) ?? '';
      final hasDice = match.group(3) != null;
      final facesToken = match.group(4) ?? '';
      final diceCount = int.tryParse(digitsToken) ?? (hasDice ? 1 : 0);

      if (!hasDice) {
        output.write('+$diceCount');
        sum += diceCount;
      } else {
        final faces = int.tryParse(facesToken);
        if (faces == null || faces <= 0) {
          hasError = true;
          output.write('+INVALID');
        } else if (diceCount > 10 || faces > 100000) {
          hasError = true;
          output.write('+OUT OF LIMIT');
        } else {
          for (var i = 0; i < diceCount; i++) {
            final roll = context.nextRoll(faces);
            output.write('+d$facesToken($roll)');
            sum += roll;
          }
        }
      }
      cursor = match.end;
    }
    output.write(working.substring(cursor));
    var expanded = output.toString();
    if (expanded.isNotEmpty) expanded = expanded.substring(1);

    return DiceResult(
      original: expression,
      expanded: expanded,
      total: hasError ? 'ERROR' : '$sum',
    );
  }
}
