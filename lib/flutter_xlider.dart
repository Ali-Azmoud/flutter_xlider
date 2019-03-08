import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// A material design slider and range slider with rtl support and lots of options and customizations for flutter
class FlutterSlider extends StatefulWidget {
  final Key key;
  final Axis axis;
  final double handlerWidth;
  final double handlerHeight;
  final FlutterSliderHandler handler;
  final FlutterSliderHandler rightHandler;
  final Function(int handlerIndex, double lowerValue, double upperValue)
      onDragStarted;
  final Function(int handlerIndex, double lowerValue, double upperValue)
      onDragCompleted;
  final Function(int handlerIndex, double lowerValue, double upperValue)
      onDragging;
  final double min;
  final double max;
  final List<double> values;
  final bool rangeSlider;
  final bool rtl;
  final bool jump;
  final List<FlutterSliderIgnoreSteps> ignoreSteps;
  final bool disabled;
  final int touchZone;
  final bool displayTestTouchZone;
  final double minimumDistance;
  final double maximumDistance;
  final FlutterSliderHandlerAnimation handlerAnimation;
  final FlutterSliderTooltip tooltip;
  final FlutterSliderTrackBar trackBar;
  final double step;

  FlutterSlider(
      {this.key,
      @required this.min,
      @required this.max,
      @required this.values,
      this.axis = Axis.horizontal,
      this.handler,
      this.rightHandler,
      this.handlerHeight = 35,
      this.handlerWidth = 35,
      this.onDragStarted,
      this.onDragCompleted,
      this.onDragging,
      this.rangeSlider = false,
      this.rtl = false,
      this.jump = false,
      this.ignoreSteps = const [],
      this.disabled = false,
      this.touchZone = 2,
      this.displayTestTouchZone = false,
      this.minimumDistance = 0,
      this.maximumDistance = 0,
      this.tooltip,
      this.trackBar = const FlutterSliderTrackBar(),
      this.handlerAnimation = const FlutterSliderHandlerAnimation(),
      this.step = 1})
      : assert(touchZone != null && (touchZone >= 1 && touchZone <= 5)),
        assert(min != null && max != null && min <= max),
        assert(handlerAnimation != null),
        super(key: key);

  @override
  _FlutterSliderState createState() => _FlutterSliderState();
}

