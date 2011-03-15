//
//  MyRecorderController.m
//  HappyFace
//
//  Created by Andreas Prang on 14.03.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyRecorderController.h"

@implementation MyRecorderController

- (void)awakeFromNib
{
    
    counter = 0;
    // Create the capture session
    
	mCaptureSession = [[QTCaptureSession alloc] init];
    
    // Connect inputs and outputs to the session	
    
	BOOL success = NO;
	NSError *error;
	
    // Find a video device  
    
    QTCaptureDevice *videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
    success = [videoDevice open:&error];
    
    
    // If a video input device can't be found or opened, try to find and open a muxed input device
    
	if (!success) {
		videoDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeMuxed];
		success = [videoDevice open:&error];
		
    }
    
    if (!success) {
        videoDevice = nil;
        // Handle error
        
    }
    
    if (videoDevice) {
        //Add the video device to the session as a device input
		
		mCaptureVideoDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:videoDevice];
		success = [mCaptureSession addInput:mCaptureVideoDeviceInput error:&error];
		if (!success) {
			// Handle error
		}
        
        // If the video device doesn't also supply audio, add an audio device input to the session
        
        if (![videoDevice hasMediaType:QTMediaTypeSound] && ![videoDevice hasMediaType:QTMediaTypeMuxed]) {
            
            QTCaptureDevice *audioDevice = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeSound];
            success = [audioDevice open:&error];
            
            if (!success) {
                audioDevice = nil;
                // Handle error
            }
            
            if (audioDevice) {
                mCaptureAudioDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:audioDevice];
                
                success = [mCaptureSession addInput:mCaptureAudioDeviceInput error:&error];
                if (!success) {
                    // Handle error
                }
            }
        }
        
        // Create the movie file output and add it to the session
        
/*        mCaptureMovieFileOutput = [[QTCaptureMovieFileOutput alloc] init];
        [mCaptureDecompressedVideoOutput setDelegate:self];
        success = [mCaptureSession addOutput:mCaptureMovieFileOutput error:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }
  */      
        // Add a decompressed video output that returns raw frames to the session
        mCaptureDecompressedVideoOutput = [[QTCaptureDecompressedVideoOutput alloc] init];
        [mCaptureDecompressedVideoOutput setAutomaticallyDropsLateVideoFrames:YES];
        [mCaptureDecompressedVideoOutput setDelegate:self];
        success = [mCaptureSession addOutput:mCaptureDecompressedVideoOutput error:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }

        
        [mCaptureMovieFileOutput setDelegate:self];
        
        
        // Set the compression for the audio/video that is recorded to the hard disk.
        
        NSEnumerator *connectionEnumerator = [[mCaptureMovieFileOutput connections] objectEnumerator];
        QTCaptureConnection *connection;
        
        // iterate over each output connection for the capture session and specify the desired compression
        while ((connection = [connectionEnumerator nextObject])) {
            NSString *mediaType = [connection mediaType];
            QTCompressionOptions *compressionOptions = nil;
            // specify the video compression options
            // (note: a list of other valid compression types can be found in the QTCompressionOptions.h interface file)
            if ([mediaType isEqualToString:QTMediaTypeVideo]) {
                // use H.264
                compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptions240SizeH264Video"];
                // specify the audio compression options
            } else if ([mediaType isEqualToString:QTMediaTypeSound]) {
                // use AAC Audio
                compressionOptions = [QTCompressionOptions compressionOptionsWithIdentifier:@"QTCompressionOptionsHighQualityAACAudio"];
            }
            
            // set the compression options for the movie file output
            [mCaptureMovieFileOutput setCompressionOptions:compressionOptions forConnection:connection];
        } 
        
        // Associate the capture view in the UI with the session
        [mCaptureView setCaptureSession:mCaptureSession];

        [mCaptureSession startRunning];
        
	}
    
    
    timer = [NSTimer scheduledTimerWithTimeInterval:0.04 target:self selector:@selector(captureImage) userInfo:nil repeats:YES];
//              timerWithTimeInterval:1.0 target:self selector:@selector(captureImage) userInfo:nil repeats:YES] retain];
    [timer fire];
}

