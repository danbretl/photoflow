//
//  PFPhotoContainerViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/28/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoContainerViewController.h"

@interface PFPhotoContainerViewController ()
@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic) NSUInteger photoIndex;
@property (nonatomic, strong) NSArray * photos;
- (void)setBarsVisible:(BOOL)visible animated:(BOOL)animated;
@end

@implementation PFPhotoContainerViewController

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
    
    self.pageViewController = self.childViewControllers[0];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];// [self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoViewController"];
    photoViewController.delegate = self;
    photoViewController.photo = [self.photos objectAtIndex:self.photoIndex];
    [self.pageViewController setViewControllers:@[photoViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
    
    [self.tapSingleGestureRecognizer requireGestureRecognizerToFail:self.tapDoubleGestureRecognizer];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPhotoIndex:(NSUInteger)photoIndex inPhotos:(NSArray *)photos {
    self.photoIndex = photoIndex;
    self.photos = photos;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.photoIndex > 0) {
        PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];//[self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoViewController"];
        photoViewController.delegate = self;
        photoViewController.photo = [self.photos objectAtIndex:self.photoIndex - 1];
        return photoViewController;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.photoIndex + 1 < self.photos.count) {
        PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];//[self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoViewController"];
        photoViewController.delegate = self;
        photoViewController.photo = [self.photos objectAtIndex:self.photoIndex + 1];
        return photoViewController;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.photoIndex = [self.photos indexOfObject:((PFPhotoViewController *)pageViewController.viewControllers[0]).photo];
}

- (void)photoViewControllerDidZoomOutToNormal:(PFPhotoViewController *)viewController {
//    NSLog(@"photoViewControllerDidZoomOutToNormal");
    if (self.navigationController.navigationBarHidden) [self setBarsVisible:YES animated:YES];
}

- (void)photoViewControllerDidZoomIn:(PFPhotoViewController *)viewController {
//    NSLog(@"photoViewControllerDidZoomIn");
    if (!self.navigationController.navigationBarHidden) [self setBarsVisible:NO animated:YES];
}

- (void)setBarsVisible:(BOOL)visible animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:!visible animated:animated];
    [self.view layoutSubviews];
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.toolbarBottomConstrant.constant = visible ? 0.0 : self.toolbar.bounds.size.height;
        [self.view layoutSubviews];
    } completion:NULL];
}

- (void)tapped:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.tapDoubleGestureRecognizer) {
        PFPhotoViewController * photoViewController = self.pageViewController.viewControllers[0];
        float zoomScaleAdj = photoViewController.scrollView.zoomScale;
        if (photoViewController.scrollView.zoomScale == photoViewController.scrollView.minimumZoomScale) {
            zoomScaleAdj = photoViewController.scrollView.maximumZoomScale;
        } else {
            zoomScaleAdj = photoViewController.scrollView.minimumZoomScale;
        }
        [photoViewController.scrollView setZoomScale:zoomScaleAdj animated:YES];
    } else if (gestureRecognizer == self.tapSingleGestureRecognizer) {
        [self setBarsVisible:self.navigationController.navigationBarHidden animated:YES];
    }
}

@end
