//
//  PFCameraViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/9/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFCameraViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

@interface PFCameraViewController ()
- (void)showImagePicker;
@end

@implementation PFCameraViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showImagePicker];
}

- (void)showImagePicker {
    
    UIImagePickerController * imagePicker = nil;
    PFCameraOverlayView * cameraOverlayView = nil;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        imagePicker.showsCameraControls = NO;
        imagePicker.allowsEditing = YES;
        
        //BOOL frontCameraAvailable = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
        BOOL rearCameraAvailable  = [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear ];
        imagePicker.cameraDevice = rearCameraAvailable ? UIImagePickerControllerCameraDeviceRear : UIImagePickerControllerCameraDeviceFront;
        
        cameraOverlayView = [[PFCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        cameraOverlayView.delegate = self;
        [imagePicker.view addSubview:cameraOverlayView];
        //imagePicker.cameraOverlayView = cameraOverlayView;
        
        self.imagePickerCamera = imagePicker;
        
    } else {
        
        imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
        imagePicker.sourceType = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary] ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        imagePicker.allowsEditing = NO;
        
        self.imagePickerLibrary = imagePicker;
        
    }
    
    self.imagePickerCurrent = imagePicker;
    [self presentViewController:self.imagePickerCurrent animated:NO completion:NULL];
    
}

- (void)cameraOverlayView:(PFCameraOverlayView *)overlayView buttonTouched:(UIButton *)buttonTouched {
    if (buttonTouched == overlayView.cancelButton) {
        if (overlayView.inReview) {
            [overlayView hideImageReview];
        } else {
            [self dismissViewControllerAnimated:NO completion:^{
                [self.delegate cameraViewControllerFinished];
            }];
        }
    } else if (buttonTouched == overlayView.photoButton) {
        [self.imagePickerCurrent takePicture];
    } else if (buttonTouched == overlayView.saveButton) {
        [self.delegate cameraViewControllerFinished];
        // ...
        // ...
        // ...
    } else if (buttonTouched == overlayView.libraryButton) {
        // ...
        // ...
        // ...
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:NO completion:^{
        [self.delegate cameraViewControllerFinished];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:");
}

@end
