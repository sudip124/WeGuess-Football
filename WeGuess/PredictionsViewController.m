//
//  SecondViewController.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "PredictionsViewController.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"
#import "Reachibility/Reachability.h"
#import "Utils.h"

@interface PredictionsViewController()

@property(nonatomic, strong)NSString *matchLocation;
@property(nonatomic, strong)NSString *matchStadium;
@property(nonatomic, strong)NSString *predictionTimeStart;
@property(nonatomic, strong)NSString *predictionTimeEnd;

@end

@implementation PredictionsViewController
{
    NSMutableData *_responseData;
    BOOL isDownloaded;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    [self setNeedsStatusBarAppearanceUpdate];
    self.predictNowButton.layer.cornerRadius = 5;
    self.homeTeamStepper.layer.cornerRadius = 5;
    self.homeTeamStepper.clipsToBounds = YES;
    self.awayTeamStepper.layer.cornerRadius = 5;
    self.awayTeamStepper.clipsToBounds = YES;
    isDownloaded = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults)
        self.userToken = [standardUserDefaults objectForKey:@"token"];
    if (self.userToken == nil)
        [self.navigationController popToRootViewControllerAnimated:NO];
    
    Reachability* internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
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
            if (!isDownloaded)
                [self downloadMatchSchedule];
        }
    }
}

- (void)downloadMatchSchedule
{
    isDownloaded = YES;
    NSString *post = [[NSString alloc] initWithFormat:@"token=%@&matchid=%@",self.userToken,self.matchID];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/selectedmatch"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:postData];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(theConnection){ }
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillDisappear:animated];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    /*self.homeTeamNameLabel.text = self.homeName;
    self.awayTeamNameLabel.text = self.awayName;
    self.homeTeamView.backgroundColor = self.homeColor;
    self.awayTeamView.backgroundColor = self.awayColor;
    
    self.homeTeamBetNameLabel.textColor = self.homeColor;
    self.awayTeamBetNameLabel.textColor = self.awayColor;
    self.homeTeamBetScoreLabel.textColor = self.homeColor;
    self.awayTeamBetScoreLabel.textColor = self.awayColor;
    self.homeTeamBetNameLabel.text = self.homeName;
    self.awayTeamBetNameLabel.text = self.awayName;
    self.homeTeamBetScoreLabel.text = self.teamhome_predicition;
    self.awayTeamBetScoreLabel.text = self.teamaway_predicition;
    self.drawbetScoreLabel.text = self.predictiondraw;
    
    NSData *data = nil;
    if(self.homeImageLogo != nil && self.homeImageLogo.length > 10)
    {
        data = [[NSData alloc] initWithData:[NSData dataFromBase64String:self.homeImageLogo]];
        self.homeTeamLogoImageView.image = [UIImage imageWithData:data];
    }
    
    if(self.awayImageLogo != nil && self.awayImageLogo.length > 10)
    {
        data = [[NSData alloc] initWithData:[NSData dataFromBase64String:self.awayImageLogo]];
        self.awayTeamLogoImageView.image = [UIImage imageWithData:data];
    }
    if(homePrediction > 0)
    {
        [self.homeTeamScoreLabel setText:[NSString stringWithFormat:@"%d", (int)homePrediction]];
        [self.awayTeamScoreLabel setText:[NSString stringWithFormat:@"%d", (int)awayPrediction]];
        self.homeTeamStepper.value = homePrediction;
        self.awayTeamStepper.value = awayPrediction;
    }
    self.matchTimeLabel.text = self.matchTime;*/
}

- (IBAction)predictButtonClicked:(id)sender {
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
            [self submitToServer];
        }
    }
}

