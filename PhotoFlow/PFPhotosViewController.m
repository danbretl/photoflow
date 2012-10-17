//
//  PFPhotosViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotosViewController.h"
#import "PFPhotoCell.h"
#import "UIImageView+AFNetworking.h"
#import "PFPhotosGridFlowLayout.h"
#import "PFPhotosBannerFlowLayout.h"
#import "DefaultsManager.h"
#import <QuartzCore/QuartzCore.h>
#import "PFHTTPClient.h"
#import "PFLoadMoreCell.h"
#import "UIAlertView+PhotoFlow.h"

const NSInteger LOAD_PHOTOS_COUNT_RELOAD = 30;
const NSInteger LOAD_PHOTOS_COUNT_MORE_OLD = 20;

@interface PFPhotosViewController ()
@property (nonatomic, strong) NSArray * photos;
- (void) backButtonTouched:(id)sender;
- (void) setToggleButtonCustomViewOppositeOfLayout:(UICollectionViewLayout *)layout;
- (void) pulledToRefresh:(UIRefreshControl *)refreshControl;
- (void) reloadRecentPhotos;
//- (void) loadMoreRecentPhotos;
- (void) loadMoreOldPhotos;
- (void) loadMorePhotosAfter:(NSDate *)afterDate before:(NSDate *)beforeDate limit:(NSNumber *)limit successBlockPre:(PFCSuccessBlock)successBlockPre successBlockPost:(PFCSuccessBlock)successBlockPost;
@property (nonatomic) BOOL isLoadingRecent;
@property (nonatomic) BOOL isLoadingOld;
@property (nonatomic) BOOL willLoadOld;
- (void) updateLoadMoreCell;
@end

