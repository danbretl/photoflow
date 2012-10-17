//
//  PFCameraViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/9/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFCameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <QuartzCore/QuartzCore.h>
#import "DefaultsManager.h"
#import <CoreMotion/CoreMotion.h>
#import <MediaPlayer/MediaPlayer.h>
#import "UIImage+Resize.h"
#import "UIAlertView+PhotoFlow.h"

@interface PFCameraViewController ()
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates;
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer;
- (void)setFlashOptionsExpanded:(BOOL)expanded focusedOnOptionForButton:(UIButton *)flashButtonFocus animated:(BOOL)animated;
@property (nonatomic, readonly) BOOL flashOptionsExpanded;
@property (nonatomic, strong) UIButton * flashButtonSelected; // Bad bad bad
- (void) showLibraryPicker;
- (void) deviceOrientationDidChange;
@property (nonatomic, strong) NSArray * buttonsToRotate;
- (void) rotateButtonsForOrientation:(UIDeviceOrientation)deviceOrientation animated:(BOOL)animated;
- (void) showFocusBoxCenteredAtPoint:(CGPoint)point fadeAway:(BOOL)shouldFadeAway;
- (void) hideFocusBox;
@property (nonatomic, strong) NSTimer * focusBoxTimer;
- (void) focusBoxTimerFired:(NSTimer *)timer;
@property (nonatomic, strong) CMMotionManager * focusMotionManager;
- (void) resetContinuousAutoFocus;
- (void) takePicture;
- (void) setViewsForNetworkActivity:(BOOL)isNetworkActive;
- (void) submitPhotoStart;
- (void) submitPhotoUploadImage;
- (void) submitPhotoSavePhoto;
- (void) submitPhotoFinish;
- (void) submitPhotoStopWithFailure:(BOOL)didFail;
@property (nonatomic) BOOL photoSubmissionInProgress;
@property (nonatomic) UIImage * imageOriginal;
@property (nonatomic) UIImage * imageEdited;
@end

