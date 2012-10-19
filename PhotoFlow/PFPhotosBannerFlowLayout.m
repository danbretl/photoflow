//
//  PFPhotosBannerFlowLayout.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotosBannerFlowLayout.h"

@implementation PFPhotosBannerFlowLayout

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = CGSizeMake(308.0, 135.0);
        self.minimumInteritemSpacing = 0.0;
        self.minimumLineSpacing = 0.0;
        self.sectionInset = UIEdgeInsetsMake(3.0, 6.0, 2.0, 6.0);
    }
    return self;
}

@end
