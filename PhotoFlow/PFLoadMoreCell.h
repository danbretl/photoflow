//
//  PFLoadMoreCell.h
//  PhotoFlow
//
//  Created by Dan Bretl on 10/12/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFLoadMoreCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UIButton * button;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * activityView;

@end
