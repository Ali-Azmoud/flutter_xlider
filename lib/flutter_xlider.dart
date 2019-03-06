import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;

/// A material design slider and range slider with rtl support and lots of options and customizations for flutter
class FlutterSlider extends StatefulWidget {
  final Key key;
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

  double leftHandlerXPosition = -1;
  double rightHandlerXPosition = 0;

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

//  double _constraintMaxHeight;
  double _containerWidthWithoutPadding;

//  double _containerHeightWithoutPadding;
  double _containerLeft = 0;

//  double _containerTop = 0;

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

  double dragtmp = 0;

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

    _leftTooltipAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _leftTooltipAnimation =
        Tween<Offset>(begin: Offset(0, 0.20), end: Offset(0, -0.92)).animate(
            CurvedAnimation(
                parent: _leftTooltipAnimationController,
                curve: Curves.fastOutSlowIn));
    _rightTooltipAnimationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    _rightTooltipAnimation =
        Tween<Offset>(begin: Offset(0, 0.20), end: Offset(0, -0.92)).animate(
            CurvedAnimation(
                parent: _rightTooltipAnimationController,
                curve: Curves.fastOutSlowIn));

    WidgetsBinding.instance.addPostFrameCallback(_initialize);

    super.initState();
  }

  _initialize(_) {
    _renderBoxInitialization();
//    _containerTop = containerRenderBox.localToGlobal(Offset.zero).dy;

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

    _handlersPadding = _handlersWidth / 2;
    leftHandlerXPosition =
        (((_constraintMaxWidth - _handlersWidth) / _fakeMax) * _lowerValue) -
            (widget.touchZone * 20 / 2);
    rightHandlerXPosition =
        ((_constraintMaxWidth - _handlersWidth) / _fakeMax) * _upperValue -
            (widget.touchZone * 20 / 2);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      _constraintMaxWidth = constraints.maxWidth;
//          _constraintMaxHeight = constraints.maxHeight;
      _containerWidthWithoutPadding =
          _constraintMaxWidth - (_handlersPadding * 2);

      _containerWidth = constraints.maxWidth;
      _containerHeight = (_handlersHeight * 1.8);

//          if (widget.axis == Axis.vertical) {
//            _containerWidth = (_handlersWidth * 1.8);
//            _containerHeight = constraints.maxHeight;
//          }

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
                icon: Icon(Icons.chevron_left, color: Colors.black38)),
        width: widget.handlerWidth,
        height: widget.handlerHeight);

    /*Left Handler Data*/
    IconData hIcon = Icons.chevron_right;
    if (widget.rtl && !widget.rangeSlider) {
      hIcon = Icons.chevron_left;
    }
    leftHandler = _MakeHandler(
        animation: _leftHandlerScaleAnimation,
        id: leftHandlerKey,
        touchZone: widget.touchZone,
        displayTestTouchZone: widget.displayTestTouchZone,
        handlerData: widget.handler ??
            FlutterSliderHandler(icon: Icon(hIcon, color: Colors.black38)),
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

    return Positioned(
      key: Key('leftHandler'),
      left: leftHandlerXPosition,
      top: 0,
      bottom: 0,
      child: Listener(
        child: Draggable(
            axis: Axis.horizontal,
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

          double dx = _.position.dx - _containerLeft;
          double xPosTmp = dx - dragtmp + (widget.touchZone * 20 / 2);

          double rx =
              ((xPosTmp / (_containerWidthWithoutPadding / _divisions)) *
                  widget.step);

          if (widget.rangeSlider &&
              widget.minimumDistance > 0 &&
              (rx + widget.minimumDistance) >= _upperValue) {
            _lowerValue = (_upperValue - widget.minimumDistance > _fakeMin)
                ? _upperValue - widget.minimumDistance
                : _fakeMin;
            validMove = false;
          }
          if (widget.rangeSlider &&
              widget.maximumDistance > 0 &&
              rx <= (_upperValue - widget.maximumDistance)) {
            _lowerValue = (_upperValue - widget.maximumDistance > _fakeMin)
                ? _upperValue - widget.maximumDistance
                : _fakeMin;
            validMove = false;
          }

          if (widget.ignoreSteps.length > 0) {
            for (FlutterSliderIgnoreSteps steps in widget.ignoreSteps) {
              if (!((widget.rtl == false &&
                      (rx >= steps.from && rx <= (steps.to + widget.step)) ==
                          false) ||
                  (widget.rtl == true &&
                      ((_fakeMax - rx) >= (steps.from - widget.step) &&
                              (_fakeMax - rx) <= steps.to) ==
                          false))) {
                validMove = false;
              }
            }
          }

          if (validMove &&
                  xPosTmp - (widget.touchZone * 20 / 2) <=
                      rightHandlerXPosition + 1 &&
                  xPosTmp + _handlersPadding >=
                      _handlersPadding - 1 /* - _leftPadding*/
              ) {
            _lowerValue = (double.parse(rx.toStringAsFixed(_decimalScale)) -
                double.parse(
                    (rx % widget.step).toStringAsFixed(_decimalScale)));

            if (_lowerValue > _fakeMax) _lowerValue = _fakeMax;
            if (_lowerValue < _fakeMin) _lowerValue = _fakeMin;

            if (_lowerValue > _upperValue) _lowerValue = _upperValue;

            if (widget.jump == true) {
              leftHandlerXPosition =
                  (((_constraintMaxWidth - _handlersWidth) / _fakeMax) *
                          _lowerValue) -
                      (widget.touchZone * 20 / 2);
            } else {
              leftHandlerXPosition = dx - dragtmp;
            }
          }

          _outputLowerValue = _displayRealValue(_lowerValue);
          if (widget.rtl == true) {
            _outputLowerValue = _displayRealValue(_fakeMax - _lowerValue);
          }

          setState(() {});

          _callbacks('onDragging', 0);
        },
        onPointerDown: (_) {
          dragtmp = (_.position.dx - _containerLeft - leftHandlerXPosition);

          _renderBoxInitialization();

          if (!_tooltipData.disabled &&
              _tooltipData.alwaysShowTooltip == false) {
            _leftTooltipOpacity = 1;
            _leftTooltipAnimationController.forward();
            setState(() {});
          }

          _leftHandlerScaleAnimationController.forward();

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
    return Positioned(
      key: Key('rightHandler'),
      left: rightHandlerXPosition,
      top: 0,
      bottom: 0,
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

          double dx = _.position.dx - _containerLeft;
          double xPosTmp = dx - dragtmp + (widget.touchZone * 20 / 2);

          double rx =
              ((xPosTmp / (_containerWidthWithoutPadding / _divisions)) *
                  widget.step);

          if (widget.rangeSlider &&
              widget.minimumDistance > 0 &&
              (rx - widget.minimumDistance) <= _lowerValue) {
            validMove = false;
            _upperValue = (_lowerValue + widget.minimumDistance < _fakeMax)
                ? _lowerValue + widget.minimumDistance
                : _fakeMax;
          }
          if (widget.rangeSlider &&
              widget.maximumDistance > 0 &&
              rx >= (_lowerValue + widget.maximumDistance)) {
            validMove = false;
            _upperValue = (_lowerValue + widget.maximumDistance < _fakeMax)
                ? _lowerValue + widget.maximumDistance
                : _fakeMax;
          }

          if (widget.ignoreSteps.length > 0) {
            for (FlutterSliderIgnoreSteps steps in widget.ignoreSteps) {
              if (!((widget.rtl == false &&
                      (rx >= steps.from && rx <= (steps.to + widget.step)) ==
                          false) ||
                  (widget.rtl == true &&
                      ((_fakeMax - rx) >= (steps.from - widget.step) &&
                              (_fakeMax - rx) <= steps.to) ==
                          false))) {
                validMove = false;
              }
            }
          }

          if (validMove &&
              xPosTmp >=
                  leftHandlerXPosition - 1 + (widget.touchZone * 20 / 2) &&
              xPosTmp + _handlersPadding <=
                  _constraintMaxWidth - _handlersPadding + 1) {
            _upperValue = (double.parse(rx.toStringAsFixed(_decimalScale)) -
                double.parse(
                    (rx % widget.step).toStringAsFixed(_decimalScale)));

            if (_upperValue > _fakeMax) _upperValue = _fakeMax;
            if (_upperValue < _fakeMin) _upperValue = _fakeMin;

            if (_upperValue < _lowerValue) _upperValue = _lowerValue;

            if (widget.jump == true) {
              rightHandlerXPosition =
                  (((_constraintMaxWidth - _handlersWidth) / _fakeMax) *
                          _upperValue) -
                      (widget.touchZone * 20 / 2);
            } else {
              rightHandlerXPosition =
                  dx - dragtmp; // - (widget.touchZone * 20 / 2);
            }
          }

          _outputUpperValue = _displayRealValue(_upperValue);
          if (widget.rtl == true) {
            _outputUpperValue = _displayRealValue(_fakeMax - _upperValue);
          }

          setState(() {});

          _callbacks('onDragging', 1);
        },
        onPointerDown: (_) {
          dragtmp = (_.position.dx - _containerLeft - rightHandlerXPosition);

          _renderBoxInitialization();

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
    if (side == 'left') {
      prefix = _tooltipData.leftPrefix;
      suffix = _tooltipData.leftSuffix;
      if (widget.rangeSlider == false)
        return Positioned(
          child: Container(),
        );
    } else {
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

    double top = -(_containerHeight - _handlersHeight);
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
    double width =
        leftHandlerXPosition - _handlersPadding + (widget.touchZone * 20 / 2);
    if (widget.rtl == true && widget.rangeSlider == false) {
      width = rightHandlerXPosition -
          _handlersPadding +
          (widget.touchZone * 20 / 2);
    }

    return Positioned(
      left: _handlersPadding,
      width: width,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          height: widget.trackBar.inactiveTrackBarHeight,
          color: widget.trackBar.leftInactiveTrackBarColor,
        ),
      ),
    );
  }

  Positioned _rightInactiveTrack() {
    double width = _constraintMaxWidth -
        rightHandlerXPosition -
        _handlersPadding -
        (widget.touchZone * 20 / 2);
//    if (widget.rangeSlider == true)
//      width = _constraintMaxWidth -
//          rightHandlerXPosition -
//          _handlersPadding -
//          (widget.touchZone * 20 / 2);

    return Positioned(
      left: rightHandlerXPosition + (widget.touchZone * 20 / 2),
      width: width,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          height: widget.trackBar.inactiveTrackBarHeight,
          color: widget.trackBar.rightInactiveTrackBarColor,
        ),
      ),
    );
  }

  Positioned _activeTrack() {
    double width = rightHandlerXPosition - leftHandlerXPosition;
    double left = leftHandlerXPosition + (widget.touchZone * 20 / 2);
    if (widget.rtl == true && widget.rangeSlider == false) {
      left = rightHandlerXPosition + (widget.touchZone * 20 / 2);
      width = _constraintMaxWidth -
          rightHandlerXPosition -
          (widget.touchZone * 20 / 2);
    }

    return Positioned(
      left: left,
      width: width,
      top: 0,
      bottom: 0,
      child: Center(
        child: Container(
          height: widget.trackBar.activeTrackBarHeight,
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
