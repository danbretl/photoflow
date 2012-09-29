//
//  PFPhotoViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"

@interface PFPhotoViewController ()

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
    
//    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
//    self.imageView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:self.photo.imageLocation]];
    AFImageRequestOperation * imageRequest = [AFImageRequestOperation imageRequestOperationWithRequest:urlRequest success:^(UIImage *image) {
        NSLog(@"got image of size %@", NSStringFromCGSize(image.size));
        self.imageView.image = image;
//        [self.imageView layoutSubviews];
//        self.scrollView.minimumZoomScale = 0.25;
//        self.scrollView.maximumZoomScale = 0.5;
//        self.scrollView.zoomScale = 0.25;
    }];
    imageRequest.imageScale = 1.0;
    [imageRequest start];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

@end
