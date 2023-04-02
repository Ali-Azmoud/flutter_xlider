import 'package:flutter/widgets.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class FlutterSliderTooltip {
  Widget Function(dynamic value)? custom;
  String Function(String value)? format;
  TextStyle? textStyle;
  FlutterSliderTooltipBox? boxStyle;
  Widget? leftPrefix;
  Widget? leftSuffix;
  Widget? rightPrefix;
  Widget? rightSuffix;
  bool? alwaysShowTooltip;
  bool? disabled;
  bool? disableAnimation;
  FlutterSliderTooltipDirection? direction;
  FlutterSliderTooltipPositionOffset? positionOffset;

  FlutterSliderTooltip({
    this.custom,
    this.format,
    this.textStyle,
    this.boxStyle,
    this.leftPrefix,
    this.leftSuffix,
    this.rightPrefix,
    this.rightSuffix,
    this.alwaysShowTooltip,
    this.disableAnimation,
    this.disabled,
    this.direction,
    this.positionOffset,
  });

  @override
  String toString() {
    return textStyle.toString() +
        '-' +
        boxStyle.toString() +
        '-' +
        leftPrefix.toString() +
        '-' +
        leftSuffix.toString() +
        '-' +
        rightPrefix.toString() +
        '-' +
        rightSuffix.toString() +
        '-' +
        alwaysShowTooltip.toString() +
        '-' +
        disabled.toString() +
        '-' +
        disableAnimation.toString() +
        '-' +
        direction.toString() +
        '-' +
        positionOffset.toString();
  }
}