@implementation PFCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib {
    self.psm = [[PFPhotoSubmissionManager alloc] init];
    self.psm.delegate = self;
}

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    self.bottomBarBackgroundImageView.image = [[UIImage imageNamed:@"toolbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0, 0, 0)];
    self.bottomBarShadowView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"toolbar_shadow.png"]];
    self.bottomBarShadowView.alpha = 0.5;
    self.bottomBarHeightConstraint.constant = [UIScreen mainScreen].bounds.size.height >= 568.0 ? 96.0 : 53.0;
    
    // Allowing for unclipped unstretched rotation of button images on orientation changes
    self.buttonsToRotate = @[self.photoButton, self.cancelButton, self.libraryButton, self.saveButton, self.flashButtonAuto, self.flashButtonOn, self.flashButtonOff, self.swapCamerasButton];
    for (UIButton * button in self.buttonsToRotate) {
        button.imageView.contentMode = UIViewContentModeCenter;
        button.imageView.clipsToBounds = NO;
    }
    
    UIImage * photoButtonBackgroundImage = [[UIImage imageNamed:@"btn_camera_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.0, 0, 1.0)];
    [self.photoButton setBackgroundImage:photoButtonBackgroundImage forState:UIControlStateNormal];
    [self.photoButton setBackgroundImage:photoButtonBackgroundImage forState:UIControlStateHighlighted];
    
    self.cancelButton.backgroundColor  = [UIColor clearColor];
    self.photoButton.backgroundColor   = [UIColor clearColor];
    self.libraryButton.backgroundColor = [UIColor clearColor];
    self.saveButton.backgroundColor    = [UIColor clearColor];
    
    self.saveButton.hidden   = YES;
    self.imageOverlay.hidden = YES;
    
    self.focusBox.alpha = 0.0;

    // Set up for volume shutter functionality
    AVAudioPlayer* p = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"photoshutter.wav"]] error:NULL];
    [p prepareToPlay];
    [p stop];
    // Hide normal volume indicator
    CGRect frame = CGRectMake(-1000, -1000, 100, 100);
    MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:frame];
    [volumeView sizeToFit];
    volumeView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:volumeView];
    
    //  Init the capture session
    if (self.captureManager == nil) {
        
        self.captureManager = [[AVCamCaptureManager alloc] init];
        self.captureManager.delegate = self;
        
        if ([self.captureManager setupSession]) {
            
            self.capturePreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureManager.session];
            [self.capturePreviewView layoutIfNeeded];
            self.capturePreviewLayer.frame = self.capturePreviewView.bounds;
            self.capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            [self.capturePreviewView.layer insertSublayer:self.capturePreviewLayer below:[self.capturePreviewView.layer.sublayers objectAtIndex:0]];
            self.capturePreviewView.layer.masksToBounds = YES;
            
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self.captureManager.session startRunning];
			});
            
        }
        
    }
    
    [self.tapFocusSingle requireGestureRecognizerToFail:self.tapFocusDouble];

    switch ([DefaultsManager getCameraFlashPreference]) {
        case AVCaptureFlashModeAuto: self.flashButtonSelected = self.flashButtonAuto; break;
        case AVCaptureFlashModeOn:   self.flashButtonSelected = self.flashButtonOn;   break;
        case AVCaptureFlashModeOff:  self.flashButtonSelected = self.flashButtonOff;  break;
        default: break;
    }
    [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:NO];
    self.swapCamerasButton.hidden = self.captureManager.cameraCount <= 1;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self rotateButtonsForOrientation:[UIDevice currentDevice].orientation animated:NO];
    // Below is (somewhat blindly - based on a hunch) fixing two bugs that were occurring if you entered this view controller while the device was in landscape orientation.
    [self.capturePreviewView layoutIfNeeded];
    self.capturePreviewLayer.frame = self.capturePreviewView.bounds;
    [self.captureManager deviceOrientationDidChange];
    // Above is (somewhat blindly - based on a hunch) fixing two bugs that were occurring if you entered this view controller while the device was in landscape orientation.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.captureManager.cameraCount == 0 &&
        self.imageOriginal == nil) {
        [self showLibraryPicker];
        self.photoButton.enabled = NO;
        self.capturePreviewView.userInteractionEnabled = NO;
    } else {
        [self resetContinuousAutoFocus];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.focusMotionManager stopDeviceMotionUpdates];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)setMoc:(NSManagedObjectContext *)moc {
    _moc = moc;
    self.psm.moc = self.moc;
}

- (void)cameraFlowButtonTouched:(UIButton *)sender {
//    NSLog(@"cameraFlowButtonTouched");
    
    if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
    
    if (sender == self.libraryButton) {
        [self showLibraryPicker];
    } else if (sender == self.saveButton) {
        self.photoEditAlertView = [[UIAlertView alloc] initWithTitle:@"Edit Image?" message:@"Would you like to crop, filter, or enhance your image?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Edit", nil];
        [self.photoEditAlertView show];
//        [self submitPhotoStart];
    } else if (sender == self.cancelButton) {
        if (self.inReview) {
            self.imageOriginal = nil;
            self.imageEdited = nil;
            [self hideImageReview];
            [self resetContinuousAutoFocus];
            [self.psm cancelFileSaves];
            [self.psm resetStatusForAll];
        } else {
            [self.delegate cameraViewController:self finishedWithPhotoSubmitted:nil];
        }
    }
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView == self.photoEditAlertView) {
        if (buttonIndex != alertView.cancelButtonIndex) {
            self.photoEditorController = [[AFPhotoEditorController alloc] initWithImage:self.imageOriginal options:@{kAFPhotoEditorControllerToolsKey : @[kAFEnhance, kAFEffects, kAFCrop, kAFOrientation, kAFSaturation, kAFBrightness, kAFContrast, kAFSharpness, kAFBlemish, kAFWhiten]}];
            self.photoEditorController.delegate = self;
            self.photoEditorSession = self.photoEditorController.session;
            [self presentViewController:self.photoEditorController animated:NO completion:NULL];
        } else {
            [self submitPhotoStart];
        }
    }
}

