/*
 File: PFPhotoScrollView.m
 Abstract: Centers image within the scroll view and configures image sizing and display.
 Version: 1.2
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import <Foundation/Foundation.h>
#import "PFPhotoScrollView.h"

@interface PFPhotoScrollView() <UIScrollViewDelegate> {
    UIImageView *_zoomView;  // if tiling, this contains a very low-res placeholder image. otherwise it contains the full image.
    CGSize _imageSize;
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}
- (void) setupFromFrameOrCoder;
@end

@implementation PFPhotoScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupFromFrameOrCoder];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupFromFrameOrCoder];
    }
    return self;
}
- (void) setupFromFrameOrCoder {
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.bouncesZoom = YES;
    self.decelerationRate = UIScrollViewDecelerationRateFast;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
//    NSLog(@"layoutSubviews");
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _zoomView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    _zoomView.frame = frameToCenter;
}

- (void)setFrame:(CGRect)frame
{
//    NSLog(@"PFPhotoScrollView setFrame");
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
}

#pragma mark - Configure scrollView to display new image (tiled or not)

- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [_zoomView removeFromSuperview];
    _zoomView = nil;
    
    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    // make a new UIImageView for the new image
    _zoomView = [[UIImageView alloc] initWithImage:image];
    [self addSubview:_zoomView];
    
    [self configureForImageSize:image.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
//    NSLog(@"configureForImageSize:%@", NSStringFromCGSize(imageSize));
    _imageSize = imageSize;
    self.contentSize = imageSize;
//    NSLog(@"self.contentSize = %@", NSStringFromCGSize(self.contentSize));
    [self setMaxMinZoomScalesForCurrentBounds];
    // self.zoomScale = self.minimumZoomScale;
    self.zoomScale = [self zoomScaleForOptimalPresentation]; // CUSTOMIZED
//    NSLog(@"self.zoomScale = %f", self.zoomScale);
}

// Portrait images look bad when they fill almost the entire height of the image view. // This is true, BUT having the flick-through-photos experience be interrupted each time you get to a portrait in portrait image is insanely annoying (more annoying than its visually worth).
- (float)zoomScaleForOptimalPresentation {
    float zoomScalePresentation = self.minimumZoomScale;
//    BOOL portraitInPortrait = self.imageView.image.size.height > self.imageView.image.size.width && self.bounds.size.height > self.bounds.size.width;
//    if (portraitInPortrait) {
//        zoomScalePresentation = self.bounds.size.height  / self.imageView.image.size.height;
//    }
    return zoomScalePresentation;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
//    NSLog(@"width  = bound:image %f:%f", boundsSize.width,  _imageSize.width);
//    NSLog(@"height = bound:image %f:%f", boundsSize.height, _imageSize.height);
//    NSLog(@"xScale = %f / yScale = %f", xScale, yScale);
    
    // fill width if the image and phone are both portrait or both landscape; otherwise take smaller scale
    // EDIT: no longer filling width if the image and phone are both portrait or both landscape. i don't know why that would be a desired feature.
    // BOOL imagePortrait = _imageSize.height > _imageSize.width;
    // BOOL phonePortrait = boundsSize.height > boundsSize.width;
//    NSLog(@"imagePortrait = %@", imagePortrait ? @"YES" : @"NO");
//    NSLog(@"phonePortrait = %@", phonePortrait ? @"YES" : @"NO");
    CGFloat minScale = /*imagePortrait == phonePortrait ? xScale : */MIN(xScale, yScale);
    
    // on high resolution screens we have double the pixel density, so we will be seeing every pixel if we limit the maximum zoom scale to 0.5.
    CGFloat maxScale = 1.0 / [[UIScreen mainScreen] scale];
    maxScale = MAX(MAX(maxScale, xScale), yScale); // CUSTOMIZED: Ensure that the maxScale is large enough so that the image can fill the screen (in both x and y).
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
//    NSLog(@"self.minimumZoomScale = %f", self.minimumZoomScale);
//    NSLog(@"self.maximumZoomScale = %f", self.maximumZoomScale);
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
//    NSLog(@"prepareToResize");
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_zoomView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
//    NSLog(@"recoverFromResizing");
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_zoomView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width / 2.0,
                                 boundsCenter.y - self.bounds.size.height / 2.0);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

- (UIImageView *)imageView {
    return _zoomView;
}

@end