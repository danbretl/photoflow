//
//  PFPhotoContainerViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/28/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPhotoViewController.h"
#import "PFEvent.h"
#import "PFCameraViewController.h"

@interface PFPhotoContainerViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, PFPhotoViewControllerDelegate, PFCameraViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapSingleGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapDoubleGestureRecognizer;
- (IBAction)tapped:(UITapGestureRecognizer *)gestureRecognizer;

- (void) setPhotoIndex:(NSUInteger)photoIndex inPhotos:(NSArray *)photos forEvent:(PFEvent *)event;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * cameraButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * shareButton ;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * deleteButton;
- (IBAction)toolbarButtonTouched:(id)sender;

@end
