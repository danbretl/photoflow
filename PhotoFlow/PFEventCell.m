//
//  PFEventCell.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFEventCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PFEventCell()
@property (strong, nonatomic) IBOutlet UIImageView * descriptionLabelBackgroundView;
@end

@implementation PFEventCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.shadowView.image = [[UIImage imageNamed:@"shadow_events_and_grid.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)];
    
    self.containerView.layer.cornerRadius = 2.0;
    self.containerView.layer.masksToBounds = YES;
//    self.containerView.layer.shadowColor = [UIColor colorWithWhite:28.0/255.0 alpha:1.0].CGColor;
//    self.containerView.layer.shadowOpacity = 0.4;
//    self.containerView.layer.shadowOffset = CGSizeMake(0.0, 0.0);
//    self.containerView.layer.shadowRadius = 4.0;
//    self.containerView.layer.shouldRasterize = YES;
    
    [self.descriptionLabelBackgroundView setImage:[[UIImage imageNamed:@"event_cell_title_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(1.0, 0, 0, 0)]];
    
    UIFont * dateLocationFont    = [UIFont fontWithName:@"Miso" size:20.0];
    self.dateLabel.font          = dateLocationFont;
    self.locationLabel.font      = dateLocationFont;

    UIColor * dateLocationColor  = [UIColor colorWithWhite:176.0/255.0 alpha:1.0];
    self.dateLabel.textColor     = dateLocationColor;
    self.locationLabel.textColor = dateLocationColor;
    
    self.descriptionLabel.font = [UIFont fontWithName:@"HabanoST" size:25.0];
    self.descriptionLabel.textColor = [UIColor colorWithRed:211.0/255.0 green:80.0/255.0 blue:63.0/255.0 alpha:1.0];// [UIColor colorWithRed:227.0/255.0 green:93.0/255.0 blue:97.0/255.0 alpha:1.0];
    self.descriptionLabel.shadowColor = [UIColor whiteColor];
    self.descriptionLabel.shadowOffset = CGSizeMake(0, 2.0);
    
    /* Need to create our own constraint which is effective against the contentView, so the UI elements indent when the cell is put into editing mode */
    // Remove the IB added horizontal constraint, as that's effective against the cell not the contentView
    [self removeConstraint:self.shadowTrailingSpace];
    [self removeConstraint:self.containerTrailingSpace];
    // Create and add the new constraints
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.shadowView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-self.shadowTrailingSpace.constant]];
    [self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeTrailing multiplier:1.0 constant:-self.containerTrailingSpace.constant]];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
