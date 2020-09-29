# GesturePasswordWidget

一个用于Flutter并且支持高度自定义的手势解锁控件。
## 使用

```dart
dependencies:
  gesture_password_widget: latest-version
```

```dart
import 'package:gesture_password_widget/gesture_password_widget.dart';
```

## 示例展示：  
1）一个简单的例子：  
效果图：  
![image](https://github.com/LuodiJackShen/BookRepo/blob/master/gifs/simple_demo.gif)
  
代码：

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
      },
    );
```

2）一个复杂的例子, 每行有4个点，通过设置hitItem支持了点选中后的效果。  
效果图：  
![image](https://github.com/LuodiJackShen/BookRepo/blob/master/gifs/complex_demo.gif)
  
代码：
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

## 属性介绍：

| 属性名 | 描述 |
| ------ | :--- |
| size |  GesturePasswordWidget 的 width 和 height. |
| identifySize | 用来判断点是否被选中的区域大小，值越大识别越精准.    |
| normalItem   | 正常情况下展示的widget    |
| selectedItem | 选中情况下展示的widget    |
| errorItem    |  错误情况下展示的widget，只有设置了minLength或answer时才会生效. <br> 1）当minLength不为null时，如果选择的点的数量小于minLength，则展示errorItem，比如设置了minLength = 4，但是选择的点的结果集为 [0,1,3]，共选择了3个点，小于4；<br>2）当answer不为null时，如果选择的点的结果集和answer不相等，则展示errorItem，比如answer = [0,1,2,4,7]，但是选择的点的结果集为[0,1,2,5,8]，和answer不相等; <br>另外，errorItem的展示时长由completeWaitMilliseconds控制。    |
| hitItem |  当这个点被选中时要展示的widget，其展示时长由hitShowMilliseconds控制，达到展示时长后继续展示selectedItem。    |
| arrowItem | 正常情况下显示的箭头控件。<br> 跟随手势旋转时，x轴正方向为0度，所以如果你使用了箭头，确保箭头指向x轴正方向。 |
| errorArrowItem | 错误情况下显示的箭头控件，如果设置了errorArrowItem,则必须设置arrowItem,否则errorArrowItem不会展示。<br> 跟随手势旋转时，x轴正方向为0度，所以如果你使用了箭头，确保箭头指向x轴正方向。 |
| arrowXAlign | arrowItem和errorArrowItem在x轴上的偏移，原点在normalItem的中心。<br>当 -1 < arrowXAlign < 1 时，arrowItem和errorArrowItem在normalItem范围内进行绘制；<br>当arrowXAlign > 1 或者arrowXAlign < -1时，在normalItem范围外进行绘制； |
| arrowYAlign | arrowItem和errorArrowItem在y轴上的偏移，原点在normalItem的中心。<br>当 -1 < arrowYAlign < 1 时，arrowItem和errorArrowItem在normalItem范围内进行绘制；<br>当arrowYAlign > 1 或者arrowYAlign < -1时，在normalItem范围外进行绘制； |
| singleLineCount  | 单行个数，总个数等于 singleLineCount * singleLineCount.    |
| color   | GesturePasswordWidget 的背景色，默认为Theme.of(context).scaffoldBackgroundColor    |
| onHitPoint   |  当点被选中时的回调函数    |
| onComplete   |  手势滑动结束时的回调函数                |
| lineColor    |   线的颜色        |
| errorLineColor  |   错误场景下线的颜色，见errorItem                |
| answer       |  正确的结果，demo: [0, 1, 2, 4, 7]    |
| loose        |  是否采用宽松策略，默认为true。<br> 考虑这种情况：选中了index=0和index=6的点，并没有选中index=3的点，但是index=3的点在index=0和index=6的连线上，如果loose=true，则获取到的手势密码为[0,3,6]，如果loose=false，则获取到的手势密码为[0,6]。         |
| completeWaitMilliseconds   |  最后选择的所有点及绘制的直线在屏幕上展示的时间，时间结束后，清除所有点，恢复到初始状态，时间结束之前 GesturePasswordWidget 不再接受任何手势事件。   |
| hitShowMilliseconds         |   见hitItem   |
|  minLength        | 如果设置了此值，则长度不够时显示errorItem和errorLine.                 |