@implementation PFPhotosViewController

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
    
    self.title = self.event.title;
    
    UIImage * backArrowImage = [UIImage imageNamed:@"btn_back.png"];
    UIImage * backArrowImageHighlight = [UIImage imageNamed:@"btn_back_highlight.png"];
    UIButton * normalButton = [UIButton buttonWithType:UIButtonTypeCustom];
    normalButton.frame = CGRectMake(15, 0, backArrowImage.size.width + 15 /* COULD HAVE ALSO DONE THIS WITH A FIXED SPACE UIBARBUTTONITEM */, backArrowImage.size.height);
    [normalButton setImage:backArrowImage forState:UIControlStateNormal];
    [normalButton setImage:backArrowImageHighlight forState:UIControlStateHighlighted];
    [normalButton addTarget:self action:@selector(backButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithCustomView:normalButton];
    self.navigationItem.leftBarButtonItem = backButton;
    
    BOOL landscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    
    UIImage * cameraButtonImage = [UIImage imageNamed:landscape ? @"btn_camera_landscape.png" : @"btn_camera.png"];
    UIImage * cameraButtonImageHighlight = [UIImage imageNamed:landscape ? @"btn_camera_highlight_landscape.png" : @"btn_camera_highlight.png"];
    UIButton * cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.contentMode = UIViewContentModeCenter;
    cameraButton.frame = CGRectMake(0, 0, 102.0, landscape ? 32.0 : 44.0); // HACK : HARD CODED TOOLBAR HEIGHTS.
    cameraButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [cameraButton setBackgroundImage:[[UIImage imageNamed:@"btn_camera_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.0, 0, 1.0)] forState:UIControlStateNormal];
    [cameraButton setBackgroundImage:[[UIImage imageNamed:@"btn_camera_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.0, 0, 1.0)] forState:UIControlStateHighlighted];
    [cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
    [cameraButton setImage:cameraButtonImageHighlight forState:UIControlStateHighlighted];
    [cameraButton addTarget:self.cameraButton.target action:self.cameraButton.action forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setCustomView:cameraButton];
    
    PFPhotosViewLayoutType layoutType = [DefaultsManager getPhotosViewLayoutPreference];
    if (landscape) layoutType = PFPhotosViewLayoutGrid;
    UICollectionViewFlowLayout * layout = nil;
    switch (layoutType) {
        case PFPhotosViewLayoutGrid:
            layout = [[PFPhotosGridFlowLayout alloc] init];
            break;
        case PFPhotosViewLayoutBanner:
            layout = [[PFPhotosBannerFlowLayout alloc] init];
            [self.view layoutIfNeeded];
            layout.itemSize = CGSizeMake(self.collectionView.bounds.size.width - layout.sectionInset.left - layout.sectionInset.right, layout.itemSize.height);
            break;
        default: break;
    }
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_medium_texture.png"]];
    self.collectionView.contentOffset = CGPointZero;
    
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(0, -44.0, self.collectionView.bounds.size.width, 44.0)];
    self.refreshControl.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.refreshControl.tintColor = [UIColor colorWithWhite:54.0/255.0 alpha:1.0];
    [self.collectionView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(pulledToRefresh:) forControlEvents:UIControlEventValueChanged];
    
    [self setToggleButtonCustomViewOppositeOfLayout:self.collectionView.collectionViewLayout];
    if (landscape) self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsLandscapePhone];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? 20.0 : 25.0], UITextAttributeTextColor : [UIColor colorWithRed:206.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 2.0)], UITextAttributeTextShadowColor : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:0.0 forBarMetrics:UIBarMetricsLandscapePhone];
    self.cameraButton.customView.frame = CGRectMake(0, 0, self.cameraButton.customView.frame.size.width, self.navigationController.toolbar.frame.size.height); // Fixing weird bug that would result in camera button growing in height past the toolbar edge. The way to replicate was switch to banner mode, then rotate horizontal (but this VC won't rotate in banner mode), then push a photo viewer, then rotate a couple times to get the photo viewer truly in horizontal, then come back to this VC.
    UIButton * cameraButtonCustomView = (UIButton *)self.cameraButton.customView;
    [cameraButtonCustomView setImage:[UIImage imageNamed:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? @"btn_camera_landscape.png" : @"btn_camera.png"] forState:UIControlStateNormal];
    [cameraButtonCustomView setImage:[UIImage imageNamed:UIInterfaceOrientationIsLandscape(self.interfaceOrientation) ? @"btn_camera_highlight_landscape.png" : @"btn_camera_highlight.png"] forState:UIControlStateHighlighted];
    self.photos = [self.event.photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.navigationController.toolbar.bounds.size.height, 0.0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, self.navigationController.toolbar.bounds.size.height, 0.0);
    if (self.event.dateReload == nil ||
        ([DefaultsManager getAppDidEnterBackgroundSinceEventReload] &&
         abs([self.event.dateReload timeIntervalSinceNow]) > 60 * 30)) {
            [self reloadRecentPhotos];
        }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell * cell = nil;
    
    if (indexPath.row == self.photos.count) {
        PFLoadMoreCell * loadMoreCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LoadMoreCell" forIndexPath:indexPath];
        loadMoreCell.button.hidden = self.isLoadingOld || self.willLoadOld;
        if (self.isLoadingOld || self.willLoadOld) {
            if (!loadMoreCell.activityView.isAnimating) [loadMoreCell.activityView startAnimating];
        } else {
            if (loadMoreCell.activityView.isAnimating) [loadMoreCell.activityView stopAnimating];
        }
        cell = loadMoreCell;
    } else {
        PFPhotoCell * photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
        PFPhoto * photo = [self.photos objectAtIndex:indexPath.row];
        [self loadImageForPhotoCell:photoCell atIndexPath:indexPath fromPhoto:photo];
        cell = photoCell;
    }
    
    return cell;
    
}

- (void) loadImageForPhotoCell:(PFPhotoCell *)cell atIndexPath:(NSIndexPath *)indexPath fromPhoto:(PFPhoto *)photo {
//        NSLog(@"about to setImageWithURL...");
//        [photoCell.imageView setImageWithURL:[NSURL URLWithString:[[PFHTTPClient sharedClient] imageURLStringForPhoto:photo.eid boundingWidth:[UIScreen mainScreen].bounds.size.width*2 boundingHeight:2000 quality:70]] placeholderImage:nil]; // The size here is dependent on the fact that banner mode (where images must be largest) only operates when device orientation is portrait. // I think this method is hurting performance. We are going to change and just get the size that fits the current orientation.
    PFPhotosGridFlowLayout * layout = (PFPhotosGridFlowLayout *)self.collectionView.collectionViewLayout;
    CGFloat boundingWidth = [layout isKindOfClass:[PFPhotosGridFlowLayout class]] ? (int)floorf(layout.itemSize.height * 3.0 / 2.0 * 2.0) : layout.itemSize.width * 2.0;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[[PFHTTPClient sharedClient] imageURLStringForPhoto:photo.eid boundingWidth:boundingWidth boundingHeight:2000 quality:60]] placeholderImage:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewPhoto"]) {
        PFPhotoContainerViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
        viewController.delegate = self;
        [viewController setPhotoIndex:[self.collectionView indexPathForCell:sender].row inPhotos:self.photos forEvent:self.event];
    } else if ([segue.identifier isEqualToString:@"ShowCamera"]) {
        PFCameraViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
        viewController.event = self.event;
        viewController.delegate = self;
    }
}

