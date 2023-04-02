import 'package:flutter/widgets.dart';

class FlutterSliderHandlerAnimation {
  final Curve curve;
  final Curve? reverseCurve;
  final Duration duration;
  final double scale;

  const FlutterSliderHandlerAnimation({
    this.curve = Curves.elasticOut,
    this.reverseCurve,
    this.duration = const Duration(milliseconds: 700),
    this.scale = 1.3,
  });

  @override
  String toString() {
    return curve.toString() +
        '-' +
        reverseCurve.toString() +
        '-' +
        duration.toString() +
        '-' +
        scale.toString();
  }
}
