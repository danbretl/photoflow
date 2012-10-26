//
//  UIAlertView+PhotoFlow.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/16/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "UIAlertView+PhotoFlow.h"

@implementation UIAlertView (PhotoFlow)

+ (UIAlertView *)connectionErrorAlertView {
    return [[UIAlertView alloc] initWithTitle:@"Connection Error" message:@"We had some trouble connecting to Photoflow. Check your network settings and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
}

@end
