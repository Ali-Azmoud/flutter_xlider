import 'package:flutter/widgets.dart';

class FlutterSliderSizedBox {
  final BoxDecoration? decoration;
  final BoxDecoration? foregroundDecoration;
  final Matrix4? transform;
  final double width;
  final double height;

  const FlutterSliderSizedBox({
    this.decoration,
    this.foregroundDecoration,
    this.transform,
    required this.height,
    required this.width,
  }) : assert(width > 0 && height > 0);

  @override
  String toString() {
    return width.toString() +
        '-' +
        height.toString() +
        '-' +
        decoration.toString() +
        '-' +
        foregroundDecoration.toString() +
        '-' +
        transform.toString();
  }
}