- (void)photoEditor:(AFPhotoEditorController *)editor finishedWithImage:(UIImage *)image {
    [self.psm cancelFileSaves];
    [self.psm resetStatusForAll];
    [self setViewsForNetworkActivity:YES];
    [self dismissViewControllerAnimated:NO completion:^{
        AFPhotoEditorContext * context = [self.photoEditorSession createContext];
        [context renderInputImage:self.imageOriginal completion:^(UIImage *result) {
            // `result` will be nil if the session is canceled, or non-nil if the session was closed successfully and rendering completed
            self.imageEdited = result;
            [self showImageReview];
            [self submitPhotoStart];
            self.photoEditorSession = nil;
        }];
    }];
}

- (void)photoEditorCanceled:(AFPhotoEditorController *)editor {
    [self dismissViewControllerAnimated:NO completion:NULL];
}

- (void)cameraControlButtonTouched:(UIButton *)sender {
//    NSLog(@"cameraControlButtonTouched");
    
    if (sender == self.photoButton) {
        
        [self takePicture];
        
    } else if (sender == self.flashButtonAuto ||
               sender == self.flashButtonOn ||
               sender == self.flashButtonOff) {
        
        [self setFlashOptionsExpanded:!self.flashOptionsExpanded focusedOnOptionForButton:sender animated:YES];
        
    } else if (sender == self.swapCamerasButton) {
        
        if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
        
        [self.captureManager toggleCamera];
        [self.captureManager continuousFocusAtPoint:CGPointMake(0.5f, 0.5f) withExposure:YES];
        
    }
    
}

- (void) takePicture {
    
    if (!(self.captureManager.stillImageOutput.isCapturingStillImage || self.photoButton.hidden || self.photoButton.alpha == 0.0 || (self.imageOriginal != nil && (!self.imageOverlay.hidden && self.imageOverlay.alpha != 0.0)))) {
        
        if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
        
        [self.captureManager captureStillImage];
        
        // Flash the screen white and fade it out to give UI feedback that a still image was taken
        UIView * flashView = [[UIView alloc] initWithFrame:self.view.frame];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [self.view.window addSubview:flashView];
        [UIView animateWithDuration:.4 animations:^{ [flashView setAlpha:0.f]; } completion:^(BOOL finished){ [flashView removeFromSuperview]; }];
        
        [self.focusMotionManager stopDeviceMotionUpdates];
        
    }
    
}

- (void)volumeChanged:(NSNotification *)notification {
    [self takePicture];
}

- (void)setFlashOptionsExpanded:(BOOL)expanded focusedOnOptionForButton:(UIButton *)flashButtonFocus animated:(BOOL)animated {
//    NSLog(@"setFlashOptionsExpanded:%d focusedOnOptionForButton:%@ animated:%d", expanded, flashButtonFocus, animated);
    
    CGFloat flashButtonSpacing = -self.flashButtonAuto.frame.size.width;
    CGFloat flashButtonsAlpha = 0.0;
    if (expanded) {
        flashButtonSpacing = 0.0;
        flashButtonsAlpha = 1.0;
    }
    void(^updateFlashButtonAlpha)(UIButton *, CGFloat) = ^(UIButton * flashButton, CGFloat alphaDefault){
        flashButton.alpha = flashButtonFocus == flashButton ? 1.0 : alphaDefault;
//        NSLog(@"updateFlashButtonAlpha:%f", flashButton.alpha);
    };
    [self.capturePreviewView layoutIfNeeded];
    [UIView animateWithDuration:animated ? 0.25 : 0.0 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        updateFlashButtonAlpha(self.flashButtonAuto, flashButtonsAlpha);
        updateFlashButtonAlpha(self.flashButtonOn  , flashButtonsAlpha);
        updateFlashButtonAlpha(self.flashButtonOff , flashButtonsAlpha);
        self.flashButtonSpaceLeftCenter.constant  = flashButtonSpacing;
        self.flashButtonSpaceCenterRight.constant = flashButtonSpacing;
        [self.capturePreviewView layoutIfNeeded];
//        NSLog(@"%@ %@ %@", NSStringFromCGRect(self.flashButtonAuto.frame), NSStringFromCGRect(self.flashButtonOn.frame), NSStringFromCGRect(self.flashButtonOff.frame));
    } completion:^(BOOL finished) {
        if (!expanded) {
            self.flashButtonSelected = flashButtonFocus;
            AVCaptureFlashMode flashMode = AVCaptureFlashModeAuto;
            if (self.flashButtonSelected == self.flashButtonOn) {
                flashMode = AVCaptureFlashModeOn;
            } else if (self.flashButtonSelected == self.flashButtonOff) {
                flashMode = AVCaptureFlashModeOff;
            }
            [self.captureManager setFlashMode:flashMode];
        }
    }];
    
}

