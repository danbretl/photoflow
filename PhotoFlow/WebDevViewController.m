//
//  WebDevViewController.m
//  Emotish
//
//  Created by Dan Bretl on 9/29/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import "WebDevViewController.h"
#import "UIView+GetFirstResponder.h"
#import <QuartzCore/QuartzCore.h>

NSString * const WEB_DEV_DATETIME_UPDATED_AFTER = @"updatedAfter";
NSString * const WEB_DEV_DATETIME_UPDATED_BEFORE = @"updatedBefore";

@interface WebDevViewController ()
- (void) keyboardWillShow:(NSNotification *)notification;
- (void) keyboardWillHide:(NSNotification *)notification;
- (void) setDatetimePickerVisible:(BOOL)visible;
@property (nonatomic, strong) NSDate * getPhotosUpdatedAfterDatetime;
@property (nonatomic, strong) NSDate * getPhotosUpdatedBeforeDatetime;
@property (nonatomic, strong) NSString * activeDatetimeIndicator;
- (NSDate *) datetimeForTextField:(UITextField *)textField;
- (void) setActiveDatetimeIndicatorForTextField:(UITextField *)textField;
- (void) setDatetime:(NSDate *)datetime forActiveDatetimeIndicator:(NSString *)activeDatetimeIndicator;
- (void) updateAllDatetimeTextFields;
- (void) logString:(NSString *)string afterClear:(BOOL)shouldClearFirst;
- (void) logSuccess:(BOOL)success forURL:(NSURL *)url;
- (void) logCountForArray:(NSArray *)array ofObjectsWithNoun:(NSString *)objectPluralNoun;
- (void) logResponseObject:(id)responseObject;
- (void) logError:(NSError *)error fromOperation:(AFHTTPRequestOperation *)operation;
@property (nonatomic, strong, readonly) UIAlertView * notImplementedAlertView;
@end

@implementation WebDevViewController
@synthesize notImplementedAlertView=_notImplementedAlertView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.clientMutable = [[PFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:PFC_BASE_URL_STRING_SAVED_KEY]]];
        self.getPhotosUpdatedAfterDatetime = nil;
        self.getPhotosUpdatedBeforeDatetime = nil;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollView addSubview:self.contentView];
    self.scrollView.contentSize = self.contentView.frame.size;
    
    [self setDatetimePickerVisible:NO];
    
    self.uploadImageImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.uploadImageImageView.layer.borderWidth = 1.0;
    self.uploadImageImageView.image = [UIImage imageNamed:@"upload1.jpg"];
    
    self.getImageImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    self.getImageImageView.layer.borderWidth = 1.0;

}

- (void)viewWillAppear:(BOOL)animated {
    self.serverTextField.text = self.clientMutable.baseURL.absoluteString;
    [self textFieldDidEndEditing:self.authUsernameTextField];
}

- (IBAction)backButtonTouched {
    [self.delegate webDevViewControllerDidFinish:self];
}

- (IBAction)hideKeyboardButtonTouched:(UIButton *)sender {
    UIView * firstResponder = [self.view getFirstResponder];
    if (firstResponder != nil && 
        [firstResponder isKindOfClass:[UITextField class]])
    [self textFieldShouldReturn:(UITextField *)[self.view getFirstResponder]];
}