-(void)submitToServer
{
    homePrediction = [self.homeTeamScoreLabel.text integerValue];
    NSString *homePredict = self.homeTeamScoreLabel.text;
    awayPrediction = [self.awayTeamScoreLabel.text integerValue];
    NSString *awayPredict = self.awayTeamScoreLabel.text;
    NSString *post = [[NSString alloc] initWithFormat:@"token=%@&matchId=%@&hometeamPrediction=%@&awayteamPrediction=%@",self.userToken,self.matchID,homePredict,awayPredict];
    
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/prediction"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:postData];
    
    
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if( theConnection )
    {
    }
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _responseData = [[NSMutableData alloc] init];
    if (response) {
        NSHTTPURLResponse* newResp = (NSHTTPURLResponse*)response;
        NSLog(@"%ld", (long)newResp.statusCode);
    }
    else {
        NSLog(@"didReceiveResponse: No response received");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_responseData appendData:data];
}

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse*)cachedResponse {
//    return nil;
//}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    if(isDownloaded)
    {
        isDownloaded = NO;
        NSArray *jsonArray=[NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
        NSDictionary *retDictionary = (NSDictionary*)[jsonArray objectAtIndex:0];
        NSString *error = nil;
        error = [[NSString alloc] initWithFormat:@"%@",[retDictionary objectForKey:@"error"]];
        if (error != nil && error.length < 2)
        {
            NSString *message = nil;
            int errorCode = [error intValue];
            switch (errorCode) {
                case 0:
                case 1:
                    message = @"Invalid User. Please reinstall";
                    break;
                case 2:
                    message = @"No scheduled match found";
                    break;
                case 3:
                    message = @"Server Error. Try again later";
                    break;
                case 10:
                    message = @"Please update app before proceeding";
                    break;
                default:
                    message = @"Unknow error";
                    break;
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Retrieve" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            return;
        }
        
        //Match & common
        //self.matchId = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"matchId"]];
        self.matchLocation = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"location"]];
        self.matchStadium = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"venue"]];
        self.matchTime = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"match_time"]];
        self.bettingStatus = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"betting_status"]];
        self.predictionTimeStart = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"predictiontimestart"]];
        self.predictionTimeEnd = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"predictiontimeend"]];
        self.predictiondraw = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"predictiondraw"]];
        
        //Home
        self.homeName = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamhome_name"]];
        self.homeColor = [Utils colorFromHexString:[NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamhome_colour"]]];
        self.homeGuide = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamhome_guide"]];
        if ([self.homeGuide isEqualToString:@"<null>"])
            self.homeGuide = nil;
        homePrediction = [[NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"user_teamhome_prediction"]] integerValue];
        self.teamhome_predicition = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamhome_prediction"]];
        NSString *homeTeamOutcome = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"homeoutcome"]];
        
        //Away
        self.awayName = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamaway_name"]];
        self.awayColor = [Utils colorFromHexString:[NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamaway_colour"]]];
        self.awayGuide = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamaway_guide"]];
        if ([self.awayGuide isEqualToString:@"<null>"])
            self.awayGuide = nil;
        self.teamaway_predicition = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamaway_prediction"]];
        awayPrediction = [[NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"user_teamaway_prediction"]] integerValue];
        NSString *awayTeamOutcome = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"awayoutcome"]];
        
        self.homeTeamNameLabel.text = self.homeName;
        self.homeTeamFormGuideLabel.text = self.homeGuide;
        self.awayTeamNameLabel.text = self.awayName;
        self.awayTeamFormGuideLabel.text = self.awayGuide;
        self.matchVenue.text = self.matchStadium;
        self.matchPlace.text = self.matchLocation;
        self.matchTimeLabel.text = self.matchTime;
        //rahul commented---------
        //[self.homeTeamFormGuideLabel setBackgroundColor:self.homeColor];
        //[self.awayTeamFormguideLabel setBackgroundColor:self.awayColor];
        
        NSString *matchImages = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"leagueLogo"]];
        NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:matchImages]];
        if(matchImages != nil && matchImages.length > 10)
            self.homeTeamLogoImageView.image = [UIImage imageWithData:data];
        
        matchImages = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamhome_logo"]];
        self.homeImageLogo = matchImages;
        data = [[NSData alloc] initWithData:[NSData dataFromBase64String:matchImages]];
        if(matchImages != nil && matchImages.length > 10)
            self.homeTeamLogoImageView.image = [UIImage imageWithData:data];
        
        matchImages = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"teamaway_logo"]];
        self.awayImageLogo = matchImages;
        data = [[NSData alloc] initWithData:[NSData dataFromBase64String:matchImages]];
        if(matchImages != nil && matchImages.length > 10)
            self.awayTeamLogoImageView.image = [UIImage imageWithData:data];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"dd LLLL yyyy HH:mm"];
        NSDate *startTime = [dateFormat dateFromString:self.predictionTimeStart];
        NSDate *endTime =  [dateFormat dateFromString:self.predictionTimeEnd];
        NSDate *now = [NSDate date];
        NSMutableString *lastTimeLabelText = nil;
        if (now.timeIntervalSince1970 > startTime.timeIntervalSince1970 && now.timeIntervalSince1970 < endTime.timeIntervalSince1970)
        {
            self.predictNowButton.enabled = YES;
            lastTimeLabelText = [[NSMutableString alloc] initWithString:@"Closes at: "];
            self.predictNowButton.alpha = 1.0f;
        }
        else
        {
            self.predictNowButton.enabled = NO;
            self.predictNowButton.alpha = 0.5f;
            lastTimeLabelText = [[NSMutableString alloc] initWithString:@"Closed at: "];
            if (homeTeamOutcome.length > 0 && awayTeamOutcome > 0)
            {
                self.homeTeamFormGuideLabel.text = homeTeamOutcome;
                self.awayTeamFormGuideLabel.text = awayTeamOutcome;
            }
        }
        [lastTimeLabelText appendString:self.predictionTimeEnd];
        self.lastTimeLabel.text = lastTimeLabelText;
        if(homePrediction < 0)
        {
            homePrediction = 0;
            awayPrediction = 0;
        }
        [self.homeTeamScoreLabel setText:[NSString stringWithFormat:@"%d", (int)homePrediction]];
        [self.awayTeamScoreLabel setText:[NSString stringWithFormat:@"%d", (int)awayPrediction]];
        self.homeTeamStepper.value = homePrediction;
        self.awayTeamStepper.value = awayPrediction;
    }
    else {
        NSArray *jsonArray=[NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
        NSDictionary *retDictionary = (NSDictionary*)[jsonArray objectAtIndex:0];
        NSString *token = [retDictionary objectForKey:@"success"];
        if(token == nil)
        {
            //NSString *error = nil;
            token = [[NSString alloc] initWithFormat:@"%@",[retDictionary objectForKey:@"error"]];
            int errorCode = [token intValue];
            NSString *message = nil;
            switch (errorCode) {
                case 0:
                case 1:
                    message = @"Invalid User. Please reinstall";
                    break;
                case 2:
                    message = @"No scheduled match found";
                    break;
                case 3:
                    message = @"Server Error. Try again later";
                    break;
                case 10:
                    message = @"Please update app before proceeding";
                    break;
                default:
                    message = @"Unknow error";
                    break;
            }
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Submit" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSString *message = [retDictionary objectForKey:@"success_message"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            [self.delegate saveMatchPrediction:homePrediction away:awayPrediction];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}
- (IBAction)homeTeamStepperValueChanged:(UIStepper*)sender {
    double value = [sender value];
    [self.homeTeamScoreLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
}

- (IBAction)awayTeamStepperValueChanged:(UIStepper*)sender {
    double value = [sender value];
    [self.awayTeamScoreLabel setText:[NSString stringWithFormat:@"%d", (int)value]];
}
@end
