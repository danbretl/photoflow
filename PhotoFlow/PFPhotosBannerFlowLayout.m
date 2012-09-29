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
        self.itemSize = CGSizeMake(320, 135);
        self.minimumLineSpacing = 10;
    }
    return self;
}

@end
