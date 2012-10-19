//
//  PFEventCell.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PFEventCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView * shadowView;
@property (strong, nonatomic) IBOutlet UIView * containerView;
@property (strong, nonatomic) IBOutlet UILabel * dateLabel;
@property (strong, nonatomic) IBOutlet UILabel * locationLabel;
@property (strong, nonatomic) IBOutlet UILabel * descriptionLabel;
@property (strong, nonatomic) IBOutlet UIImageView * bannerImageView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint * shadowTrailingSpace;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint * containerTrailingSpace;

@end
