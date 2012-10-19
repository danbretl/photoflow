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

/* THE FOLLOWING CONDITIONAL / VISIBILITY CODE WAS TOTALLY THE RIGHT IDEA FOR WHAT I WAS TRYING TO DO, AND WAS TOTALLY WORKING, BUT IT'S NOT REALLY THE RIGHT LOGIC. VISIBILITY OF THE LOAD MORE BUTTON SHOULD NOT BE DETERMINED BASED ON CONTENT SIZE. */
- (void)setContentSize:(CGSize)contentSize {
//    NSLog(@"%@:%@", NSStringFromSelector(_cmd), NSStringFromCGSize(contentSize));
//    if (contentSize.height > self.bounds.size.height - (self.contentInset.top + self.contentInset.bottom)) {
        contentSize.height += 44.0 + self.loadMoreViewPaddingBottom;
//        self.loadMoreView.hidden = NO;
//    } else {
//        self.loadMoreView.hidden = YES;
//    }
    [super setContentSize:contentSize];
    self.loadMoreView.frame = CGRectMake(0, contentSize.height - (44.0 + self.loadMoreViewPaddingBottom), contentSize.width, 44.0);
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