- (BOOL)flashOptionsExpanded {
    return self.flashButtonAuto.alpha > 0 && self.flashButtonOn.alpha > 0 && self.flashButtonOff.alpha > 0;
}

- (void)showLibraryPicker {
    if (self.imagePickerLibrary == nil) {
        self.imagePickerLibrary = [[UIImagePickerController alloc] init];
        self.imagePickerLibrary.delegate = self;
        self.imagePickerLibrary.mediaTypes = @[(NSString *)kUTTypeImage];
        self.imagePickerLibrary.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        self.imagePickerLibrary.allowsEditing = NO;
        [self.imagePickerLibrary.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
        [self.imagePickerLibrary.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsLandscapePhone];
    }
    [self presentViewController:self.imagePickerLibrary animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.imageOriginal = info[UIImagePickerControllerOriginalImage];
    self.imageEdited = self.imageOriginal;
    [self showImageReview];
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self.psm uploadImage:[self.imageEdited resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1600.0, 1600.0) interpolationQuality:kCGInterpolationHigh]];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.captureManager.cameraCount == 0) {
        [self.delegate cameraViewController:self finishedWithPhotoSubmitted:nil];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager {
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        self.imageOriginal = captureManager.imageCaptured;
        self.imageEdited = self.imageOriginal;
        [self showImageReview];
        [self.psm uploadImage:[self.imageEdited resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1600.0, 1600.0) interpolationQuality:kCGInterpolationHigh]];
    });
}

- (void)showImageReview {
    self.imageOverlay.image = self.imageEdited;
//    self.imageOverlay.image = [image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1500.0, 1500.0) interpolationQuality:kCGInterpolationHigh]; // This will only scale down, and should force normal orientation for all images (for ease of display on non-native-apple platforms, such as the web).
//    NSLog(@"showImageReview:(imageWithSize=%@)", NSStringFromCGSize(self.imageOverlay.image.size));
    self.imageOverlay.hidden = NO;
    self.imageOverlay.userInteractionEnabled = YES;
    self.photoButton.hidden = YES;
    self.libraryButton.hidden = YES;
    self.saveButton.hidden = NO;
}

- (void)hideImageReview {
    self.imageOverlay.hidden = YES;
    self.imageOverlay.image = nil;
    self.imageOverlay.userInteractionEnabled = NO;
    self.photoButton.hidden = NO;
    self.libraryButton.hidden = NO;
    self.saveButton.hidden = YES;
}

- (BOOL)inReview {
    return !self.imageOverlay.hidden;
}

- (IBAction)tappedToFocus:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
    if (tapGestureRecognizer == self.tapFocusSingle) {
        [self tapToAutoFocus:self.tapFocusSingle];
    } else if (tapGestureRecognizer == self.tapFocusDouble) {
        [self tapToContinouslyAutoFocus:self.tapFocusDouble];
    }
}