class _FlutterSliderState extends State<FlutterSlider>
    with TickerProviderStateMixin {
  Widget leftHandler;
  Widget rightHandler;

  double _leftHandlerXPosition = -1;
  double _rightHandlerXPosition = 0;
  double _leftHandlerYPosition = -1;
  double _rightHandlerYPosition = 0;

  double _lowerValue = 0;
  double _upperValue = 0;
  double _outputLowerValue = 0;
  double _outputUpperValue = 0;

  double _fakeMin;
  double _fakeMax;

  double _divisions;
  double _handlersPadding = 0;

  GlobalKey leftHandlerKey = GlobalKey();
  GlobalKey rightHandlerKey = GlobalKey();
  GlobalKey containerKey = GlobalKey();

  double _handlersWidth = 30;
  double _handlersHeight = 30;

  double _constraintMaxWidth;
  double _constraintMaxHeight;

  double _containerWidthWithoutPadding;
  double _containerHeightWithoutPadding;

  double _containerLeft = 0;
  double _containerTop = 0;

  FlutterSliderTooltip _tooltipData;

  List<Function> _positionedItems;

  double _finalLeftHandlerWidth;
  double _finalRightHandlerWidth;
  double _finalLeftHandlerHeight;
  double _finalRightHandlerHeight;

  double _rightTooltipOpacity = 0;
  double _leftTooltipOpacity = 0;

  AnimationController _rightTooltipAnimationController;
  Animation<Offset> _rightTooltipAnimation;
  AnimationController _leftTooltipAnimationController;
  Animation<Offset> _leftTooltipAnimation;

  AnimationController _leftHandlerScaleAnimationController;
  Animation<double> _leftHandlerScaleAnimation;
  AnimationController _rightHandlerScaleAnimationController;
  Animation<double> _rightHandlerScaleAnimation;

  double _originalLowerValue;
  double _originalUpperValue;

  double _containerHeight;
  double _containerWidth;

  int _decimalScale = 0;

  double xDragTmp = 0;
  double yDragTmp = 0;

  @override
  void initState() {
    // validate inputs
    _validations();

    // to display min of the range correctly.
    // if we use fakes, then min is always 0
    // so calculations works well, but when we want to display
    // result numbers to user, we add ( widget.min ) to the final numbers
    _fakeMin = 0;
    _fakeMax = widget.max - widget.min;

    _handlersWidth = widget.handlerWidth;
    _handlersHeight = widget.handlerHeight;

    // lower value. if not available then min will be used
    _originalLowerValue =
        (widget.values[0] != null) ? widget.values[0] : widget.min;
    if (widget.rangeSlider == true) {
      _originalUpperValue =
          (widget.values[1] != null) ? widget.values[1] : widget.max;
    } else {
      // when direction is rtl, then we use left handler. so to make right hand side
      // as blue ( as if selected ), then upper value should be max
      if (widget.rtl == true) {
        _originalUpperValue = widget.max;
      } else {
        // when direction is ltr, so we use right handler, to make left hand side of handler
        // as blue ( as if selected ), we set lower value to min, and upper value to (input lower value)
        _originalUpperValue = _originalLowerValue;
        _originalLowerValue = widget.min;
      }
    }

    _lowerValue = _originalLowerValue - widget.min;
    _upperValue = _originalUpperValue - widget.min;

    String tmpDecimalScale = widget.step.toString().split(".")[1];
    if (int.parse(tmpDecimalScale) > 0) {
      _decimalScale = tmpDecimalScale.length;
    }

    if (widget.rangeSlider == true &&
        widget.maximumDistance != null &&
        widget.maximumDistance > 0 &&
        (_upperValue - _lowerValue) > widget.maximumDistance) {
      throw 'lower and upper distance is more than maximum distance';
    }
    if (widget.rangeSlider == true &&
        widget.minimumDistance != null &&
        widget.minimumDistance > 0 &&
        (_upperValue - _lowerValue) < widget.minimumDistance) {
      throw 'lower and upper distance is less than minimum distance';
    }

    _tooltipData = widget.tooltip ?? FlutterSliderTooltip();
    _tooltipData.boxStyle ??= FlutterSliderTooltipBox(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.black12, width: 0.5),
            color: Color(0xffffffff)));
    _tooltipData.textStyle ??= TextStyle(fontSize: 12, color: Colors.black38);
    _tooltipData.leftPrefix ??= Container();
    _tooltipData.leftSuffix ??= Container();
    _tooltipData.rightPrefix ??= Container();
    _tooltipData.rightSuffix ??= Container();
    _tooltipData.alwaysShowTooltip ??= false;
    _tooltipData.disabled ??= false;

    _rightTooltipOpacity = (_tooltipData.alwaysShowTooltip == true) ? 1 : 0;
    _leftTooltipOpacity = (_tooltipData.alwaysShowTooltip == true) ? 1 : 0;

    _outputLowerValue = _displayRealValue(_lowerValue);
    _outputUpperValue = _displayRealValue(_upperValue);

    if (widget.rtl == true) {
      _outputUpperValue = _displayRealValue(_lowerValue);
      _outputLowerValue = _displayRealValue(_upperValue);

      double tmpUpperValue = _fakeMax - _lowerValue;
      double tmpLowerValue = _fakeMax - _upperValue;

      _lowerValue = tmpLowerValue;
      _upperValue = tmpUpperValue;
    }

    _positionedItems = [
      _leftHandlerWidget,
      _rightHandlerWidget,
    ];

    _arrangeHandlersZIndex();

    _finalLeftHandlerWidth = _handlersWidth;
    _finalRightHandlerWidth = _handlersWidth;
    _finalLeftHandlerHeight = _handlersHeight;
    _finalRightHandlerHeight = _handlersHeight;

//    _plusSpinnerStyle = widget.plusButton ?? SpinnerButtonStyle();
//    _plusSpinnerStyle.child ??= Icon(Icons.add, size: 16);

    _divisions = _fakeMax / widget.step;
//    if (widget.divisions != null) {
//      _divisions = widget.divisions;
//    } else {
//      _divisions = (_fakeMax / 1000) < 1000 ? _fakeMax : (_fakeMax / 1000);
//    }

    _leftHandlerScaleAnimationController = AnimationController(
        duration: widget.handlerAnimation.duration, vsync: this);
    _rightHandlerScaleAnimationController = AnimationController(
        duration: widget.handlerAnimation.duration, vsync: this);
    _leftHandlerScaleAnimation =
        Tween(begin: 1.0, end: widget.handlerAnimation.scale).animate(
            CurvedAnimation(
                parent: _leftHandlerScaleAnimationController,
                reverseCurve: widget.handlerAnimation.reverseCurve,
                curve: widget.handlerAnimation.curve));
    _rightHandlerScaleAnimation =
        Tween(begin: 1.0, end: widget.handlerAnimation.scale).animate(
            CurvedAnimation(
                parent: _rightHandlerScaleAnimationController,
                reverseCurve: widget.handlerAnimation.reverseCurve,
                curve: widget.handlerAnimation.curve));

    _generateHandler();

    Offset animationStart = Offset(0, 0.20);
    Offset animationFinish = Offset(0, -0.92);
