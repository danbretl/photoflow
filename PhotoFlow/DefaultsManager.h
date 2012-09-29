//
//  DefaultsManager.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PFPhotosViewConstants.h"

@interface DefaultsManager : NSObject

+ (void) setPhotosViewLayoutPreference:(PFPhotosViewLayoutType)layoutType;
+ (PFPhotosViewLayoutType) getPhotosViewLayoutPreference;

@end
