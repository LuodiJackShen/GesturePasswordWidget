import 'package:flutter/material.dart';
import 'package:gesture_password_widget/gesture_password_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GesturePasswordWidgetDemo(),
    );
  }
}

const backgroundColor = Color(0xff252534);

class GesturePasswordWidgetDemo extends StatefulWidget {
  @override
  _GesturePasswordWidgetDemoState createState() => _GesturePasswordWidgetDemoState();
}

class _GesturePasswordWidgetDemoState extends State<GesturePasswordWidgetDemo> {
  String? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 150.0, bottom: 10.0),
              child: Text(
                'Right Answer：0, 1, 2, 4, 7',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20.0),
              height: 80,
              child: Text(
                'Result：${result ?? ''}',
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: 22.0,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 30.0),
              child: createNormalGesturePasswordView(),
            ),
          ],
        ),
      ),
    );
  }

  /// A simple and common demo.
  Widget createNormalGesturePasswordView() {
    return GesturePasswordWidget(
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
      arrowItem: Image.asset(
        'images/arrow.png',
        width: 20.0,
        height: 20.0,
        color: const Color(0xff0C6BFE),
        fit: BoxFit.fill,
      ),
      errorArrowItem: Image.asset(
        'images/arrow.png',
        width: 20.0,
        height: 20.0,
        fit: BoxFit.fill,
        color: const Color(0xffFB2E4E),
      ),
      answer: [0, 1, 2, 4, 7],
      color: backgroundColor,
      onComplete: (data) {
        setState(() {
          result = data.join(', ');
        });
        debugPrint("result: $result");
      },
      cancelButton: Container(
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.all(Radius.circular(100))),
        padding: EdgeInsets.all(20),
        child: Text("Cancel", style: TextStyle(color: Colors.white)),
      ),
      onCancel: () {
        setState(() {
          result = "Cancelled";
        });
        debugPrint("Drawn Pattern Cancelled");
      },
    );
  }

  /// A complex demo.
  /// A line has four dots and supports the effect of the selection by set [hitItem].
  Widget createXiMiGesturePasswordView() {
    return GesturePasswordWidget(
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
    );
  }
}
