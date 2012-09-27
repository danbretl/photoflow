//
//  PFJoinEventViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PFJoinEventViewControllerDelegate;

@interface PFJoinEventViewController : UIViewController

- (IBAction)cancelButtonTouched:(UIBarButtonItem *)button;

@property (weak, nonatomic) id<PFJoinEventViewControllerDelegate> delegate;

@end

@protocol PFJoinEventViewControllerDelegate <NSObject>

- (void) joinEventViewControllerCancelled:(PFJoinEventViewController *)viewController;

@end