- (void)captureImage {

    
    // Get the most recent frame
	// This must be done in a @synchronized block because the delegate method that sets the most recent frame is not called on the main thread
    CVImageBufferRef imageBuffer;
    
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
    
    if (imageBuffer) {
        // Create an NSImage and add it to the movie
        NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
        NSImage *image = [[[NSImage alloc] initWithSize:[imageRep size]] autorelease];
        [image addRepresentation:imageRep];
        
        float imageWidth          = [image size].width;
        float imageHeight         = [image size].height;
        
        float overlayWidth        = [overlayController frame].size.width;
        float overlayHeight       = [overlayController frame].size.height;

        float relationalWidth   = overlayWidth/imageWidth;
        float relationalHeight  = overlayHeight/imageHeight;
        
        // FaceDetection
        // self.image is valid NSImage containing a face
//        NSBitmapImageRep *bitmapImageRep = [NSBitmapImageRep ];
        
//        CIImage *ciImage = [[CIImage alloc] initWithBitmapImageRep:bitmapImageRep];
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
        
        CIImage *ciImage = [CIImage imageWithCVImageBuffer:imageBuffer];

        NSArray *features = [detector featuresInImage:ciImage];
        
        if ([features count]) {
            CIFaceFeature *faceFeature = [features objectAtIndex:0];
            

//            NSGraphicsContext context = [NSGraphicsContext ];
            if ([faceFeature hasLeftEyePosition]) {
            
                [overlayController setLeftEye:CGPointMake([faceFeature leftEyePosition].x * relationalWidth, [faceFeature leftEyePosition].y * relationalHeight) 
                                     rightEye:CGPointMake([faceFeature rightEyePosition].x * relationalWidth, [faceFeature rightEyePosition].y * relationalHeight) 
                                        mouth:CGPointMake([faceFeature mouthPosition].x * relationalWidth, [faceFeature mouthPosition].y * relationalHeight)
                 ];
            }
            if ([faceFeature hasRightEyePosition]) {
                
            }
            if ([faceFeature hasMouthPosition]) {
                
            }
            

        
        }
        
        
//        counter++;
        //        NSImage *testImage = [NSImage imageNamed:@"Apple.gif" ];
//        NSArray *representations;
//        NSData *bitmapData;
//        representations = [image representations];
//        NSLog(@"%i", [representations count]);
        
        
        
        CVBufferRelease(imageBuffer);
        [imageView setImage:image];

//        bitmapData = [NSBitmapImageRep representationOfImageRepsInArray:representations usingType:NSPNGFileType properties:nil];
//        [bitmapData writeToFile:[NSString stringWithFormat:@"/%i_.png", counter] atomically:YES];
    }
}


- (void)captureOutput:(QTCaptureOutput *)captureOutput didOutputVideoFrame:(CVImageBufferRef)videoFrame withSampleBuffer:(QTSampleBuffer *)sampleBuffer fromConnection:(QTCaptureConnection *)connection {
    // Store the latest frame
	// This must be done in a @synchronized block because this delegate method is not called on the main thread
    CVImageBufferRef imageBufferToRelease;
    
    CVBufferRetain(videoFrame);
    
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    
    CVBufferRelease(imageBufferToRelease);
    
}

    

// Handle window closing notifications for your device input
- (void)windowWillClose:(NSNotification *)notification
{
	
	[mCaptureSession stopRunning];
    
    if ([[mCaptureVideoDeviceInput device] isOpen])
        [[mCaptureVideoDeviceInput device] close];
    
    if ([[mCaptureAudioDeviceInput device] isOpen])
        [[mCaptureAudioDeviceInput device] close];
    
}

// Handle deallocation of memory for your capture objects
- (void)dealloc
{
	[mCaptureSession release];
	[mCaptureVideoDeviceInput release];
    [mCaptureAudioDeviceInput release];
	[mCaptureMovieFileOutput release];
	
	[super dealloc];
}

#pragma mark-

// Add these start and stop recording actions, and specify the output destination for your recorded media. The output is a QuickTime movie.

- (IBAction)startRecording:(id)sender {

	[mCaptureMovieFileOutput recordToOutputFileURL:[NSURL fileURLWithPath:@"/Users/Shared/My Recorded Movie.mov"]];
}

- (IBAction)stopRecording:(id)sender
{
	[mCaptureMovieFileOutput recordToOutputFileURL:nil];
}

// Do something with your QuickTime movie at the path you've specified at /Users/Shared/My Recorded Movie.mov"

- (void)captureOutput:(QTCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL forConnections:(NSArray *)connections dueToError:(NSError *)error
{
	[[NSWorkspace sharedWorkspace] openURL:outputFileURL];
}


@end