// Convert from view coordinates to camera coordinates, where {0,0} represents the top left of the picture area, and {1,1} represents
// the bottom right in landscape mode with the home button on the right.
- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates
{
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = self.capturePreviewView.frame.size;
    
    if (self.capturePreviewLayer.connection.videoMirrored) {
        viewCoordinates.x = frameSize.width - viewCoordinates.x;
    }
    
    if ( [self.capturePreviewLayer.videoGravity isEqualToString:AVLayerVideoGravityResize] ) {
		// Scale, switch x and y, and reverse x
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        for (AVCaptureInputPort *port in [[[self captureManager] videoInput] ports]) {
            if ([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if ( [self.capturePreviewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspect] ) {
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
						// If point is inside letterboxed area, do coordinate conversion; otherwise, don't change the default value returned (.5,.5)
                        if (point.x >= blackBar && point.x <= blackBar + x2) {
							// Scale (accounting for the letterboxing on the left and right of the video preview), switch x and y, and reverse x
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
						// If point is inside letterboxed area, do coordinate conversion. Otherwise, don't change the default value returned (.5,.5)
                        if (point.y >= blackBar && point.y <= blackBar + y2) {
							// Scale (accounting for the letterboxing on the top and bottom of the video preview), switch x and y, and reverse x
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if ([self.capturePreviewLayer.videoGravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
					// Scale, switch x and y, and reverse x
                    if (viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2; // Account for cropped height
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2); // Account for cropped width
                        xc = point.y / frameSize.height;
                    }
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

// Auto focus at a particular point. The focus mode will change to locked once the auto focus happens.
- (void)tapToAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.captureManager.videoInput.device.isFocusPointOfInterestSupported) {
        CGPoint tapPoint = [gestureRecognizer locationInView:self.capturePreviewView];
        CGPoint convertedFocusPoint = [self convertToPointOfInterestFromViewCoordinates:tapPoint];
        [self.captureManager autoFocusAtPoint:convertedFocusPoint withExposure:YES];
        [self showFocusBoxCenteredAtPoint:tapPoint fadeAway:NO];
        [self.focusMotionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                double accelerationThreshold = 0.03;
                double rotationThreshold     = 0.15;
                double ax = fabs(motion.userAcceleration.x);
                double ay = fabs(motion.userAcceleration.y);
                double az = fabs(motion.userAcceleration.z);
                double rx = fabs(motion.rotationRate.x);
                double ry = fabs(motion.rotationRate.y);
                double rz = fabs(motion.rotationRate.z);
//                NSLog(@"\nax %f %@\nay %f %@\naz %f %@", ax, ax > accelerationThreshold ? @"OVER" : @"", ay, ay > accelerationThreshold ? @"OVER" : @"", az, az > accelerationThreshold ? @"OVER" : @"");
//                NSLog(@"\nrx %f %@\nry %f %@\nrz %f %@", rx, rx > rotationThreshold ? @"OVER" : @"", ry, ry > rotationThreshold ? @"OVER" : @"", rz, rz > rotationThreshold ? @"OVER" : @"");
                if (ax > accelerationThreshold ||
                    ay > accelerationThreshold ||
                    az > accelerationThreshold ||
                    rx > rotationThreshold     ||
                    ry > rotationThreshold     ||
                    rz > rotationThreshold       ) {
                    [self resetContinuousAutoFocus];
                    [self.focusMotionManager stopDeviceMotionUpdates];
                }
            });
        }];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    [self resetContinuousAutoFocus];
}

- (void) resetContinuousAutoFocus {
    if (self.captureManager.videoInput.device.isFocusPointOfInterestSupported) {
        [self.captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f) withExposure:YES];
        [self showFocusBoxCenteredAtPoint:self.capturePreviewView.center fadeAway:YES];
    }
}

- (CMMotionManager *)focusMotionManager {
    if (_focusMotionManager == nil) {
        _focusMotionManager = [[CMMotionManager alloc] init];
        _focusMotionManager.deviceMotionUpdateInterval = 0.1; // 10 Hz
    }
    return _focusMotionManager;
}

- (void) showFocusBoxCenteredAtPoint:(CGPoint)point fadeAway:(BOOL)shouldFadeAway {
//    NSLog(@"showFocusBoxCenteredAtPoint:%@", NSStringFromCGPoint(point));
    [self.focusBoxTimer invalidate];
    self.focusBoxTimer = nil;
    self.focusBox.alpha = 0.0;
    self.focusBoxX.constant = point.x - self.focusBox.bounds.size.width  / 2.0; // THE BOX DOES NOT SEEM TO BE GOING TO RIGHT POINT EXACTLY
    self.focusBoxY.constant = point.y - self.focusBox.bounds.size.height / 2.0; // THE BOX DOES NOT SEEM TO BE GOING TO RIGHT POINT EXACTLY
    [self.focusBox layoutIfNeeded];
    self.focusBox.transform = CGAffineTransformMakeScale(1.75, 1.75);
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.focusBox.alpha = 1.0;
        self.focusBox.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (shouldFadeAway) {
            self.focusBoxTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(focusBoxTimerFired:) userInfo:nil repeats:NO];
        }
    }];
}

- (void)focusBoxTimerFired:(NSTimer *)timer {
    [self hideFocusBox];
    [self.focusBoxTimer invalidate];
    self.focusBoxTimer = nil;
}

- (void) hideFocusBox {
    [UIView animateWithDuration:0.15 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.focusBox.alpha = 0.0;
    } completion:^(BOOL finished) {
        
        // ...
        // ...
        // ...
    }];
}

