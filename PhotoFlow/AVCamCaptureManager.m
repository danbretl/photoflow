/*
     File: AVCamCaptureManager.m
 Abstract: Uses the AVCapture classes to capture video and still images.
  Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */

#import "AVCamCaptureManager.h"
#import "AVCamUtilities.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/CGImageProperties.h>
#import "DefaultsManager.h"

@interface AVCamCaptureManager ()
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition)position;
- (AVCaptureDevice *) frontFacingCamera;
- (AVCaptureDevice *) backFacingCamera;
@property (nonatomic) AVCaptureFlashMode flashModePreference; // May not always be respected, depending on the current camera's capabilities.
@end

#pragma mark -
@implementation AVCamCaptureManager

@synthesize session;
@synthesize orientation;
@synthesize videoInput;
@synthesize stillImageOutput;
@synthesize deviceConnectedObserver;
@synthesize deviceDisconnectedObserver;
@synthesize delegate;

- (id) init
{
    self = [super init];
    if (self != nil) {
		__block id weakSelf = self;
        void (^deviceConnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
			BOOL sessionHasDeviceWithMatchingMediaType = NO;
			NSString *deviceMediaType = nil;
			if ([device hasMediaType:AVMediaTypeVideo])
                deviceMediaType = AVMediaTypeVideo;
			
			if (deviceMediaType != nil) {
				for (AVCaptureDeviceInput *input in [session inputs])
				{
					if ([[input device] hasMediaType:deviceMediaType]) {
						sessionHasDeviceWithMatchingMediaType = YES;
						break;
					}
				}
				
				if (!sessionHasDeviceWithMatchingMediaType) {
					NSError	*error;
					AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
					if ([session canAddInput:input])
						[session addInput:input];
				}				
			}
            
			if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[delegate captureManagerDeviceConfigurationChanged:self];
			}			
        };
        void (^deviceDisconnectedBlock)(NSNotification *) = ^(NSNotification *notification) {
			AVCaptureDevice *device = [notification object];
			
            if ([device hasMediaType:AVMediaTypeVideo]) {
				[session removeInput:[weakSelf videoInput]];
				[weakSelf setVideoInput:nil];
			}
			
			if ([delegate respondsToSelector:@selector(captureManagerDeviceConfigurationChanged:)]) {
				[delegate captureManagerDeviceConfigurationChanged:self];
			}			
        };
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [self setDeviceConnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification object:nil queue:nil usingBlock:deviceConnectedBlock]];
        [self setDeviceDisconnectedObserver:[notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification object:nil queue:nil usingBlock:deviceDisconnectedBlock]];
		[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
		[notificationCenter addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
		orientation = AVCaptureVideoOrientationPortrait;
    }
    
    return self;
}

- (void) dealloc
{
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:[self deviceConnectedObserver]];
    [notificationCenter removeObserver:[self deviceDisconnectedObserver]];
	[notificationCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    
    [self.session stopRunning];
    
}

- (BOOL) setupSession
{
    BOOL success = NO;
    
    // Create session (use AVCaptureSessionPresetPhoto)
    AVCaptureSession *newCaptureSession = [[AVCaptureSession alloc] init];
    newCaptureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
	// Init the device inputs
    AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self cameraWithPosition:[DefaultsManager getCameraPositionPreference]] error:nil];
	
    // Setup the still image file output
    AVCaptureStillImageOutput *newStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    newStillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    
    // Add inputs and output to the capture session
    if ([newCaptureSession canAddInput:newVideoInput]) {
        [newCaptureSession addInput:newVideoInput];
    }
    if ([newCaptureSession canAddOutput:newStillImageOutput]) {
        [newCaptureSession addOutput:newStillImageOutput];
    }
    
    // Set properties
    self.stillImageOutput = newStillImageOutput;
    self.videoInput = newVideoInput;
    self.session = newCaptureSession;
    
    // Set flash mode to auto
    [self setFlashMode:[DefaultsManager getCameraFlashPreference]];
    	
    success = YES;
    
    return success;
}

- (void) captureStillImage
{
    AVCaptureConnection *stillImageConnection = [AVCamUtilities connectionWithMediaType:AVMediaTypeVideo fromConnections:[[self stillImageOutput] connections]];
    if ([stillImageConnection isVideoOrientationSupported])
        [stillImageConnection setVideoOrientation:orientation];
    
    [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:stillImageConnection
                                                         completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
															 
															 ALAssetsLibraryWriteImageCompletionBlock completionBlock = ^(NSURL *assetURL, NSError *error) {
																 if (error) {
                                                                     if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                                                                         [[self delegate] captureManager:self didFailWithError:error];
                                                                         }
																 }
															 };
															 
															 if (imageDataSampleBuffer != NULL) {
																 NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
																 ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
																 
                                                                 UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                                 self.imageCaptured = image;
																 [library writeImageToSavedPhotosAlbum:[image CGImage]
																						   orientation:(ALAssetOrientation)[image imageOrientation]
																					   completionBlock:completionBlock];
															 }
															 else
																 completionBlock(nil, error);
															 
															 if ([[self delegate] respondsToSelector:@selector(captureManagerStillImageCaptured:)]) {
																 [[self delegate] captureManagerStillImageCaptured:self];
															 }
                                                         }];
}