- (void)cameraViewController:(PFCameraViewController *)viewController finishedWithPhotoSubmitted:(PFPhoto *)photoSubmitted {
//    self.photos = [@[photoSubmitted] arrayByAddingObjectsFromArray:self.photos]; // This will happen automatically in viewWillAppear
//    [self.collectionView reloadData]; // This will happen automatically in viewWillAppear
    [self dismissViewControllerAnimated:NO completion:NULL];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
//    [self reloadRecentPhotos]; // This is dumb... It's only necessary because if we just added the one new photo, then the next load more recent photos request would be looking for photos more recent than that new added one, and it might miss some photos that came before that new added one, but after the previous most recent photo (now the second most recent). If this fails, we're still going to have this trouble. We need to start using an attribute on the event object rather than just using the top photo view in this VC. // Not doing this here anymore because pull to refresh has been changed to a full recent reload rather than a "load more recent".
}

- (void)toggleViewModeButtonTouched:(UIBarButtonItem *)button {
    PFPhotosViewLayoutType layoutTypeNew = PFPhotosViewLayoutNone;
    UICollectionViewLayout * layoutOld = self.collectionView.collectionViewLayout;
    UICollectionViewFlowLayout * layoutNew = nil;
    if ([layoutOld isKindOfClass:[PFPhotosGridFlowLayout class]]) {
        layoutNew = [[PFPhotosBannerFlowLayout alloc] init];
        layoutNew.itemSize = CGSizeMake(self.collectionView.bounds.size.width - layoutNew.sectionInset.left - layoutNew.sectionInset.right, layoutNew.itemSize.height);
        layoutTypeNew = PFPhotosViewLayoutBanner;
    } else {
        layoutNew = [[PFPhotosGridFlowLayout alloc] init];
        layoutTypeNew = PFPhotosViewLayoutGrid;
    }
    [DefaultsManager setPhotosViewLayoutPreference:layoutTypeNew];
    [self.collectionView setCollectionViewLayout:layoutNew animated:YES];
//    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [self setToggleButtonCustomViewOppositeOfLayout:self.collectionView.collectionViewLayout];
    if (layoutTypeNew == PFPhotosViewLayoutBanner) {
        for (PFPhotoCell * cell in self.collectionView.visibleCells) {
            NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
            if (indexPath.row != self.photos.count) {
                PFPhoto * photo = [self.photos objectAtIndex:indexPath.row];
                [self loadImageForPhotoCell:cell atIndexPath:indexPath fromPhoto:photo];
            }
        }
    }
}

//- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    UICollectionViewFlowLayout * layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
//    if ([self.collectionView.collectionViewLayout isKindOfClass:[PFPhotosBannerFlowLayout class]]) {
//        layout.itemSize = CGSizeMake(layout.itemSize.height, layout.itemSize.width);
//        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    }
//}

