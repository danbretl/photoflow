//
//  PFPhotosViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSManagedObjectContext+PhotoFlow.h"
#import "PFEvent.h"
#import "PFPhotosViewConstants.h"

@interface PFPhotosViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) PFEvent * event;

@property (nonatomic, strong) IBOutlet UICollectionView * collectionView;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * toggleViewModeButton;
- (IBAction)toggleViewModeButtonTouched:(UIBarButtonItem *)button;

@property (nonatomic, strong) IBOutlet UIBarButtonItem * cameraButton;
- (IBAction)cameraButtonTouched:(id)sender;

@end
