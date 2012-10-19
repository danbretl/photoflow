//
//  PFPhotosCollectionView.h
//  PhotoFlow
//
//  Created by Dan Bretl on 10/18/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PFLoadMoreView.h"

@interface PFPhotosCollectionView : UICollectionView

@property (nonatomic, strong) PFLoadMoreView * loadMoreView;
@property (nonatomic) CGFloat loadMoreViewPaddingBottom;
@property (nonatomic, readonly) CGSize contentSizeProper;

@end
