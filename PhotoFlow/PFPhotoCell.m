//
//  PFPhotoCell.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/27/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFPhotoCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PFPhotoCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
//    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_medium_texture.png"]];
    
    self.shadowView.image = [[UIImage imageNamed:@"shadow_events_and_grid.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)];
    
    self.imageViewContainer.layer.cornerRadius = 2.0;
    self.imageViewContainer.layer.masksToBounds = YES;
    
}

@end
