//
//  OverlayController.h
//  HappyFace
//
//  Created by Andreas Prang on 15.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface OverlayController : NSView {

    CGPoint leftEyePosition, rightEyePosition, MouthPosition;

@private
    
}

-(void)setLeftEye:(CGPoint)leftEye rightEye:(CGPoint)rightEye mouth:(CGPoint)mouth;

@end
