# flutter_slider

A material design slider and range slider with rtl support and lots of options and customizations for flutter

### Version 1.0.0 and above will break functionality of older (beta) versions.

## Get Started

### Single Slider

A single slider

```dart
FlutterSlider(
  values: [300],
  max: 500,
  min: 0,
  onDragging: (lowerValue, upperValue) {
    _lowerValue = lowerValue;
    _upperValue = upperValue;
    setState(() {});
  },
)
```

![](images/single.gif)

to make slider `Right To Left` use `rtl: true`

```dart
 FlutterSlider(
  ...
  rtl: true,
  ...
)
```

![](images/single-rtl.gif)


### Range Slider

A simple example of slider

```dart
FlutterSlider(
  values: [30, 420],
  rangeSlider: true,
  max: 500,
  min: 0,
  onDragging: (lowerValue, upperValue) {
    _lowerValue = lowerValue;
    _upperValue = upperValue;
    setState(() {});
  },
)
```

![](images/range-1.gif)

## Handlers

You can customize handlers using `handler` and `rightHandler` properties.  
`width` and `height` are required for custom handlers, so we use `SizedBox` as a wrapper

**if you use `rangeSlider` then you should define `rightHandler` as well if you want to customize handlers**


here there is a range slider with customized handlers and trackbars
```dart
FlutterSlider(
  ...
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
          border: Border.all(color: Colors.black.withOpacity(0.12))),
    ),
  ),
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
          border: Border.all(color: Colors.black.withOpacity(0.12))),
    ),
  ),
  ...
)

```

### Handler Scale Animation

You can control the scale animation type of your handlers, it's duration and it's scale size using `handlerAnimation`    
`handlerAnimation` accepts a `FlutterSliderHandlerAnimation` class which has 4 properties as following

```dart
FlutterSlider(
  ...
    handlerAnimation: FlutterSliderHandlerAnimation(
      curve: Curves.elasticOut,
      reverseCurve: Curves.bounceIn,
      duration: Duration(milliseconds: 500),
      scale: 1.5
    ),
  ...
)
```

![](images/range-handler-animation.gif)

**if you don't want scale animation, then just pass `1` to `scale` property**  
**if you don't want `reverseCurve`, just ignore it. default is null**



## Trackbars

to customize track bars you can use `FlutterSliderTrackBar`. [You can see the details here](https://pub.dartlang.org/documentation/flutter_xlider/latest/flutter_xlider/FlutterSliderTrackBar-class.html)

```dart
FlutterSlider(
  ...
    trackBar: FlutterSliderTrackBar(
      activeTrackBarColor: Colors.redAccent,
      activeTrackBarHeight: 5,
      leftInactiveTrackBarColor: Colors.greenAccent.withOpacity(0.5),
    ),
  ...
)
```

## Tooltips

in order to customize your tooltips, you can use `FlutterSliderTooltip` class. [You can see all properties here](https://pub.dartlang.org/documentation/flutter_xlider/latest/flutter_xlider/FlutterSliderTooltip/FlutterSliderTooltip.html)

```dart
FlutterSlider(
  ...
  tooltip: FlutterSliderTooltip(
    textStyle: TextStyle(fontSize: 17, color: Colors.white),
    boxStyle: FlutterSliderTooltipBox(
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.7)
      )
    )
  ),
  ...
)
```

![](images/range-customized.gif)

### Tooltip Prefix

You can use `leftPrefix`, `leftSuffix`, `rightPrefix`, `rightSuffix` to add your desired widget around tooltip content.

```dart
FlutterSlider(
  ...
    tooltip: FlutterSliderTooltip(
      leftPrefix: Icon(Icons.attach_money, size: 19, color: Colors.black45,),
      rightSuffix: Icon(Icons.attach_money, size: 19, color: Colors.black45,),
    ),
  ...
)
```

![](images/range-tooltip-prefix-suffix.gif)


### Tooltip Number Format

you can customize tooltip numbers by using `NumberFormat` class  
here is an example  

```dart
FlutterSlider(
  ...
    tooltip: FlutterSliderTooltip(
      numberFormat: intl.NumberFormat(),
      // numberFormat: intl.compact(),
    ),
  ...
)
```
you can find more about [NumberFormat](https://docs.flutter.io/flutter/intl/NumberFormat-class.html)

![](images/range-compact.gif)


## Controls

### Jump

by default slider handlers move fluently, if you set `jump` to true, handlers will jump between intervals

```dart
FlutterSlider(
  ...
  jump: true,
  ...
)
```

### divisions

The number of discrete divisions

```dart
FlutterSlider(
  ...
  divisions: 25,
  ...
)
```

### Ignore Steps

if your configurations requires that some steps are not available, you can use `ignoreSteps` property.  
this property accepts a simple class to define `from` and `to` ranges.

```dart
FlutterSlider(
  ...
    ignoreSteps: [
      FlutterSliderIgnoreSteps(from: 8000, to: 12000),
      FlutterSliderIgnoreSteps(from: 18000, to: 22000),
    ],
  ...
)
```

![](images/range-ignore-steps.gif)

### Minimum Distance

when using range slider, the minimum distance between two handlers can be defined using `minimumDistance` option

```dart
FlutterSlider(
  ...
    minimumDistance: 300,
  ...
)
```

![](images/range-minimum-distance.gif)

### Maximum Distance

this is the opposite of minimum distance, when using range slider, the maximum distance between two handlers can be defined using `maximumDistance` option

```dart
FlutterSlider(
  ...
    maximumDistance: 300,
  ...
)
```

![](images/range-maximum-distance.gif)




### Always Show Tooltips

tooltips always displayed if this property is set to `true`. like above example

```dart
FlutterSlider(
  ...
  alwaysShowTooltip: true,
  ...
)
```

### Touch Zone

You can control how big a handler's touch area could be. by default touch zone is 2  
the range is between 1 to 5

```dart
FlutterSlider(
  ...
  touchZone: 2,
  ...
)
```

to see the touchable area for handlers you set `displayTestTouchZone` to true and test your slider

```dart
FlutterSlider(
  ...
  displayTestTouchZone: true,
  ...
)
```

![](images/range-touchable-area.gif)

### disabled

to disable your slider, you can use `disabled`. 

```dart
FlutterSlider(
  ...
  disabled: true,
  ...
)
```

### rtl

makes the slider `Right To Left`

```dart
FlutterSlider(
  ...
  rtl: true,
  ...
)
```

## Events

There are 3 events

`onDragStarted`: fires when drag starts  
`onDragCompleted` fires when drag ends  
`onDragging` keeps firing when dragging  


all three of above functions returns two `double` values. `Lower Value` and `Upper Value`

```dart
FlutterSlider(
  ...
  onDragging: (lowerValue, upperValue) {
    _lowerValue = lowerValue;
    _upperValue = upperValue;
    setState(() {});
  },
  ...
)
```



