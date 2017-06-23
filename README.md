# XTBezierPathBuilderDemo
![图来自pexels](http://upload-images.jianshu.io/upload_images/1319710-f68c70b0ca4ac62c.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
>说来话长，这一切都得从PhotoShop中的钢笔工具开始说起...

**声明：本文不含复杂数学公式，学渣放心阅读吧😂**(我仿佛看到了学渣们留下了激动的泪水)

# 背景
贝塞尔曲线(Bézier curve)是应用于二维图形应用程序的数学曲线，贝塞尔曲线基于多个点构成。它的应用非常广泛，比如说PS中的钢笔工具所绘画的曲线就是贝塞尔曲线，绘制动画的运动轨迹等等，而最近一次想用到贝塞尔曲线是想做一个 **路径动画** 。


# 简介
在iOS开发中一般通过``UIBezierPath``来实现贝塞尔曲线的绘制，平时一般使用绘制二阶和三阶贝塞尔曲线的方法。而我们要做的远超二三阶的贝塞尔曲线，[本文 iOS Demo](https://github.com/xietao3/XTBezierPathBuilderDemo)在原理上实现了N阶贝塞尔曲线的绘制，未使用任何相关API，纯手动绘制贝塞尔曲线，并且可以拖动滑块浏览贝塞尔曲线的绘制过程。


[本文 iOS Demo](https://github.com/xietao3/XTBezierPathBuilderDemo) 实现以下功能:

实现功能|描述
-|-
绘制贝塞尔曲线|1、点击空白处设置贝塞尔曲线的点 </br>2、可以设置贝塞尔曲线阶数 </br>3、播放贝塞尔曲线绘制过程 </br> 4、拖动滑块，自由查看绘制过程每一个瞬间
简易曲线图表|每两个点之间都是用3阶贝塞尔曲线连接(细节待完善)
过山车|1、在空白处绘制贝塞尔曲线 </br>2、过山车沿着绘制的贝塞尔曲线行驶</br>3、支持多个连接的贝塞尔曲线路径

**Demo示例图**
![8阶贝塞尔曲线绘制过程](http://upload-images.jianshu.io/upload_images/1319710-b802c4d1da045b6e.gif?imageMogr2/auto-orient/strip)

# 贝塞尔曲线的绘制原理


说到绘制原理，如果贴👇这张图，我只能说：什么鬼！！！我看不懂，听不见，你说什么... 
路人甲：简单点...说话的方式简单点~

![失败案例](http://upload-images.jianshu.io/upload_images/1819486-bfbef7229c101bde?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)  

首先提供[一个可以动态绘制贝塞尔曲线的网站](http://myst729.github.io/bezier-curve/)帮助你更好地理解贝塞尔曲线的绘制。
### 1.  点

贝塞尔曲线点的数量决定了曲线的阶数，一般N个点构成的N-1阶贝塞尔曲线，即3个点为二阶，至少由3个点组成，为什么两个点不行，两个点组成的是直线。按顺序，第一个点为 **起点** ，最后一个点为 **终点** ，其余点都为 **控制点** 。

![A起点、B控制点 、C终点以及绘制的贝塞尔曲线](http://upload-images.jianshu.io/upload_images/1319710-654861388c5b30d9.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/440)

### 2. 点生线
这里说的线不是贝塞尔曲线，而是各个点按顺序连接起来，形成的直线，如上图``AB``、``BC``两条线。在这里我们要将整个曲线的绘制量化为从``0~1``的过程，用``progress``为当前过程的进度，``progress``的区间即``0~1``。每一条线都需要根据``progress``生成一个点，如下图，一个点从``P0``移动到``P1``,这是这条线从``0~1``的过程。
![根据进度点从起点向终点移动](http://upload-images.jianshu.io/upload_images/1319710-646b9393dc6bdf05.gif?imageMogr2/auto-orient/strip)

下面是绘制一个二阶贝塞尔曲线过程，先给口诀： **点生线，线生点** 😂。由``A``、``B``、``C``这3个点组成2条线``AB``和``BC``，2条线根据``progress``分别生成2个移动的点``D``和``E``，而``D``和``E``又连成一条线，始终保持``AD:DB=BE:EC``。

![progress为0.3 的连线 ](http://upload-images.jianshu.io/upload_images/1319710-ae1473f2f7da53ab.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/440)
![移动的线](http://upload-images.jianshu.io/upload_images/1319710-efbcbd8d33b9e7a7.gif?imageMogr2/auto-orient/strip)

``DE``,``DE``再根据``progress``生成点``F``，只剩一个点，无法构成线，即为最终构成贝塞尔曲线的点。红色点为``progress``在``0~1``过程中点``F``的移动过程，保持``AD:DB=BE:EC=DF:FE``。



![progress为0.3 最终的点](http://upload-images.jianshu.io/upload_images/1319710-7ea572906d977e3b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/440)



![点F的移动过程](http://upload-images.jianshu.io/upload_images/1319710-e23aa5ee1c570b24.gif?imageMogr2/auto-orient/strip)


### 3. 绘制贝塞尔曲线
经过上面 **点生线，线生点** 的过程 ，我们拿到了点F在移动中所有点的，将这些点集合连接起来，即形成了贝塞尔曲线。``progress``自增越慢，点集合的点越多，曲线就越细致。

![绘制二阶贝塞尔曲线过程](http://upload-images.jianshu.io/upload_images/1319710-34d7cf413ee16f0e.gif?imageMogr2/auto-orient/strip)

### 4. N阶贝塞尔曲线
稍微了解算法的同学就能发现，其实 **点生线，线生点** 是一个递归的过程，通过底层的点，一步步推算出最高阶的点。整个推导过程像一个金字塔，底部点的数量最多，每高一阶点的数量就减1，直至最高阶只有1个点。

**下面是递归代码： **

```
// 贝塞尔曲线每高一阶  需要递归次数+1
+ (NSArray *)recursionGetsubLevelPointsWithSuperPoints:(NSArray *)points progress:(CGFloat)progress{
    // 得到最终的点 正确结束递归 
    if (points.count == 1) return points;
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] init];
    for (int i = 0; i < points.count-1; i++) {
        // 第一个点 
        NSValue *preValue = [points objectAtIndex:i];
        CGPoint prePoint = preValue.CGPointValue;
        // 第二个点
        NSValue *lastValue = [points objectAtIndex:i+1];
        CGPoint lastPoint = lastValue.CGPointValue;

        // 两点坐标差
        CGFloat diffX = lastPoint.x-prePoint.x;
        CGFloat diffY = lastPoint.y-prePoint.y;

        // 根据当前progress得出高一阶的点
        CGPoint currentPoint = CGPointMake(prePoint.x+diffX*progress, prePoint.y+diffY*progress);
        [tempArr addObject:[NSValue valueWithCGPoint:currentPoint]];
    }
    // 继续下一次递归过程
    return [self recursionGetsubLevelPointsWithSuperPoints:tempArr progress:progress];
}
```
**8阶贝塞尔曲线绘制过程：**
![8阶贝塞尔曲线绘制过程](http://upload-images.jianshu.io/upload_images/1319710-b802c4d1da045b6e.gif?imageMogr2/auto-orient/strip)


# 贝塞尔曲线的应用
光讲原理脱离实践这不是程序员的风格，简单地写了2个贝塞尔曲线的应用，都在**[本文 iOS Demo](https://github.com/xietao3/XTBezierPathBuilderDemo)** 里面，欢迎运行体验。
### 1. 过山车
通过点击屏幕收集点，将点集合生成贝塞尔曲线，可生成多个相连的贝塞尔曲线。小车按照生成的贝塞尔曲线路径前进。

**a. 画路径**
通过计算贝塞尔曲线的长度，根据曲线长度分配点的数量，达到点的相对均匀分布，使过山车 **匀速前进** 。
![画路径](http://upload-images.jianshu.io/upload_images/1319710-f9f35dbe987a9c51.gif?imageMogr2/auto-orient/strip)

**b. 发车**
每个点都与前面一个点连线，通过计算得出两点的连线与水平形成的夹角，将角度赋予过山车实现 **转向功能** 。
![发车](http://upload-images.jianshu.io/upload_images/1319710-71703ee22240004c.gif?imageMogr2/auto-orient/strip)

### 2. 简易曲线图表

**a. 直线图表**
即最简单的两点连成直线。

![直线图表](http://upload-images.jianshu.io/upload_images/1319710-78a238b63e1be55e.gif?imageMogr2/auto-orient/strip)

**b. 曲线图表**
曲线图表的曲线全部由3阶贝塞尔曲线构成，整个曲线图不含任何棱角。
![曲线图表](http://upload-images.jianshu.io/upload_images/1319710-b3fce50cd7dd88ac.gif?imageMogr2/auto-orient/strip)

# 拓展

![PaintCode](http://upload-images.jianshu.io/upload_images/1319710-57b4a7ab5be942bd.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/240)
推荐一个``iOS``画路径神器``PaintCode``，画好图形直接生成代码，用钢笔工具画贝塞尔曲线也十分方便。下图为用钢笔工具画一个圆球(貌似不够圆😆)：

![生成代码](http://upload-images.jianshu.io/upload_images/1319710-0e96890b3f08676c.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


# 总结
为了准备这一篇文章差不多理解了贝塞尔曲线的绘制原理，但是在细节处，比如说真正意义上贝塞尔曲线点的均匀分布还有待完善，求曲线公式也没有去研究，贝塞尔曲线在复杂的动画方向地应用也是大有作为。

# 参考
[贝塞尔曲线开发的艺术](http://www.jianshu.com/p/55c721887568)
[Android：贝塞尔曲线原理分析](http://www.jianshu.com/p/1af5c3655fa3)

**个人水平有限，欢迎提出建议。**
