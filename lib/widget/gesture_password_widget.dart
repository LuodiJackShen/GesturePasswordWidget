import 'dart:math' as math;
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
typedef OnComplete = void Function(List<int?> result);

typedef OnCancel = void Function();

/// 一个支持高度自定义、满足绝大部分日常需求的手势密码绘制widget
///
/// [简体中文](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/README-CN.md)
/// [English](https://github.com/LuodiJackShen/GesturePasswordWidget/blob/master/README.md) <br>
///
/// Demo:
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
///      arrowItem: Image.asset(
///         'images/arrow.png',
///         width: 20.0,
///         height: 20.0,
///         color: const Color(0xff0C6BFE),
///         fit: BoxFit.fill,
///      ),
///      errorArrowItem: Image.asset(
///         'images/arrow.png',
///         width: 20.0,
///         height: 20.0,
///         fit: BoxFit.fill,
///         color: const Color(0xffFB2E4E),
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
class GesturePasswordWidget extends StatefulWidget with DiagnosticableTreeMixin {
  /// GesturePasswordWidget 的 width 和 height.
  final double size;

  ///用来判断点是否被选中的区域大小，值越大识别越精准.
  final double identifySize;

  ///正常情况下展示的widget
  final Widget? normalItem;

  ///选中情况下展示的widget
  final Widget? selectedItem;

  /// 错误情况下展示的widget，只有设置了[minLength]或[answer]时才会生效，
  /// 1）当[minLength]不为null时，如果选择的点的数量小于minLength，则展示[errorItem]，
  /// 比如设置了 minLength = 4，但是选择的点的结果集为 [0,1,3]，共选择了3个点，小于4；
  /// 2）当[answer]不为null时，如果选择的点的结果集和[answer]不相等，则展示[errorItem]，
  /// 比如 answer = [0,1,2,4,7]，但是选择的点的结果集为[0,1,2,5,8]，和answer不相等;
  /// 另外，[errorItem]的展示时长由[completeWaitMilliseconds]控制。
  final Widget? errorItem;

  /// 当这个点被选中时要展示的widget，其展示时长由[hitShowMilliseconds]控制，达到展示时长
  /// 后继续展示[selectedItem]。
  final Widget? hitItem;

  ///正常情况下显示的箭头控件。
  ///跟随手势旋转时，x轴正方向为0度，所以如果你使用了箭头，确保箭头指向x轴正方向。
  final Widget? arrowItem;

  ///错误情况下显示的箭头控件，如果设置了[errorArrowItem],则必须设置[arrowItem],
  ///否则[errorArrowItem]不会展示。
  ///跟随手势旋转时，x轴正方向为0度，所以如果你使用了箭头，确保箭头指向x轴正方向。
  final Widget? errorArrowItem;

  ///[arrowItem]和[errorArrowItem]在x轴上的偏移，原点在[normalItem]的中心。
  ///当 -1 < [arrowXAlign] < 1 时，[arrowItem]和[errorArrowItem]在[normalItem]范围内进行绘制；
  ///当[arrowXAlign] > 1 或者[arrowXAlign] < -1时，在[normalItem]范围外进行绘制；
  final double arrowXAlign;

  ///[arrowItem]和[errorArrowItem]在y轴上的偏移，原点在[normalItem]的中心。
  ///当 -1 < [arrowYAlign] < 1 时，[arrowItem]和[errorArrowItem]在[normalItem]范围内进行绘制；
  ///当[arrowYAlign] > 1 或者[arrowYAlign] < -1时，在[normalItem]范围外进行绘制；
  final double arrowYAlign;

  ///单行个数，总个数等于 singleLineCount * singleLineCount.
  final int singleLineCount;

  ///GesturePasswordWidget的背景色，默认为 [Theme.of].[scaffoldBackgroundColor]
  final Color? color;

  ///当点被选中时的回调函数
  final OnHitPoint? onHitPoint;

  ///手势滑动结束时的回调函数
  final OnComplete? onComplete;

