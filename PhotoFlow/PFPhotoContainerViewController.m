//
//  PFPhotoContainerViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/28/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoContainerViewController.h"
#import "UIAlertView+PhotoFlow.h"
#import <Social/Social.h>
#import "LocalyticsSession.h"

@interface PFPhotoContainerViewController ()
@property (nonatomic, strong) UIPageViewController * pageViewController;
@property (nonatomic) NSInteger photoIndex;
@property (nonatomic, strong) NSArray * photos;
@property (nonatomic, strong) PFEvent * event;
- (void)setBarsVisible:(BOOL)visible animated:(BOOL)animated;
- (void) backButtonTouched:(id)sender;
- (UIImage *) toolbarButtonImageForBase:(NSString *)base highlight:(BOOL)highlight landscape:(BOOL)landscape;
- (void) updateDeleteButtonVisibleForPhoto:(PFPhoto *)photo;
@property (nonatomic) UIPageViewControllerNavigationDirection navDirectionMostRecent;
- (PFPhotoViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerForPhotoIndex:(NSInteger)photoIndex;
@property (nonatomic, strong) UIActionSheet * deleteActionSheet;
- (void) updateFacebookButtonVisible;
@end

@implementation PFPhotoContainerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navDirectionMostRecent = UIPageViewControllerNavigationDirectionForward;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.pageViewController = self.childViewControllers[0];
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    
    [self.pageViewController setViewControllers:@[[self pageViewController:self.pageViewController viewControllerForPhotoIndex:self.photoIndex]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
    
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
    
    [self updateDeleteButtonVisibleForPhoto:self.photos[self.photoIndex]];
    
}

- (void) updateDeleteButtonVisibleForPhoto:(PFPhoto *)photo {
//    NSLog(@"updateDeleteButtonVisibleForPhoto");
    BOOL shouldBeVisible = [photo.user isEqualToString:[PFUser currentUser].objectId];
//    NSLog(@"shouldBeVisible = %d", shouldBeVisible);
    NSMutableArray * toolbarItemsMutable = self.toolbarItems.mutableCopy;
    if (!shouldBeVisible) {
        [toolbarItemsMutable removeObject:self.deleteButton];
    } else {
        if (![toolbarItemsMutable containsObject:self.deleteButton]) [toolbarItemsMutable addObject:self.deleteButton];
    }
    self.toolbarItems = toolbarItemsMutable;
}

- (void) updateFacebookButtonVisible {
    BOOL shouldBeVisible = [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook];
    NSMutableArray * toolbarItemsMutable = self.toolbarItems.mutableCopy;
    if (!shouldBeVisible) {
        [toolbarItemsMutable removeObject:self.shareButton];
    } else {
        if (![toolbarItemsMutable containsObject:self.shareButton]) [toolbarItemsMutable insertObject:self.shareButton atIndex:0];
    }
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
    [self updateFacebookButtonVisible];
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
        
        [self updateDeleteButtonVisibleForPhoto:photoViewController.photo];
    }
    
    [self dismissViewControllerAnimated:NO completion:NULL];
    
}

- (void)setPhotoIndex:(NSInteger)photoIndex inPhotos:(NSArray *)photos forEvent:(PFEvent *)event {
    self.photoIndex = photoIndex;
    self.photos = photos;
    self.event = event;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return [self pageViewController:pageViewController viewControllerForPhotoIndex:self.photoIndex - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSLog(@"%@", NSStringFromSelector(_cmd));
    return [self pageViewController:pageViewController viewControllerForPhotoIndex:self.photoIndex + 1];
}

- (PFPhotoViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerForPhotoIndex:(NSInteger)photoIndex {
    NSLog(@"pageViewController:viewControllerForPhotoIndex:%d", photoIndex);
    PFPhotoViewController * viewController = nil;
    if (0 <= photoIndex && photoIndex < self.photos.count) {
        viewController = [[PFPhotoViewController alloc] initWithNibName:@"PFPhotoViewController" bundle:[NSBundle mainBundle]];
        viewController.delegate = self;
        viewController.photo = [self.photos objectAtIndex:photoIndex];
    }
    return viewController;
}

- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray *)previousViewControllers transitionCompleted:(BOOL)completed {
    PFPhoto * photo = ((PFPhotoViewController *)pageViewController.viewControllers[0]).photo;
    NSInteger photoIndexPrevious = self.photoIndex;
    self.photoIndex = [self.photos indexOfObject:photo];
    if (photoIndexPrevious != self.photoIndex) {
        self.navDirectionMostRecent = photoIndexPrevious < self.photoIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    }
    NSLog(@"photoIndex : %d -> %d %@", photoIndexPrevious, self.photoIndex, photoIndexPrevious != self.photoIndex ? (self.navDirectionMostRecent == UIPageViewControllerNavigationDirectionForward ? @"(Forward)" : @"(Reverse)") : @"");
    [self updateDeleteButtonVisibleForPhoto:photo];
}

//- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray *)pendingViewControllers {
//    NSLog(@"FOO FOO FOO FOO FOO");
//}

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
    if (sender == self.shareButton.customView) {
        SLComposeViewController * facebookViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        PFPhotoViewController * photoViewController = (PFPhotoViewController *)self.pageViewController.viewControllers[0];
        [facebookViewController setInitialText:[photoViewController.photo.event.descriptionShort stringByAppendingString:@" via"]];
        [facebookViewController addURL:[NSURL URLWithString:@"www.photoflowapp.com"]];
        [facebookViewController addImage:photoViewController.image];
        SLComposeViewControllerCompletionHandler __block facebookCompletionHandler = ^(SLComposeViewControllerResult result){
            [self dismissViewControllerAnimated:YES completion:NULL];
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                    NSLog(@"Facebook post cancelled");
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Facebook post finished");
                    NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithDictionary:@{@"Event ID" : photoViewController.photo.event.eid, @"Event Title" : photoViewController.photo.event.title, @"Photo ID" : photoViewController.photo.eid}];
                    if ([PFUser currentUser].objectId) {
                        [attributes setObject:[PFUser currentUser].objectId forKey:@"User ID"];
                    }
                    if (photoViewController.photo.user) {
                        [attributes setObject:photoViewController.photo.user forKey:@"Photo User ID"];
                    }
                    [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Facebook Share" attributes:attributes];
                    break;
            }
        };
        facebookViewController.completionHandler = facebookCompletionHandler;
        [self presentViewController:facebookViewController animated:YES completion:NULL];
    } else if (sender == self.deleteButton.customView) {
        [self.deleteActionSheet showFromBarButtonItem:self.deleteButton animated:YES];
    }
}

