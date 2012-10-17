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

@protocol PFPhotoContainerViewControllerDelegate;

@interface PFPhotoContainerViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, PFPhotoViewControllerDelegate, PFCameraViewControllerDelegate, UIActionSheetDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapSingleGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapDoubleGestureRecognizer;
- (IBAction)tapped:(UITapGestureRecognizer *)gestureRecognizer;

- (void) setPhotoIndex:(NSInteger)photoIndex inPhotos:(NSArray *)photos forEvent:(PFEvent *)event;
@property (nonatomic, readonly) NSInteger photoIndex;
@property (nonatomic, strong, readonly) NSArray * photos;
@property (nonatomic, strong, readonly) PFEvent * event;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * cameraButton;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * shareButton ;
@property (nonatomic, strong) IBOutlet UIBarButtonItem * deleteButton;
- (IBAction)toolbarButtonTouched:(id)sender;

@property (nonatomic, strong) IBOutlet UIView * containerView;

@property (nonatomic, weak) id<PFPhotoContainerViewControllerDelegate> delegate;

@end

@protocol PFPhotoContainerViewControllerDelegate <NSObject>
- (void) photoContainerViewControllerDidRequestRefresh:(PFPhotoContainerViewController *)viewController;
@end
