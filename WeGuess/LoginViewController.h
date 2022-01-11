//
//  LoginViewController.h
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "WeGuessRootViewController.h"

@protocol MovetoTabView <NSObject>

- (void)moveToFirstView;

@end

@interface LoginViewController : UIViewController <NSURLConnectionDelegate, MovetoTabView>
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)loginButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *forgotPassword;
@property (weak, nonatomic) IBOutlet UILabel *registerLabel;
- (IBAction)hideKeyboard:(id)sender;
- (IBAction)textFieldShouldReturn:(id)sender;
@property (weak, nonatomic) IBOutlet FBLoginView *loginView;
@property (nonatomic, weak) id<UserProfile> delegate;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@end
