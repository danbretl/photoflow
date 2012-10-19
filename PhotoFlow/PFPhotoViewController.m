//
//  PFPhotoViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoViewController.h"
#import "AFNetworking.h"
#import "PFHTTPClient.h"

@interface PFPhotoViewController ()
@property (nonatomic) float zoomScaleStart;
@end

@implementation PFPhotoViewController

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
	// Do any additional setup after loading the view.
        
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[[PFHTTPClient sharedClient] imageURLStringForPhoto:self.photo.eid boundingSize:[UIScreen mainScreen].bounds.size.height*2 quality:80 mode:UIViewContentModeScaleAspectFill]]];
    AFImageRequestOperation * imageRequest = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest success:^(UIImage *image) {
        if (image != nil) {
    //        NSLog(@"got image of size %@", NSStringFromCGSize(image.size));
            self.placeholderImageView.alpha = 0.0;
            [self.scrollView displayImage:image];
        }
    }];
    imageRequest.imageScale = 1.0;
    [imageRequest start];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.scrollView.zoomScale = self.scrollView.zoomScaleForOptimalPresentation;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        return self.scrollView.imageView;
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (scrollView == self.scrollView) {
        self.zoomScaleStart = scrollView.zoomScale;
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.zoomScaleStart != 0 &&
            self.zoomScaleStart < scrollView.zoomScale) {
            [self.delegate photoViewControllerDidZoomIn:self];
        }
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale {
    if (scrollView == self.scrollView) {
        if (scale == self.scrollView.minimumZoomScale) {
            [self.delegate photoViewControllerDidZoomOutToNormal:self];
        }
        self.zoomScaleStart = 0;
    }
}

@end
