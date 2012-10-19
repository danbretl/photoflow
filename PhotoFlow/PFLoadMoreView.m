//
//  PFLoadMoreCell.m
//  PhotoFlow
//
//  Created by Dan Bretl on 10/12/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFLoadMoreView.h"

@implementation PFLoadMoreView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage * loadOlderPhotosButtonImage = [UIImage imageNamed:@"btn_load_more.png"];
        UIImage * loadOlderPhotosButtonImageHighlight = [UIImage imageNamed:@"btn_load_more_highlight.png"];
        self.button.frame = self.bounds;
        self.button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        self.button.contentMode = UIViewContentModeCenter;
        [self.button setImage:loadOlderPhotosButtonImage forState:UIControlStateNormal];
        [self.button setImage:loadOlderPhotosButtonImageHighlight forState:UIControlStateHighlighted];
        [self addSubview:self.button];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        self.activityView.center = self.center;
        self.activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin;
        self.activityView.color = [UIColor colorWithWhite:54.0/255.0 alpha:1.0];
        self.activityView.hidesWhenStopped = YES;
        [self addSubview:self.activityView];
        
    }
    return self;
}

@end