//    if(widget.axis == Axis.vertical) {
//      animationStart = Offset(0.20, 0);
//      animationFinish = Offset(-0.52, 0);
//    }

    _leftTooltipAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _leftTooltipAnimation =
        Tween<Offset>(begin: animationStart, end: animationFinish).animate(
            CurvedAnimation(
                parent: _leftTooltipAnimationController,
                curve: Curves.fastOutSlowIn));
    _rightTooltipAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _rightTooltipAnimation =
        Tween<Offset>(begin: animationStart, end: animationFinish).animate(
            CurvedAnimation(
                parent: _rightTooltipAnimationController,
                curve: Curves.fastOutSlowIn));

    WidgetsBinding.instance.addPostFrameCallback(_initialize);

    super.initState();
  }

  _initialize(_) {
    _renderBoxInitialization();

    _handlersWidth = _finalLeftHandlerWidth;
    _handlersHeight = _finalLeftHandlerHeight;

    if (widget.rangeSlider == true &&
        _finalLeftHandlerWidth != _finalRightHandlerWidth) {
      throw 'ERROR: Width of both handlers should be equal';
    }

    if (widget.rangeSlider == true &&
        _finalLeftHandlerHeight != _finalRightHandlerHeight) {
      throw 'ERROR: Height of both handlers should be equal';
    }

    if (widget.axis == Axis.horizontal) {
      _handlersPadding = _handlersWidth / 2;
      _leftHandlerXPosition =
          (((_constraintMaxWidth - _handlersWidth) / _fakeMax) * _lowerValue) -
              (widget.touchZone * 20 / 2);
      _rightHandlerXPosition =
          ((_constraintMaxWidth - _handlersWidth) / _fakeMax) * _upperValue -
              (widget.touchZone * 20 / 2);
    } else {
      _handlersPadding = _handlersHeight / 2;
      _leftHandlerYPosition =
          (((_constraintMaxHeight - _handlersHeight) / _fakeMax) *
                  _lowerValue) -
              (widget.touchZone * 20 / 2);
      _rightHandlerYPosition =
          ((_constraintMaxHeight - _handlersHeight) / _fakeMax) * _upperValue -
              (widget.touchZone * 20 / 2);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      _constraintMaxWidth = constraints.maxWidth;
      _constraintMaxHeight = constraints.maxHeight;

      _containerWidthWithoutPadding = _constraintMaxWidth - _handlersWidth;

      _containerHeightWithoutPadding = _constraintMaxHeight - _handlersHeight;

      _containerWidth = constraints.maxWidth;
      _containerHeight = (_handlersHeight * 1.8);

      if (widget.axis == Axis.vertical) {
        _containerWidth = (_handlersWidth * 1.8);
        _containerHeight = constraints.maxHeight;
      }

      return Container(
        key: containerKey,
        height: _containerHeight,
        width: _containerWidth,
        child: Stack(
          overflow: Overflow.visible,
          children: drawHandlers(),
        ),
      );
    });
  }

  void _validations() {
    if (widget.rangeSlider == true && widget.values.length < 2)
      throw 'when range mode is true, slider needs both lower and upper values';

    if (widget.values[0] != null && widget.values[0] < widget.min)
      throw 'Lower value should be greater than min';

    if (widget.rangeSlider == true) {
      if (widget.values[1] != null && widget.values[1] > widget.max)
        throw 'Upper value should be smaller than max';
    }
  }

  void _generateHandler() {
    /*Right Handler Data*/
    rightHandler = _MakeHandler(
        animation: _rightHandlerScaleAnimation,
        id: rightHandlerKey,
        touchZone: widget.touchZone,
        displayTestTouchZone: widget.displayTestTouchZone,
        handlerData: widget.rightHandler ??
            FlutterSliderHandler(
                icon: Icon(
                    (widget.axis == Axis.horizontal)
                        ? Icons.chevron_left
                        : Icons.expand_less,
                    color: Colors.black45)),
        width: widget.handlerWidth,
        height: widget.handlerHeight);

    /*Left Handler Data*/
    IconData hIcon = (widget.axis == Axis.horizontal)
        ? Icons.chevron_right
        : Icons.expand_more;
    if (widget.rtl && !widget.rangeSlider) {
      hIcon = (widget.axis == Axis.horizontal)
          ? Icons.chevron_left
          : Icons.expand_less;
    }

    leftHandler = _MakeHandler(
        animation: _leftHandlerScaleAnimation,
        id: leftHandlerKey,
        touchZone: widget.touchZone,
        displayTestTouchZone: widget.displayTestTouchZone,
        handlerData: widget.handler ??
            FlutterSliderHandler(icon: Icon(hIcon, color: Colors.black45)),
        width: widget.handlerWidth,
        height: widget.handlerHeight);

    if (widget.rangeSlider == false) {
      rightHandler = leftHandler;
    }
  }

  Positioned _leftHandlerWidget() {
    if (widget.rangeSlider == false)
      return Positioned(
        child: Container(),
      );

    double bottom;
    double right;
    if (widget.axis == Axis.horizontal) {
      bottom = 0;
    } else {
      right = 0;
    }

    return Positioned(
      key: Key('leftHandler'),
      left: _leftHandlerXPosition,
      top: _leftHandlerYPosition,
      bottom: bottom,
      right: right,
      child: Listener(
        child: Draggable(
            axis: widget.axis,
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                _tooltip(
                    side: 'left',
                    value: _outputLowerValue,
                    opacity: _leftTooltipOpacity,
                    animation: _leftTooltipAnimation),
                leftHandler,
              ],
            ),
            feedback: Container()),
        onPointerMove: (_) {
          if (widget.disabled == true) return;

          bool validMove = true;

          double dAxis,
              rAxis,
              axisDragTmp,
              axisPosTmp,
              containerSizeWithoutPadding,
              rightHandlerPosition,
              leftHandlerPosition,
              containerSizeWithoutHandlerSize;
          if (widget.axis == Axis.horizontal) {
            dAxis = _.position.dx - _containerLeft;
            axisDragTmp = xDragTmp;
            containerSizeWithoutPadding = _containerWidthWithoutPadding;
            rightHandlerPosition = _rightHandlerXPosition;
            leftHandlerPosition = _leftHandlerXPosition;
            containerSizeWithoutHandlerSize =
                _constraintMaxWidth - _handlersWidth;
          } else {
            dAxis = _.position.dy - _containerTop;
            axisDragTmp = yDragTmp;
            containerSizeWithoutPadding = _containerHeightWithoutPadding;
            rightHandlerPosition = _rightHandlerYPosition;
            leftHandlerPosition = _leftHandlerYPosition;
            containerSizeWithoutHandlerSize =
                _constraintMaxHeight - _handlersHeight;
          }

          axisPosTmp = dAxis - axisDragTmp + (widget.touchZone * 20 / 2);
          rAxis = ((axisPosTmp / (containerSizeWithoutPadding / _divisions)) *
              widget.step);
          rAxis = (double.parse(rAxis.toStringAsFixed(_decimalScale)) -
              double.parse(
                  (rAxis % widget.step).toStringAsFixed(_decimalScale)));

          if (widget.rangeSlider &&
              widget.minimumDistance > 0 &&
              (rAxis + widget.minimumDistance) >= _upperValue) {
            _lowerValue = (_upperValue - widget.minimumDistance > _fakeMin)
                ? _upperValue - widget.minimumDistance
                : _fakeMin;
            validMove = false;
          }

          if (widget.rangeSlider &&
              widget.maximumDistance > 0 &&
              rAxis <= (_upperValue - widget.maximumDistance)) {
            _lowerValue = (_upperValue - widget.maximumDistance > _fakeMin)
                ? _upperValue - widget.maximumDistance
                : _fakeMin;
            validMove = false;
          }

          if (widget.ignoreSteps.length > 0) {
            for (FlutterSliderIgnoreSteps steps in widget.ignoreSteps) {
              if (!((widget.rtl == false &&
                      (rAxis >= steps.from && rAxis <= steps.to) == false) ||
                  (widget.rtl == true &&
                      ((_fakeMax - rAxis) >= steps.from &&
                              (_fakeMax - rAxis) <= steps.to) ==
                          false))) {
                validMove = false;
              }
            }
          }

          if (validMove &&
                  axisPosTmp - (widget.touchZone * 20 / 2) <=
                      rightHandlerPosition + 1 &&
                  axisPosTmp + _handlersPadding >=
                      _handlersPadding - 1 /* - _leftPadding*/
              ) {
            _lowerValue = rAxis;

            if (_lowerValue > _fakeMax) _lowerValue = _fakeMax;
            if (_lowerValue < _fakeMin) _lowerValue = _fakeMin;

            if (_lowerValue > _upperValue) _lowerValue = _upperValue;

            if (widget.jump == true) {
              leftHandlerPosition =
                  ((containerSizeWithoutHandlerSize / _fakeMax) * _lowerValue) -
                      (widget.touchZone * 20 / 2);
            } else {
              leftHandlerPosition = dAxis - axisDragTmp;
            }
          }

          if (widget.axis == Axis.horizontal) {
            _leftHandlerXPosition = leftHandlerPosition;
          } else {
            _leftHandlerYPosition = leftHandlerPosition;
          }

          _outputLowerValue = _displayRealValue(_lowerValue);
          if (widget.rtl == true) {
            _outputLowerValue = _displayRealValue(_fakeMax - _lowerValue);
          }

          setState(() {});

          _callbacks('onDragging', 0);
        },
        onPointerDown: (_) {
          _renderBoxInitialization();

          xDragTmp = (_.position.dx - _containerLeft - _leftHandlerXPosition);
          yDragTmp = (_.position.dy - _containerTop - _leftHandlerYPosition);

          if (!_tooltipData.disabled &&
              _tooltipData.alwaysShowTooltip == false) {
            _leftTooltipOpacity = 1;
            _leftTooltipAnimationController.forward();
          }

          _leftHandlerScaleAnimationController.forward();

          setState(() {});

          _callbacks('onDragStarted', 0);
        },
        onPointerUp: (_) {
          _arrangeHandlersZIndex();

          _stopHandlerAnimation(
              animation: _leftHandlerScaleAnimation,
              controller: _leftHandlerScaleAnimationController);

          if (_tooltipData.alwaysShowTooltip == false) {
            _leftTooltipOpacity = 0;
            _leftTooltipAnimationController.reset();
          }

          setState(() {});

          _callbacks('onDragCompleted', 0);
        },
      ),
    );
  }

  Positioned _rightHandlerWidget() {
    double bottom;
    double right;
    if (widget.axis == Axis.horizontal) {
      bottom = 0;
    } else {
      right = 0;
    }

    return Positioned(
      key: Key('rightHandler'),
      left: _rightHandlerXPosition,
      top: _rightHandlerYPosition,
      right: right,
      bottom: bottom,
      child: Listener(
        child: Draggable(
            axis: Axis.horizontal,
            child: Stack(
              overflow: Overflow.visible,
              children: <Widget>[
                _tooltip(
                    side: 'right',
                    value: _outputUpperValue,
                    opacity: _rightTooltipOpacity,
                    animation: _rightTooltipAnimation),
                rightHandler,
              ],
            ),
            feedback: Container(
//                            width: 20,
//                            height: 20,
//                            color: Colors.blue.withOpacity(0.7),
                )),
        onPointerMove: (_) {
          if (widget.disabled == true) return;

          bool validMove = true;

          double dAxis,
              rAxis,
              axisDragTmp,
              axisPosTmp,
              containerSizeWithoutPadding,
              containerSizeWithoutHalfPadding,
              rightHandlerPosition,
              leftHandlerPosition,
              containerSizeWithoutHandlerSize;
          if (widget.axis == Axis.horizontal) {
            dAxis = _.position.dx - _containerLeft;
            axisDragTmp = xDragTmp;
            containerSizeWithoutPadding = _containerWidthWithoutPadding;
            rightHandlerPosition = _rightHandlerXPosition;
            leftHandlerPosition = _leftHandlerXPosition;
            containerSizeWithoutHandlerSize =
                _constraintMaxWidth - _handlersWidth;
            containerSizeWithoutHalfPadding =
                _constraintMaxWidth - _handlersPadding + 1;
          } else {
            dAxis = _.position.dy - _containerTop;
            axisDragTmp = yDragTmp;
            containerSizeWithoutPadding = _containerHeightWithoutPadding;
            rightHandlerPosition = _rightHandlerYPosition;
            leftHandlerPosition = _leftHandlerYPosition;
            containerSizeWithoutHandlerSize =
                _constraintMaxHeight - _handlersHeight;
            containerSizeWithoutHalfPadding =
                _constraintMaxHeight - _handlersPadding + 1;
          }

          axisPosTmp = dAxis - axisDragTmp + (widget.touchZone * 20 / 2);

          rAxis = ((axisPosTmp / (containerSizeWithoutPadding / _divisions)) *
              widget.step);
          rAxis = (double.parse(rAxis.toStringAsFixed(_decimalScale)) -
              double.parse(
                  (rAxis % widget.step).toStringAsFixed(_decimalScale)));

          if (widget.rangeSlider &&
              widget.minimumDistance > 0 &&
              (rAxis - widget.minimumDistance) <= _lowerValue) {
            validMove = false;
            _upperValue = (_lowerValue + widget.minimumDistance < _fakeMax)
                ? _lowerValue + widget.minimumDistance
                : _fakeMax;
          }
          if (widget.rangeSlider &&
              widget.maximumDistance > 0 &&
              rAxis >= (_lowerValue + widget.maximumDistance)) {
            validMove = false;
            _upperValue = (_lowerValue + widget.maximumDistance < _fakeMax)
                ? _lowerValue + widget.maximumDistance
                : _fakeMax;
          }

          if (widget.ignoreSteps.length > 0) {
            for (FlutterSliderIgnoreSteps steps in widget.ignoreSteps) {
              if (!((widget.rtl == false &&
                      (rAxis >= steps.from && rAxis <= steps.to) == false) ||
                  (widget.rtl == true &&
                      ((_fakeMax - rAxis) >= steps.from &&
                              (_fakeMax - rAxis) <= steps.to) ==
                          false))) {
                validMove = false;
              }
            }
          }

          if (validMove &&
              axisPosTmp >=
                  leftHandlerPosition - 1 + (widget.touchZone * 20 / 2) &&
              axisPosTmp + _handlersPadding <=
                  containerSizeWithoutHalfPadding) {
            _upperValue = rAxis;

            if (_upperValue > _fakeMax) _upperValue = _fakeMax;
            if (_upperValue < _fakeMin) _upperValue = _fakeMin;

            if (_upperValue < _lowerValue) _upperValue = _lowerValue;

            if (widget.jump == true) {
              rightHandlerPosition =
                  ((containerSizeWithoutHandlerSize / _fakeMax) * _upperValue) -
                      (widget.touchZone * 20 / 2);
            } else {
              rightHandlerPosition =
                  dAxis - axisDragTmp; // - (widget.touchZone * 20 / 2);
            }
          }

          if (widget.axis == Axis.horizontal) {
            _rightHandlerXPosition = rightHandlerPosition;
          } else {
            _rightHandlerYPosition = rightHandlerPosition;
          }

          _outputUpperValue = _displayRealValue(_upperValue);
          if (widget.rtl == true) {
            _outputUpperValue = _displayRealValue(_fakeMax - _upperValue);
          }

          setState(() {});

          _callbacks('onDragging', 1);
        },
        onPointerDown: (_) {
          _renderBoxInitialization();

          xDragTmp = (_.position.dx - _containerLeft - _rightHandlerXPosition);
          yDragTmp = (_.position.dy - _containerTop - _rightHandlerYPosition);

          if (!_tooltipData.disabled &&
              _tooltipData.alwaysShowTooltip == false) {
            _rightTooltipOpacity = 1;
            _rightTooltipAnimationController.forward();
            setState(() {});
          }

          if (widget.rangeSlider == false)
            _leftHandlerScaleAnimationController.forward();
          else
            _rightHandlerScaleAnimationController.forward();

          _callbacks('onDragStarted', 1);
        },
        onPointerUp: (_) {
          _arrangeHandlersZIndex();

          if (widget.rangeSlider == false) {
            _stopHandlerAnimation(
                animation: _leftHandlerScaleAnimation,
                controller: _leftHandlerScaleAnimationController);
          } else {
            _stopHandlerAnimation(
                animation: _rightHandlerScaleAnimation,
                controller: _rightHandlerScaleAnimationController);
          }

          if (_tooltipData.alwaysShowTooltip == false) {
            _rightTooltipOpacity = 0;
            _rightTooltipAnimationController.reset();
          }

          setState(() {});

          _callbacks('onDragCompleted', 1);
        },
      ),
    );
  }

  void _stopHandlerAnimation(
      {Animation animation, AnimationController controller}) {
    if (widget.handlerAnimation.reverseCurve != null) {
      if (animation.isCompleted)
        controller.reverse();
      else {
        controller.reset();
      }
    } else
      controller.reset();
  }

  drawHandlers() {
    List<Widget> items = [
      Function.apply(_leftInactiveTrack, []),
      Function.apply(_rightInactiveTrack, []),
      Function.apply(_activeTrack, []),
    ];

    for (Function func in _positionedItems) {
      items.add(Function.apply(func, []));
    }

    return items;
  }

  Positioned _tooltip(
      {String side, double value, double opacity, Animation animation}) {
    if (_tooltipData.disabled)
      return Positioned(
        child: Container(),
      );

    Widget prefix;
    Widget suffix;
    double handlerYPosition;
    if (side == 'left') {
      handlerYPosition = _leftHandlerYPosition;
      prefix = _tooltipData.leftPrefix;
      suffix = _tooltipData.leftSuffix;
      if (widget.rangeSlider == false)
        return Positioned(
          child: Container(),
        );
    } else {
      handlerYPosition = _rightHandlerYPosition;
      prefix = _tooltipData.rightPrefix;
      suffix = _tooltipData.rightSuffix;
    }
    String numberFormat = value.toString();
    if (_tooltipData.numberFormat != null)
      numberFormat = _tooltipData.numberFormat.format(value);

    Widget tooltipWidget = IgnorePointer(
        child: Center(
      child: Container(
        alignment: Alignment.center,
        child: Container(
            padding: EdgeInsets.all(8),
            decoration: _tooltipData.boxStyle.decoration,
            foregroundDecoration: _tooltipData.boxStyle.foregroundDecoration,
            transform: _tooltipData.boxStyle.transform,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                prefix,
                Text(numberFormat, style: _tooltipData.textStyle),
                suffix,
              ],
            )),
      ),
    ));

