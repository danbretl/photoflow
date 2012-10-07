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
#import "PFPhotoContainerViewController.h"

@interface PFPhotosViewController ()
@property (nonatomic, strong) NSArray * photos;
- (void) backButtonTouched:(id)sender;
- (void) setToggleButtonCustomViewOppositeOfLayout:(UICollectionViewLayout *)layout;
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
    
    UIImage * cameraButtonImage = [UIImage imageNamed:@"btn_camera.png"];
    UIImage * cameraButtonImageHighlight = [UIImage imageNamed:@"btn_camera_highlight.png"];
    UIButton * cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraButton.frame = CGRectMake(0, 0, 102.0, UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 32.0 : 44.0); // HARD CODED, VERY BAD HACK.
    cameraButton.contentMode = UIViewContentModeCenter;
    [cameraButton setBackgroundImage:[[UIImage imageNamed:@"btn_camera_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.0, 0, 1.0)] forState:UIControlStateNormal];
    [cameraButton setBackgroundImage:[[UIImage imageNamed:@"btn_camera_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1.0, 0, 1.0)] forState:UIControlStateHighlighted];
    [cameraButton setImage:cameraButtonImage forState:UIControlStateNormal];
    [cameraButton setImage:cameraButtonImageHighlight forState:UIControlStateHighlighted];
    [cameraButton addTarget:self.cameraButton.target action:self.cameraButton.action forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setCustomView:cameraButton];
    
    self.photos = [self.event.photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"imageLocation" ascending:YES]]];
    [self.collectionView reloadData];
    
    PFPhotosViewLayoutType layoutType = PFPhotosViewLayoutGrid;
    PFPhotosViewLayoutType layoutTypePreference = [DefaultsManager getPhotosViewLayoutPreference];
    if (layoutTypePreference != PFPhotosViewLayoutNone) layoutType = layoutTypePreference;
    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) layoutType = PFPhotosViewLayoutGrid;
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
    
    [self setToggleButtonCustomViewOppositeOfLayout:self.collectionView.collectionViewLayout];
    if (UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation)) self.navigationItem.rightBarButtonItem = nil;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsLandscapePhone];
    self.navigationController.navigationBar.titleTextAttributes = @{UITextAttributeFont : [UIFont fontWithName:@"HabanoST" size:UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 20.0 : 25.0], UITextAttributeTextColor : [UIColor colorWithRed:206.0/255.0 green:201.0/255.0 blue:201.0/255.0 alpha:1.0], UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0, 2.0)], UITextAttributeTextShadowColor : [UIColor whiteColor]};
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setTitleVerticalPositionAdjustment:2.0 forBarMetrics:UIBarMetricsLandscapePhone];
    CGRect cameraButtonFrame = self.cameraButton.customView.frame;
    cameraButtonFrame.size.height = UIInterfaceOrientationIsLandscape([UIDevice currentDevice].orientation) ? 32.0 : 44.0; // HARD CODED, VERY BAD HACK.
    self.cameraButton.customView.frame = cameraButtonFrame;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.toolbar.bounds.size.height, 0.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    PFPhotoCell * photoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    
    PFPhoto * photo = [self.photos objectAtIndex:indexPath.row];
    [photoCell.imageView setImageWithURL:[NSURL URLWithString:photo.imageLocation] placeholderImage:nil];
    
    return photoCell;
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ViewPhoto"]) {
        PFPhotoContainerViewController * viewController = segue.destinationViewController;
        [viewController setPhotoIndex:[self.collectionView indexPathForCell:sender].row inPhotos:self.photos forEvent:self.event];
    }
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
    [self.collectionView setContentOffset:CGPointZero animated:NO];
    [self setToggleButtonCustomViewOppositeOfLayout:self.collectionView.collectionViewLayout];
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
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.collectionView.contentInset = UIEdgeInsetsMake(0.0, 0.0, self.toolbar.bounds.size.height, 0.0);
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

- (void)cameraButtonTouched:(id)sender {
    
}

@end
