//
//  PFJoinEventViewController.h
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSManagedObjectContext+PhotoFlow.h"

@interface PFJoinEventViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) NSManagedObjectContext * moc;

@property (nonatomic, strong) IBOutlet UIImageView * cardBackgroundView;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint * cardContainerViewBottomSpace;
@property (nonatomic, strong) IBOutlet UIImageView * welcomeImageView;
@property (nonatomic, strong) IBOutlet UILabel * promptLabel;
@property (nonatomic, strong) IBOutlet UITextField * codeTextField;
@property (nonatomic, strong) IBOutlet UIImageView * codeTextFieldBackgroundView;
@property (nonatomic, strong) IBOutlet UIButton * cancelButton;
@property (nonatomic, strong) IBOutlet UIButton * goButton;
@property (nonatomic, strong) IBOutlet UIImageView * photoflowImageView;

//- (IBAction)cancelButtonTouched:(UIButton *)button;
//- (IBAction)goButtonTouched:(UIButton *)button;

@end