- (NSUInteger)supportedInterfaceOrientations {
    return [self.collectionView.collectionViewLayout isKindOfClass:[PFPhotosBannerFlowLayout class]] ? UIInterfaceOrientationMaskPortrait : UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.navigationItem setRightBarButtonItem:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? nil : self.toggleViewModeButton animated:YES];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? 20.0 : 25.0], UITextAttributeTextColor : [UIColor colorWithRed:206.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 2.0)], UITextAttributeTextShadowColor : [UIColor whiteColor]};
    UIButton * cameraButtonCustomView = (UIButton *)self.cameraButton.customView;
    [cameraButtonCustomView setImage:[UIImage imageNamed:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? @"btn_camera_landscape.png" : @"btn_camera.png"] forState:UIControlStateNormal];
    [cameraButtonCustomView setImage:[UIImage imageNamed:UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ? @"btn_camera_highlight_landscape.png" : @"btn_camera_highlight.png"] forState:UIControlStateHighlighted];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.navigationController.toolbar.bounds.size.height, 0.0);
    self.collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, self.navigationController.toolbar.bounds.size.height, 0.0);
}

- (void)backButtonTouched:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setToggleButtonCustomViewOppositeOfLayout:(UICollectionViewLayout *)layout {
    NSString * toggleImageNameNormal = [NSString stringWithFormat:@"btn_photos_mode_%@.png", [layout isKindOfClass:[PFPhotosGridFlowLayout class]] ? @"banner" : @"grid"];
    UIImage * toggleImage = [UIImage imageNamed:toggleImageNameNormal];
    UIImage * toggleImageHighlight = [UIImage imageNamed:[toggleImageNameNormal stringByReplacingOccurrencesOfString:@".png" withString:@"_highlight.png"]];
    UIButton * customView = (UIButton *)self.toggleViewModeButton.customView;
    if (customView == nil) {
        customView = [UIButton buttonWithType:UIButtonTypeCustom];
        customView.frame = CGRectMake(0, 0, toggleImage.size.width + 15 /* COULD HAVE ALSO DONE THIS WITH A FIXED SPACE UIBARBUTTONITEM */, toggleImage.size.height);
        [customView addTarget:self.toggleViewModeButton.target action:self.toggleViewModeButton.action forControlEvents:UIControlEventTouchUpInside];
        self.toggleViewModeButton.customView = customView;
    }
    [customView setImage:toggleImage forState:UIControlStateNormal];
    [customView setImage:toggleImageHighlight forState:UIControlStateHighlighted];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        if (scrollView.contentSize.height > scrollView.bounds.size.height) {
            if (scrollView.contentOffset.y + scrollView.bounds.size.height > scrollView.contentSize.height + scrollView.contentInset.bottom &&
                (!(self.isLoadingRecent || self.isLoadingOld || self.willLoadOld))) {
                self.willLoadOld = YES;
                [self updateLoadMoreCell];
            } else {
                if (self.willLoadOld &&
                    scrollView.isDragging &&
                    scrollView.contentOffset.y + scrollView.bounds.size.height < scrollView.contentSize.height + scrollView.contentInset.bottom) {
                    self.willLoadOld = NO;
                    [self updateLoadMoreCell];
                }
            }
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView == self.collectionView) {
        if (self.willLoadOld) {
            self.willLoadOld = NO;
            [self loadMoreOldPhotos];
        }
    }
}

- (void)loadOlderPhotosButtonTouched:(UIButton *)button {
    [self loadMoreOldPhotos];
}

- (void)updateLoadMoreCell {
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.photos.count inSection:0]]];
}

- (void)pulledToRefresh:(UIRefreshControl *)refreshControl {
    [self reloadRecentPhotos];
//    [self loadMoreRecentPhotos];
}

