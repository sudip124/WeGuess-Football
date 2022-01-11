//
//  AccountsViewController.h
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccountsViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource,NSURLConnectionDelegate , UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIToolbarDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UISwitch *notificationOn;
@property (weak, nonatomic) IBOutlet UITextField *countryTextField;
@property (weak, nonatomic) IBOutlet UITextField *timezoneTextField;

- (IBAction)hideKeyboard:(id)sender;
- (IBAction)saveButtonClicked:(id)sender;

@end
