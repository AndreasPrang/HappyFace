//
//  MyRecorderController.h
//  HappyFace
//
//  Created by Andreas Prang on 14.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTkit.h>
#import <QuartzCore/QuartzCore.h>
#import "OverlayController.h"

@interface MyRecorderController : NSObject {
    
    IBOutlet QTCaptureView      *mCaptureView;
    IBOutlet NSImageView        *imageView;
    IBOutlet OverlayController  *overlayController;
    
    QTCaptureSession            *mCaptureSession;
    QTCaptureMovieFileOutput    *mCaptureMovieFileOutput;
    QTCaptureDeviceInput        *mCaptureVideoDeviceInput;
    QTCaptureDeviceInput        *mCaptureAudioDeviceInput;
    QTCaptureDecompressedVideoOutput       *mCaptureDecompressedVideoOutput;
    
    CVImageBufferRef            mCurrentImageBuffer;
    
    NSTimer *timer;
    int counter;
}

- (void)captureImage;

- (IBAction)startRecording:(id)sender;
- (IBAction)stopRecording:(id)sender;

@end
