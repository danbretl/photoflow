//
//  PFEventsViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSManagedObjectContext+PhotoFlow.h"
#import "WebDevViewController.h"

@interface PFEventsViewController : UITableViewController<WebDevViewControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;
@property (nonatomic, strong) NSArray * events;

@property (nonatomic, strong) UIBarButtonItem * addEventButton;
- (IBAction)addEventButtonTouched:(id)sender;

- (IBAction)devButtonTouched:(UIBarButtonItem *)devButton;

@end
