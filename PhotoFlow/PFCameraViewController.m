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
@end

@implementation PFCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
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

    self.flashButtonSelected = self.flashButtonAuto;
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
        self.imageOverlay.image == nil) {
        [self showLibraryPicker];
        self.photoButton.enabled = NO;
        self.capturePreviewView.userInteractionEnabled = NO;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)cameraFlowButtonTouched:(UIButton *)sender {
    NSLog(@"cameraFlowButtonTouched");
    
    if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
    
    if (sender == self.libraryButton) {
        [self showLibraryPicker];
    } else if (sender == self.saveButton) {
        [self.delegate cameraViewControllerFinished];
        // ...
        // ...
        // ...
    } else if (sender == self.cancelButton) {
        if (self.inReview) {
            [self hideImageReview];
        } else {
            [self.delegate cameraViewControllerFinished];
        }
    }
    
}

- (void)cameraControlButtonTouched:(UIButton *)sender {
    NSLog(@"cameraControlButtonTouched");
    
    if (sender == self.photoButton) {
        
        if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
        
        [self.captureManager captureStillImage];
        // Flash the screen white and fade it out to give UI feedback that a still image was taken
        UIView * flashView = [[UIView alloc] initWithFrame:self.view.frame];
        [flashView setBackgroundColor:[UIColor whiteColor]];
        [self.view.window addSubview:flashView];
        [UIView animateWithDuration:.4 animations:^{ [flashView setAlpha:0.f]; } completion:^(BOOL finished){ [flashView removeFromSuperview]; }];
        
    } else if (sender == self.flashButtonAuto ||
               sender == self.flashButtonOn ||
               sender == self.flashButtonOff) {
        
        [self setFlashOptionsExpanded:!self.flashOptionsExpanded focusedOnOptionForButton:sender animated:YES];
        
    } else if (sender == self.swapCamerasButton) {
        
        if (self.flashOptionsExpanded) [self setFlashOptionsExpanded:NO focusedOnOptionForButton:self.flashButtonSelected animated:YES];
        
        [self.captureManager toggleCamera];
        [self.captureManager continuousFocusAtPoint:CGPointMake(0.5f, 0.5f)];
        
    }
    
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
    [UIView animateWithDuration:animated ? 0.25 : 0.0 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
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
            // ...
            // ...
            // ...
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
    [self showImageReview:[info objectForKey:UIImagePickerControllerOriginalImage]];
    [self dismissViewControllerAnimated:YES completion:^{
        // ...
        // ...
        // ...
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (self.captureManager.cameraCount == 0) {
        [self.delegate cameraViewControllerFinished];
    } else {
        [self dismissViewControllerAnimated:YES completion:^{
            // ...
            // ...
            // ...
        }];
    }
}

- (void)captureManagerStillImageCaptured:(AVCamCaptureManager *)captureManager {
    CFRunLoopPerformBlock(CFRunLoopGetMain(), kCFRunLoopCommonModes, ^(void) {
        [self showImageReview:captureManager.imageCaptured];
    });
}

- (void)showImageReview:(UIImage *)image {
    self.imageOverlay.image = image;
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
        [self.captureManager autoFocusAtPoint:convertedFocusPoint];
    }
}

// Change to continuous auto focus. The camera will constantly focus at the point choosen.
- (void)tapToContinouslyAutoFocus:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.captureManager.videoInput.device.isFocusPointOfInterestSupported)
        [self.captureManager continuousFocusAtPoint:CGPointMake(.5f, .5f)];
}

- (void)deviceOrientationDidChange {
    NSLog(@"deviceOrientationDidChange");
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

@end