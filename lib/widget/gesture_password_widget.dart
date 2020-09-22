import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gesture_password_widget/model/point_item.dart';
import 'package:gesture_password_widget/widget/line_painter.dart';

/// 当点被选中时的回调函数
typedef OnHitPoint = void Function();

/// 手势滑动结束时的回调函数
/// [result] 已经选择的所有点的结果集
typedef OnComplete = void Function(List<int> result);

/// 手势密码绘制 widget
///
/// [size] GesturePasswordWidget 的 width 和 height.
///
/// [identifySize] 用来判断点是否被选中的区域大小，值越大识别越精准.
///
/// [normalItem] 正常情况下展示的widget
///
/// [selectedItem] 选中情况下展示的widget
///
/// [errorItem] 错误情况下展示的widget，只有设置了[minLength]或[answer]时才会生效，
/// 1）当[minLength]不为null时，如果选择的点的数量小于minLength，则展示[errorItem]，比如
/// 设置了minLength = 4，但是选择的点的结果集为 [0,1,3]，共选择了3个点，小于4；
/// 2）当[answer]不为null时，如果选择的点的结果集和[answer]不相等，则展示[errorItem]，比如
/// answer = [0,1,2,4,7]，但是选择的点的结果集为[0,1,2,5,8]，和answer不想等;
/// 另外，[errorItem]的展示时长由[completeWaitMilliseconds]控制。
///
/// [hitItem] 当这个点被选中时要展示的widget，其展示时长由[hitShowMilliseconds]控制，达到
/// 展示时长后继续展示[selectedItem]。
///
/// [singleLineCount] 单行个数，总个数等于 singleLineCount * singleLineCount.
///
/// [color] GesturePasswordWidget 的背景色，默认为 [Theme.of].[scaffoldBackgroundColor]
///
/// [onHitPoint] 当点被选中时的回调函数
///
/// [onComplete] 手势滑动结束时的回调函数
///
/// [lineColor] 线的颜色
///
/// [errorLineColor] 错误场景下线的颜色，见[errorItem]
///
/// [lineWidth] 线的宽度
///
/// [answer] 正确的结果，demo: [0, 1, 2, 4, 7]
///
/// [loose] 是否采用宽松策略，默认为true。
/// 考虑这种情况：第一个点选中了 index = 0 的点，第二个点选中了 index = 6的点，
/// 此时index = 0,index = 3,index = 6这三个点在一条直线上，
/// 如果loose为true，输出为[0,3,6],
/// 如果loose为false，输出为[0,6].
///
/// [completeWaitMilliseconds] 最后选择的所有点及绘制的直线在屏幕上展示的时间，时间结束后，
/// 清除所有点，恢复到初始状态，时间结束之前 GesturePasswordWidget 不再接受任何手势事件。
///
/// [hitShowMilliseconds] 见[hitItem]
///
/// [minLength] 如果设置了此值，则长度不够时显示errorItem和errorLine.
///
/// Demo:
///
/// ```dart
/// GesturePasswordWidget(
///      lineColor: Colors.white,
///      errorLineColor: Colors.redAccent,
///      singleLineCount: 3,
///      identifySize: 80.0,
///      minLength: 4,
///      hitShowMilliseconds: 40,
///      errorItem: Container(
///        width: 10.0,
///        height: 10.0,
///        decoration: BoxDecoration(
///          color: Colors.redAccent,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      normalItem: Container(
///        width: 10.0,
///        height: 10.0,
///        decoration: BoxDecoration(
///          color: Colors.white,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      selectedItem: Container(
///        width: 10.0,
///        height: 10.0,
///        decoration: BoxDecoration(
///          color: Colors.white,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      hitItem: Container(
///        width: 15.0,
///        height: 15.0,
///        decoration: BoxDecoration(
///          color: Colors.white,
///          borderRadius: BorderRadius.circular(50.0),
///        ),
///      ),
///      answer: [0, 1, 2, 4, 7],
///      color: Color(0xff252534),
///      onComplete: (data) {
///        setState(() {
///          result = data.join(', ');
///        });
///      },
/// )
/// ```
///
class GesturePasswordWidget extends StatefulWidget
    with DiagnosticableTreeMixin {
  final double size;
  final double identifySize;
  final Widget normalItem;
  final Widget selectedItem;
  final Widget errorItem;
  final Widget hitItem;
  final int singleLineCount;
  final Color color;
  final OnHitPoint onHitPoint;
  final OnComplete onComplete;
  final Color lineColor;
  final Color errorLineColor;
  final double lineWidth;
  final bool loose;
  final List<int> answer;
  final int completeWaitMilliseconds;
  final int hitShowMilliseconds;
  final int minLength;

  GesturePasswordWidget({
    this.size = 300.0,
    this.identifySize = 50.0,
    this.normalItem,
    this.selectedItem,
    this.errorItem,
    this.hitItem,
    this.singleLineCount = 3,
    this.color,
    this.onHitPoint,
    this.onComplete,
    this.lineColor = Colors.green,
    this.errorLineColor = Colors.redAccent,
    this.lineWidth = 2.0,
    this.answer,
    this.loose = true,
    this.completeWaitMilliseconds = 300,
    this.hitShowMilliseconds = 40,
    this.minLength,
  })  : assert(singleLineCount > 1, 'singLineCount must not be smaller than 1'),
        assert(identifySize > 0),
        assert(size > identifySize);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
    properties.add(DoubleProperty('identifySize', identifySize));
    properties.add(DiagnosticsProperty<Widget>('normalItem', normalItem));
    properties.add(DiagnosticsProperty<Widget>('selectedItem', selectedItem));
    properties.add(DiagnosticsProperty<Widget>('errorItem', errorItem));
    properties.add(DiagnosticsProperty<Widget>('hitItem', hitItem));
    properties.add(IntProperty('singleLineCount', singleLineCount));
    properties.add(ColorProperty('color', color));
    properties.add(DiagnosticsProperty<OnHitPoint>('onHitPoint', onHitPoint));
    properties.add(DiagnosticsProperty<OnComplete>('onComplete', onComplete));
    properties.add(ColorProperty('lineColor', lineColor));
    properties.add(ColorProperty('errorLineColor', errorLineColor));
    properties.add(IterableProperty('answer', answer));
    properties.add(DoubleProperty('lineWidth', lineWidth));
    properties.add(FlagProperty(
      'loose',
      value: loose,
      ifFalse: 'loose: false',
      ifTrue: 'loose: true',
      defaultValue: true,
    ));
    properties
        .add(IntProperty('completeWaitMilliseconds', completeWaitMilliseconds));
    properties.add(IntProperty('hitShowMilliseconds', hitShowMilliseconds));
    properties.add(IntProperty('minLength', minLength));
  }

  @override
  _GesturePasswordWidgetState createState() => _GesturePasswordWidgetState();
}

