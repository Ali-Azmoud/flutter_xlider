class FlutterSliderIgnoreSteps {
  final double? from;
  final double? to;

  FlutterSliderIgnoreSteps({
    this.from,
    this.to,
  }) : assert(from != null && to != null && from <= to);

  @override
  String toString() {
    return from.toString() + '-' + to.toString();
  }
}
