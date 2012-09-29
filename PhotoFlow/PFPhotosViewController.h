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

@interface PFPhotosViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) PFEvent * event;

- (IBAction)toggleViewModeButtonTouched:(UIBarButtonItem *)button;

@end
