//
//  WebDevViewController.h
//  Emotish
//
//  Created by Dan Bretl on 9/29/12.
//  Copyright (c) 2012 Dan Bretl. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "PFHTTPClient.h"

@protocol WebDevViewControllerDelegate;

@interface WebDevViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) PFHTTPClient * clientMutable;

@property (unsafe_unretained, nonatomic) id<WebDevViewControllerDelegate> delegate;
- (IBAction)backButtonTouched;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *hideKeyboardButton;
- (IBAction)hideKeyboardButtonTouched:(UIButton *)sender;

@property (unsafe_unretained, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIView * contentView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextView *consoleTextView;

@property (strong, nonatomic) IBOutlet UIView *datetimePickerContainer;
@property (unsafe_unretained, nonatomic) IBOutlet UIDatePicker *datetimePicker;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *datetimeClearButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *datetimeAcceptButton;
- (IBAction)datetimeButtonTouched:(UIButton *)sender;
@property (unsafe_unretained, nonatomic) IBOutlet NSLayoutConstraint * datetimePickerContainerBottomConstraint;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *serverTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *authUsernameTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *authPasswordTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getEventTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *getEventButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIButton *getPhotosButton;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getPhotosEventTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getPhotosLimit;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getPhotosUpdatedAfterTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getPhotosUpdatedBeforeTextField;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *uploadImageImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *uploadImageRotateButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *uploadImageUploadButton;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *actionPhotoTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *deleteButton;

@property (unsafe_unretained, nonatomic) IBOutlet UITextField *createPhotoTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *createPhotoEventTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *createPhotoButton;

@property (unsafe_unretained, nonatomic) IBOutlet UIImageView *getImageImageView;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getImageTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getImageSizeTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UITextField *getImageQualityTextField;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *getImageButton;

- (IBAction)buttonTouched:(UIButton *)sender forEvent:(UIEvent *)event;

@end

@protocol WebDevViewControllerDelegate <NSObject>
- (void) webDevViewControllerDidFinish:(WebDevViewController *)viewController;
@end