//    double top, left, right, bottom;
//    top = left = right = bottom = -50;
//    if(widget.axis == Axis.horizontal) {
//      top = -(_containerHeight - _handlersHeight);
//      bottom = null;
//    } else {
//      top = bottom = 20;
//      right = null;
//      left = -(_containerWidth - _handlersWidth);
//    }

    double top = -(_containerHeight - _handlersHeight);
    if (widget.axis == Axis.vertical) top = -_handlersHeight + 10;

    if (_tooltipData.alwaysShowTooltip == false) {
      top = 0;
      tooltipWidget =
          SlideTransition(position: animation, child: tooltipWidget);
    }

    return Positioned(
      left: -50,
      right: -50,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: tooltipWidget,
      ),
    );
  }

  Positioned _leftInactiveTrack() {
    double top, bottom, left, right, width, height;
    top = left = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      width = _leftHandlerXPosition + (widget.touchZone * 20 / 2);
      height = widget.trackBar.inactiveTrackBarHeight;
      left = _handlersPadding;
      if (widget.rtl == true && widget.rangeSlider == false) {
        width = _rightHandlerXPosition -
            _handlersPadding +
            (widget.touchZone * 20 / 2);
      }
    } else {
      right = 0;
      height = _leftHandlerYPosition -
          _handlersPadding +
          (widget.touchZone * 20 / 2);
      width = widget.trackBar.inactiveTrackBarHeight;
      top = _handlersPadding;
      if (widget.rtl == true && widget.rangeSlider == false) {
        height = _rightHandlerYPosition -
            _handlersPadding +
            (widget.touchZone * 20 / 2);
      }
    }

    width = (width < 0) ? 0 : width;
    height = (height < 0) ? 0 : height;

    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      child: Center(
        child: Container(
          height: height,
          width: width,
          color: widget.trackBar.leftInactiveTrackBarColor,
        ),
      ),
    );
  }

  Positioned _rightInactiveTrack() {
    double top, bottom, left, right, width, height;
    top = left = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      height = widget.trackBar.inactiveTrackBarHeight;
      width = _constraintMaxWidth -
          _rightHandlerXPosition -
          _handlersPadding -
          (widget.touchZone * 20 / 2);
      left = _rightHandlerXPosition + (widget.touchZone * 20 / 2);
    } else {
      right = 0;
      width = widget.trackBar.inactiveTrackBarHeight;
      height = _constraintMaxHeight -
          _rightHandlerYPosition -
          _handlersPadding -
          (widget.touchZone * 20 / 2);
      top = _rightHandlerYPosition + (widget.touchZone * 20 / 2);
    }

