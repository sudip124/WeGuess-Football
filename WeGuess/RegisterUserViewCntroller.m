//
//  RegisterUserViewCntroller.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "RegisterUserViewCntroller.h"
#import "Reachibility/Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "LeaguesModel.h"
#import "FavouriteTeamsViewController.h"
#import "NSData+Base64.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

#define kOFFSET_FOR_KEYBOARD 180.0

@interface RegisterUserViewCntroller()
@property (nonatomic, strong)NSMutableArray *leagueArray;
@property (strong, atomic) NSString* imageFilePath;
@property (strong, atomic) NSString* userToken;
@property (strong, nonatomic) UIPickerView *countryPickerView;
@end

@implementation RegisterUserViewCntroller
{
    BOOL keyBoardShown;
    NSMutableArray *countryAllNameList;
    NSMutableArray *countryAllIdList;
    NSMutableData *_responseData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.navigationController.navigationBarHidden = NO;
    self.registerButton.layer.cornerRadius = 5;
    //[Utils setRoundedView:self.imageView toDiameter:110];
    self.imageView.layer.cornerRadius = 60;
    //self.imageView.clipsToBounds = YES;
    self.imageView.layer.masksToBounds = YES;
    
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    [self.imageView addGestureRecognizer:imageTapRecognizer];
    
    countryAllNameList = [[NSMutableArray alloc] init];
    countryAllIdList = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *e = nil;
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    data = nil;
    e = nil;
    
    for (NSDictionary *values in JSON)
    {
        [countryAllIdList addObject:[values objectForKey:@"CountryCode"]];
        [countryAllNameList addObject:[values objectForKey:@"CountryName"]];
    }
    
    self.countryPickerView = [[UIPickerView alloc] init];
    self.countryPickerView.dataSource = self;
    self.countryPickerView.delegate = self;
    self.countryPickerView.backgroundColor = [Utils weGuessGreenColor];
    self.countryTextField.inputView = self.countryPickerView;
    UIToolbar *countryPickerToolBar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,0, 320, 44)];
    countryPickerToolBar.barTintColor = [Utils weGuessyellowColor];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *countryToolBarDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(countryAccessoryViewDidFinish)];
    
    [countryToolBarDoneButton setTitleTextAttributes:@{
                    UITextAttributeFont :             [UIFont fontWithName:@"ContinuumMedium" size:20.0f],
                    UITextAttributeTextColor :        [UIColor whiteColor],
                    UITextAttributeTextShadowColor :  [Utils weGuessyellowColor],
                    UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]}                          forState:UIControlStateNormal];
    
    [countryPickerToolBar setItems:[NSArray arrayWithObjects:flexibleItem,countryToolBarDoneButton,nil] animated:NO];
    self.countryTextField.inputAccessoryView = countryPickerToolBar;
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *countryCode = [locale objectForKey: NSLocaleCountryCode];
    NSLocale *usLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"] ;
    NSString *country = [usLocale displayNameForKey: NSLocaleCountryCode value: countryCode];
    NSInteger localCountryId = -1;
    localCountryId = [countryAllNameList indexOfObject:country];
    if(localCountryId > -1 && localCountryId < countryAllNameList.count)
    {
        [self.countryPickerView selectRow:localCountryId inComponent:0 animated:YES];
        self.countryTextField.text = country;
    }
}

- (void)countryAccessoryViewDidFinish
{
    NSInteger row = [self.countryPickerView selectedRowInComponent:0];
    self.countryTextField.text = countryAllNameList[row];
    [self.countryTextField resignFirstResponder];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.userToken != nil)
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults) {
            self.userToken = [standardUserDefaults objectForKey:@"token"];
            //self.userToken = @"Hello";
        }
        
        if (self.userToken != nil && self.userToken.length > 0)
        {
            [self performSegueWithIdentifier:@"first" sender:self];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}



