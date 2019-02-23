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
              values: [30, 420],
              rangeSlider: true,
//              ignoreSteps: [
//                SliderIgnoreSteps(from: 100, to: 100),
//                SliderIgnoreSteps(from: 250, to: 350),
//              ],
              max: 500,
              min: 0,
              divisions: 50,
              onDragging: (lowerValue, upperValue) {
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
                  SliderIgnoreSteps(from: 8000, to: 12000),
                  SliderIgnoreSteps(from: 18000, to: 22000),
                ],
                max: 25000,
                min: 0,
                divisions: 25,
                tooltipNumberFormat: intl.NumberFormat(),
//displayTestTouchZone: true,
                jump: true,

                activeTrackBarColor: Colors.redAccent,
                activeTrackBarHeight: 5,
                leftInactiveTrackBarColor: Colors.greenAccent.withOpacity(0.5),
                disabled: false,

                tooltipTextStyle:
                    TextStyle(fontSize: 17, color: Colors.lightBlue),
                handler: SizedBox(
                    width: 20,
                    height: 50,
                    child: Container(
                      child: Icon(
                        Icons.view_headline,
                        color: Colors.black54,
                        size: 13,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.12))),
                    )),
                rightHandler: SizedBox(
                    width: 20,
                    height: 50,
                    child: Container(
                      child: Icon(
                        Icons.view_headline,
                        color: Colors.black54,
                        size: 13,
                      ),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors.black.withOpacity(0.12))),
                    )),
                onDragging: (lowerValue, upperValue) {
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
              alwaysShowTooltip: true,
              max: 2000000000,
              min: 0,
              divisions: 20,
              tooltipNumberFormat: intl.NumberFormat.compact(),
              jump: true,
              onDragging: (lowerValue, upperValue) {
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
              onDragging: (lowerValue, upperValue) {
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
}
