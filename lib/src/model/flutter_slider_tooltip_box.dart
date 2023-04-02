import 'package:flutter/widgets.dart';

class FlutterSliderTooltipBox {
  final BoxDecoration? decoration;
  final BoxDecoration? foregroundDecoration;
  final Matrix4? transform;

  const FlutterSliderTooltipBox({
    this.decoration,
    this.foregroundDecoration,
    this.transform,
  });

  @override
  String toString() {
    return decoration.toString() +
        '-' +
        foregroundDecoration.toString() +
        '-' +
        transform.toString();
  }
}