  ///线的颜色
  final Color lineColor;

  ///错误场景下线的颜色，见[errorItem]
  final Color errorLineColor;

  ///线的宽度
  final double lineWidth;

  /// 是否采用宽松策略，默认为true。
  /// 考虑这种情况：第一个点选中了 index = 0 的点，第二个点选中了 index = 6的点，
  /// 此时index = 0,index = 3,index = 6这三个点在一条直线上，
  /// 如果loose为true，输出为[0,3,6],
  /// 如果loose为false，输出为[0,6].
  final bool loose;

  ///正确的结果，demo: [0, 1, 2, 4, 7]
  final List<int>? answer;

  ///最后选择的所有点及绘制的直线在屏幕上展示的时间，时间结束后，清除所有点，恢复到初始状态，
  ///时间结束之前 GesturePasswordWidget 不再接受任何手势事件。
  final int completeWaitMilliseconds;

  ///见[hitItem]
  final int hitShowMilliseconds;

  ///如果设置了此值，则长度不够时显示[errorItem]和[errorLineColor].
  final int? minLength;

  ///Used to cancel the drawn pattern
  final Widget? cancelButton;

  ///The size of the area used to judge whether the cancel point is selected, the larger the value, the more accurate the recognition.
  final double cancelIdentifySize;

  ///Callback function when the cancelled
  final OnCancel? onCancel;

  /// Space value between PasswordWidget and CancelButton
  final double? cancelButtonSpace;

  /// CancelButton height area
  final double? cancelButtonHeight;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('size', size));
    properties.add(DoubleProperty('identifySize', identifySize));
    properties.add(DiagnosticsProperty<Widget>('normalItem', normalItem));
    properties.add(DiagnosticsProperty<Widget>('selectedItem', selectedItem));
    properties.add(DiagnosticsProperty<Widget>('errorItem', errorItem));
    properties.add(DiagnosticsProperty<Widget>('hitItem', hitItem));
    properties.add(DiagnosticsProperty<Widget>('arrowItem', arrowItem));
    properties.add(
      DiagnosticsProperty<Widget>('errorArrowItem', errorArrowItem),
    );
    properties.add(DoubleProperty('arrowXAlign', arrowXAlign));
    properties.add(DoubleProperty('arrowYAlign', arrowYAlign));
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
    properties.add(
      IntProperty('completeWaitMilliseconds', completeWaitMilliseconds),
    );
    properties.add(IntProperty('hitShowMilliseconds', hitShowMilliseconds));
    properties.add(IntProperty('minLength', minLength));
  }

  GesturePasswordWidget({
    this.size = 300.0,
    this.identifySize = 50.0,
    this.normalItem,
    this.selectedItem,
    this.errorItem,
    this.hitItem,
    this.arrowItem,
    this.errorArrowItem,
    this.arrowXAlign = 0.6,
    this.arrowYAlign = 0.0,
    this.singleLineCount = 3,
    this.color,
    this.onHitPoint,
    this.onComplete,
    this.onCancel,
    this.lineColor = Colors.green,
    this.errorLineColor = Colors.redAccent,
    this.lineWidth = 2.0,
    this.answer,
    this.loose = true,
    this.completeWaitMilliseconds = 300,
    this.hitShowMilliseconds = 40,
    this.minLength,
    this.cancelIdentifySize = 50.0,
    this.cancelButton,
    this.cancelButtonSpace = 30,
    this.cancelButtonHeight = 70,
  })  : assert(singleLineCount > 1, 'singLineCount must not be smaller than 1'),
        assert(identifySize > 0),
        assert(size > identifySize),
        assert(!(errorArrowItem != null && arrowItem == null), 'when arrowItem == null, errorArrowItem will not be shown.');

  @override
  _GesturePasswordWidgetState createState() => _GesturePasswordWidgetState();
}

