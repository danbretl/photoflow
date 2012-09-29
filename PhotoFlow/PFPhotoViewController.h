//
//  PFPhotoViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFPhoto.h"

@interface PFPhotoViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, strong) IBOutlet UIScrollView * scrollView;
@property (nonatomic, strong) IBOutlet UIImageView * imageView;

@property (nonatomic, strong) PFPhoto * photo;

@end
