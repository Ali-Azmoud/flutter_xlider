class FlutterSliderRangeStep {
  final double? from;
  final double? to;
  final double? step;

  FlutterSliderRangeStep({
    this.from,
    this.to,
    this.step,
  }) : assert(from != null && to != null && step != null);

  @override
  String toString() {
    return from.toString() + '-' + to.toString() + '-' + step.toString();
  }
}
