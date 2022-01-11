//
//  RegisterUserViewCntroller.h
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
@interface RegisterUserViewCntroller : UIViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSURLConnectionDelegate, MovetoTabView, UIToolbarDelegate, UIAlertViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *loginIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
- (IBAction)submitButtonClicked:(id)sender;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)textFieldShouldReturn:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UIButton *registerButton;
- (IBAction)cancelButtonClicked:(id)sender;
@end
