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
@property (nonatomic, strong) PFEvent * event;
- (void)setBarsVisible:(BOOL)visible animated:(BOOL)animated;
- (void) backButtonTouched:(id)sender;
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
    
    self.title = self.event.title;
    
    UIImage * backArrowImage = [UIImage imageNamed:@"btn_back_photos.png"];
    UIImage * backArrowImageHighlight = [UIImage imageNamed:@"btn_back_photos_highlight.png"];
    UIButton * normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    normalButton.frame = CGRectMake(15, 0, backArrowImage.size.width + 15 /* COULD HAVE ALSO DONE THIS WITH A FIXED SPACE UIBARBUTTONITEM */, backArrowImage.size.height);
    [normalButton setImage:backArrowImage forState:UIControlStateNormal];
    [normalButton setImage:backArrowImageHighlight forState:UIControlStateHighlighted];
    [normalButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithCustomView:normalButton];
    self.navigationItem.leftBarButtonItem = backButton;
        
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsLandscapePhone];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:/*UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 20.0 : */25.0], UITextAttributeTextColor : [UIColor colorWithWhite:33.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowColor : [UIColor clearColor]};
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsLandscapePhone];
//    [self setBarsVisible:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsLandscapePhone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPhotoIndex:(NSUInteger)photoIndex inPhotos:(NSArray *)photos forEvent:(PFEvent *)event {
    self.photoIndex = photoIndex;
    self.photos = photos;
    self.event = event;
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
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:0.20 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.toolbarBottomConstrant.constant = visible ? 0.0 : self.toolbar.bounds.size.height;
        [self.view layoutIfNeeded];
    } completion:NULL];
}

- (void)tapped:(UITapGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.tapDoubleGestureRecognizer) {
        PFPhotoViewController * photoViewController = self.pageViewController.viewControllers[0];
        float zoomScaleAdj = photoViewController.scrollView.zoomScale;
        if (photoViewController.scrollView.zoomScale == photoViewController.scrollView.minimumZoomScale) {
            zoomScaleAdj = photoViewController.scrollView.maximumZoomScale;
        } else {
            // zoomScaleAdj = photoViewController.scrollView.minimumZoomScale;
            zoomScaleAdj = photoViewController.scrollView.zoomScaleForOptimalPresentation;
            if (photoViewController.scrollView.zoomScaleForOptimalPresentation == photoViewController.scrollView.maximumZoomScale) {
                zoomScaleAdj = photoViewController.scrollView.minimumZoomScale;
            }
        }
        [photoViewController.scrollView setZoomScale:zoomScaleAdj animated:YES];
    } else if (gestureRecognizer == self.tapSingleGestureRecognizer) {
        [self setBarsVisible:self.navigationController.navigationBarHidden animated:YES];
    }
}

- (void)backButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:/*UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 20.0 : */25.0], UITextAttributeTextColor : [UIColor colorWithWhite:33.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowColor : [UIColor clearColor]};
}

@end
