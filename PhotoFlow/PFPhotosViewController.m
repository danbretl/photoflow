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
    
    self.photos = [self.event.photos sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"imageLocation" ascending:YES]]];
    [self.collectionView reloadData];
    
    PFPhotosViewLayoutType layoutType = PFPhotosViewLayoutGrid;
    PFPhotosViewLayoutType layoutTypePreference = [DefaultsManager getPhotosViewLayoutPreference];
    if (layoutTypePreference != PFPhotosViewLayoutNone) layoutType = layoutTypePreference;
    UICollectionViewLayout * layout = nil;
    switch (layoutType) {
        case PFPhotosViewLayoutGrid:   layout = [[PFPhotosGridFlowLayout alloc] init]; break;
        case PFPhotosViewLayoutBanner: layout = [[PFPhotosBannerFlowLayout alloc] init]; break;
        default: break;
    }
    self.collectionView.collectionViewLayout = layout;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
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
        [viewController setPhotoIndex:[self.collectionView indexPathForCell:sender].row inPhotos:self.photos];
    }
}

- (void)toggleViewModeButtonTouched:(UIBarButtonItem *)button {
    PFPhotosViewLayoutType layoutTypeNew = PFPhotosViewLayoutNone;
    UICollectionViewLayout * layoutOld = self.collectionView.collectionViewLayout;
    UICollectionViewLayout * layoutNew = nil;
    if ([layoutOld isKindOfClass:[PFPhotosGridFlowLayout class]]) {
        layoutNew = [[PFPhotosBannerFlowLayout alloc] init];
        layoutTypeNew = PFPhotosViewLayoutBanner;
    } else {
        layoutNew = [[PFPhotosGridFlowLayout alloc] init];
        layoutTypeNew = PFPhotosViewLayoutGrid;
    }
    [DefaultsManager setPhotosViewLayoutPreference:layoutTypeNew];
    [self.collectionView setCollectionViewLayout:layoutNew animated:YES];
    [self.collectionView setContentOffset:CGPointZero animated:NO];
}

@end
