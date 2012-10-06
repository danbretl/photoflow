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

NSString * const EVENT_CODE_PLACEHOLDER = @"EventCode123";
const CGFloat CARD_CONTAINER_VIEW_BOTTOM_SPACE_DEFAULT = 10.0;

@interface PFJoinEventViewController ()
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
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

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait; // The only purpose of this view controller is to get an inputted event code, and while it would technically be possible to show the event code text field and the "go" button while in landscape with the keyboard up, it looks pretty silly. So, we are going to restrict this view controller to portrait only.
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
    // Nav bar
    self.navigationController.navigationBar.translucent = NO;
    // Text field
    self.codeTextField.text = EVENT_CODE_PLACEHOLDER;
    // Start responding to keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.codeTextField resignFirstResponder];
    // Stop responding to keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowEventsFromCancel"]) {
        PFEventsViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
    } else if ([segue.identifier isEqualToString:@"ShowEventsFromGo"]) {
        // IN DEVELOPMENT - CHANGE FOR PRODUCTION
        PFEventsViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
    }
}

- (void) finishedWithCode:(NSString *)code {
    PFEventsViewController * viewController = nil;
    if (code == nil) {
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
        viewController.moc = self.moc;
    } else {
        // IN DEVELOPMENT - CHANGE FOR PRODUCTION
        viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
        viewController.moc = self.moc;
    }
    [self.navigationController pushViewController:viewController animated:YES];
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

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.codeTextField) {
        if ([textField.text isEqualToString:EVENT_CODE_PLACEHOLDER]) {
            textField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.codeTextField) {
        NSString * text = textField.text;
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (textField.text.length == 0) {
            text = EVENT_CODE_PLACEHOLDER;
        }
        textField.text = text;
        if (![textField.text isEqualToString:EVENT_CODE_PLACEHOLDER]) {
            [self finishedWithCode:textField.text];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL should = YES;
    if (textField == self.codeTextField) {
        should = NO;
        [textField resignFirstResponder];
    }
    return should;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    double keyboardAnimationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        self.cardContainerViewBottomSpace.constant = CARD_CONTAINER_VIEW_BOTTOM_SPACE_DEFAULT + keyboardEndFrame.size.height;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // ...
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    double keyboardAnimationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
        self.cardContainerViewBottomSpace.constant = CARD_CONTAINER_VIEW_BOTTOM_SPACE_DEFAULT;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        // ...
    }];
}

@end
