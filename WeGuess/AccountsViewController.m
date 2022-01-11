//
//  AccountsViewController.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "AccountsViewController.h"
#import "Reachibility/Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"

#define IMAGE_RADIUS 35
@interface AccountsViewController()
{
    BOOL userNotification;
}
@property (strong, atomic) NSString* imageFilePath;
@property(nonatomic, strong) NSString *userToken;
@property (strong, nonatomic) UIPickerView *countryPickerView;
@property (strong, nonatomic) UIPickerView *timeZonePickerView;
@property(nonatomic, strong) NSString *userName;
@property(nonatomic, strong) NSString *userTimeZone;
@property(nonatomic, strong) NSString *userCountry;
@end


@implementation AccountsViewController
{
    NSMutableArray *countryAllNameList;
    NSMutableArray *countryAllIdList;
    NSMutableData *_responseData;
    NSArray *timeZoneList;
    BOOL fetchFromUser;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.navigationController.navigationBarHidden = YES;
    self.saveButton.layer.cornerRadius = 5;
    UITapGestureRecognizer *imageTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)];
    [self.imageView addGestureRecognizer:imageTapRecognizer];
    [self setUpTextFieldPickers];
    
    Reachability* internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    switch (netStatus)
    {
        case NotReachable:
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *message = @"Unable to fetch information";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            break;
        }
            
        default:
        {
            [self fetchFromServer];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.nameTextField.text = self.userName;
    self.notificationOn.on = userNotification;
    self.timezoneTextField.text = self.userTimeZone;
    self.countryTextField.text = self.userCountry;
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    if((![self.userCountry isEqualToString:self.countryTextField.text]) || (![self.userName isEqualToString:self.nameTextField.text]) || (![self.userTimeZone isEqualToString:self.timezoneTextField.text]) || self.notificationOn.isOn != userNotification)
       {
           //NSLog(@"HEllo");
           //return;
       }
    [super viewWillDisappear:animated];
}

- (void)setUpTextFieldPickers
{
    countryAllNameList = [[NSMutableArray alloc] init];
    countryAllIdList = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *e = nil;
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    data = nil; e = nil;
    
    for (NSDictionary *values in JSON)
    {
        [countryAllIdList addObject:[values objectForKey:@"CountryCode"]];
        [countryAllNameList addObject:[values objectForKey:@"CountryName"]];
    }
    timeZoneList = [NSTimeZone knownTimeZoneNames];
    
    self.countryPickerView = [[UIPickerView alloc] init];
    self.countryPickerView.dataSource = self;
    self.countryPickerView.delegate = self;
    self.countryPickerView.backgroundColor = [Utils weGuessGreenColor];
    self.countryTextField.inputView = self.countryPickerView;
    UIToolbar *countryPickerToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,0, 320, 44)];
    countryPickerToolbar.barTintColor = [Utils weGuessyellowColor];
    
    UIBarButtonItem *flexibleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *countryToolbarDoneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(CountryPickerAccessoryViewDidFinish)];
    [countryToolbarDoneButton setTitleTextAttributes:@{
            UITextAttributeFont :             [UIFont fontWithName:@"ContinuumMedium" size:20.0f],
            UITextAttributeTextColor :        [UIColor whiteColor],
            UITextAttributeTextShadowColor :  [Utils weGuessyellowColor],
            UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]}                          forState:UIControlStateNormal];
    
    [countryPickerToolbar setItems:[NSArray arrayWithObjects:flexibleItem,countryToolbarDoneButton,nil] animated:NO];
    self.countryTextField.inputAccessoryView = countryPickerToolbar;
    
    self.timeZonePickerView = [[UIPickerView alloc] init];
    self.timeZonePickerView.dataSource = self;
    self.timeZonePickerView.delegate = self;
    self.timeZonePickerView.backgroundColor = [Utils weGuessGreenColor];
    self.timezoneTextField.inputView = self.timeZonePickerView;
    
    UIToolbar *myToolbar = [[UIToolbar alloc] initWithFrame: CGRectMake(0,0, 320, 44)];
    myToolbar.barTintColor = [Utils weGuessyellowColor];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self action:@selector(timeZonePickerAccessoryViewDidFinish)];
    [doneButton setTitleTextAttributes:@{
                    UITextAttributeFont :             [UIFont fontWithName:@"ContinuumMedium" size:20.0f],
                    UITextAttributeTextColor :        [UIColor whiteColor],
                    UITextAttributeTextShadowColor :  [Utils weGuessyellowColor],
                    UITextAttributeTextShadowOffset : [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]}                          forState:UIControlStateNormal];
    
    [myToolbar setItems:[NSArray arrayWithObjects:flexibleItem,doneButton,nil] animated:NO];
    self.timezoneTextField.inputAccessoryView = myToolbar;
}

- (void)CountryPickerAccessoryViewDidFinish
{
    NSInteger row = [self.countryPickerView selectedRowInComponent:0];
    self.countryTextField.text = countryAllNameList[row];
    [self.countryTextField resignFirstResponder];
}

- (void)timeZonePickerAccessoryViewDidFinish
{
    NSInteger row = [self.timeZonePickerView selectedRowInComponent:0];
    self.timezoneTextField.text = timeZoneList[row];
    [self.timezoneTextField resignFirstResponder];
}

- (IBAction)hideKeyboard:(id)sender
{
    [self.view endEditing:YES];
    [self.nameTextField resignFirstResponder];
}