- (void)deviceOrientationDidChange {
//    NSLog(@"deviceOrientationDidChange");
    [self rotateButtonsForOrientation:[UIDevice currentDevice].orientation animated:YES];
}

- (void) rotateButtonsForOrientation:(UIDeviceOrientation)deviceOrientation animated:(BOOL)animated {
    [UIView animateWithDuration:animated ? 0.25 : 0.0 animations:^{
        for (UIButton * button in self.buttonsToRotate) {
            CGAffineTransform transform = CGAffineTransformIdentity;
            if (deviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
                transform = CGAffineTransformMakeRotation(M_PI);
            } else if (UIDeviceOrientationIsLandscape(deviceOrientation)) {
                transform = CGAffineTransformMakeRotation((deviceOrientation == UIDeviceOrientationLandscapeLeft ? 1 : -1) * M_PI / 2.0);
            }
            button.imageView.transform = transform;
        }
    }];
}

- (void) setViewsForNetworkActivity:(BOOL)isNetworkActive {
    self.view.userInteractionEnabled = !isNetworkActive;
    self.cancelButton.enabled = !isNetworkActive;
    self.saveButton.enabled = !isNetworkActive;
}

- (void) submitPhotoStart {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    self.photoSubmissionInProgress = YES;
    [self setViewsForNetworkActivity:YES];
    [self submitPhotoUploadImage];
}

- (void) submitPhotoUploadImage {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([self.psm getStatusForStage:StageImageUpload] == StatusComplete) {
        [self submitPhotoSavePhoto];
    } else {
        [self.psm uploadImage:[self.imageEdited resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(1600.0, 1600.0) interpolationQuality:kCGInterpolationHigh]];
    }
}

- (void) submitPhotoSavePhoto {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    if ([self.psm getStatusForStage:StagePhotoSave] == StatusComplete) {
        [self submitPhotoFinish];
    } else {
        [self.psm savePhoto:self.psm.photoEID toEvent:self.event];
    }
}

- (void) submitPhotoFinish {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    [self.delegate cameraViewController:self finishedWithPhotoSubmitted:self.psm.photoSubmitted];
}

- (void) submitPhotoStopWithFailure:(BOOL)didFail {
    [self setViewsForNetworkActivity:NO];
    if (didFail) {
        [[UIAlertView connectionErrorAlertView] show];
    } else {
        // ...
    }
    self.photoSubmissionInProgress = NO;
}

- (void)photoSubmissionManager:(PFPhotoSubmissionManager *)manager changedStatus:(PhotoSubmissionStatus)statusNew forStage:(PhotoSubmissionStage)stage photoSubmissionIsComplete:(BOOL)isComplete {
    NSLog(@"psm:changedStatus:%@ forStage:%@ ...IsComplete:%d", [PFPhotoSubmissionManager stringForStatus:statusNew], [PFPhotoSubmissionManager stringForStage:stage], isComplete);
    if (self.photoSubmissionInProgress) {
        if (statusNew == StatusFailure) {
            [self submitPhotoStopWithFailure:YES];
        } else if (statusNew == StatusComplete) {
            if (stage == StageImageUpload) {
                [self submitPhotoSavePhoto];
            } else if (stage == StagePhotoSave) {
                [self submitPhotoFinish];
            }
        }
    }
}

@end