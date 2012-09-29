//
//  PFPhotoContainerViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/28/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFPhotoContainerViewController : UIViewController <UIPageViewControllerDelegate, UIPageViewControllerDataSource>

- (void) setPhotoIndex:(NSUInteger)photoIndex inPhotos:(NSArray *)photos;

@end