- (void) deletePhotoCurrent {
    NSLog(@"deletePhotoCurrent");
    NSLog(@"  self.photoIndex = %d", self.photoIndex);
    
    PFPhoto * photo = self.photos[self.photoIndex];
    
    PFCSuccessBlock successBlock = ^(AFHTTPRequestOperation *operation, id responseObject){
        // Remove from local array
        NSMutableArray * photosMutable = [NSMutableArray arrayWithArray:self.photos];
        [photosMutable removeObject:photo];
        self.photos = photosMutable;
        
        // Remove from database
        [self.moc deleteAllObjectsForEntityName:@"PFPhoto" matchingPredicate:[NSPredicate predicateWithFormat:@"eid == %@", photo.eid]];
        [self.moc saveCoreData];
        
        // Transition can either be: go to previous, go to next, or pop this container VC altogether.
        if (photosMutable.count == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            // recent direction was forward
            //   go back 1, direction reverse
            //   if nothing back there, go forward 1, direction forward
            // recent direction was backward
            //   go forward 1, direction forward
            //   if nothing up there, go backward 1, direction backward
            UIPageViewControllerNavigationDirection navDirection = self.navDirectionMostRecent == UIPageViewControllerNavigationDirectionForward ? UIPageViewControllerNavigationDirectionReverse : UIPageViewControllerNavigationDirectionForward;
            if ((navDirection == UIPageViewControllerNavigationDirectionReverse && self.photoIndex != 0) ||
                (navDirection == UIPageViewControllerNavigationDirectionForward && self.photoIndex > self.photos.count)) {
                navDirection = UIPageViewControllerNavigationDirectionReverse;
                self.photoIndex -= 1;
            } else {
                navDirection = UIPageViewControllerNavigationDirectionForward;
            }
            
            /* The following is so ugly, but I can't find a way around it currently. The problem is that a UIPageViewController is not used to dealing with the deletion of pages. Well, the REAL problem is that UIPageViewController is very lazy when it comes to loading its view controllers. So, if it already has an "after" view controller, it's not going to load that view controller again until it gets taken out of the Page view controllers altogether (not in before, current, or after slots). This presents a problem when deleting a page and navigating to the previous page, because the after page does not get reloaded. I can't find any way to tell a UIPageViewController to refresh all its pages. A slightly less ugly solution to this problem would be to re-create the UIPageViewController. I have not been able to get this to work cleanly though. There is stutter or a disappearing view. Perhaps if I had stuck with it, I could get that to work. For now, this works fine, and just requires a rather silly delegate pattern. */
            __block typeof(self) bself = self; // To avoid warnings about retain cycles
            PFPhotoViewController * viewController = [self pageViewController:self.pageViewController viewControllerForPhotoIndex:self.photoIndex];
            [self.pageViewController setViewControllers:@[viewController] direction:navDirection animated:YES completion:^(BOOL finished) {
                [bself updateDeleteButtonVisibleForPhoto:self.photos[self.photoIndex]];
                [bself.delegate photoContainerViewControllerDidRequestRefresh:bself];
            }];
        }
        
    };
    
    
    [[PFHTTPClient sharedClient] deletePhoto:photo.eid successBlock:successBlock failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (operation.response.statusCode == 200) {
            successBlock(operation, nil);
        } else {
            [[UIAlertView connectionErrorAlertView] show];
        }
    }];
    
}

- (UIActionSheet *)deleteActionSheet {
    if (_deleteActionSheet == nil) {
        _deleteActionSheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure you want to delete this photo? This can't be undone." delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Delete Photo" otherButtonTitles:nil];
    }
    return _deleteActionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet == self.deleteActionSheet &&
        buttonIndex != actionSheet.cancelButtonIndex) {
        [self deletePhotoCurrent];
    }
}

@end
