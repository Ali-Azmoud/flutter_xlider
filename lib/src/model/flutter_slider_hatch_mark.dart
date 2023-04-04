import 'package:flutter_xlider/flutter_xlider.dart';

class FlutterSliderHatchMark {
  bool disabled;
  double density;
  double? linesDistanceFromTrackBar;
  double? labelsDistanceFromTrackBar;
  List<FlutterSliderHatchMarkLabel>? labels;
  FlutterSliderSizedBox? smallLine;
  FlutterSliderSizedBox? bigLine;
  FlutterSliderSizedBox? labelBox;
  FlutterSliderHatchMarkAlignment linesAlignment;
  bool? displayLines;

  FlutterSliderHatchMark({
    this.disabled = false,
    this.density = 1,
    this.linesDistanceFromTrackBar,
    this.labelsDistanceFromTrackBar,
    this.labels,
    this.smallLine,
    this.bigLine,
    this.linesAlignment = FlutterSliderHatchMarkAlignment.right,
    this.labelBox,
    this.displayLines,
  }) : assert(density > 0 && density <= 2);

  @override
  String toString() {
    return disabled.toString() +
        '-' +
        density.toString() +
        '-' +
        linesDistanceFromTrackBar.toString() +
        '-' +
        labelsDistanceFromTrackBar.toString() +
        '-' +
        labels.toString() +
        '-' +
        smallLine.toString() +
        '-' +
        bigLine.toString() +
        '-' +
        labelBox.toString() +
        '-' +
        linesAlignment.toString() +
        '-' +
        displayLines.toString();
  }
}
