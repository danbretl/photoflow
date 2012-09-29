//
//  DefaultsManager.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "DefaultsManager.h"

@implementation DefaultsManager

+ (void)setPhotosViewLayoutPreference:(PFPhotosViewLayoutType)layoutType {
    [[NSUserDefaults standardUserDefaults] setInteger:layoutType forKey:@"PhotosViewLayoutPreference"];
}
+ (PFPhotosViewLayoutType)getPhotosViewLayoutPreference {
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"PhotosViewLayoutPreference"];
}



@end
