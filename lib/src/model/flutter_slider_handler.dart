import 'package:flutter/widgets.dart';

class FlutterSliderHandler {
  BoxDecoration? decoration;
  BoxDecoration? foregroundDecoration;
  Matrix4? transform;
  Widget? child;
  bool disabled;
  double opacity;

  FlutterSliderHandler({
    this.child,
    this.decoration,
    this.foregroundDecoration,
    this.transform,
    this.disabled = false,
    this.opacity = 1,
  });

  @override
  String toString() {
    return child.toString() +
        '-' +
        disabled.toString() +
        '-' +
        decoration.toString() +
        '-' +
        foregroundDecoration.toString() +
        '-' +
        transform.toString() +
        '-' +
        opacity.toString();
  }
}
