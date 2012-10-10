//
//  PFCameraOverlayView.h
//  PhotoFlow
//
//  Created by Dan Bretl on 10/8/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PFCameraOverlayViewDelegate;

@interface PFCameraOverlayView : UIView

@property (strong, nonatomic) UIImageView * imageOverlay;

@property (strong, nonatomic) UIView * bottomBar;
@property (strong, nonatomic) UIButton * cancelButton;
@property (strong, nonatomic) UIButton * photoButton;
@property (strong, nonatomic) UIButton * libraryButton;
@property (strong, nonatomic) UIButton * saveButton;

@property (weak, nonatomic) id<PFCameraOverlayViewDelegate> delegate;

- (void) showImageReview:(UIImage *)image;
- (void) hideImageReview;
@property (nonatomic, readonly) BOOL inReview;

@end

@protocol PFCameraOverlayViewDelegate <NSObject>
- (void) cameraOverlayView:(PFCameraOverlayView *)overlayView buttonTouched:(UIButton *)buttonTouched;
@end