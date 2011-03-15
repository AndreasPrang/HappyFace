//
//  OverlayController.m
//  HappyFace
//
//  Created by Andreas Prang on 15.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OverlayController.h"


@implementation OverlayController

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        leftEyePosition = CGPointMake(20, 20);
        rightEyePosition = CGPointMake(60, 20);
        MouthPosition = CGPointMake(40, 50);
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect
{
    NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint: leftEyePosition];
	[line lineToPoint: rightEyePosition];
    [line lineToPoint: MouthPosition];
    [line lineToPoint: leftEyePosition];
	
	[[NSColor redColor] set];
    [line stroke];

    
    
    // Auge
    NSRect rect = NSMakeRect(10, 10, 10, 10);
    NSBezierPath* circlePath = [NSBezierPath bezierPath];
    [circlePath appendBezierPathWithOvalInRect: rect];
}


-(void)setLeftEye:(CGPoint)leftEye rightEye:(CGPoint)rightEye mouth:(CGPoint)mouth {

    leftEyePosition = leftEye;
    rightEyePosition = rightEye;
    MouthPosition = mouth;
    
    /*
     leftEyePosition = CGPointMake(leftEye.x - 50, leftEye.y - 50);
     rightEyePosition = CGPointMake(rightEye.x - 50, rightEye.y - 50);
     MouthPosition = CGPointMake(mouth.x - 50, mouth.y - 50);
 
    */
    [self setNeedsDisplay:YES];
}

@end
