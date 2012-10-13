//
//  PFCameraViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 10/9/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFEvent.h"
#import "NSManagedObjectContext+PhotoFlow.h"
#import <AVFoundation/AVFoundation.h>
#import "AVCamCaptureManager.h"
#import "AFPhotoEditorController.h"
#import "PFPhotoSubmissionManager.h"
#import "PFPhoto.h"

@protocol PFCameraViewControllerDelegate;

@interface PFCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCamCaptureManagerDelegate, PFPhotoSubmissionManagerDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) PFEvent * event;
@property (nonatomic, strong) PFPhotoSubmissionManager * psm;

// Camera
// Camera capture
@property (nonatomic, strong) AVCamCaptureManager * captureManager;
//@property (nonatomic, strong) AVCaptureSession * captureSession;
//@property (nonatomic, strong) AVCaptureInput * captureInputVideo;
//@property (nonatomic, strong) AVCaptureStillImageOutput * captureOutputImage;
// Camera preview
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * capturePreviewLayer;
@property (nonatomic, strong) IBOutlet UIView   * capturePreviewView;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapFocusSingle;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapFocusDouble;
- (IBAction)tappedToFocus:(UITapGestureRecognizer *)tapGestureRecognizer;
// Camera controls
@property (strong, nonatomic) IBOutlet UIButton * flashButtonAuto;
@property (strong, nonatomic) IBOutlet UIButton * flashButtonOn;
@property (strong, nonatomic) IBOutlet UIButton * flashButtonOff;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * flashButtonSpaceLeftCenter;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * flashButtonSpaceCenterRight;
@property (strong, nonatomic) IBOutlet UIButton * swapCamerasButton;
@property (strong, nonatomic) IBOutlet UIView   * bottomBar;
@property (strong, nonatomic) IBOutlet UIImageView * bottomBarBackgroundImageView;
@property (strong, nonatomic) IBOutlet UIView * bottomBarShadowView;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * bottomBarHeightConstraint;
@property (strong, nonatomic) IBOutlet UIButton * cancelButton;
@property (strong, nonatomic) IBOutlet UIButton * photoButton;
@property (strong, nonatomic) IBOutlet UIButton * libraryButton;
@property (strong, nonatomic) IBOutlet UIButton * saveButton;
@property (strong, nonatomic) IBOutlet UIImageView * focusBox;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * focusBoxX;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * focusBoxY;
// Camera review
@property (strong, nonatomic) IBOutlet UIImageView * imageOverlay;
- (void) showImageReview:(UIImage *)image;
- (void) hideImageReview;
@property (nonatomic, readonly) BOOL inReview;
// Library
@property (nonatomic, strong) UIImagePickerController * imagePickerLibrary;

- (IBAction)cameraControlButtonTouched:(UIButton *)sender;
- (IBAction)cameraFlowButtonTouched:(UIButton *)sender;

@property (nonatomic, weak) id<PFCameraViewControllerDelegate> delegate;

@end

@protocol PFCameraViewControllerDelegate <NSObject>
- (void) cameraViewController:(PFCameraViewController *)viewController finishedWithPhotoSubmitted:(PFPhoto *)photoSubmitted;
@end