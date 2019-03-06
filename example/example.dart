import 'package:flutter/material.dart';
import 'package:flutter_xlider/flutter_xlider.dart';
import 'package:intl/intl.dart' as intl;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double _lowerValue = 50;
  double _upperValue = 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 50, left: 50, right: 50),
            alignment: Alignment.centerLeft,
            child: FlutterSlider(
              values: [60, 160],
//              ignoreSteps: [
//                FlutterSliderIgnoreSteps(from: 120, to: 150),
//                FlutterSliderIgnoreSteps(from: 160, to: 190),
//              ],
              max: 200,
              min: 50,
              maximumDistance: 300,
              rangeSlider: true,
              rtl: true,
              handlerAnimation: FlutterSliderHandlerAnimation(
                  curve: Curves.elasticOut,
                  reverseCurve: null,
                  duration: Duration(milliseconds: 700),
                  scale: 1.4
              ),
              onDragging: (handlerIndex, lowerValue, upperValue) {
                _lowerValue = lowerValue;
                _upperValue = upperValue;
                setState(() {});
              },
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 50, left: 20, right: 20),
              alignment: Alignment.centerLeft,
              child: FlutterSlider(
                values: [1000, 15000],
                rangeSlider: true,
//rtl: true,
//                touchZone: 2,
                ignoreSteps: [
                  FlutterSliderIgnoreSteps(from: 8000, to: 12000),
                  FlutterSliderIgnoreSteps(from: 18000, to: 22000),
                ],
                max: 25000,
                min: 0,
                step: 100,
//displayTestTouchZone: true,
                jump: true,

                trackBar: FlutterSliderTrackBar(
                  activeTrackBarColor: Colors.redAccent,
                  activeTrackBarHeight: 5,
                  leftInactiveTrackBarColor: Colors.greenAccent.withOpacity(0.5),
                ),
                tooltip: FlutterSliderTooltip(
                  textStyle: TextStyle(fontSize: 17, color: Colors.lightBlue),
                  numberFormat: intl.NumberFormat(),
                ),
                handler: FlutterSliderHandler(
                  child: Material(
                    type: MaterialType.canvas,
                    color: Colors.orange,
                    elevation: 3,
                    child: Container(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.adjust, size: 25,)),
                  ),
                ),
                rightHandler: FlutterSliderHandler(
                  icon: Icon(Icons.chevron_left, color: Colors.red, size: 24,),
                ),
                disabled: false,

                onDragging: (handlerIndex, lowerValue, upperValue) {
                  _lowerValue = lowerValue;
                  _upperValue = upperValue;
                  setState(() {});
                },
              )),

          Container(
              margin: EdgeInsets.only(top: 50, left: 20, right: 20),
              alignment: Alignment.centerLeft,
              child: FlutterSlider(
                values: [3000, 17000],
                rangeSlider: true,
//rtl: true,
//                touchZone: 2,
//                ignoreSteps: [
//                  FlutterSliderIgnoreSteps(from: 8000, to: 12000),
//                  FlutterSliderIgnoreSteps(from: 18000, to: 22000),
//                ],
                max: 25000,
                min: 0,
                step: 100,
//displayTestTouchZone: true,
                jump: true,
                trackBar: FlutterSliderTrackBar(
                  activeTrackBarColor: Colors.blue.withOpacity(0.6),
                  inactiveTrackBarHeight: 2,
                  activeTrackBarHeight: 3,
                ),

                disabled: false,

                handler: customHandler(Icons.chevron_right),
                rightHandler: customHandler(Icons.chevron_left),
                tooltip: FlutterSliderTooltip(
                  numberFormat: intl.NumberFormat(),
                  leftPrefix: Icon(Icons.attach_money, size: 19, color: Colors.black45,),
                  rightSuffix: Icon(Icons.attach_money, size: 19, color: Colors.black45,),
                  textStyle: TextStyle(fontSize: 17, color: Colors.black45),
                ),

                onDragging: (handlerIndex, lowerValue, upperValue) {
                  _lowerValue = lowerValue;
                  _upperValue = upperValue;
                  setState(() {});
                },
              )),

          Container(
            margin: EdgeInsets.only(top: 20, left: 20, right: 20),
            alignment: Alignment.centerLeft,
            child: FlutterSlider(
              key: Key('3343'),
              values: [300000000, 1600000000],
              rangeSlider: true,
              tooltip: FlutterSliderTooltip(
                alwaysShowTooltip: true,
                numberFormat: intl.NumberFormat.compact(),
              ),
              max: 2000000000,
              min: 0,
              step: 20,
              jump: true,
              onDragging: (handlerIndex, lowerValue, upperValue) {
                _lowerValue = lowerValue;
                _upperValue = upperValue;
                setState(() {});
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 50, left: 50, right: 50),
            alignment: Alignment.centerLeft,
            child: FlutterSlider(
              values: [30, 60],
              rangeSlider: true,
              max: 100,
              min: 0,
              displayTestTouchZone: true,
              onDragging: (handlerIndex, lowerValue, upperValue) {
                _lowerValue = lowerValue;
                _upperValue = upperValue;
                setState(() {});
              },
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Text('Lower Value: ' + _lowerValue.toString()),
          SizedBox(height: 25),
          Text('Upper Value: ' + _upperValue.toString())
        ],
      ),
    );
  }


  customHandler(IconData icon){
    return FlutterSliderHandler(
      child: Container(
        child: Container(
          margin: EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.3),
              shape: BoxShape.circle
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 23,
          ),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                spreadRadius: 0.05,
                blurRadius: 5,
                offset: Offset(0, 1))
          ],
        ),
      ),
    );
  }
}
