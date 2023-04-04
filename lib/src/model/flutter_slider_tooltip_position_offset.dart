class FlutterSliderTooltipPositionOffset {
  double? top;
  double? left;
  double? right;
  double? bottom;

  FlutterSliderTooltipPositionOffset({
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  String toString() {
    return top.toString() +
        '-' +
        left.toString() +
        '-' +
        bottom.toString() +
        '-' +
        right.toString();
  }
}
