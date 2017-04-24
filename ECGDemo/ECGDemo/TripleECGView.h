////
////  TripleECGView.h
////  SuoSiApp
////
////  Created by zhang on 16/4/1.
////  Copyright © 2016年 Ym. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//
//@interface PointContainer : NSObject
//
//// 这应该是要刷新的元素
//@property (nonatomic, readonly) NSInteger numberOfrefreshElements;
////要平移的元素
//@property (nonatomic, readonly) NSInteger numberOfTranslationElements;
////保存要刷新的点
//@property (nonatomic, readonly) CGPoint *refreshpointContainer;
////保存要平移的点
//@property (nonatomic, readonly) CGPoint *translationPointContainer;
//
//+ (PointContainer *)shareContainer;
////刷新变化
//- (void)addPointAsRefreshChangeform:(CGPoint)point;
////平移变化
//- (void)addPointAstranslationChangeform:(CGPoint)point;
//
//@end
//
//
//@interface TripleECGView : UIView
//
//
//- (void)fireDrawingWithPoints:(CGPoint *)points pointsCount:(NSInteger)count;
//@end

//
//  GridView.h
//  a0412
//
//  Created by zhang on 16/4/12.
//  Copyright © 2016年 Ym. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"

@interface TripleECGView : UIView
{
    

    //   绘图上下文
    CGContextRef contex;
    CGPoint drawingPoints[1000];
    
    //    获取当前点
    //    int  currentPoint;
    //
    //    int pos_x_offset;
    
}
@property (nonatomic, assign) CGPoint endPoint1, endPoint2, endPoint3;
//@property (nonatomic, assign) CGPoint drawingPoints[];
@property (nonatomic, assign) int count;

@property (nonatomic, strong) NSMutableArray *pointArray;
@property (nonatomic, assign)     int index;
@property (nonatomic, strong) ViewController *viewController;

@property (nonatomic, assign) int pos_x_offset;
@property (nonatomic, assign) int currentPoint;

//点的间隔 控制画图的速度  点的幅度
@property (nonatomic, assign) float pointMartin ,pointRang; //= 3;



//- (void)resetBuffer;
- (void)fireDrawing;
- (void)tapGesture;
- (void)keepDrawing;
//缓存点
@property (nonatomic, assign) CGPoint endPoint;

// 创建一个暂时的值 判断蓝牙产生的数据是否有效
@property (nonatomic, assign) int tempValue;

//第几个通道
@property (nonatomic, strong) UILabel *channelLB;


@property (nonatomic, assign) CGFloat max, min;
@property (nonatomic, strong) NSMutableArray *maxArr, *minArr;
@property (nonatomic, strong) NSMutableArray *avgArr;
@property (nonatomic, strong) NSMutableArray *tempArr;

//通过一个 属性 修改 心电图的幅值
@property (nonatomic, assign) CGFloat heartAmplitude;
@property (nonatomic, assign) CGFloat kkk,bbb;


@end

