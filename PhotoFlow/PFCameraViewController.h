//
//  PFCameraViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 10/9/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFCameraOverlayView.h"
#import "PFEvent.h"
#import "NSManagedObjectContext+PhotoFlow.h"

@protocol PFCameraViewControllerDelegate;

@interface PFCameraViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, PFCameraOverlayViewDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) PFEvent * event;

@property (nonatomic, strong) UIImagePickerController * imagePickerCurrent;
@property (nonatomic, strong) UIImagePickerController * imagePickerCamera;
@property (nonatomic, strong) UIImagePickerController * imagePickerLibrary;

@property (nonatomic, weak) id<PFCameraViewControllerDelegate> delegate;

@end

@protocol PFCameraViewControllerDelegate <NSObject>
- (void) cameraViewControllerFinished;
@end