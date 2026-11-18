import 'package:material_ui/material_ui.dart';

class Dash extends StatelessWidget {
  const Dash({
    super.key,
    this.direction = Axis.horizontal,
    this.dashColor,
    this.length = 200,
    this.dashGap = 3,
    this.dashLength = 6,
    this.dashThickness = 1,
    this.dashBorderRadius = 0,
  });

  final Axis direction;

  /// 为空时使用主题的 [ColorScheme.outlineVariant]。
  final Color? dashColor;
  final double length;
  final double dashGap;
  final double dashLength;
  final double dashThickness;
  final double dashBorderRadius;

  @override
  Widget build(BuildContext context) {
    final color = dashColor ?? Theme.of(context).colorScheme.outlineVariant;
    var dashes = <Widget>[];
    double n = (length + dashGap) / (dashGap + dashLength);
    int newN = n.round();
    double newDashGap = (length - dashLength * newN) / (newN - 1);
    for (var i = newN; i > 0; i--) {
      dashes.add(step(i, newDashGap, color));
    }
    if (direction == Axis.horizontal) {
      return SizedBox(
        width: length,
        child: Row(children: dashes),
      );
    } else {
      return Column(children: dashes);
    }
  }

  Widget step(int index, double newDashGap, Color color) {
    bool isHorizontal = direction == Axis.horizontal;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        0,
        0,
        isHorizontal && index != 1 ? newDashGap : 0,
        isHorizontal || index == 1 ? 0 : newDashGap,
      ),
      child: SizedBox(
        width: isHorizontal ? dashLength : dashThickness,
        height: isHorizontal ? dashThickness : dashLength,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.all(Radius.circular(dashBorderRadius)),
          ),
        ),
      ),
    );
  }
}
