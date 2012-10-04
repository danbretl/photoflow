//
//  PFJoinEventViewController.m
//  PhotoFlow
//
//  Created by Dan Bretl on 9/25/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "PFJoinEventViewController.h"
#import "PFEventsViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface PFJoinEventViewController ()

@end

@implementation PFJoinEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage * titleImage = [UIImage imageNamed:@"branding_text.png"];
    UIImageView * titleImageView = [[UIImageView alloc] initWithImage:titleImage];
    titleImageView.frame = CGRectMake(0, 3, titleImage.size.width, titleImage.size.height + 3);
    titleImageView.contentMode = UIViewContentModeBottom;
    [self.navigationItem setTitleView:titleImageView];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_medium_texture.png"]];
    
    self.cardBackgroundView.image = [[UIImage imageNamed:@"invite_card_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0, 25.0, 25.0, 25.0)];

    self.photoflowImageView.image = [UIImage imageNamed:@"branding_text.png"];

    self.promptLabel.font = [UIFont fontWithName:@"Miso" size:21.0];
    self.promptLabel.textColor = [UIColor colorWithWhite:54.0/255.0 alpha:1.0];
    self.promptLabel.shadowColor = [UIColor whiteColor];
    self.promptLabel.shadowOffset = CGSizeMake(0.0, 2.0);
    [self.promptLabel sizeToFit];
    
    // text field
    self.codeTextField.font = [UIFont fontWithName:@"Miso" size:25.0];
    self.codeTextField.textColor = [UIColor colorWithWhite:253.0/255.0 alpha:1.0];
    self.codeTextField.layer.shadowColor = [UIColor blackColor].CGColor;
    self.codeTextField.layer.shadowOpacity = 0.3;
    self.codeTextField.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    self.codeTextField.layer.shadowRadius = 0.0;
    self.codeTextFieldBackgroundView.image = [[UIImage imageNamed:@"invite_code_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 42.0, 0, 42.0)];
    
//    self.goButton.contentEdgeInsets = UIEdgeInsetsMake(0, 2.0, 1.0, 0);
    
    
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowEventsFromCancel"] ||
        [segue.identifier isEqualToString:@"ShowEventsFromGo"]) {
        PFEventsViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
    }
}

//- (void)cancelButtonTouched:(UIBarButtonItem *)button {
//    // This is rather non-standard...
//    PFEventsViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
//    viewController.moc = self.moc;
//    [self.navigationController pushViewController:viewController animated:YES];
//}
//
//- (void)goButtonTouched:(UIButton *)button {
//    PFEventsViewController * viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
//    viewController.moc = self.moc;
//    [self.navigationController pushViewController:viewController animated:YES];
//}

@end
