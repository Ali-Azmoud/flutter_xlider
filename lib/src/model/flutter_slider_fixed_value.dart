class FlutterSliderFixedValue {
  final int? percent;
  final dynamic value;

  FlutterSliderFixedValue({
    this.percent,
    this.value,
  }) : assert(
            percent != null && value != null && percent >= 0 && percent <= 100);

  @override
  String toString() {
    return percent.toString() + '-' + value.toString();
  }
}
