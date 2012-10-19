//
//  PFPhotosCollectionView.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/18/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotosCollectionView.h"

@implementation PFPhotosCollectionView

- (void)awakeFromNib {
    self.loadMoreView = [[PFLoadMoreView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 44.0)];
    self.loadMoreView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.loadMoreView];
}

- (void)setContentSize:(CGSize)contentSize {
    if (!self.loadMoreView.hidden) {
        contentSize.height += 44.0 + self.loadMoreViewPaddingBottom;
    }
    [super setContentSize:contentSize];
    if (!self.loadMoreView.hidden) {
        self.loadMoreView.frame = CGRectMake(0, contentSize.height - (44.0 + self.loadMoreViewPaddingBottom), contentSize.width, 44.0);
    }
}

- (CGSize)contentSizeProper {
    CGSize contentSize = self.contentSize;
    if (!self.loadMoreView.hidden) contentSize.height -= (44.0 + self.loadMoreViewPaddingBottom);
    return contentSize;
}

// I think the following wasn't working because the refresh control was doing something weird to contentInset... Maybe not. In any case, this doesn't really make that much sense anyway. The load more view is a first class citizen view. It is part of the content. Thus, it should be part of the contentSize.
//- (void) setContentInset:(UIEdgeInsets)contentInset {
//    NSLog(@"%@:%@", NSStringFromSelector(_cmd), NSStringFromUIEdgeInsets(contentInset));
//    contentInset.bottom += self.loadMoreView.bounds.size.height + self.loadMoreViewPaddingBottom;
//    NSLog(@"%@:%@", NSStringFromSelector(_cmd), NSStringFromUIEdgeInsets(contentInset));
//    [super setContentInset:contentInset];
//}

@end
