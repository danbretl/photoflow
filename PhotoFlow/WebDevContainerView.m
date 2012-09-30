//
//  WebDevContainerView.m
//  Emotish
//
//  Created by Dan Bretl on 9/29/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "WebDevContainerView.h"
#import <QuartzCore/QuartzCore.h>

@interface WebDevContainerView()
- (void) initWithFrameOrCoder;
@end

@implementation WebDevContainerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initWithFrameOrCoder];
    }
    return self;    
}

- (void) initWithFrameOrCoder {
    self.layer.cornerRadius = 5.0;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
    self.clipsToBounds = YES;
}

@end
