//
//  LiveMonitorVC.m
//  ECG
//
//  Created by Will Yang (yangyu.will@gmail.com) on 4/29/11.
//  Copyright 2013 WMS Studio. All rights reserved.
//


#import <QuartzCore/QuartzCore.h>
#import "LiveMonitorVC.h"
#import "LeadPlayer.h"
#import "Helper.h"

@implementation LiveMonitorVC
@synthesize leads, btnStart,scrollView, labelProfileId, labelProfileName, btnDismiss;
@synthesize liveMode, labelRate, statusInfo, startRecordingIndex, HR, stopTheTimer;
@synthesize buffer, DEMO, labelMsg, photoView, btnRefresh, newBornMode;

int leadCount = 3;
int sampleRate = 500;
float uVpb = 0.9;
float drawingInterval = 0.04; // the interval is greater, the drawing is faster, but more choppy, smaller -> slower and smoother
int bufferSecond = 300;
float pixelPerUV = 5 * 10.0 / 1000;

- (void)viewDidLoad {
    [super viewDidLoad];

	[self addViews];
    [self initialMonitor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self setLeadsLayout:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self startLiveMonitoring];
}

-(BOOL)canBecomeFirstResponder 
{
    return YES;
}


- (void)viewWillDisappear:(BOOL)animated
{	
    [super viewWillDisappear:animated];
}


#pragma mark -
#pragma mark Initialization, Monitoring and Timer events 

- (void)initialMonitor
{
	bufferCount = 10;
	self.labelMsg.text = @"25mm/s  10mm/mv";
    
    self.btnRecord.enabled = NO;
    self.btnDismiss.enabled = NO;
    
    NSMutableArray *buf = [[NSMutableArray alloc] init];
    self.buffer = buf;
}

- (void)startLiveMonitoring
{
	monitoring = YES;
	stopTheTimer = NO;
    
    [self startTimer_popDataFromBuffer];
    [self startTimer_drawing];
}

- (void)startTimer_popDataFromBuffer
{	
	CGFloat popDataInterval = 420.0f / sampleRate;
	
	popDataTimer = [NSTimer scheduledTimerWithTimeInterval:popDataInterval
													target:self
												  selector:@selector(timerEvent_popData)
												  userInfo:NULL
												   repeats:YES];
}

- (void)startTimer_drawing
{	
	drawingTimer = [NSTimer scheduledTimerWithTimeInterval:drawingInterval
													target:self
												  selector:@selector(timerEvent_drawing)
												  userInfo:NULL
                                                    repeats:YES];
}


- (void)timerEvent_drawing
{
    [self drawRealTime];
}

- (void)timerEvent_popData
{
    [self popDemoDataAndPushToLeads];
}

- (void)popDemoDataAndPushToLeads
{
	int length = 440;
	short **data = [Helper getDemoData:length];
	
	NSArray *data12Arrays = [self convertDemoData:data dataLength:length doWilsonConvert:NO];
	
	for (int i=0; i<leadCount; i++)
	{
		NSArray *data = [data12Arrays objectAtIndex:i];
		[self pushPoints:data data12Index:i];
	}
}

- (void)pushPoints:(NSArray *)_pointsArray data12Index:(NSInteger)data12Index;
{
	LeadPlayer *lead = [self.leads objectAtIndex:data12Index];
    
	if (lead.pointsArray.count > bufferSecond * sampleRate)
	{
		[lead resetBuffer];
	}
	
    if (lead.pointsArray.count - lead.currentPoint <= 2000)
    {
        [lead.pointsArray addObjectsFromArray:_pointsArray];
    }

	if (data12Index==0)
	{
		countOfPointsInQueue = lead.pointsArray.count;
		currentDrawingPoint = lead.currentPoint;
	}
}

- (NSArray *)convertDemoData:(short **)rawdata dataLength:(int)length doWilsonConvert:(BOOL)wilsonConvert
{
	NSMutableArray *data = [[NSMutableArray alloc] init];
	for (int i=0; i<12; i++)
	{
		NSMutableArray *array = [[NSMutableArray alloc] init];
		[data addObject:array];
	}
	
	for (int i=0; i<length; i++)
	{
		for (int j=0; j<12; j++)
		{
			NSMutableArray *array = [data objectAtIndex:j];
			NSNumber *number = [NSNumber numberWithInt:rawdata[i][j]];
			[array insertObject:number atIndex:i];
		}
	}
	
	return data;
}

- (void)drawRealTime
{
	LeadPlayer *l = [self.leads objectAtIndex:0];
	
	if (l.pointsArray.count > l.currentPoint)
	{	
		for (LeadPlayer *lead in self.leads)
		{
			[lead fireDrawing];
		}
	}
}

- (void)addViews
{	
	NSMutableArray *array = [[NSMutableArray alloc] init];
	
	for (int i=0; i<leadCount; i++) {
		LeadPlayer *lead = [[LeadPlayer alloc] init];
		
        lead.layer.cornerRadius = 8;
        lead.layer.borderColor = [[UIColor grayColor] CGColor];
        lead.layer.borderWidth = 1;
        lead.clipsToBounds = YES;
        
		lead.index = i;
        lead.pointsArray = [[NSMutableArray alloc] init];
                
        lead.liveMonitor = self;
		      
        [array insertObject:lead atIndex:i];
        
        [self.scrollView addSubview:lead];
	}
	
	self.leads = array;
}

- (void)setLeadsLayout:(UIInterfaceOrientation)orientation
{
    float margin = 5;
	NSInteger leadHeight = self.scrollView.frame.size.height / 3 - margin * 2;
	NSInteger leadWidth = self.scrollView.frame.size.width;
    scrollView.contentSize = self.scrollView.frame.size;
    
    for (int i=0; i<leadCount; i++)
    {
        LeadPlayer *lead = [self.leads objectAtIndex:i];
        float pos_y = i * (margin + leadHeight);
        
        [lead setFrame:CGRectMake(0., pos_y, leadWidth, leadHeight)];
        lead.pos_x_offset = lead.currentPoint;
        lead.alpha = 0;
        [lead setNeedsDisplay];
    }
    
    [UIView animateWithDuration:0.6f animations:^{
        for (int i=0; i<leadCount; i++)
        {
            LeadPlayer *lead = [self.leads objectAtIndex:i];
            lead.alpha = 1;
        }
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{

}


#pragma mark -
#pragma mark Memory and others

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

- (void)dealloc {
	
	



	drawingTimer = nil;
	readDataTimer = nil;
	popDataTimer = nil;
	
}

@end