- (IBAction)buttonTouched:(UIButton *)sender forEvent:(UIEvent *)event {
    NSLog(@"buttonTouched");
    
    UIView * firstResponder = [self.view getFirstResponder];
    if (firstResponder != nil && 
        [firstResponder isKindOfClass:[UITextField class]])
        [self textFieldShouldReturn:(UITextField *)[self.view getFirstResponder]];
    
    if (sender == self.getEventButton) {
        NSLog(@"Get event details");
        
        [self.clientMutable getEventDetails:self.getEventTextField.text successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self logSuccess:YES forURL:operation.response.URL];
            [self logResponseObject:responseObject];
            self.getPhotosEventTextField.text   = [responseObject objectForKey:@"event_eid"];
            self.createPhotoEventTextField.text = [responseObject objectForKey:@"event_eid"];
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self logSuccess:NO forURL:operation.response.URL];
            [self logError:error fromOperation:operation];
        }];
        
    } else if (sender == self.getPhotosButton) {
        NSLog(@"Get recent photos");
        
        NSNumber * limit = nil;
        NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
        limit = [numberFormatter numberFromString:self.getPhotosLimit.text];
        if (self.getPhotosLimit.text.length > 0) {
            NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
            limit = [numberFormatter numberFromString:self.getPhotosLimit.text];
        }
        
        [self.clientMutable getPhotosForEvent:self.getPhotosEventTextField.text limit:limit updatedAfter:self.getPhotosUpdatedAfterDatetime updatedBefore:self.getPhotosUpdatedBeforeDatetime successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self logSuccess:YES forURL:operation.response.URL];
            [self logCountForArray:[responseObject objectForKey:@"photos"] ofObjectsWithNoun:@"photos"];
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self logSuccess:NO forURL:operation.response.URL];
            [self logError:error fromOperation:operation];
        }];
        
    } else if (sender == self.getImageButton) {
        NSLog(@"Get image");
        
        NSURLRequest * imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[self.clientMutable imageURLStringForPhoto:self.getImageTextField.text size:self.getImageSizeTextField.text.intValue quality:self.getImageQualityTextField.text.intValue]]];
        [self.getImageImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder_full.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            [self logSuccess:YES forURL:request.URL];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [self logSuccess:NO forURL:request.URL];
            [self logError:error fromOperation:nil];
        }];
        
    } else if (sender == self.uploadImageRotateButton) {
        
        for (int i=0; i<10; i++) {
            if ([self.uploadImageImageView.image isEqual:[UIImage imageNamed:[NSString stringWithFormat:@"upload%d.jpg", i]]]) {
                i++;
                if (i>=10) i=0;
                self.uploadImageImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"upload%d.jpg", i]];
                break;
            }
        }
        
    } else if (sender == self.uploadImageUploadButton) {
        NSLog(@"Upload image");
        
        [self.clientMutable saveImage:self.uploadImageImageView.image successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self logSuccess:YES forURL:operation.response.URL];
            [self logResponseObject:responseObject];
            self.createPhotoTextField.text = [responseObject objectForKey:@"photo_eid"];
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self logSuccess:NO forURL:operation.response.URL];
            [self logError:error fromOperation:operation];
        }];
        
    } else if (sender == self.createPhotoButton) {
        NSLog(@"Save photo");
        
        [self.clientMutable savePhoto:self.createPhotoTextField.text toEvent:self.createPhotoEventTextField.text successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self logSuccess:YES forURL:operation.response.URL];
            [self logResponseObject:responseObject];
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self logSuccess:NO forURL:operation.response.URL];
            [self logError:error fromOperation:operation];
        }];
        
    } else if (sender == self.deleteButton) {
        NSLog(@"Delete photo");
        
        [self.clientMutable deletePhoto:self.actionPhotoTextField.text successBlock:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self logSuccess:YES forURL:operation.response.URL];
            [self logResponseObject:responseObject];
        } failureBlock:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self logSuccess:NO forURL:operation.response.URL];
            [self logError:error fromOperation:operation];
        }];
        
    } 
    
}

- (void) logSuccess:(BOOL)success forURL:(NSURL *)url {
    [self logString:[NSString stringWithFormat:@"EmotishClient %@ for URL %@", success ? @"success" : @"failure", url.absoluteString] afterClear:YES];
}

- (void) logCountForArray:(NSArray *)array ofObjectsWithNoun:(NSString *)objectPluralNoun {
    [self logString:[NSString stringWithFormat:@"Retrieved %d %@", array.count, objectPluralNoun] afterClear:NO];
}

- (void) logResponseObject:(id)responseObject {
    [self logString:[NSString stringWithFormat:@"%@", responseObject] afterClear:NO];
}

- (void) logError:(NSError *)error fromOperation:(AFHTTPRequestOperation *)operation {
    [self logString:[NSString stringWithFormat:@"%@", error] afterClear:NO];
    if (operation != nil) {
        [self logString:[NSString stringWithFormat:@"%@", operation.responseString] afterClear:NO];
    }
}

- (void) logString:(NSString *)string afterClear:(BOOL)shouldClearFirst {
    if (shouldClearFirst) {
        self.consoleTextView.text = @"";
    }
    NSLog(@"%@", string);
    self.consoleTextView.text = [self.consoleTextView.text stringByAppendingFormat:@"%@\n", string];
}

