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
#import "PFHTTPClient.h"
#import "UIAlertView+PhotoFlow.h"
#import "LocalyticsSession.h"
#import <Parse/Parse.h>

NSString * const EVENT_CODE_PLACEHOLDER = @"EventID123";

@interface PFJoinEventViewController ()
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) finishedWithCode:(NSString *)code;
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
    
    UIImage * cancelButtonImage = [UIImage imageNamed:@"btn_cancel_photos.png"];
    UIImage * cancelButtonImageHighlight = [UIImage imageNamed:@"btn_cancel_photos_highlight.png"];
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.contentMode = UIViewContentModeCenter;
    cancelButton.frame = CGRectMake(0, 0, cancelButtonImage.size.width + 15.0, cancelButtonImage.size.height);
    cancelButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [cancelButton setImage:cancelButtonImage forState:UIControlStateNormal];
    [cancelButton setImage:cancelButtonImageHighlight forState:UIControlStateHighlighted];
    [cancelButton addTarget:self.cancelButtonNav.target action:self.cancelButtonNav.action forControlEvents:UIControlEventTouchUpInside];
    [self.cancelButtonNav setCustomView:cancelButton];
    self.navigationItem.rightBarButtonItem = nil;
    
    self.navigationItem.hidesBackButton = YES;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_medium_texture.png"]];
    
    self.cardBackgroundView.image = [[UIImage imageNamed:@"invite_card_bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(25.0, 25.0, 25.0, 25.0)];

    self.promptLabel.font = [UIFont fontWithName:@"Miso" size:21.0];
    self.promptLabel.textColor = [UIColor colorWithWhite:54.0/255.0 alpha:1.0];
    self.promptLabel.shadowColor = [UIColor whiteColor];
    self.promptLabel.shadowOffset = CGSizeMake(0.0, 2.0);
    [self.promptLabel sizeToFit];
    
    NSString * lineOne = @"Create a new event at".uppercaseString;
    NSString * lineTwo = @"photoflowapp.com".uppercaseString;
    NSMutableAttributedString * attributedString = self.codeOnlineLabel.attributedText.mutableCopy;
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Miso" size:15.0]} range:NSMakeRange(0, lineOne.length + 1)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Miso" size:6.0]} range:NSMakeRange(lineOne.length + 1, 1)];
    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Miso" size:21.0]} range:NSMakeRange(lineOne.length + 2, lineTwo.length)];
//    style.paragraphSpacing = 5.0;
//    [attributedString setAttributes:@{NSParagraphStyleAttributeName:style} range:NSMakeRange(0, attributedString.length)];
//    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Miso" size:15.0]} range:NSMakeRange(0, lineOne.length + 1)];
//    [attributedString setAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Miso" size:21.0]} range:NSMakeRange(lineOne.length + 1, lineTwo.length)];
    self.codeOnlineLabel.attributedText = attributedString;
    self.codeOnlineLabel.textAlignment = NSTextAlignmentCenter;
    self.codeOnlineLabel.textColor = [UIColor colorWithWhite:99.0/255.0 alpha:1.0];
    
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
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setBackgroundImage:[[UIImage imageNamed:@"nav_bar_landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7.0, 0, 7.0)] forBarMetrics:UIBarMetricsLandscapePhone];
    // Text field
    self.codeTextField.text = EVENT_CODE_PLACEHOLDER;
    // Start responding to keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    NSArray * events = [self.moc getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:nil];
    self.navigationController.navigationBarHidden = events.count == 0;
    self.cancelButton.alpha = events.count == 0 ? 0.0 : 1.0;
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
    if ([segue.identifier isEqualToString:@"ShowEventsFromCancel"] ||
        [segue.identifier isEqualToString:@"ShowEventsFromCancelNav"]) {
        PFEventsViewController * viewController = segue.destinationViewController;
        viewController.moc = self.moc;
    }
}

- (void) finishedWithCode:(NSString *)code {
    if (code == nil || code.length == 0 || [code isEqualToString:EVENT_CODE_PLACEHOLDER]) {
        UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Enter Event Code" message:@"Please enter a valid event code." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
    } else {
        [[PFHTTPClient sharedClient] getEventDetails:self.codeTextField.text successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            // Update local data
            PFEvent * event = [self.moc addOrUpdateEventFromAPI:responseObject];
            NSMutableDictionary * attributes = [NSMutableDictionary dictionaryWithDictionary:@{@"Event ID" : event.eid, @"Event Title" : event.title}];
            if ([PFUser currentUser].objectId) {
                [attributes setObject:[PFUser currentUser].objectId forKey:@"User ID"];
            }
            [[LocalyticsSession sharedLocalyticsSession] tagEvent:@"Event Add" attributes:attributes];
            if (![responseObject[@"coverPhoto"] isEqual:[NSNull null]]) {
                [self.moc addOrUpdatePhotoFromAPI:responseObject[@"coverPhoto"] toEvent:event checkIfExists:YES];
            }
            [self.moc saveCoreData];
            // Push view controller
            PFEventsViewController * eventsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
            eventsViewController.moc = self.moc;
            [self.navigationController pushViewController:eventsViewController animated:YES];            
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView * connectionErrorAlertView = [UIAlertView connectionErrorAlertView];
            NSString * alertTitle = connectionErrorAlertView.title;
            NSString * alertMessage = connectionErrorAlertView.message;
            if (operation.response.statusCode == 404) {
                alertTitle = @"Event Not Found";
                alertMessage = @"We couldn't find an event for that code. Check your invitation and try again.";
            }
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:alertTitle message:alertMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }];
    }
}