//    if (widget.rangeSlider == true)
//      width = _constraintMaxWidth -
//          _rightHandlerXPosition -
//          _handlersPadding -
//          (widget.touchZone * 20 / 2);

    return Positioned(
      left: left,
      top: top,
      bottom: bottom,
      right: right,
      child: Center(
        child: Container(
          height: height,
          width: width,
          color: widget.trackBar.rightInactiveTrackBarColor,
        ),
      ),
    );
  }

  Positioned _activeTrack() {
    double top, bottom, left, right, width, height;
    top = left = width = height = 0;
    right = bottom = null;

    if (widget.axis == Axis.horizontal) {
      bottom = 0;
      height = widget.trackBar.activeTrackBarHeight;
      width = _rightHandlerXPosition - _leftHandlerXPosition;
      left = _leftHandlerXPosition + (widget.touchZone * 20 / 2);
      if (widget.rtl == true && widget.rangeSlider == false) {
        left = _rightHandlerXPosition + (widget.touchZone * 20 / 2);
        width = _constraintMaxWidth -
            _rightHandlerXPosition -
            (widget.touchZone * 20 / 2);
      }
    } else {
      right = 0;
      width = widget.trackBar.activeTrackBarHeight;
      height = _rightHandlerYPosition - _leftHandlerYPosition;
      top = _leftHandlerYPosition + (widget.touchZone * 20 / 2);
      if (widget.rtl == true && widget.rangeSlider == false) {
        top = _rightHandlerYPosition + (widget.touchZone * 20 / 2);
        height = _constraintMaxHeight -
            _rightHandlerYPosition -
            (widget.touchZone * 20 / 2);
      }
    }
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Center(
        child: Container(
          height: height,
          width: width,
          color: widget.trackBar.activeTrackBarColor,
        ),
      ),
    );
  }

  void _callbacks(String callbackName, int handlerIndex) {
    double lowerValue = _outputLowerValue;
    double upperValue = _outputUpperValue;
    if (widget.rtl == true || widget.rangeSlider == false) {
      lowerValue = _outputUpperValue;
      upperValue = _outputLowerValue;
    }

    switch (callbackName) {
      case 'onDragging':
        if (widget.onDragging != null)
          widget.onDragging(handlerIndex, lowerValue, upperValue);
        break;
      case 'onDragCompleted':
        if (widget.onDragCompleted != null)
          widget.onDragCompleted(handlerIndex, lowerValue, upperValue);
        break;
      case 'onDragStarted':
        if (widget.onDragStarted != null)
          widget.onDragStarted(handlerIndex, lowerValue, upperValue);
        break;
    }
  }

  double _displayRealValue(double value) {
    return double.parse((value + widget.min).toStringAsFixed(_decimalScale));
    // return (value + widget.min);
//    if(_decimalScale > 0) {
//    }
//    return double.parse((value + widget.min).floor().toStringAsFixed(_decimalScale));
  }

  void _arrangeHandlersZIndex() {
    if (_lowerValue >= (_fakeMax / 2))
      _positionedItems = [
        _rightHandlerWidget,
        _leftHandlerWidget,
      ];
    else
      _positionedItems = [
        _leftHandlerWidget,
        _rightHandlerWidget,
      ];
  }

  void _renderBoxInitialization() {
    if (_containerLeft <= 0 ||
        (MediaQuery.of(context).size.width - _constraintMaxWidth) <=
            _containerLeft) {
      RenderBox containerRenderBox =
          containerKey.currentContext.findRenderObject();
      _containerLeft = containerRenderBox.localToGlobal(Offset.zero).dx;
    }
    if (_containerTop <= 0 ||
        (MediaQuery.of(context).size.height - _constraintMaxHeight) <=
            _containerTop) {
      RenderBox containerRenderBox =
          containerKey.currentContext.findRenderObject();
      _containerTop = containerRenderBox.localToGlobal(Offset.zero).dy;
    }
  }
}