- (IBAction)saveButtonClicked:(id)sender {
    Reachability* internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            NSString *message = @"Unable to save information";
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


- (void)fetchFromServer
{
    fetchFromUser = YES;
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        self.userToken = [standardUserDefaults objectForKey:@"token"];
        //self.userToken = @"Hello";
    }
    
    NSString *post = [[NSString alloc] initWithFormat:@"token=%@",self.userToken];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/edit"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:postData];
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if(!theConnection)
        NSLog(@"AccountViewController");
}

- (void) imageViewTapped : (id) sender
{
    NSString *actionSheetTitle = nil; //Action Sheet Title
    NSString *destructiveTitle = nil;
    [self.nameTextField resignFirstResponder];
    
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
        //addUserMetadata = YES;
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
    [Utils setRoundedView:self.imageView toDiameter:96.0f];
    pngData = nil;
    viewImage = nil;
    picker = nil;
}

#pragma mark Picker Delegate Methods
/*- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(component == 0)
        return [countryAllNameList objectAtIndex:row];
    else
        return [timeZoneList objectAtIndex:row];
}*/

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(pickerView == self.countryPickerView)
        return [countryAllNameList count];
    else
        return [timeZoneList count];
    
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView
{
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    UILabel* tView = (UILabel*)view;
    if (!tView){
        tView = [[UILabel alloc] initWithFrame:CGRectMake(2, 0, 200, 35)];
        tView.textAlignment = NSTextAlignmentCenter;
        tView.font = [UIFont fontWithName:@"Continuum Medium" size:18];
        tView.textColor = [UIColor whiteColor];
    }
    if(pickerView == self.countryPickerView)
        tView.text =  [countryAllNameList objectAtIndex:row];
    else
        tView.text =  [timeZoneList objectAtIndex:row];
    
    return tView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    /*if (pickerView == self.countryPickerView) {
        self.countryTextField.text = countryAllNameList[row];
    }
    else
        self.timezoneTextField.text = timeZoneList[row];*/
}

- (void) postToServer
{
    fetchFromUser = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSData *testData = UIImageJPEGRepresentation(self.imageView.image, 1.0);
    NSString *finalImagePath = [testData base64EncodedString];
    NSInteger countryId = [countryAllNameList indexOfObject:self.countryTextField.text];
    NSString *imageDataString = [finalImagePath stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    NSString *post = [[NSString alloc] initWithFormat:@"token=%@&name=%@&timezone=%@&countryid=%@&pushnotification=%d&profile_Picture=%@",self.userToken, self.nameTextField.text,self.timezoneTextField.text,countryAllIdList[countryId],self.notificationOn.isOn,imageDataString];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/saveedit"];
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

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSArray *jsonArray=[NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
    NSDictionary *retDictionary = nil;
    if([jsonArray isKindOfClass:[NSArray class]])
        retDictionary = (NSDictionary*)[jsonArray objectAtIndex:0];
    else
        retDictionary = (NSDictionary*)jsonArray;

    if(fetchFromUser)
    {
        self.nameTextField.text = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"name"]];
        self.userName = self.nameTextField.text;
        NSString *timeZone = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"timezone"]];
        NSString *finalImagePath = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"profile_Picture"]];
        
        NSString *push = [NSString stringWithFormat:@"%@",[retDictionary objectForKeyedSubscript:@"pushnotification"]];
        self.notificationOn.on = [push boolValue];
        userNotification = [push boolValue];
        
        NSString *matchImages = [finalImagePath stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        
        NSData *imageData = [[NSData alloc] initWithData:[NSData dataFromBase64String:matchImages]];
        if(matchImages != nil && matchImages.length > 20)
        {
            self.imageView.image = [UIImage imageWithData:imageData];
            [Utils setRoundedView:self.imageView toDiameter:96.0f];
        }
        
        NSString *countryCode = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"country"]];
        NSInteger localCountryId = -1;
        localCountryId = [countryAllNameList indexOfObject:countryCode];
        if(localCountryId > -1 && localCountryId < countryAllNameList.count)
        {
            [self.countryPickerView selectRow:localCountryId inComponent:0 animated:YES];
            self.countryTextField.text = countryCode;
            self.userCountry = countryCode;
        }
        
        NSInteger localtimeZone = -1;
        localtimeZone = [timeZoneList indexOfObject:timeZone];
        if(localtimeZone > -1 && localtimeZone < timeZoneList.count)
        {
            [self.timeZonePickerView selectRow:localtimeZone inComponent:0 animated:YES];
            self.timezoneTextField.text = timeZoneList[localtimeZone];
            self.userTimeZone = timeZoneList[localtimeZone];
        }
        
        _responseData = nil;
    }
    else
    {
        NSString *token = [retDictionary objectForKey:@"success"];
        if(token == nil)
        {
            token = [retDictionary objectForKey:@"error"];
            int errorCode = [token intValue];
            if (errorCode == 10)
            {
                NSString *message = @"Please update app before proceeding";
            
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to register" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
                return;
            }
            NSString* responseString = [[NSString alloc] initWithData:_responseData encoding:NSNonLossyASCIIStringEncoding];
            
            if(responseString == nil)
                responseString= [[NSString alloc] initWithData:_responseData encoding:NSUTF8StringEncoding];
            if(responseString == nil)
                responseString = [NSString stringWithUTF8String:[_responseData bytes]];
            
            NSLog(@"%@",responseString);
            NSString *message = responseString;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSString *message = @"Profile Updated";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"did fail");
}

@end
