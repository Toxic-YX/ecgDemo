//
//  HeartBeatDrawing.m
//  ECG
//
//  Created by Will Yang (yangyu.will@gmail.com) on 5/7/11.
//  Copyright 2013 WMS Studio. All rights reserved.
//

#import "LeadPlayer.h"
#import "LiveMonitorVC.h"

@implementation LeadPlayer
@synthesize pointsArray, index, label, liveMonitor, lightSpot, currentPoint, pos_x_offset, viewCenter;

int pixelsPerCell = 30.00; // 0.2 second per cell   0.2秒绘制出来一个大格子, 0.04秒绘制出来一个小格子

float lineWidth_Grid = 0.5;  //
float lineWidth_LiveMonitor = 1.3;
float lineWidth_Static = 1;

int pointsPerSecond = 500;  //  每秒取出 500 个点
float pixelPerPoint = 2 * 60.0f / 500.0f;  // 60秒 绘制 500 个点, 每个点绘制的像素
int pointPerDraw = 500.0f * 0.04f;  //  500个点  绘制出来  需要时长

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor whiteColor];
		self.clearsContextBeforeDrawing = YES;
		
		[self addGestureRecgonizer];
	}
    return self;
}

- (void)drawRect:(CGRect)rect
{	
	context = UIGraphicsGetCurrentContext();
    
    // 绘制心电图 背景网格
    [self drawGrid:context];
    // 绘制心电图类型
    [self drawCurve:context];
}

- (void)drawGrid:(CGContextRef)ctx {
	CGFloat full_height = self.frame.size.height;
	CGFloat full_width = self.frame.size.width;
	CGFloat cell_square_width = pixelsPerCell;
	CGContextSetStrokeColorWithColor(ctx, [UIColor redColor].CGColor);
	
    // x 轴 大网格
	int pos_x = 1;
	while (pos_x < full_width) {
        CGContextSetLineWidth(ctx, 0.2);
		CGContextMoveToPoint(ctx, pos_x, 1);
		CGContextAddLineToPoint(ctx, pos_x, full_height);
		pos_x += cell_square_width;
		
		CGContextStrokePath(ctx);
	}
	// y 轴 大网格
	CGFloat pos_y = 1;
	while (pos_y <= full_height) {
		
		CGContextSetLineWidth(ctx, 0.2);
		CGContextMoveToPoint(ctx, 1, pos_y);
		CGContextAddLineToPoint(ctx, full_width, pos_y);
		pos_y += cell_square_width;
		
		CGContextStrokePath(ctx);
	}
	
    // x轴 小的网格
	cell_square_width = cell_square_width / 5;
	pos_x = 1 + cell_square_width;
	while (pos_x < full_width) {
        CGContextSetLineWidth(ctx, 0.1);
		CGContextMoveToPoint(ctx, pos_x, 1);
		CGContextAddLineToPoint(ctx, pos_x, full_height);
		pos_x += cell_square_width;
		
		CGContextStrokePath(ctx);
	}
	
    // y轴 小的网格
	pos_y = 1 + cell_square_width;
	while (pos_y <= full_height) {
         CGContextSetLineWidth(ctx, 0.1);
		CGContextMoveToPoint(ctx, 1, pos_y);
		CGContextAddLineToPoint(ctx, full_width, pos_y);
		pos_y += cell_square_width;
		
		CGContextStrokePath(ctx);
	}
}

- (void)drawLabel:(CGContextRef)ctx {
	CGContextSetRGBFillColor(ctx, 1.0, 1.0, 1.0, 1.0);
	CGContextSelectFont(ctx, "Helvetica", 12, kCGEncodingMacRoman);

	CGAffineTransform xform = CGAffineTransformMake(1.0, 0.0, 0.0, -1.0, 0.0, 0.0);
    CGContextSetTextMatrix(ctx, xform);
    CGContextShowTextAtPoint(ctx, 8, 18, [self.label UTF8String], strlen([self.label UTF8String]));
}