class _MakeHandler extends StatelessWidget {
  final double width;
  final double height;
  final GlobalKey id;
  final FlutterSliderHandler handlerData;
  final int touchZone;
  final bool displayTestTouchZone;
  final Animation animation;

  _MakeHandler(
      {this.id,
      this.handlerData,
      this.touchZone,
      this.displayTestTouchZone,
      this.width,
      this.height,
      this.animation});

  @override
  Widget build(BuildContext context) {
    double touchOpacity = (displayTestTouchZone == true) ? 1 : 0;

    return Container(
      key: id,
      width: width + touchZone * 20,
      height: height + touchZone * 20,
      child: Stack(children: <Widget>[
        Opacity(
          opacity: touchOpacity,
          child: Container(
            color: Colors.black12,
            child: Container(),
          ),
        ),
        Center(
          child: ScaleTransition(
            scale: animation,
            child: handlerData.child ??
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 2,
                        spreadRadius: 0.2,
                        offset: Offset(0, 1))
                  ], color: Colors.white, shape: BoxShape.circle),
                  width: width,
                  height: height,
                  child: handlerData.icon,
                ),
          ),
        )
      ]),
    );
  }
}

class FlutterSliderHandler {
  final Widget child;
  final Icon icon;

  FlutterSliderHandler({this.child, this.icon})
      : assert(child != null || icon != null);
}