- (void)codeOnlineButtonTouched:(UIButton *)button {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.photoflowapp.com/register.php"]];
}

- (void)cancelButtonTouched:(UIBarButtonItem *)button {
    [self.codeTextField resignFirstResponder];
    NSArray * events = [self.moc getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:nil];
    if (events.count > 0) {
        PFEventsViewController * eventsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PFEventsViewController"];
        eventsViewController.moc = self.moc;
        [self.navigationController pushViewController:eventsViewController animated:YES];
    }
}

- (void)goButtonTouched:(UIButton *)button {
    [self.codeTextField resignFirstResponder];
    [self finishedWithCode:self.codeTextField.text];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.codeTextField) {
        [UIView animateWithDuration:0.25 animations:^{
            self.cancelButton.alpha = 1.0;
        }];
        if ([textField.text isEqualToString:EVENT_CODE_PLACEHOLDER]) {
            textField.text = @"";
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.codeTextField) {
        if ([self.moc getAllObjectsForEntityName:@"PFEvent" predicate:nil sortDescriptors:nil].count == 0) {
            [UIView animateWithDuration:0.25 animations:^{
                self.cancelButton.alpha = 0.0;
            }];
        }
        NSString * text = textField.text;
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (text.length == 0) {
            text = EVENT_CODE_PLACEHOLDER;
        }
        textField.text = text;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    BOOL should = YES;
    if (textField == self.codeTextField) {
        should = NO;
        [textField resignFirstResponder];
        [self finishedWithCode:textField.text];
    }
    return should;
}

- (void)keyboardWillShow:(NSNotification *)notification {
    double keyboardAnimationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    CGRect keyboardEndFrame = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    UIEdgeInsets insets = UIEdgeInsetsMake(0, 0, keyboardEndFrame.size.height, 0);
    if ([UIScreen mainScreen].bounds.size.height >= 568.0) {
        CGFloat specialAdjustment = floorf(keyboardEndFrame.size.height / 2.0);
        insets.bottom = specialAdjustment;
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
            self.scrollViewBottomSpace.constant = -specialAdjustment;
            [self.view layoutIfNeeded];
        } completion:NULL];
    }/* else {*/
        self.scrollView.scrollEnabled = YES;
        self.scrollView.contentInset = insets;
        [self.scrollView scrollRectToVisible:CGRectInset([self.scrollView convertRect:self.codeTextField.frame fromView:self.codeTextField.superview], 0, -(self.scrollView.bounds.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom - self.codeTextField.bounds.size.height) / 2.0) animated:YES];
//        NSLog(@"codeTextField.frame = %@", NSStringFromCGRect(self.codeTextField.frame));
//        NSLog(@"codeTextField.frame (in window) = %@", NSStringFromCGRect([self.scrollView convertRect:self.codeTextField.frame fromView:self.codeTextField.superview]));
//        NSLog(@"self.scrollView.visibleHeight = %f", self.scrollView.bounds.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom);
//        NSLog(@"CGRectInset([self.scrollView convertRect:self.codeTextField.frame fromView:self.codeTextField.superview], 0, (self.scrollView.bounds.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom - self.codeTextField.bounds.size.height) / 2.0) = %@", NSStringFromCGRect(CGRectInset([self.scrollView convertRect:self.codeTextField.frame fromView:self.codeTextField.superview], 0, (self.scrollView.bounds.size.height - self.scrollView.contentInset.top - self.scrollView.contentInset.bottom - self.codeTextField.bounds.size.height) / 2.0)));
    /*}*/
}

- (void)keyboardWillHide:(NSNotification *)notification {
    double keyboardAnimationDuration = [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve keyboardAnimationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] intValue];
    if ([UIScreen mainScreen].bounds.size.height >= 568.0) {
        [self.view layoutIfNeeded];
        [UIView animateWithDuration:keyboardAnimationDuration delay:0.0 options:keyboardAnimationCurve animations:^{
            self.scrollViewBottomSpace.constant = 0;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            // ...
        }];
    }/* else {*/
        self.scrollView.scrollEnabled = NO;
        [self.scrollView setContentOffset:CGPointZero animated:YES];
    /*}*/
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > [self.scrollView convertPoint:CGPointMake(0, CGRectGetMidY(self.cancelButton.frame)) fromView:self.cancelButton.superview].y) {
        if (self.navigationItem.rightBarButtonItem == nil) [self.navigationItem setRightBarButtonItem:self.cancelButtonNav animated:YES];
    } else {
        if (self.navigationItem.rightBarButtonItem != nil) [self.navigationItem setRightBarButtonItem:nil animated:YES];
    }
}

@end
