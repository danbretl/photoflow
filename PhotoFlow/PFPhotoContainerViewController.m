//
//  PFPhotoContainerViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/28/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoContainerViewController.h"
#import "PFPhotoViewController.h"

@interface PFPhotoContainerViewController ()
@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic) NSUInteger photoIndex;
@property (nonatomic, strong) NSArray * photos;
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
    
    PFPhotoViewController * photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoViewController"];
    photoViewController.photo = [self.photos objectAtIndex:self.photoIndex];
    [self.pageViewController setViewControllers:@[photoViewController]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
    
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
        PFPhotoViewController * photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoViewController"];
        photoViewController.photo = [self.photos objectAtIndex:self.photoIndex - 1];
        return photoViewController;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.photoIndex + 1 < self.photos.count) {
        PFPhotoViewController * photoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoViewController"];
        photoViewController.photo = [self.photos objectAtIndex:self.photoIndex + 1];
        return photoViewController;
    }
    return nil;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    self.photoIndex = [self.photos indexOfObject:((PFPhotoViewController *)pageViewController.viewControllers[0]).photo];
}

@end