class FlutterSliderTooltip {
  TextStyle textStyle;
  FlutterSliderTooltipBox boxStyle;
  Widget leftPrefix;
  Widget leftSuffix;
  Widget rightPrefix;
  Widget rightSuffix;
  intl.NumberFormat numberFormat;
  bool alwaysShowTooltip;
  bool disabled;

  FlutterSliderTooltip(
      {this.textStyle,
      this.boxStyle,
      this.leftPrefix,
      this.leftSuffix,
      this.rightPrefix,
      this.rightSuffix,
      this.numberFormat,
      this.alwaysShowTooltip,
      this.disabled});
}

class FlutterSliderTooltipBox {
  final BoxDecoration decoration;
  final BoxDecoration foregroundDecoration;
  final Matrix4 transform;

  const FlutterSliderTooltipBox(
      {this.decoration, this.foregroundDecoration, this.transform});
}

class FlutterSliderTrackBar {
  final Color leftInactiveTrackBarColor;
  final Color rightInactiveTrackBarColor;
  final Color activeTrackBarColor;
  final double activeTrackBarHeight;
  final double inactiveTrackBarHeight;

  const FlutterSliderTrackBar({
    this.leftInactiveTrackBarColor = const Color(0x110000ff),
    this.rightInactiveTrackBarColor = const Color(0x110000ff),
    this.activeTrackBarColor = const Color(0xff2196F3),
    this.activeTrackBarHeight = 3.5,
    this.inactiveTrackBarHeight = 3,
  })  : assert(leftInactiveTrackBarColor != null &&
            rightInactiveTrackBarColor != null &&
            activeTrackBarColor != null),
        assert(inactiveTrackBarHeight != null && inactiveTrackBarHeight > 0),
        assert(activeTrackBarHeight != null && activeTrackBarHeight > 0);
}

class FlutterSliderIgnoreSteps {
  final double from;
  final double to;

  FlutterSliderIgnoreSteps({this.from, this.to})
      : assert(from != null && to != null && from <= to);
}

class FlutterSliderHandlerAnimation {
  final Curve curve;
  final Curve reverseCurve;
  final Duration duration;
  final double scale;

  const FlutterSliderHandlerAnimation(
      {this.curve = Curves.elasticOut,
      this.reverseCurve,
      this.duration = const Duration(milliseconds: 700),
      this.scale = 1.3})
      : assert(curve != null && duration != null && scale != null);
}
