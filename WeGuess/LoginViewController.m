//
//  LoginViewController.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "LoginViewController.h"
#import "Reachibility/Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import "LeaguesModel.h"
#import "FavouriteTeamsViewController.h"
#import "AppDelegate.h"
#define kOFFSET_FOR_KEYBOARD 180.0

@interface LoginViewController () <FBLoginViewDelegate>
@property (nonatomic, strong)NSMutableArray *leagueArray;
@property (nonatomic, strong)NSString *userToken;
@end

@implementation LoginViewController
{
    BOOL keyBoardShown;
    NSMutableData *_responseData;
    BOOL facebookLogin;
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSString *userId = [user objectForKey:@"id"];
    NSString *pasword = [[NSString alloc] initWithFormat:@"%u",arc4random()];
    UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [[dev identifierForVendor] UUIDString];
    NSString *email = [user objectForKey:@"email"];
    
    [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *FBuser, NSError *error) {
        if (error) {/* Handle error*/}
        
        else
        {
            NSString *username = [FBuser name];
            self.userName.text = username;
            NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [FBuser username]];
            
            NSString* finalImagePath = [[NSData dataWithContentsOfURL:[NSURL URLWithString:userImageURL]] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
            NSString *imageDataString = [finalImagePath stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
            
            NSString *country = nil;
            NSString *countryIdString = @"AM";
            NSDictionary<FBGraphPlace> *graphPlace = (id)[FBuser location];
            if(graphPlace != nil)
            {
                NSDictionary<FBGraphLocation> *graphLocation = (id)[graphPlace location];
                if(graphLocation != nil)
                    country = [graphLocation country];
                
                else
                {
                    NSArray *splits = [[graphPlace name] componentsSeparatedByString:@","];
                    NSInteger row = splits.count - 1;
                    country = splits[row];
                    country = [country stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                }
                countryIdString = [Utils getCountryID:country];
                if(countryIdString == nil)
                    countryIdString = @"AM";
            }
            
            
            NSString *post = [[NSString alloc] initWithFormat:@"email=%@&countryId=%@&time=%@&name=%@&password=%@&loginId=%@&singupDevice=%@&signupUsing=%@&singupIp=%@&phoneType=%@&file=%@&pushnotification=%d&appversion=%@",email, countryIdString,[[NSTimeZone localTimeZone] name],username,pasword,userId,deviceUuid,@"phone-fb",[Utils getIPAddress:NO],@"iOS",imageDataString,1, [Utils getAppVersionNumber]];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/registration"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:postData];
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            if (theConnection) {}
        }
    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loginbackground"]];
    bgImageView.frame = self.view.bounds;
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];*/
    
    UITapGestureRecognizer *registerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(registerView:)];
    [self.registerLabel addGestureRecognizer:registerTapRecognizer];
    
    UITapGestureRecognizer *forgotPasswordTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(forgotPassword:)];
    [self.forgotPassword addGestureRecognizer:forgotPasswordTapRecognizer];
    self.loginView.readPermissions = @[@"basic_info", @"email", @"user_location"];
    for (id obj in self.loginView.subviews)
    {
        if ([obj isKindOfClass:[UILabel class]])
        {
            UILabel * loginLabel =  obj;
            loginLabel.font = [UIFont fontWithName:@"ContinuumMedium" size:14.0f];
        }
    }

    //self.loginView
    facebookLogin = YES;
    self.enterButton.layer.cornerRadius = 5;
    //self.enterButton.layer.cornerRadius = 8.0f;
    /*self.enterButton.layer.masksToBounds = NO;
    self.enterButton.layer.borderWidth = 0.20f;
    
    self.enterButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.enterButton.layer.shadowOpacity = 0.2;
    self.enterButton.layer.shadowRadius = 12;
    self.enterButton.layer.shadowOffset = CGSizeMake(12.0f, 12.0f);*/
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


- (IBAction)loginButtonClicked:(id)sender {
    [self hideKeyboard:sender];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if(![self validateInput])
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        return;
    }
    
    Reachability* internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *message = @"Unable to submit information";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            break;
        }
        default:
        {
            [self postToServer];
        }
    }
}

