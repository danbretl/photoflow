//
//  PFEventsViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFJoinEventViewController.h"
#import "NSManagedObjectContext+PhotoFlow.h"

@interface PFEventsViewController : UITableViewController<PFJoinEventViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) NSArray * events;

@end
