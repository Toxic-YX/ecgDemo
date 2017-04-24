

#import "TripleECGView.h"
//  http://blog.csdn.net/iosyangming/article/details/50977395#comments
@interface TripleECGView ()

{
    float testX; //= 0.00;

    CGFloat pixelsPerCell; //= 30.00; // 0.2 second per cell

    float lineWidth_Grid;
    //= 0.5;

// 动态画线的宽度
    float lineWidth_LiveMonitor;
    //= 2;
//float lineWidth_Static = 1;

    int pointsPerSecond;
    //= 500;

//  这个是设备的 每个点 代表的分辨率
    float pixelPerPoint;
    //= 2 * 30.0f / 500.0f;
//
    int pointPerDraw;
    //= 500.0f * 0.04f;

}
@end

@implementation TripleECGView

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.clearsContextBeforeDrawing = YES;

        [self addSubs];
        [self addTapGestureRecognizer];
        _avgArr = [[NSMutableArray alloc]init];
        _maxArr = [[NSMutableArray alloc]init];
        _minArr = [[NSMutableArray alloc]init];
        _tempArr = [[NSMutableArray alloc]init];
        _tempValue = 0;
        [self initE];
        
        
    }
    return self;
}
-(void) initE{
    
    
    
     testX = 0.00;
    
    if (kScrenWidth > 380) {
        pixelsPerCell = k6pmm; // 0.2 second per cell
        
    } else {
        pixelsPerCell = k1mm; // 0.2 second per cell

    }
    
     lineWidth_Grid = 1;
    
    // 动态画线的宽度
     lineWidth_LiveMonitor = 1;
    //float lineWidth_Static = 1;
    
     pointsPerSecond = 500;
    
    //  这个是设备的 每个点 代表的分表率
     pixelPerPoint = 2 * 30.0f / 500.0f;
    //
     pointPerDraw = 500.0f * 0.04f;
}



- (void)addSubs{

    self.channelLB = [[UILabel alloc]initWithFrame:CGRectMake(kMartin5, kMartin5, kMartin50, kMartin30)];
    self.channelLB.textColor = BSWhite;
    [self addSubview:_channelLB];


}


- (void)drawRect:(CGRect)rect{
    

    contex = UIGraphicsGetCurrentContext();
    
    [self drawGrid:contex];
    
    [self drawCurve:contex];
    
}
// 绘制网格 显示区域
- (void)drawGrid:(CGContextRef)ctx{
    
    //  显示区域的宽 和 高
    CGFloat full_height = self.frame.size.height;
    CGFloat full_width = self.frame.size.width;
    //    每一格的宽度
    CGFloat cell_squar_width = pixelsPerCell;
    
    CGContextSetLineWidth(ctx, 0.2);
    //    设置画笔的颜色
    CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
    
    CGFloat pos_x = 1;
    while (pos_x < full_width) {
        //        开始画线  大的
        CGContextMoveToPoint(ctx, pos_x, 1);
        CGContextAddLineToPoint(ctx, pos_x, full_height);
        pos_x += cell_squar_width;
        CGContextStrokePath(ctx);
    }
    
    CGFloat pos_y = 1;
    while (pos_y < full_height) {
        
        CGContextMoveToPoint(ctx, full_width, pos_y);
        CGContextAddLineToPoint(ctx, 1, pos_y);
        pos_y += cell_squar_width;
        CGContextStrokePath(ctx);
    }
    
    //    小格子
    
    CGContextSetLineWidth(ctx, 0.1); // 宽度
    
    float cell_squar = 0.00;
    
    cell_squar = (CGFloat)pixelsPerCell / 5.00;
    
    pos_x = 1 + cell_squar;
    
    while (pos_x < full_width) {
      
        CGContextMoveToPoint(ctx, pos_x, 1);
        CGContextAddLineToPoint(ctx, pos_x, full_height);
        CGContextStrokePath(ctx);
        pos_x += cell_squar;
    }
    
    pos_y = 1 ;//+ cell_squar;
    while (pos_y < full_height) {
        CGContextMoveToPoint(ctx, 1, pos_y);
        CGContextAddLineToPoint(ctx, full_width, pos_y);
        CGContextStrokePath(ctx);
        pos_y += cell_squar;
    }
}

