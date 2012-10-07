//
//  PFPhotoViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPhoto.h"
#import "PFPhotoScrollView.h"

@protocol PFPhotoViewControllerDelegate;

@interface PFPhotoViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet PFPhotoScrollView * scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *placeholderImageView;

@property (nonatomic, strong) PFPhoto * photo;

@property (nonatomic, readonly) float zoomScaleStart;

@property (nonatomic, weak) id<PFPhotoViewControllerDelegate> delegate;

@end

@protocol PFPhotoViewControllerDelegate <NSObject>
- (void) photoViewControllerDidZoomOutToNormal:(PFPhotoViewController *)viewController;
- (void) photoViewControllerDidZoomIn:(PFPhotoViewController *)viewController;
@end
