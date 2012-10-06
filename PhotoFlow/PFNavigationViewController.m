//
//  PFNavigationViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/6/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFNavigationViewController.h"

@interface PFNavigationViewController ()

@end

@implementation PFNavigationViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    if ([self.topViewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
        return self.topViewController.supportedInterfaceOrientations;
    } else {
        return [super supportedInterfaceOrientations];
    }
}

@end
