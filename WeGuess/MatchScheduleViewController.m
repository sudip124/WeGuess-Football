//
//  MatchScheduleViewController.m
//  WeGuess
//
//  Created by Maurice on 30/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "MatchScheduleViewController.h"
#import "Reachibility/Reachability.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"
#import "PredictionsViewController.h"
#import "Utils.h"

@interface MatchScheduleViewController ()
{
    NSInteger homePrediction;
    NSInteger awayPrediction;
    BOOL isFetchedFromServer;
}
@property(nonatomic, strong)NSString *userToken;
//@property(nonatomic, strong)NSString *matchId;
@property(nonatomic, strong)NSString *bettingStatus;
@property(nonatomic, strong)NSString *matchLocation;
@property(nonatomic, strong)NSString *matchVenue;
@property(nonatomic, strong)NSString *matchTime;
@property(nonatomic, strong)UIColor *awayColor;
@property(nonatomic, strong)NSString *awayGuide;
@property(nonatomic, strong)NSString *awayName;
@property(nonatomic, strong)NSString *awayImageLogo;
@property(nonatomic, strong)UIColor *homeColor;
@property(nonatomic, strong)NSString *homeGuide;
@property(nonatomic, strong)NSString *homeName;
@property(nonatomic, strong)NSString *homeImageLogo;
@property(nonatomic, strong)NSString *predictionTimeStart;
@property(nonatomic, strong)NSString *predictionTimeEnd;
@property(nonatomic, strong)NSString *teamhome_predicition;
@property(nonatomic, strong)NSString *teamaway_predicition;
@property(nonatomic, strong)NSString *predictiondraw;
@end

@implementation MatchScheduleViewController
{
    NSMutableData *_responseData;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.navigationController.navigationBarHidden = NO;
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.predictButton.layer.cornerRadius = 5;
    [self.predictButton setTitle:@"Predict" forState:UIControlStateNormal];
    [self.predictButton setTitle:@"Prediction Closed" forState:UIControlStateDisabled];
    //[self.tabBarController.tabBar setBackgroundColor:[UIColor clearColor]];
    
    isFetchedFromServer = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.homeName == nil)
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
            if (!isFetchedFromServer)
                [self downloadMatchSchedule];
        }
    }
}

- (void)downloadMatchSchedule
{
    isFetchedFromServer = YES;
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
    isFetchedFromServer = NO;
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to register" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    //Match & common
    //self.matchId = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"matchId"]];
    self.matchLocation = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"location"]];
    self.matchVenue = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"venue"]];
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
    self.awayTeamFormguideLabel.text = self.awayGuide;
    self.stadiumLabel.text = self.matchVenue;
    self.placeLabel.text = self.matchLocation;
    self.matchTimeLabel.text = self.matchTime;
    //rahul commented---------
    //[self.homeTeamFormGuideLabel setBackgroundColor:self.homeColor];
    //[self.awayTeamFormguideLabel setBackgroundColor:self.awayColor];
    
    NSString *matchImages = [NSString stringWithFormat:@"%@", [retDictionary objectForKey:@"leagueLogo"]];
    NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:matchImages]];
    if(matchImages != nil && matchImages.length > 10)
        self.leagueLogoImageView.image = [UIImage imageWithData:data];
    
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
        self.predictButton.enabled = YES;
        lastTimeLabelText = [[NSMutableString alloc] initWithString:@"Closes at: "];
        self.predictButton.alpha = 1.0f;
    }
    else
    {
        self.predictButton.enabled = NO;
        self.predictButton.alpha = 0.5f;
        lastTimeLabelText = [[NSMutableString alloc] initWithString:@"Closed at: "];
        if (homeTeamOutcome.length > 0 && awayTeamOutcome > 0)
        {
            self.homeTeamFormGuideLabel.text = homeTeamOutcome;
            self.awayTeamFormguideLabel.text = awayTeamOutcome;
        }
    }
    [lastTimeLabelText appendString:self.predictionTimeEnd];
    self.lastTimeLabel.text = lastTimeLabelText;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"MatchSchedule:didFailWithError: %@",error.description);
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (IBAction)predictButtonClicked:(id)sender {
    
    [self performSegueWithIdentifier:@"predict" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"predict"])
    {
        PredictionsViewController *dest = (PredictionsViewController*)[segue destinationViewController];
        dest.userToken = self.userToken;
        //dest.matchId = self.matchID;
        dest.bettingStatus = self.bettingStatus;
        dest.matchTime = self.matchTime;
        dest.awayColor = self.awayColor;
        dest.awayName = self.awayName;
        dest.awayGuide = self.awayGuide;
        dest->awayPrediction = awayPrediction;
        dest.awayImageLogo = self.awayImageLogo;
        dest.homeColor = self.homeColor;
        dest.homeName = self.homeName;
        dest.homeGuide = self.homeGuide;
        dest->homePrediction = homePrediction;
        dest.homeImageLogo = self.homeImageLogo;
        dest.delegate = self;
        dest.teamhome_predicition = self.teamhome_predicition;
        dest.teamaway_predicition = self.teamaway_predicition;
        dest.predictiondraw = self.predictiondraw;
    }
}

- (void) saveMatchPrediction:(NSInteger)home away:(NSInteger)away
{
    homePrediction = home;
    awayPrediction = away;
}

@end
