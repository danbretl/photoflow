//
//  PFPhotoCell.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFPhotoCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView * shadowView;
@property (strong, nonatomic) IBOutlet UIImageView * imageView;
@property (strong, nonatomic) IBOutlet UIView * imageViewContainer;

@end
