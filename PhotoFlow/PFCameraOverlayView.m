//
//  PFCameraOverlayView.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/8/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFCameraOverlayView.h"

@interface PFCameraOverlayView()
- (void)buttonTouched:(UIButton *)button;
@end

@implementation PFCameraOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        CGFloat bottomBarHeight = [UIScreen mainScreen].bounds.size.height == 568.0 ? 96.0 : 53.0;
        
        self.bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - bottomBarHeight, self.bounds.size.width, bottomBarHeight)];
        self.bottomBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        UIImageView * bottomBarBackgroundImageView = [[UIImageView alloc] initWithFrame:self.bottomBar.bounds];
        bottomBarBackgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        bottomBarBackgroundImageView.backgroundColor = [UIColor blackColor];
        bottomBarBackgroundImageView.image = [[UIImage imageNamed:@"toolbar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0, 0, 0)];
        [self.bottomBar addSubview:bottomBarBackgroundImageView];
        [self addSubview:self.bottomBar];
        
        self.photoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        CGFloat photoButtonWidth = 102.0;
        self.photoButton.frame = CGRectMake(floorf((self.bottomBar.bounds.size.width - photoButtonWidth) / 2.0), 0, photoButtonWidth, self.bottomBar.bounds.size.height);
        self.photoButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        self.photoButton.contentMode = UIViewContentModeCenter;
        [self.photoButton setImage:[UIImage imageNamed:@"btn_camera.png"] forState:UIControlStateNormal];
        [self.photoButton setImage:[UIImage imageNamed:@"btn_camera_highlight.png"] forState:UIControlStateHighlighted];
        UIImage * photoButtonBackgroundImage = [[UIImage imageNamed:@"btn_camera_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.0, 0, 1.0)];
        [self.photoButton setBackgroundImage:photoButtonBackgroundImage forState:UIControlStateNormal];
        [self.photoButton setBackgroundImage:photoButtonBackgroundImage forState:UIControlStateHighlighted];
        [self.bottomBar addSubview:self.photoButton];
        
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * cancelButtonImage = [UIImage imageNamed:@"btn_cancel_photos.png"];
        UIImage * cancelButtonImageHighlight = [UIImage imageNamed:@"btn_cancel_photos_highlight.png"];
        self.cancelButton.frame = CGRectMake(0, 0, self.bottomBar.bounds.size.height, self.bottomBar.bounds.size.height);
        self.cancelButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;
        self.cancelButton.contentMode = UIViewContentModeRight;
        [self.cancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
        [self.cancelButton setImage:cancelButtonImageHighlight forState:UIControlStateHighlighted];
        [self.bottomBar addSubview:self.cancelButton];
        
        self.libraryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * libraryButtonImage = [UIImage imageNamed:@"btn_library_photos.png"];
        UIImage * libraryButtonImageHighlight = [UIImage imageNamed:@"btn_library_photos_highlight.png"];
        self.libraryButton.frame = CGRectMake(self.bottomBar.bounds.size.width - self.bottomBar.bounds.size.height, 0, self.bottomBar.bounds.size.height, self.bottomBar.bounds.size.height);
        self.libraryButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        self.libraryButton.contentMode = UIViewContentModeCenter;
        [self.libraryButton setImage:libraryButtonImage forState:UIControlStateNormal];
        [self.libraryButton setImage:libraryButtonImageHighlight forState:UIControlStateHighlighted];
        [self.bottomBar addSubview:self.libraryButton];
        
        self.saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * saveButtonImage = [UIImage imageNamed:@"btn_save_photos.png"];
        UIImage * saveButtonImageHighlight = [UIImage imageNamed:@"btn_save_photos_highlight.png"];
        self.saveButton.frame = CGRectMake(self.bottomBar.bounds.size.width - self.bottomBar.bounds.size.height, 0, self.bottomBar.bounds.size.height, self.bottomBar.bounds.size.height);
        self.saveButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
        self.saveButton.contentMode = UIViewContentModeCenter;
        [self.saveButton setImage:saveButtonImage forState:UIControlStateNormal];
        [self.saveButton setImage:saveButtonImageHighlight forState:UIControlStateHighlighted];
        [self.bottomBar addSubview:self.saveButton];
        
        self.imageOverlay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, CGRectGetMinY(self.bottomBar.frame))];
        self.imageOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.imageOverlay.contentMode = UIViewContentModeScaleAspectFit;
        self.imageOverlay.userInteractionEnabled = NO;
        [self insertSubview:self.imageOverlay belowSubview:self.bottomBar];
        
        self.saveButton.hidden   = YES;
        self.imageOverlay.hidden = YES;
        
        [self.photoButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.cancelButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.saveButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        [self.libraryButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return CGRectContainsPoint(self.bottomBar.bounds, [self convertPoint:point toView:self.bottomBar]);
}

- (void)buttonTouched:(UIButton *)button {
    [self.delegate cameraOverlayView:self buttonTouched:button];
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

@end