- (void)clearDrawing {
	CGFloat full_height = self.frame.size.height;
	CGFloat full_width = self.frame.size.width;
	
	CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
	CGContextFillRect(context, CGRectMake(0, 0, full_width, full_height));
	[self setNeedsDisplay];
}


- (void)drawCurve:(CGContextRef)ctx
{	
	if (count == 0) return;
	
	CGContextSetLineWidth(ctx, lineWidth_LiveMonitor);
	CGContextSetStrokeColorWithColor(ctx, [UIColor greenColor].CGColor);
	
	CGContextAddLines(ctx, drawingPoints, count);
	CGContextStrokePath(ctx);

	endPoint = drawingPoints[count-1]; 
	endPoint2 = drawingPoints[count-2];
	endPoint3 = drawingPoints[count-3];
	
}

- (void)fireDrawing
{
    float uVpb = 0.9;  //  0.9 代表是 小格子中 空白处 宽度  ;  每一个小格子的 宽度 0.9 + 0.1 = 1 mm  ; 每个大格子宽度 5 * 1 = 5 mm
    float pixelPerUV = 5 * 10.0 / 1000;  // 一个大格子 的 像素
    
	int pointCount = pointPerDraw;
	CGFloat pointPixel = pixelPerPoint;
	CGFloat full_height = self.frame.size.height;
	
	count = 0;
	for (int i=0; i<pointCount; i++)
    {
		if ([self pointAvailable:currentPoint])
		{
			CGFloat pos_x = [self getPosX:currentPoint];
			if (i > 0 && pos_x == 0) break;
			
			if (i == 0 && pos_x != 0)
			{
				drawingPoints[0] = endPoint3;
				drawingPoints[1] = endPoint2;
				drawingPoints[2] = endPoint;
				i+=3; pointCount+=3; count+=3;
			}
			
			CGFloat value = full_height/2 - [[self.pointsArray objectAtIndex:currentPoint] intValue] * uVpb * pixelPerUV;
			drawingPoints[i] = CGPointMake(pos_x, value); 
						
			currentPoint++;	
			count++;
		}
		else {
			break;
		}
	}
	
	if (count > 0)
	{
		CGRect rect = CGRectMake(drawingPoints[1].x, 0, count*pointPixel+20, full_height);
		[self setNeedsDisplayInRect:rect];
	}
}

- (void)resetBuffer
{
	CGFloat full_width = self.frame.size.width;
	CGFloat pixelsPerPoint = pixelPerPoint;
	int cyclePoints = ceil(full_width / pixelsPerPoint);
	int temp = currentPoint % cyclePoints;
	int countToRemove = currentPoint - temp;
	
	currentPoint = temp;
	
	if (self.pointsArray.count > countToRemove)
	{
		[pointsArray removeObjectsInRange:NSMakeRange(0, countToRemove)];
	}
	

	//currentPoint = 0;
//	[pointsArray removeAllObjects];	
//	[self setNeedsDisplay];
}

- (CGFloat)getPosX:(int)point
{
	CGFloat full_width = self.frame.size.width;
	
	int cyclePoints = ceil(full_width / pixelPerPoint);
	int aPoint = (point - pos_x_offset) % cyclePoints;
	
	return aPoint * pixelPerPoint;
}

- (BOOL)pointAvailable:(NSInteger)pointIndex
{
	int pCount = self.pointsArray.count;
	return ((pCount > pointIndex) && ([self.pointsArray objectAtIndex:pointIndex] != NULL));
}

- (void)redraw
{
	[self setNeedsDisplay];
}

#pragma mark -
#pragma mark GestureRecognizer


- (void)singleTapGestureRecognizer:(UIGestureRecognizer *)sender
{
}

- (void)doubleTapGestureRecognizer:(UIGestureRecognizer *)sender
{
}

- (void)longPressGestureRecognizerStateChanged:(UIGestureRecognizer *)sender
{
}

- (void)addGestureRecgonizer
{

}

- (void)dealloc {

//	NSLog(@"Lead dealloced");
	
	self.liveMonitor = nil;
	
}

@end
