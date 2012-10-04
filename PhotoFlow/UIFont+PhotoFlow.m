//
//  UIFont+PhotoFlow.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/3/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "UIFont+PhotoFlow.h"

@implementation UIFont (PhotoFlow)

+ (void) logAvailableFonts {
    NSLog(@"Logging available fonts:");
    NSArray * familyNames = [self familyNames];
    for (NSString * familyName in familyNames) {
        NSLog(@"  Family: %@", familyName);
        NSArray * fontNames = [self fontNamesForFamilyName:familyName];
        for (NSString * fontName in fontNames) {
            NSLog(@"    Font: %@", fontName);
        }
    }
}

@end
