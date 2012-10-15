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
- (UIImage *) toolbarButtonImageForBase:(NSString *)base highlight:(BOOL)highlight landscape:(BOOL)landscape;
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
    
    PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];
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
    
    BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    
    UIImage * cameraButtonImage = [self toolbarButtonImageForBase:@"camera" highlight:NO landscape:landscape];
    UIImage * cameraButtonImageHighlight = [self toolbarButtonImageForBase:@"camera" highlight:YES landscape:landscape];
    UIButton * cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.contentMode = UIViewContentModeCenter;
    cameraButton.frame = CGRectMake(0, 0, 102.0, landscape ? 32.0 : 44.0); // HACK : HARD CODED TOOLBAR HEIGHTS.
    cameraButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
    [cameraButton setImage:cameraButtonImageHighlight forState:UIControlStateHighlighted];
    [cameraButton addTarget:self.cameraButton.target action:self.cameraButton.action forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setCustomView:cameraButton];
    
    UIImage * shareButtonImage = [self toolbarButtonImageForBase:@"share" highlight:NO landscape:landscape];
    UIImage * shareButtonImageHighlight = [self toolbarButtonImageForBase:@"share" highlight:YES landscape:landscape];
    UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.contentMode = UIViewContentModeCenter;
    shareButton.frame = CGRectMake(15.0, 0, shareButtonImage.size.width + 15.0, landscape ? 32.0 : 44.0); // HACK : HARD CODED TOOLBAR HEIGHTS.
    shareButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [shareButton setImage:shareButtonImage forState:UIControlStateNormal];
    [shareButton setImage:shareButtonImageHighlight forState:UIControlStateHighlighted];
    [shareButton addTarget:self.shareButton.target action:self.shareButton.action forControlEvents:UIControlEventTouchUpInside];
    [self.shareButton setCustomView:shareButton];

    UIImage * deleteButtonImage = [self toolbarButtonImageForBase:@"delete" highlight:NO landscape:landscape];
    UIImage * deleteButtonImageHighlight = [self toolbarButtonImageForBase:@"delete" highlight:YES landscape:landscape];
    UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteButton.contentMode = UIViewContentModeCenter;
    deleteButton.frame = CGRectMake(0, 0, deleteButtonImage.size.width + 15.0, landscape ? 32.0 : 44.0); // HACK : HARD CODED TOOLBAR HEIGHTS.
    deleteButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [deleteButton setImage:deleteButtonImage forState:UIControlStateNormal];
    [deleteButton setImage:deleteButtonImageHighlight forState:UIControlStateHighlighted];
    [deleteButton addTarget:self.deleteButton.target action:self.deleteButton.action forControlEvents:UIControlEventTouchUpInside];
    [self.deleteButton setCustomView:deleteButton];
    
    // IN DEVELOPMENT - HIDING SHARE AND DELETE BUTTONS FOR NOW, UNTIL THEIR CORRESPONDING FEATURES GET IMPLEMENTED
    NSMutableArray * toolbarItemsMutable = self.toolbarItems.mutableCopy;
    [toolbarItemsMutable removeObject:self.shareButton];
    self.toolbarItems = toolbarItemsMutable;
    
}

- (UIImage *) toolbarButtonImageForBase:(NSString *)base highlight:(BOOL)highlight landscape:(BOOL)landscape {
    return [UIImage imageNamed:[NSString stringWithFormat:@"btn_%@_photos%@%@.png", base, highlight ? @"_highlight" : @"", landscape ? @"_landscape" : @""]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = YES;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsLandscapePhone];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 20.0 : 25.0], UITextAttributeTextColor : [UIColor colorWithWhite:33.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowColor : [UIColor clearColor]};
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0.0 forBarMetrics:UIBarMetricsLandscapePhone];
    [self updateToolbarButtonImagesForOrientation:self.interfaceOrientation];
//    [self setBarsVisible:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsDefault];
//    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_photos_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5.0, 0, 5.0)] forBarMetrics:UIBarMetricsLandscapePhone];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowCamera"]) {
        PFCameraViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
        viewController.event = self.event;
        viewController.delegate = self;
    }
}

- (void)cameraViewController:(PFCameraViewController *)viewController finishedWithPhotoSubmitted:(PFPhoto *)photoSubmitted {
    
    if (photoSubmitted != nil) {
        NSArray * arrayMod = [@[photoSubmitted] arrayByAddingObjectsFromArray:self.photos];
        [self setPhotoIndex:0 inPhotos:arrayMod forEvent:self.event];
        
        PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];
        photoViewController.delegate = self;
        photoViewController.photo = photoSubmitted;
        [self.pageViewController setViewControllers:@[photoViewController] direction:UIPageViewControllerNavigationDirectionReverse animated:NO completion:NULL];
    }
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
}

- (void)setPhotoIndex:(NSUInteger)photoIndex inPhotos:(NSArray *)photos forEvent:(PFEvent *)event {
    self.photoIndex = photoIndex;
    self.photos = photos;
    self.event = event;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    if (self.photoIndex > 0) {
        PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];
        photoViewController.delegate = self;
        photoViewController.photo = [self.photos objectAtIndex:self.photoIndex - 1];
        return photoViewController;
    }
    return nil;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    if (self.photoIndex + 1 < self.photos.count) {
        PFPhotoViewController * photoViewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];
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
    if (self.navigationController.navigationBarHidden) [self setBarsVisible:YES animated:YES];
}

- (void)photoViewControllerDidZoomIn:(PFPhotoViewController *)viewController {
    if (!self.navigationController.navigationBarHidden) [self setBarsVisible:NO animated:YES];
}

- (void)setBarsVisible:(BOOL)visible animated:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:!visible animated:animated];
    [self.navigationController setToolbarHidden:!visible animated:animated];
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
    BOOL toLandscape = UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:toLandscape ? 20.0 : 25.0], UITextAttributeTextColor : [UIColor colorWithWhite:33.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0, 0)], UITextAttributeTextShadowColor : [UIColor clearColor]};
    [self updateToolbarButtonImagesForOrientation:toInterfaceOrientation];
}

- (void) updateToolbarButtonImagesForOrientation:(UIInterfaceOrientation)orientation {
    void(^updateToolbarButtonImage)(BOOL, NSString *, UIBarButtonItem *) = ^(BOOL landscape, NSString * toolbarButtonBase, UIBarButtonItem * toolbarButton){
        UIButton * customViewButton = (UIButton *)toolbarButton.customView;
        [customViewButton setImage:[self toolbarButtonImageForBase:toolbarButtonBase highlight:NO landscape:landscape] forState:UIControlStateNormal];
        [customViewButton setImage:[self toolbarButtonImageForBase:toolbarButtonBase highlight:YES landscape:landscape] forState:UIControlStateHighlighted];
    };
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    updateToolbarButtonImage(landscape, @"camera", self.cameraButton);
    updateToolbarButtonImage(landscape, @"share" , self.shareButton);
    updateToolbarButtonImage(landscape, @"delete", self.deleteButton);
}

- (void)toolbarButtonTouched:(id)sender {
    
}

@end