- (void)reloadRecentPhotos {
    if (!(self.isLoadingRecent || self.isLoadingOld || self.willLoadOld)) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        self.isLoadingRecent = YES;
        [self.refreshControl beginRefreshing];
        [self loadMorePhotosAfter:nil before:nil limit:@(LOAD_PHOTOS_COUNT_RELOAD) successBlockPre:^(AFHTTPRequestOperation *operation, id responseObject) {
            self.event.dateReload = [NSDate date];
            [DefaultsManager setAppDidEnterBackgroundSinceEventReload:NO];
            [self.moc deleteAllObjectsForEntityName:@"PFPhoto" matchingPredicate:[NSPredicate predicateWithFormat:@"event == %@", self.event]];
        } successBlockPost:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self.collectionView setContentOffset:CGPointZero animated:NO];
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }];
    }
}

//- (void)loadMoreRecentPhotos {
//    if (!(self.isLoadingRecent || self.isLoadingOld || self.willLoadOld)) {
//        NSLog(@"%@", NSStringFromSelector(_cmd));
//        self.isLoadingRecent = YES;
//        [self.refreshControl beginRefreshing];
//        [self loadMorePhotosAfter:((PFPhoto *)[self.photos objectAtIndex:0]).updatedAt before:nil limit:nil successBlockPre:NULL successBlockPost:^(AFHTTPRequestOperation *operation, id responseObject) {
//            //[self.collectionView setContentOffset:CGPointZero animated:YES];
//        }];
//    }
//}

- (void)loadMoreOldPhotos {
    if (!(self.isLoadingRecent || self.isLoadingOld || self.willLoadOld)) {
        NSLog(@"%@", NSStringFromSelector(_cmd));
        int countBefore = self.photos.count;
        self.isLoadingOld = YES;
        [self updateLoadMoreCell];
        [self loadMorePhotosAfter:nil before:((PFPhoto *)self.photos.lastObject).updatedAt limit:@(LOAD_PHOTOS_COUNT_MORE_OLD) successBlockPre:NULL successBlockPost:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSArray * photos = responseObject[@"photos"];
            NSMutableArray * indexPaths = [NSMutableArray array];
            int i = countBefore;
            for (NSDictionary * photo in photos) {
                [indexPaths addObject:[NSIndexPath indexPathForItem:i++ inSection:0]];
            }
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:indexPaths];
            } completion:NULL];
        }];
    }
}

- (void)loadMorePhotosAfter:(NSDate *)afterDate before:(NSDate *)beforeDate limit:(NSNumber *)limit successBlockPre:(PFCSuccessBlock)successBlockPre successBlockPost:(PFCSuccessBlock)successBlockPost {
    void(^sharedBlockPost)(void) = ^{
        self.isLoadingRecent = NO;
        self.isLoadingOld = NO;
        self.willLoadOld = NO;
        [self.refreshControl endRefreshing];
        [self updateLoadMoreCell];
        
    };
    [[PFHTTPClient sharedClient] getPhotosForEvent:self.event.eid limit:limit updatedAfter:afterDate updatedBefore:beforeDate successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (successBlockPre != NULL) successBlockPre(operation, responseObject);
        [self.moc addPhotosFromAPI:responseObject[@"photos"] toEvent:self.event];
        [self.moc saveCoreData];
        self.photos = [self.event.photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO]]];
        if (successBlockPost != NULL) successBlockPost(operation, responseObject);
        sharedBlockPost();
    } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
        [[UIAlertView connectionErrorAlertView] show];
        sharedBlockPost();
    }];
}

- (void)photoContainerViewControllerDidRequestRefresh:(PFPhotoContainerViewController *)viewController {
    PFPhotoContainerViewController * viewControllerRefreshed = [self.storyboard instantiateViewControllerWithIdentifier:@"PFPhotoContainerViewController"];
    viewControllerRefreshed.moc = viewController.moc;
    viewControllerRefreshed.delegate = self;
    [viewControllerRefreshed setPhotoIndex:viewController.photoIndex inPhotos:viewController.photos forEvent:viewController.event];
    [self.navigationController popViewControllerAnimated:NO];
    [self.navigationController pushViewController:viewControllerRefreshed animated:NO];
}

@end