class _GesturePasswordWidgetState extends State<GesturePasswordWidget> {
  late Point origin;
  late int totalCount;
  Point<double>? lastPoint;
  Widget? normalItem;
  Widget? defaultNormalItem;
  Widget? selectedItem;
  Widget? defaultSelectedItem;
  Widget? errorItem;
  Widget? defaultErrorItem;
  Color? lineColor;
  bool ignoring = false;
  final points = <PointItem>[];
  final linePoints = <Point<double>>[];
  final result = <int?>[];
  final double defaultSize = 10.0;
  late PointItem cancelPoint;
  bool cancelButtonVisibility = false;

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

    cancelPoint = PointItem(x: widget.size * 0.5, y: widget.size + 50, isSelected: false);

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
      child: widget.cancelButton != null
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                buildGesturePasswordWidget(),
                SizedBox(height: widget.cancelButtonSpace),
                Container(
                    height: widget.cancelButtonHeight,
                    child: Visibility(
                      child: widget.cancelButton!,
                      visible: cancelButtonVisibility,
                    )),
              ],
            )
          : buildGesturePasswordWidget(),
    );
  }

  Widget buildGesturePasswordWidget() {
    return Container(
      alignment: Alignment.center,
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
              onPanCancel: () {
                print("onPanCancel ");
                handPanEnd(null);
              },
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
    );
  }

  //计算每个点的位置
  void calculatePointPosition() {
    double initX = widget.identifySize * 0.5;
    double initY = widget.identifySize * 0.5;
    double gap = (widget.size - widget.identifySize) / (widget.singleLineCount - 1);

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

      Widget? child = normalItem;
      if (p.isError) {
        child = errorItem;
      } else if (p.isFirstSelected) {
        child = widget.hitItem;
      } else if (p.isSelected) {
        child = selectedItem;
      }

      Widget? arrowItem = widget.arrowItem;
      if (p.isError && widget.errorArrowItem != null) {
        arrowItem = widget.errorArrowItem;
      }

      return Align(
        alignment: Alignment(x, y),
        child: Container(
          color: Colors.transparent,
          width: widget.identifySize,
          height: widget.identifySize,
          alignment: Alignment.center,
          child: widget.arrowItem == null || p.angle == double.infinity
              ? child
              : Transform.rotate(
                  angle: p.angle,
                  child: Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      child!,
                      Align(
                        alignment: Alignment(
                          widget.arrowXAlign,
                          widget.arrowYAlign,
                        ),
                        child: arrowItem,
                      ),
                    ],
                  ),
                ),
        ),
      );
    }).toList();
  }

  void handlePanDown(DragDownDetails details) {
    Point<double> curPoint = Point(details.localPosition.dx, details.localPosition.dy);
    final point = calculateHintPoint(curPoint);
    if (point != null) {
      if (!linePoints.contains(Point(point.x, point.y))) {
        addPointToResult(point.index);
        setState(() {
          point.isSelected = true;
          linePoints.add(Point(point.x, point.y));
          cancelButtonVisibility = true;
        });
      }
    }
  }

  void checkCancelPoint(Point<double> curPoint) {
    final point = calculateCancelHintPoint(curPoint);
    if (point != null) {
      cancelPoint.isSelected = true;
    }
  }

  void handlePanUpdate(DragUpdateDetails details) {
    Point<double> curPoint = Point(details.localPosition.dx, details.localPosition.dy);
    final hitPoint = calculateHintPoint(curPoint);
    if (hitPoint != null) {
      if (!linePoints.contains(Point(hitPoint.x, hitPoint.y))) {
        final drawPoint = Point(hitPoint.x, hitPoint.y);
        //宽松策略下，若三点共线则自动将中间的点设置为选中状态。
        if (widget.loose && linePoints.isNotEmpty) {
          handleLooseCase(points[result.last!], hitPoint);
        }

        //处理箭头的角度展示
        if (widget.arrowItem != null) {
          for (int i = 0; i < result.length - 1; i++) {
            final p1 = math.Point(
              points[result[i]!].x,
              points[result[i]!].y,
            );
            final p2 = math.Point(
              points[result[i + 1]!].x,
              points[result[i + 1]!].y,
            );

            points[result[i]!].angle = calculateAngle(p1, p2);
          }
        }

        if (result.isNotEmpty) {
          int length = result.length;
          final p1 = Point(
            points[result[length - 1]!].x,
            points[result[length - 1]!].y,
          );

          double angle = calculateAngle(p1, math.Point(hitPoint.x, hitPoint.y));
          points[result[length - 1]!].angle = angle;
        }
        addPointToResult(hitPoint.index);
        setState(() {
          linePoints.remove(lastPoint);
          hitPoint.isSelected = true;
          linePoints.add(drawPoint);
          cancelButtonVisibility = true;
        });
      }
    } else {
      if (linePoints.isNotEmpty) {
        if (widget.arrowItem != null) {
          int length = result.length;
          final p1 = Point(
            points[result[length - 1]!].x,
            points[result[length - 1]!].y,
          );

          double angle = calculateAngle(p1, curPoint);
          points[result[length - 1]!].angle = angle;
        }

        setState(() {
          linePoints.remove(lastPoint);
          linePoints.add(curPoint);
        });
        lastPoint = curPoint;
      }
    }
    checkCancelPoint(curPoint);
  }

  void handPanEnd(DragEndDetails? details) async {
    if (result.isEmpty) {
      return;
    }

    if (cancelPoint.isSelected) {
      widget.onCancel?.call();
    } else {
      widget.onComplete?.call(result);
      if (!mounted) {
        return;
      }

      linePoints.removeLast();

      if ((widget.answer != null && widget.answer!.join() != result.join()) ||
          (widget.minLength != null && widget.minLength! > result.length)) {
        lineColor = widget.errorLineColor;
        for (int i = 0; i < result.length; i++) {
          points[result[i]!].isError = true;
        }
      }

      //清除最后一个点的角度
      points[result.last!].angle = double.infinity;

      if (!mounted) {
        return;
      }

      setState(() {
        ignoring = true;
      });
      await Future.delayed(Duration(
        milliseconds: widget.completeWaitMilliseconds,
      ));
      ignoring = false;
      lineColor = widget.lineColor;

      if (!mounted) {
        return;
      }
    }

    setState(() {
      points.forEach((p) {
        p.isSelected = false;
        p.isError = false;
        p.angle = double.infinity;
      });
      linePoints.clear();
      result.clear();
      cancelPoint.isSelected = false;
      cancelButtonVisibility = false;
    });
  }

  //计算命中的点
  PointItem? calculateHintPoint(Point<double> curPoint) {
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

  PointItem? calculateCancelHintPoint(Point<double> curPoint) {
    final p = Point(cancelPoint.x, cancelPoint.y);
    if (p.distanceTo(curPoint) + 0.5 < widget.cancelIdentifySize) {
      return cancelPoint;
    }
    return null;
  }

  void addPointToResult(int? index) {
    widget.onHitPoint?.call();
    result.add(index);

    if (widget.hitItem != null) {
      setState(() {
        points[index!].isFirstSelected = true;
      });
      Future.delayed(Duration(milliseconds: widget.hitShowMilliseconds), () {
        setState(() {
          points[index!].isFirstSelected = false;
        });
      });
    }
  }

  //根据海伦公式计算三角形面积，面积为0时视为三点共线。如果这个点还在共线的中间，
  //则将其设置为选中状态，并将其添加到result中。
  void handleLooseCase(PointItem pre, PointItem next) {
    List<int?> midItems = [];
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
          midItems.add(item.index);
        }
      }
    });

    if (next.index! > pre.index!) {
      midItems.sort((a, b) => a! - b!);
    } else {
      midItems.sort((a, b) => b! - a!);
    }

    midItems.forEach((index) {
      addPointToResult(index);
    });
  }

  //计算两点之间连线和 x 轴的夹角,返回弧度
  double calculateAngle(Point p1, Point p2) {
    return math.atan2((p2.y - p1.y), (p2.x - p1.x)); //弧度
  }
}