// Toggle between the front and back camera, if both are present.
- (BOOL) toggleCamera
{
    BOOL success = NO;
    
    if ([self cameraCount] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = self.videoInput.device.position;
        
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self frontFacingCamera] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self backFacingCamera] error:&error];
        } else {
            return success;
        }

        if (newVideoInput != nil) {
            [self.session beginConfiguration];
            [self.session removeInput:self.videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                self.videoInput = newVideoInput;
            } else {
                [self.session addInput:self.videoInput];
            }
            [self setFlashMode:self.flashModePreference];
            [self.session commitConfiguration];
            success = YES;
            [DefaultsManager setCameraPositionPreference:self.videoInput.device.position];
        } else if (error) {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
    }
    
    return success;
}

- (BOOL)setFlashMode:(AVCaptureFlashMode)flashMode {
    self.flashModePreference = flashMode;
    [self.session beginConfiguration];
//    NSLog(@"setFlashMode:%d", self.flashModePreference);
    AVCaptureDevice * device = self.videoInput.device;
//    NSLog(@"self.videoInput.device = %@", self.videoInput.device);
    BOOL success = NO;
//    NSLog(@"device.hasFlash = %d", device.hasFlash);
    if (device.hasFlash) {
        if ([device lockForConfiguration:nil]) {
//            NSLog(@"device lockForConfiguration...");
//            NSLog(@"device isFlashMode(%d)Supported:%d", self.flashModePreference, [device isFlashModeSupported:self.flashModePreference]);
            if ([device isFlashModeSupported:self.flashModePreference]) {
                device.flashMode = self.flashModePreference;
            }
            [device unlockForConfiguration];
            success = YES;
            [DefaultsManager setCameraFlashPreference:flashMode];
        }
    }
    [self.session commitConfiguration];
//    NSLog(@"setFlashMode success? %d", success);
    return success;
}


#pragma mark Device Counts
- (NSUInteger) cameraCount
{
    return [[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count];
}

#pragma mark Camera Properties
// Perform an auto focus at the specified point. The focus mode will automatically change to locked once the auto focus is complete.
- (void) autoFocusAtPoint:(CGPoint)point withExposure:(BOOL)shouldAdjustExposure
{
    AVCaptureDevice *device = self.videoInput.device;
    if (device.isFocusPointOfInterestSupported &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        [self.session beginConfiguration];
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
//            NSLog(@"\nshouldAdjustExposure=%d\ndevice.isExposurePointOfInterestSupported=%d", shouldAdjustExposure, device.isExposurePointOfInterestSupported);
            if (shouldAdjustExposure && device.isExposurePointOfInterestSupported) {
                device.exposurePointOfInterest = point;
                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
            [device unlockForConfiguration];
        } else {
            if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
            }
        }
        [self.session commitConfiguration];
    }
}

// Switch to continuous auto focus mode at the specified point
- (void) continuousFocusAtPoint:(CGPoint)point withExposure:(BOOL)shouldAdjustExposure
{
    AVCaptureDevice *device = self.videoInput.device;
    if (device.isFocusPointOfInterestSupported &&
        [device isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
		NSError *error;
        [self.session beginConfiguration];
		if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
//            NSLog(@"\nshouldAdjustExposure=%d\ndevice.isExposurePointOfInterestSupported=%d\n[device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]=%d", shouldAdjustExposure, device.isExposurePointOfInterestSupported, [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]);
            if (shouldAdjustExposure && device.isExposurePointOfInterestSupported && [device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                device.exposurePointOfInterest = point;
                device.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
            }
			[device unlockForConfiguration];
		} else {
			if ([[self delegate] respondsToSelector:@selector(captureManager:didFailWithError:)]) {
                [[self delegate] captureManager:self didFailWithError:error];
			}
		}
        [self.session commitConfiguration];
	}
}

// Keep track of current device orientation so it can be applied to movie recordings and still image captures
- (void)deviceOrientationDidChange
{	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
    
	if (deviceOrientation == UIDeviceOrientationPortrait)
		orientation = AVCaptureVideoOrientationPortrait;
	else if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
		orientation = AVCaptureVideoOrientationPortraitUpsideDown;
	
	// AVCapture and UIDevice have opposite meanings for landscape left and right (AVCapture orientation is the same as UIInterfaceOrientation)
	else if (deviceOrientation == UIDeviceOrientationLandscapeLeft)
		orientation = AVCaptureVideoOrientationLandscapeRight;
	else if (deviceOrientation == UIDeviceOrientationLandscapeRight)
		orientation = AVCaptureVideoOrientationLandscapeLeft;
	
	// Ignore device orientations for which there is no corresponding still image orientation (e.g. UIDeviceOrientationFaceUp)
}

// Find a camera with the specificed AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices) {
        if ([device position] == position) {
            return device;
        }
    }
    return nil;
}

// Find a front facing camera, returning nil if one is not found
- (AVCaptureDevice *) frontFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionFront];
}

// Find a back facing camera, returning nil if one is not found
- (AVCaptureDevice *) backFacingCamera
{
    return [self cameraWithPosition:AVCaptureDevicePositionBack];
}

@end