- (void) imageViewTapped : (id) sender
{
    NSString *actionSheetTitle = nil; //Action Sheet Title
    NSString *destructiveTitle = nil;
    
    
    NSString *galleryButton = NSLocalizedString(@"CameraRoll", nil);
    NSString *cameraButton = NSLocalizedString(@"TakePhoto", nil);
    NSString *cancelTitle = NSLocalizedString(@"Dismiss", nil);
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:cancelTitle
                                  destructiveButtonTitle:destructiveTitle
                                  otherButtonTitles:galleryButton, cameraButton, nil];
    actionSheet.actionSheetStyle = UIActivityIndicatorViewStyleGray;
    [actionSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIImagePickerController *picker = nil;
    
    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:NSLocalizedString(@"CameraRoll", nil)])
    {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        picker.allowsEditing = YES;
        //addUserMetadata = YES;
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    else if ([buttonTitle isEqualToString:NSLocalizedString(@"TakePhoto", nil)])
    {
        picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        BOOL isCamera = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
        if(isCamera)
        {
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
        }
        else
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        picker.allowsEditing = YES;
        [self presentViewController:picker animated:YES completion:NULL];
        
    }
    
    else
    {
        picker = nil;
    }
    buttonTitle = nil;
    actionSheet = nil;
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *viewImage = [info objectForKey:UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:nil];
    viewImage = [Utils correctCapturedImageOrientation:viewImage];
    NSData *pngData = UIImagePNGRepresentation(viewImage);
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) objectAtIndex:0];
    
    int imageFileName = arc4random();
    NSString *fileName = [NSString stringWithFormat:@"/%d.png", imageFileName];
    filePath = [filePath stringByAppendingString:fileName];
    if(![pngData writeToFile:filePath atomically:YES])
        NSLog(@"Saving the image failed");
    
    self.imageFilePath = filePath;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSData *imgData = [[NSData alloc] initWithContentsOfURL:fileURL];
    self.imageView.image = [[UIImage alloc] initWithData:imgData];
    pngData = nil;
    viewImage = nil;
    picker = nil;
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if([self.confirmPasswordTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
    {
        if (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
        else if (self.view.frame.origin.y < 0)
        {
            [self setViewMovedUp:NO];
        }
        //self.navigationController.navigationBarHidden = YES;
    }
    
}

-(void)keyboardWillHide {
    if([self.confirmPasswordTextField isFirstResponder] || [self.passwordTextField isFirstResponder])
    {
        if (self.view.frame.origin.y >= 0)
        {
            [self setViewMovedUp:YES];
        }
        else if (self.view.frame.origin.y < 0)
        {
            [self setViewMovedUp:NO];
        }
        //self.navigationController.navigationBarHidden = NO;
    }
    
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


- (IBAction)submitButtonClicked:(id)sender {
    [self hideKeyboard:sender];
    if(![self validateInput])
        return;
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        NSString *message = @"Unable to submit information";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
    }
    else
        [self postToServer];
}

- (void) postToServer
{
    UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [[dev identifierForVendor] UUIDString];
    NSInteger row = [self.countryPickerView selectedRowInComponent:0];
    NSString *countryIdString = countryAllIdList[row];
    NSData *testData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    NSString *finalImagePath = [testData base64EncodedString];
    NSString *imageDataString = [finalImagePath stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSString *post = [[NSString alloc] initWithFormat:@"email=%@&countryId=%@&time=%@&name=%@&password=%@&loginId=%@&singupDevice=%@&signupUsing=%@&singupIp=%@&phoneType=%@&file=%@&pushnotification=%d&appversion=%@",self.emailTextField.text, countryIdString,[[NSTimeZone localTimeZone] name],self.nameTextField.text,self.passwordTextField.text,self.loginIdTextField.text,deviceUuid,@"phone-form",[Utils getIPAddress:NO],@"iOS",imageDataString,1, [Utils getAppVersionNumber]];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/registration"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:postData];
    
    NSURLConnection *requestConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [requestConnection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [requestConnection start];

}

- (BOOL)validateInput
{
    NSString *input = self.nameTextField.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Username can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.nameTextField becomeFirstResponder];
        return NO;
    }
    
    input = self.loginIdTextField.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Log In Id can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.loginIdTextField becomeFirstResponder];
        return NO;
    }
    
    input = self.passwordTextField.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Password can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    
    input = self.confirmPasswordTextField.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Confirm password can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.confirmPasswordTextField becomeFirstResponder];
        return NO;
    }
    
    if(![self.passwordTextField.text isEqualToString:input])
    {
        NSString *message = @"Passwords do not match";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.passwordTextField becomeFirstResponder];
        return NO;
    }
    
    input = self.emailTextField.text;
    if(input == nil || input.length < 1)
    {
        NSString *message = @"Email can't be empty";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.emailTextField becomeFirstResponder];
        return NO;
    }
    
    if (![self NSStringIsValidEmail:input])
    {
        NSString *message = @"Please enter a valid email";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        [self.emailTextField becomeFirstResponder];
        return NO;
    }
    return YES;
}