class _GesturePasswordWidgetState extends State<GesturePasswordWidget> {
  Point origin;
  int totalCount;
  Point<double> lastPoint;
  Widget normalItem;
  Widget defaultNormalItem;
  Widget selectedItem;
  Widget defaultSelectedItem;
  Widget errorItem;
  Widget defaultErrorItem;
  Color lineColor;
  bool ignoring = false;
  final points = <PointItem>[];
  final linePoints = <Point<double>>[];
  final result = <int>[];
  final double defaultSize = 10.0;

  @override
  void initState() {
    super.initState();
    defaultNormalItem = Container(
      width: defaultSize,
      height: defaultSize,
      decoration: BoxDecoration(
        color: Colors.greenAccent,
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
    defaultSelectedItem = Container(
      width: defaultSize,
      height: defaultSize,
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(50.0),
      ),
    );
    defaultErrorItem = Container(
      width: defaultSize,
      height: defaultSize,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(50.0),
      ),
    );

    lineColor = widget.lineColor;
    normalItem = widget.normalItem ?? defaultNormalItem;
    selectedItem = widget.selectedItem ?? defaultSelectedItem;
    errorItem = widget.errorItem ?? defaultErrorItem;

    totalCount = widget.singleLineCount * widget.singleLineCount;
    origin = Point<double>(widget.size * 0.5, widget.size * 0.5);
    calculatePointPosition();
  }

  @override
  void didUpdateWidget(GesturePasswordWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.lineColor != oldWidget.lineColor) {
      lineColor = widget.lineColor;
    }

    if (widget.normalItem != oldWidget.normalItem) {
      normalItem = widget.normalItem ?? defaultNormalItem;
    }

    if (widget.selectedItem != oldWidget.selectedItem) {
      selectedItem = widget.selectedItem ?? defaultSelectedItem;
    }

    if (widget.errorItem != oldWidget.errorItem) {
      errorItem = widget.errorItem ?? defaultErrorItem;
    }

