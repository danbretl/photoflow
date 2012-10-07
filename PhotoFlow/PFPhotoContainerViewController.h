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

@interface PFPhotoContainerViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource, PFPhotoViewControllerDelegate>

@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapSingleGestureRecognizer;
@property (nonatomic, strong) IBOutlet UITapGestureRecognizer * tapDoubleGestureRecognizer;
- (IBAction)tapped:(UITapGestureRecognizer *)gestureRecognizer;

- (void) setPhotoIndex:(NSUInteger)photoIndex inPhotos:(NSArray *)photos forEvent:(PFEvent *)event;

@property (strong, nonatomic) IBOutlet UIToolbar * toolbar;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * toolbarBottomConstrant;

@end