- (void) postToServer
{
    NSString *post = [[NSString alloc] initWithFormat:@"loginId=%@&password=%@&appversion=%@",self.userName.text,self.password.text, [Utils getAppVersionNumber]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/login"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if(theConnection )
        facebookLogin = NO;

}

-(void)keyboardWillShow
{
    if (self.view.frame.origin.y >= 0)
        [self setViewMovedUp:YES];
    else if (self.view.frame.origin.y < 0)
        [self setViewMovedUp:NO];
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
        [self setViewMovedUp:YES];
    else if (self.view.frame.origin.y < 0)
        [self setViewMovedUp:NO];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)textFieldShouldReturn:(id)sender {
    if (sender == self.userName) {
        [sender resignFirstResponder];
        [self.password becomeFirstResponder];
    }
    else if (sender == self.password)
        [sender resignFirstResponder];
}

- (void)forgotPassword:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.weguesstheapp.com/resetpassword"]];
}

- (void)registerView:(id)sender
{
    [self performSegueWithIdentifier:@"register" sender:self];
}

- (BOOL)validateInput
{
    NSString *input = self.userName.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Username can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.userName becomeFirstResponder];
        return NO;
    }
    
    input = self.password.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Password can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.password becomeFirstResponder];
        return NO;
    }
    return YES;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
    if (!response)
        NSLog(@"didReceiveResponse: No response received");
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if (!facebookLogin)
    {
        NSArray *jsonArray=[NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
        NSDictionary *retDictionary = (NSDictionary*)[jsonArray objectAtIndex:0];
        facebookLogin = YES;
        NSString *token = (NSString*)[retDictionary objectForKey:@"token"];
        if (token.length > 1)
        {
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            self.userToken = token;
            if (standardUserDefaults) {
                [standardUserDefaults setObject:token forKey:@"token"];
                [standardUserDefaults setBool:NO forKey:@"facebookLogin"];
                [standardUserDefaults synchronize];
            }
            
            AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            NSData *deviceToken = [standardUserDefaults objectForKey:@"deviceToken"];
            [appDelegate sendTokentoServer:deviceToken userToken:token];
            [self.delegate saveProfile:self.userName.text isFacebookLogin:NO];
            [self performSegueWithIdentifier:@"first" sender:self];
        }
        else
        {
            NSString *message = @"Invalid Username or Password";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to login" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            self.password.text=@"";
            [self.userName becomeFirstResponder];
        }
    }
    else
    {
        NSError *error = nil;
        
        id jsonData = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
        if(![jsonData isKindOfClass:[NSArray class]])
        {
            NSString *token = [jsonData objectForKey:@"token"];
            self.userToken = token;
            NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
            if (standardUserDefaults) {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                NSData *deviceToken = [standardUserDefaults objectForKey:@"deviceToken"];
                [appDelegate sendTokentoServer:deviceToken userToken:token];
                [standardUserDefaults setObject:token forKey:@"token"];
                [standardUserDefaults setBool:YES forKey:@"facebookLogin"];
                [standardUserDefaults synchronize];
            }
            
            NSArray *leagueObjectList = (NSArray*)[jsonData objectForKey:@"league"];
            NSDictionary *leagueObject = nil;
            self.leagueArray = [[NSMutableArray alloc] init];
            for (int i = 0; i < [leagueObjectList count]; i ++)
            {
                leagueObject = (NSDictionary*)[leagueObjectList objectAtIndex:i];
                LeaguesModel *league = [[LeaguesModel alloc] init];
                league.leagueId = [leagueObject objectForKey:@"id"];
                league.leagueName = [leagueObject objectForKey:@"name"];
                league.leagueLogo = [leagueObject objectForKey:@"logo"];
                [self.leagueArray addObject:league];
            }
            [self performSegueWithIdentifier:@"leagueList" sender:self];
        }
        else
        {
            NSDictionary *retVal = (NSDictionary*)[jsonData objectAtIndex:0];
            NSString *retToken = [retVal objectForKey:@"error"];
            NSString *message = nil;
            int errorCode = [retToken intValue];
            switch (errorCode) {
                case 0:
                case 1:
                    message = @"Email already exist";
                    break;
                case 2:
                    message = @"Userid already exist";
                    break;
                case 3:
                    message = @"Email & user name already exist";
                    break;
                case 4:
                    message = @"Invalid file";
                    break;
                case 5:
                    message = @"Internal server error. Please try again";
                    break;
                case 10:
                    message = @"Please update app before proceeding";
                    break;
                default:
                    message = @"Unknow error";
                    break;
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to register" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"Login:didFailWithError: %@",error.description);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if (([[segue identifier] isEqualToString:@"leagueList"]))
    {
        FavouriteTeamsViewController *dest = (FavouriteTeamsViewController*)[segue destinationViewController];
        dest.leagueArray = self.leagueArray;
        dest.userToken = self.userToken;
        dest.delegate = self;
    }
}

- (void)moveToFirstView
{
    [self performSegueWithIdentifier:@"first" sender:self];
}
@end