    if (widget.singleLineCount != oldWidget.singleLineCount ||
        widget.size != oldWidget.size ||
        widget.identifySize != oldWidget.identifySize) {
      totalCount = widget.singleLineCount * widget.singleLineCount;
      origin = Point<double>(widget.size * 0.5, widget.size * 0.5);
      points.clear();
      calculatePointPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignoring,
      child: Container(
        color: widget.color ?? Theme.of(context).scaffoldBackgroundColor,
        width: widget.size,
        height: widget.size,
        child: Stack(
          children: createPointsWidget()
            ..add(
              GestureDetector(
                onPanDown: handlePanDown,
                onPanUpdate: handlePanUpdate,
                onPanEnd: handPanEnd,
                child: CustomPaint(
                  painter: LinePainter(
                    points: linePoints,
                    lineColor: lineColor,
                    lineWidth: widget.lineWidth,
                  ),
                  willChange: true,
                  size: Size(widget.size, widget.size),
                ),
              ),
            ),
        ),
      ),
    );
  }

  //计算每个点的位置
  void calculatePointPosition() {
    double initX = widget.identifySize * 0.5;
    double initY = widget.identifySize * 0.5;
    double gap =
        (widget.size - widget.identifySize) / (widget.singleLineCount - 1);

    for (int i = 0; i < totalCount; i++) {
      double centerX = initX + i % widget.singleLineCount * gap;
      double centerY = initY + i ~/ widget.singleLineCount * gap;
      points.add(PointItem(x: centerX, y: centerY, index: i));
    }
  }

  //创建每个点的widget
  List<Widget> createPointsWidget() {
    return points.map<Widget>((p) {
      double reference = 1 - (widget.identifySize / widget.size);
      double x = (p.x - origin.x) / (widget.size * 0.5) / reference;
      double y = (p.y - origin.y) / (widget.size * 0.5) / reference;

      Widget child = normalItem;
      if (p.isError) {
        child = errorItem;
      } else if (p.isFirstSelected) {
        child = widget.hitItem;
      } else if (p.isSelected) {
        child = selectedItem;
      }

      return Align(
        alignment: Alignment(x, y),
        child: Container(
          color: Colors.transparent,
          width: widget.identifySize,
          height: widget.identifySize,
          alignment: Alignment.center,
          child: child,
        ),
      );
    }).toList();
  }

  void handlePanDown(DragDownDetails details) {
    Point<double> curPoint =
        Point(details.localPosition.dx, details.localPosition.dy);
    final point = calculateHintPoint(curPoint);
    if (point != null) {
      if (!linePoints.contains(Point(point.x, point.y))) {
        addPointToResult(point.index);
        setState(() {
          point.isSelected = true;
          linePoints.add(Point(point.x, point.y));
        });
      }
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    Point<double> curPoint =
        Point(details.localPosition.dx, details.localPosition.dy);
    final point = calculateHintPoint(curPoint);
    if (point != null) {
      if (!linePoints.contains(Point(point.x, point.y))) {
        final drawPoint = Point(point.x, point.y);
        //宽松策略下，若三点共线则自动将中间的点设置为选中状态。
        if (widget.loose && linePoints.isNotEmpty) {
          handleLooseCase(points[result.last], point);
        }
        addPointToResult(point.index);
        setState(() {
          linePoints.remove(lastPoint);
          point.isSelected = true;
          linePoints.add(drawPoint);
        });
      }
    } else {
      if (linePoints.isNotEmpty) {
        setState(() {
          linePoints.remove(lastPoint);
          linePoints.add(curPoint);
        });
        lastPoint = curPoint;
      }
    }
  }

  void handPanEnd(DragEndDetails details) async {
    widget.onComplete?.call(result);

    linePoints.removeLast();

    if ((widget.answer != null && widget.answer.join() != result.join()) ||
        (widget.minLength != null && widget.minLength > result.length)) {
      setState(() {
        lineColor = widget.errorLineColor;
        for (int i = 0; i < result.length; i++) {
          points[result[i]].isError = true;
        }
      });
    }

    setState(() {
      ignoring = true;
    });
    await Future.delayed(Duration(
      milliseconds: widget.completeWaitMilliseconds,
    ));
    ignoring = false;
    lineColor = widget.lineColor;

    setState(() {
      points.forEach((p) {
        p.isSelected = false;
        p.isError = false;
      });
      linePoints.clear();
      result.clear();
    });
  }

  //计算命中的点
  PointItem calculateHintPoint(Point<double> curPoint) {
    for (int i = 0; i < points.length; i++) {
      final p = Point(points[i].x, points[i].y);
      if (p.distanceTo(curPoint) + 0.5 < widget.identifySize * 0.5) {
        if (points[i].isSelected) {
          return null;
        }
        return points[i];
      }
    }
    return null;
  }

  void addPointToResult(int index) {
    widget.onHitPoint?.call();
    result.add(index);

    if (widget.hitItem != null) {
      setState(() {
        points[index].isFirstSelected = true;
      });
      Future.delayed(Duration(milliseconds: widget.hitShowMilliseconds), () {
        setState(() {
          points[index].isFirstSelected = false;
        });
      });
    }
  }

  //根据海伦公式计算三角形面积，面积为0时视为三点共线。
  //如果这个点还在共线的中间，则将其设置为选中状态，并将其添加到result中。
  void handleLooseCase(PointItem pre, PointItem next) {
    points.forEach((item) {
      if (item != pre && item != next && item.isSelected == false) {
        final itemDrawPoint = Point<double>(item.x, item.y);
        final preDrawPoint = Point<double>(pre.x, pre.y);
        final nextDrawPoint = Point<double>(next.x, next.y);
        double a = itemDrawPoint.distanceTo(preDrawPoint);
        double b = itemDrawPoint.distanceTo(nextDrawPoint);
        double c = preDrawPoint.distanceTo(nextDrawPoint);
        double p = (a + b + c) * 0.5;
        double area = p * (p - a) * (p - b) * (p - c);

        double halfDistance = c * 0.5;
        Point<double> mid = Point(
          (pre.x + next.x) * 0.5,
          (pre.y + next.y) * 0.5,
        );

        if (area - 0.5 <= 0 && itemDrawPoint.distanceTo(mid) < halfDistance) {
          item.isSelected = true;
          addPointToResult(item.index);
        }
      }
    });
  }
}
