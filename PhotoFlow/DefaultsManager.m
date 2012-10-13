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
    [[NSUserDefaults standardUserDefaults] setInteger:layoutType forKey:@"DM_PhotosViewLayout"];
}
+ (PFPhotosViewLayoutType)getPhotosViewLayoutPreference {
    NSNumber * object = [[NSUserDefaults standardUserDefaults] objectForKey:@"DM_PhotosViewLayout"];
    PFPhotosViewLayoutType value = object == nil ? PFPhotosViewLayoutGrid : object.integerValue;
    return value;
}

+ (void) setCameraPositionPreference:(AVCaptureDevicePosition)positionPreference {
    [[NSUserDefaults standardUserDefaults] setInteger:positionPreference forKey:@"DM_CameraPosition"];
}
+ (AVCaptureDevicePosition) getCameraPositionPreference {
    NSNumber * object = [[NSUserDefaults standardUserDefaults] objectForKey:@"DM_CameraPosition"];
    AVCaptureDevicePosition value = object == nil ? AVCaptureDevicePositionBack : object.integerValue;
    return value;
}

+ (void) setCameraFlashPreference:(AVCaptureFlashMode)flashPreference {
    [[NSUserDefaults standardUserDefaults] setInteger:flashPreference forKey:@"DM_CameraFlash"];
}
+ (AVCaptureFlashMode) getCameraFlashPreference {
    NSNumber * object = [[NSUserDefaults standardUserDefaults] objectForKey:@"DM_CameraFlash"];
    AVCaptureFlashMode value = object == nil ? AVCaptureFlashModeAuto : object.integerValue;
    return value;
}

+ (void)setAppDidEnterBackgroundSinceEventReload:(BOOL)didEnterBackground {
    [[NSUserDefaults standardUserDefaults] setBool:didEnterBackground forKey:@"DM_AppDidEnterBGSinceEventReload"];
}
+ (BOOL)getAppDidEnterBackgroundSinceEventReload {
    NSNumber * object = [[NSUserDefaults standardUserDefaults] objectForKey:@"DM_AppDidEnterBGSinceEventReload"];
    BOOL value = object == nil ? YES : object.boolValue;
    return value;
}

@end