-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)textFieldShouldReturn:(id)sender {
    if (sender == self.nameTextField) {
        [sender resignFirstResponder];
        [self.loginIdTextField becomeFirstResponder];
    }
    else if (sender == self.loginIdTextField) {
        [sender resignFirstResponder];
        [self.emailTextField becomeFirstResponder];
    }
    else if (sender == self.emailTextField) {
        [sender resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    }
    else if (sender == self.passwordTextField) {
        [sender resignFirstResponder];
        [self.confirmPasswordTextField becomeFirstResponder];
    }
    else if (sender == self.confirmPasswordTextField) {
        [sender resignFirstResponder];
    }
}


#pragma mark Picker Delegate Methods
/*- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [countryAllNameList objectAtIndex:row];
}*/

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [countryAllNameList count];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}



- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 230, 35)];
        tView.font = [UIFont fontWithName:@"Continuum Medium" size:20];
        tView.textColor = [UIColor whiteColor];
        tView.textAlignment = NSTextAlignmentCenter;
        // Setup label properties - frame, font, colors etc
        
    }
    // Fill the label text here
    tView.text = [countryAllNameList objectAtIndex:row];
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{

}

/*
- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = [countryAllNameList objectAtIndex:row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"Verdana" size:8]}];
    
    return attString;
}*/
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
    if (!response)
        NSLog(@"didReceiveResponse: No response received");

}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
            [standardUserDefaults setBool:NO forKey:@"facebookLogin"];
            [standardUserDefaults synchronize];
        }
        
        NSArray *leagueObjectList = (NSArray*)[jsonData objectForKey:@"league"];
        NSDictionary *leagueObject = nil;
        self.leagueArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [leagueObjectList count]; i ++)
        {
            leagueObject = (NSDictionary*)[leagueObjectList objectAtIndex:i];
            LeaguesModel *league = [[LeaguesModel alloc] init];
            league.leagueId = [[NSString alloc] initWithFormat:@"%@",[leagueObject objectForKey:@"id"]];
            
            league.leagueName = [[NSString alloc] initWithFormat:@"%@",[leagueObject objectForKey:@"name"]];
            league.leagueLogo = [[NSString alloc] initWithFormat:@"%@",[leagueObject objectForKey:@"logo"]];
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
        self.passwordTextField.text=@"";
        self.confirmPasswordTextField.text=@"";
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Registration:didFailWithError: %@",error.description);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
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
- (IBAction)cancelButtonClicked:(id)sender {
    if (self.imageFilePath != nil || ![self.nameTextField.text isEqualToString:@""] || ![self.emailTextField.text isEqualToString:@""] || ![self.loginIdTextField.text isEqualToString:@""])
    {
        [self hideKeyboard:sender];
        NSString *message = @"Proceed without registration";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Registration Incomplete" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
        alert.delegate = self;
        [alert show];
    }
    else
        [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
        [self.navigationController popViewControllerAnimated:YES];
}
@end