// 绘制心电图型
- (void)drawCurve:(CGContextRef)ctx{
    CGContextSetLineWidth(ctx, lineWidth_LiveMonitor);
    CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
    
    //    开始画线
    //     这里开始画线 drawingPoints 是X count 是 Y坐标
    NSInteger count =  _pointArray.count + 1;
    CGContextAddLines(ctx, drawingPoints,count);
    
    _endPoint1 = drawingPoints[count - 1];
//    _endPoint2 = drawingPoints[count - 2];
//    _endPoint3 = drawingPoints[count - 3];
    CGContextStrokePath(ctx);
    
}

- (void)fireDrawing

{
    if (_heartAmplitude == 0) {
        _heartAmplitude = 330;
    }
    if (_pointMartin == 0) {
        _pointMartin = 1.2;
    }
    if (_pointRang == 0) {
        _pointRang = 1;
    }
    
    //   取点太少 导致波动很到 基准变化太快
    if (_tempArr.count < 200 && self.pointArray) {
        [_tempArr addObjectsFromArray:self.pointArray];
    } else {
        [_tempArr removeObjectsInRange:NSMakeRange(0, self.pointArray.count)];
        [_tempArr addObjectsFromArray:_pointArray];
    }
    
    //    获取最近的最大值和 最小值  取平均值 作为中间点
    CGFloat avg = 0;;//= [[self.pointArray valueForKeyPath:@"@avg.floatValue"] floatValue];
    CGFloat min = [[_tempArr valueForKeyPath:@"@min.floatValue"] floatValue];
    CGFloat max = [[_tempArr valueForKeyPath:@"@max.floatValue"] floatValue];
    
    //    除去0
    if (avg == 0) {
        avg = 1;
    }
    if (max == 0) {
        max = 1;
    }
    if (min == 0) {
        min = 1;
    }
    
    
    //    得到最大有效值
    if (fabs(max - _max) > fabs(_max)/4) {
        _max = max;
    }
    //    得到最小值的平均值
    if (fabs(min - _min) > fabs(min)/4) {
        _min = min;
    }
    
//    求出他们的差值
    avg = (_max - _min);
    
#pragma mark 1mm  大概是  32  16   64
    //    这个比值  以后要确定
    CGFloat k = 0;
    if (fabs(_pointMartin - 0.6) < 0.1 ) {
        k = (CGFloat) (self.height /4)/avg;
    }
    if (fabs(_pointMartin - 1.2) < 0.1 ) {
        k = (CGFloat) (self.height *1/2)/avg;
    }
    if (fabs(_pointMartin - 2.4) < 0.1 ) {
        k = (CGFloat) (self.height *4/5)/avg;
    }
    
    k = (CGFloat)1 / 31;
    
    drawingPoints[0] = _endPoint1;
    float answer = 0;
    
    for (int i = 0 ; i < _pointArray.count ; i++) {
        
        float value = (_max - [self.pointArray[i] floatValue]);
        
        //        NSLog(@"%f",value);
        if (value == 0) {
            value = 1;
        }
//        这个比例 需要修该
        
        answer = value*k;
        
        answer = (CGFloat)(value / _heartAmplitude)*31;
//
        if (_kkk == 0) {
            _kkk = 1;
        }
        if (_bbb == 0) {
            _bbb = 1;
        }
        
        answer = (CGFloat)answer/_kkk;
        answer = (CGFloat)answer/_bbb;

//        NSLog(@"比例K >> %f  平均值 >> %f  Y坐标>>%f  要花点的数量 >> %ld, 最大值 >> %f, 最小值 >> %f",k,avg,answer,(unsigned long)self.pointArray.count,_max,_min);
        
        //        一开始drawingPoints为空的时候
        if (testX < self.width) {
            
            //        每次画图的第一个点 应该是上次画的最后一个点
            drawingPoints[i + 1 ] =   CGPointMake(testX, answer + self.height/5);
            testX = testX + _pointMartin;
            //  NSLog(@">>>>  %f",_pointMartin);
        } else {
            testX = 0;
        }
        
    }
    
    CGRect reck = CGRectMake(drawingPoints[0].x , 0,    30, self.height);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplayInRect:reck];
    });

}



- (NSMutableArray *)pointArray{
    
    if (!_pointArray) {
        _pointArray = [[NSMutableArray alloc]init];
    }
    return _pointArray;
}

// 添加手势
- (void)addTapGestureRecognizer{

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture)];

    [self addGestureRecognizer:tap];
}

- (void)keepDrawing{

    
    CGRect reck = CGRectMake(testX , 0,    30, self.height);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplayInRect:reck];
            });
    testX+=1;
    
    if (testX > self.width) {
        testX = 0;
    }
}
- (void)tapGesture{

}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end