- (IBAction)switchValueChanged:(id)sender forEvent:(UIEvent *)event {
    NSLog(@"switchValueChanged");
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    BOOL begin = YES;
    if (textField == self.getPhotosUpdatedAfterTextField ||
        textField == self.getPhotosUpdatedBeforeTextField) {
        begin = NO;
        [self setDatetime:self.datetimePicker.date forActiveDatetimeIndicator:self.activeDatetimeIndicator];
        [self updateAllDatetimeTextFields];
        if ([self datetimeForTextField:textField]) {
            [self.datetimePicker setDate:[self datetimeForTextField:textField] animated:YES];            
        } else {
            [self.datetimePicker setDate:[NSDate date] animated:YES];
        }
        [self setDatetimePickerVisible:YES];
        [self setActiveDatetimeIndicatorForTextField:textField];
    }
    return begin;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == self.serverTextField ||
        textField == self.authUsernameTextField ||
        textField == self.authPasswordTextField) {
        [self resetClient];
    }
}

- (void) resetClient {
    
    // Cookies
    if (self.clientMutable.baseURL) {
        NSArray * specificCookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:self.clientMutable.baseURL];
        int deletedCount = 0;
        for (NSHTTPCookie * cookie in specificCookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
            deletedCount++;
        }
    }
    
    // Save dev info
    [[NSUserDefaults standardUserDefaults] setObject:self.serverTextField.text forKey:PFC_BASE_URL_STRING_SAVED_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Recreate client
    self.clientMutable = [[PFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:PFC_BASE_URL_STRING_SAVED_KEY]]];
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (textField == self.serverTextField) {
        self.serverTextField.text = @"http://";
        return NO;
    } else {
        return YES;
    }
}

- (void) updateAllDatetimeTextFields {
    self.getPhotosUpdatedAfterTextField.text = [self.clientMutable stringFromDate:self.getPhotosUpdatedAfterDatetime];
    self.getPhotosUpdatedBeforeTextField.text = [self.clientMutable stringFromDate:self.getPhotosUpdatedBeforeDatetime];
}

- (NSDate *) datetimeForTextField:(UITextField *)textField {
    if (textField == self.getPhotosUpdatedAfterTextField) {
        return self.getPhotosUpdatedAfterDatetime;
    } else if (textField == self.getPhotosUpdatedBeforeTextField) {
        return self.getPhotosUpdatedBeforeDatetime;
    }
    return nil;
}

- (void) setActiveDatetimeIndicatorForTextField:(UITextField *)textField {
    if (textField == self.getPhotosUpdatedAfterTextField) {
        self.activeDatetimeIndicator = WEB_DEV_DATETIME_UPDATED_AFTER;
    } else if (textField == self.getPhotosUpdatedBeforeTextField) {
        self.activeDatetimeIndicator = WEB_DEV_DATETIME_UPDATED_BEFORE;
    }
}

- (void) setDatetime:(NSDate *)datetime forActiveDatetimeIndicator:(NSString *)activeDatetimeIndicator {
    if ([activeDatetimeIndicator isEqualToString:WEB_DEV_DATETIME_UPDATED_AFTER]) {
        self.getPhotosUpdatedAfterDatetime = datetime;
    } else if ([activeDatetimeIndicator isEqualToString:WEB_DEV_DATETIME_UPDATED_BEFORE]) {
        self.getPhotosUpdatedBeforeDatetime = datetime;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboardWillShow");
    if (self.view.window) {
        [UIView animateWithDuration:0.25 animations:^{
            self.hideKeyboardButton.alpha = 1.0;
        }];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboardWillHide");
    if (self.view.window) {
        [UIView animateWithDuration:0.25 animations:^{
            self.hideKeyboardButton.alpha = 0.0;
        }];
    }
}

- (IBAction)datetimeButtonTouched:(UIButton *)sender {
    if (sender == self.datetimeClearButton) {
        [self setDatetime:nil forActiveDatetimeIndicator:self.activeDatetimeIndicator];
    } else if (sender == self.datetimeAcceptButton) {
        [self setDatetime:self.datetimePicker.date forActiveDatetimeIndicator:self.activeDatetimeIndicator];
    }
    self.activeDatetimeIndicator = nil;
    [self setDatetimePickerVisible:NO];
    [self updateAllDatetimeTextFields];
}


- (void) setDatetimePickerVisible:(BOOL)visible {
    [self.view layoutSubviews];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.datetimePickerContainerBottomConstraint.constant = visible ? 0 : -self.datetimePickerContainer.bounds.size.height;
        [self.view layoutSubviews];
    } completion:NULL];
}

- (UIAlertView *)notImplementedAlertView {
    if (_notImplementedAlertView == nil) {
        _notImplementedAlertView = [[UIAlertView alloc] initWithTitle:@"Not Implemented" message:@"Sorry, this feature has not yet been implemented. It's probably McLarnon's fault." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    }
    return _notImplementedAlertView;
}

@end
