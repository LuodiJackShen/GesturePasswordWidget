# GesturePasswordWidget
[English](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/README.md) | [简体中文](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/README-CN.md)

A gesture-unlocking control for Flutter that supports a high degree of customization.

## Demo:
1）A simple and common demo.

Rendering:<br>
![image](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/resoures/simple_demo.gif)

Code：
```dart
GesturePasswordWidget(
      lineColor: const Color(0xff0C6BFE),
      errorLineColor: const Color(0xffFB2E4E),
      singleLineCount: 3,
      identifySize: 80.0,
      minLength: 4,
      errorItem: Image.asset(
        'images/error.png',
        color: const Color(0xffFB2E4E),
      ),
      normalItem: Image.asset('images/normal.png'),
      selectedItem: Image.asset(
        'images/selected.png',
        color: const Color(0xff0C6BFE),
      ),
      answer: [0, 1, 2, 4, 7],
      color: backgroundColor,
      onComplete: (data) {
        setState(() {
          result = data.join(', ');
        });
      },
    )
```

2）A complex demo. A line has four dots and supports the effect of the selection by set [hitItem].

Rendering:<br>
![image](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/resoures/complex_demo.gif)

Code:
```dart
GesturePasswordWidget(
      lineColor: Colors.white,
      errorLineColor: Colors.redAccent,
      singleLineCount: 4,
      identifySize: 80.0,
      minLength: 4,
      hitShowMilliseconds: 40,
      errorItem: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      normalItem: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      selectedItem: Container(
        width: 10.0,
        height: 10.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      hitItem: Container(
        width: 15.0,
        height: 15.0,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
      answer: [0, 1, 2, 3, 6, 10, 14],
      color: backgroundColor,
      onComplete: (data) {
        setState(() {
          result = data.join(', ');
        });
      },
    )
```

## Properties:

| Property | Description |
| ------ | :--- |
| size |  The width and height of GesturePasswordWidget. |
| identifySize | The size of the area used to determine whether a point is selected, the larger the value of the more accurate identification.    |
| normalItem   | Normal display of widget.    |
| selectedItem | The widget to display in the selected case.    |
| errorItem    |  The widget displayed in the error case will only work if minLength or answer is set. <br> (1) When minLength is not null, if the number of selected points is less than minLength, display errorItem, for example, minLength = 4 is set, but the result set of selected points is [0,1,3], a total of 3 points are selected, less than 4.<br>2) When answer is not null, the errorItem is displayed if the result set of the selected point and answer are not equal, e.g., answer = [0,1,2,4,7], but the result set of the selected point is [0,1,2,5,8], which is not equal to answer; <br>In addition, the display duration of the errorItem is controlled by completeWaitMilliseconds.    |
| hitItem |  The widget to be displayed when this point is selected, its display duration is controlled by hitShowMilliseconds, continue to display selectedItem after reaching the display duration.    |
| singleLineCount  | The total number of single lines is equal to singleLineCount * singleLineCount.    |
| color   | The background color of GesturePasswordWidget,which defaults to Theme.of(context).scaffoldBackgroundColor.    |
| onHitPoint   |  The callback function when a point is selected.    |
| onComplete   |  The callback function at the end of a gesture slide.         |
| lineColor    |   The color of line in the normal case.        |
| errorLineColor  |   The color of line in the error casr, see [errorItem].                |
| answer       |  The right result,e.g., [0, 1, 2, 4, 7]    |
| loose        |  The default is true.<br> Consider this case: the points index=0 and index=6 are selected, and the point index=3 is not selected, but the point index=3 is on the line between index=0 and index=6. If loose=true, the gesture password obtained is [0,3,6] if loose=false, then the obtained gesture password is [0,6].                |
| completeWaitMilliseconds   |  The last selected point and the drawn line are displayed on the screen for the duration of the time, after which all points are cleared and the initial state is restored, and GesturePasswordWidget no longer accepts any gesture events until the time expires.   |
| hitShowMilliseconds         |   See hitItem.   |
| minLength    | If this value is set, errorItem and errorLine are displayed if the length is short.                 |



