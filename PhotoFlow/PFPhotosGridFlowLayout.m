//
//  PFPhotosGridFlowLayout.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotosGridFlowLayout.h"

@implementation PFPhotosGridFlowLayout

- (id)init {
    if (self = [super init]) {
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
        self.itemSize = CGSizeMake(100, 100);
        self.minimumInteritemSpacing = 10;
        self.minimumLineSpacing = 10;
    }
    return self;
}

@end
