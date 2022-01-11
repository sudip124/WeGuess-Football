//
//  FavouriteTeamsViewController.m
//  WeGuess
//
//  Created by Maurice on 07/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "FavouriteTeamsViewController.h"
#import "NSData+Base64.h"
#import "LeaguesModel.h"
#import "Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "ModalPickerViewController.h"

@interface FavouriteTeamsViewController()
{
    NSMutableData *_responseData;
    BOOL isFetchedFromServer;
    BOOL isTeam1Selected;
    BOOL isTeam2Selected;
    BOOL isTeam3Selected;
    BOOL isLeagueListEmpty;
    NSString *selectedTeamId1;
    NSString *selectedTeamId2;
    NSString *selectedTeamId3;
    id deleteButtonSender;
}
@property(nonatomic, strong)NSMutableArray *leagueNameList;
@property(nonatomic, strong)NSMutableDictionary *leagueTeamList;
@property(nonatomic, strong)NSString *selectedLeagueId;
@end

@implementation FavouriteTeamsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.backBarButtonItem = nil;
    self.navigationItem.leftBarButtonItem = nil;
    self.holderView.layer.cornerRadius = 5;
    self.saveButton.layer.cornerRadius = 5;
    
    self.leagueTeamList = [[NSMutableDictionary alloc] init];
    self.leagueNamePicker.tintColor = [Utils weGuessyellowColor];
    //self.leagueNamePicker.style = HPStyle_iOS7;
    self.leagueNamePicker.font = [UIFont fontWithName:@"Continuum Medium" size:12];
    self.leagueNamePicker.cropStringIfNecessary = NO;
    
    if (self.userToken == nil)
    {
        NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults)
            self.userToken = [standardUserDefaults objectForKey:@"token"];
    }
    
    [self.team1Name addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(team1Tapped:)]];
    [self.team2Name addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(team2Tapped:)]];
    [self.team3Name addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(team3Tapped:)]];
    
    if(self.leagueArray == nil || self.leagueArray.count <1)
    {
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
                isLeagueListEmpty = YES;
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                NSString *post = [[NSString alloc] initWithFormat:@"token=%@",self.userToken];
                NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
                NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
                
                NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/getuserteamandleague"];
                NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
                [theRequest setHTTPMethod:@"POST"];
                [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
                [theRequest setHTTPBody:postData];
                NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
                
                if(theConnection){ }
            }
        }
    }
    else
        [self setUpUI];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void) setUpUI
{
    LeaguesModel *displayedLeague = nil;
    self.leagueNameList = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.leagueArray.count; i++)
    {
        displayedLeague = (LeaguesModel*)[self.leagueArray objectAtIndex:i];
        [self.leagueNameList addObject:displayedLeague.leagueName];
        if(i == 0)
        {
            self.selectedLeagueId = displayedLeague.leagueId;
            NSString *logo = displayedLeague.leagueLogo;
            NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:logo]];
            if(logo != nil && logo.length > 10)
                self.leagueLogo.image = [UIImage imageWithData:data];
        }
    }
    [self getTeamListFromServer:self.selectedLeagueId];
}

-(void) getTeamListFromServer:(NSString *)leagueId
{
    isFetchedFromServer = YES;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
            NSString *post = [[NSString alloc] initWithFormat:@"token=%@&leagueid=%@",self.userToken,leagueId];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/team"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:postData];
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            if(theConnection ){ }
        }
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}


#pragma mark -  HPickerViewDataSource

- (NSInteger)numberOfRowsInPickerView:(HorizontalPickerView *)pickerView
{
    return self.leagueNameList.count;
}

#pragma mark -  HPickerViewDelegate

- (NSString *)pickerView:(HorizontalPickerView *)pickerView titleForRow:(NSInteger)row
{
    return (NSString*)self.leagueNameList[row];
}

- (void)pickerView:(HorizontalPickerView *)pickerView didSelectRow:(NSInteger)row
{
    LeaguesModel *displayedLeague = (LeaguesModel*)[self.leagueArray objectAtIndex:row];
    NSString *logo = displayedLeague.leagueLogo;
    if(logo != nil && logo.length > 10)
    {
        NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:logo]];
        self.leagueLogo.image = [UIImage imageWithData:data];
    }
    
    self.selectedLeagueId = displayedLeague.leagueId;
    TeamDetailsModel *currentLeagueTeam = [self.leagueTeamList objectForKey:self.selectedLeagueId];
    if (currentLeagueTeam == nil)
        [self getTeamListFromServer:self.selectedLeagueId];
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
    NSError *error = nil;
    id jsonData = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    if (isLeagueListEmpty)
    {
        if([jsonData isKindOfClass:[NSDictionary class]])
        {
            NSArray *favouriteList = [jsonData objectForKey:@"user_team"];
            for (int j = 0; j < favouriteList.count; j++) {
                NSDictionary *favouriteTeam = [favouriteList objectAtIndex:j];
                if (j == 0)
                {
                    selectedTeamId1 = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"id"]];
                    self.team1Name.text = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"team_name"]];
                    
                    NSString *logo = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"team_logo"]];
                    NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:logo]];
                    if(logo != nil && logo.length > 10)
                        self.team1Logo.image = [UIImage imageWithData:data];
                    self.team1DeleteButton.hidden = NO;
                }
                else if (j == 1)
                {
                    selectedTeamId2 = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"id"]];
                    self.team2Name.text = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"team_name"]];
                    
                    NSString *logo = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"team_logo"]];
                    NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:logo]];
                    if(logo != nil && logo.length > 10)
                        self.team2Logo.image = [UIImage imageWithData:data];
                    self.team2DeleteButton.hidden = NO;
                }
                else if (j == 2)
                {
                    selectedTeamId3 = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"id"]];
                    self.team3Name.text = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"team_name"]];
                    
                    NSString *logo = [[NSString alloc] initWithFormat:@"%@",[favouriteTeam objectForKey:@"team_logo"]];
                    NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:logo]];
                    if(logo != nil && logo.length > 10)
                        self.team3Logo.image = [UIImage imageWithData:data];
                    self.team3DeleteButton.hidden = NO;
                }
            }
        }
        NSArray *leagueObjectList = [jsonData objectForKey:@"league"];
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
        isLeagueListEmpty = NO;
        [self setUpUI];
        [self.leagueNamePicker reloadAllComponents];
    }
    else if(isFetchedFromServer)
    {
        isFetchedFromServer = NO;
        if([jsonData isKindOfClass:[NSArray class]])
        {
            NSMutableArray *temp = [[NSMutableArray alloc] init];
            for (int i = 0; i < [jsonData count]; i ++)
            {
                NSDictionary *leagueObject = (NSDictionary*)[jsonData objectAtIndex:i];
                TeamDetailsModel *team = [[TeamDetailsModel alloc] init];
                team.leagueId = self.selectedLeagueId;
                team.teamId = [[NSString alloc] initWithFormat:@"%@",[leagueObject objectForKey:@"id"]];
                team.teamLogo = [[NSString alloc] initWithFormat:@"%@",[leagueObject objectForKey:@"team_logo"]];
                team.teamName = [[NSString alloc] initWithFormat:@"%@",[leagueObject objectForKey:@"team_name"]];
                [temp addObject:team];
            }
            [self.leagueTeamList setObject:temp forKey:self.selectedLeagueId];
        }
        else
        {
            NSDictionary *retVal = (NSDictionary*)[jsonData objectAtIndex:0];
            NSString *retToken = [retVal objectForKey:@"error"];
            if (retToken != nil)
            {
                NSString *message = @"Cant fetch league information";
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
                [alert show];
            }
        }
    }
    else
    {
        NSDictionary *retVal = (NSDictionary*)[jsonData objectAtIndex:0];
        NSString *token = [retVal objectForKey:@"success"];
        if(token == nil)
        {
            //token = [jsonData objectForKey:@"error"];
            NSString *message = @"Unable to submit!!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
        else
        {
            NSString *message = @"Favourites Saved";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
            //[self.navigationController popViewControllerAnimated:YES];
            [self.delegate moveToFirstView];
        }
    }
    
}

- (void) team1Tapped : (id) sender
{
    isTeam1Selected = YES;
    isTeam2Selected = NO;
    isTeam3Selected = NO;
    [self teamTapped:sender];
}

- (void) team2Tapped : (id) sender
{
    isTeam1Selected = NO;
    isTeam2Selected = YES;
    isTeam3Selected = NO;
    [self teamTapped:sender];
}

- (void) team3Tapped : (id) sender
{
    isTeam1Selected = NO;
    isTeam2Selected = NO;
    isTeam3Selected = YES;
    [self teamTapped:sender];
}

- (void) teamTapped : (id) sender
{
    [self performSegueWithIdentifier:@"modalPickerView" sender:self];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"modalPickerView"])
    {
        ModalPickerViewController *dest = (ModalPickerViewController*)[segue destinationViewController];
        dest.teamList = (NSMutableArray*)[self.leagueTeamList objectForKey:self.selectedLeagueId];
        dest.selectedLeagueId = self.selectedLeagueId;
        dest.delegate = self;
        dest = nil;
    }
}

- (void)saveTeam:(TeamDetailsModel*)team
{
    if((selectedTeamId1 != nil && [selectedTeamId1 isEqualToString:team.teamId]) || (selectedTeamId2 != nil && [selectedTeamId2 isEqualToString:team.teamId]) || (selectedTeamId3 != nil && [selectedTeamId3 isEqualToString:team.teamId]))
    {
        NSString *message = [[NSString alloc] initWithFormat:@"%@ already set as favourite",team.teamName];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to save" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:team.teamLogo]];
    if (isTeam1Selected)
    {
        if(team.teamLogo != nil && team.teamLogo.length > 10)
            self.team1Logo.image = [UIImage imageWithData:data];
        self.team1Name.text = team.teamName;
        selectedTeamId1 = team.teamId;
        self.team1DeleteButton.hidden = NO;
    }
    if (isTeam2Selected)
    {
        if(team.teamLogo != nil && team.teamLogo.length > 10)
            self.team2Logo.image = [UIImage imageWithData:data];
        self.team2Name.text = team.teamName;
        selectedTeamId2 = team.teamId;
        self.team2DeleteButton.hidden = NO;
    }
    if (isTeam3Selected)
    {
        if(team.teamLogo != nil && team.teamLogo.length > 10)
            self.team3Logo.image = [UIImage imageWithData:data];
        self.team3Name.text = team.teamName;
        selectedTeamId3 = team.teamId;
        self.team3DeleteButton.hidden = NO;
    }
}
- (IBAction)saveButtonClicked:(id)sender {
    if (selectedTeamId1 == nil && selectedTeamId2 == nil && selectedTeamId3 == nil)
    {
        NSString *message = @"Please select your favorite teams";
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Team Selected" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
        [alert show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
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
            NSMutableString *selectedList = nil;
            if(selectedTeamId1 != nil)
            {
                selectedList = [[NSMutableString alloc] initWithString:selectedTeamId1];
                if (selectedTeamId2 != nil)
                {
                    [selectedList appendString:@","];
                    [selectedList appendString:selectedTeamId2];
                }
                if (selectedTeamId3 != nil)
                {
                    [selectedList appendString:@","];
                    [selectedList appendString:selectedTeamId3];
                }
            }
            else if (selectedTeamId2 != nil)
            {
                [selectedList appendString:@","];
                [selectedList appendString:selectedTeamId2];
                if (selectedTeamId3 != nil)
                {
                    [selectedList appendString:@","];
                    [selectedList appendString:selectedTeamId3];
                }
            }
            else
            {
                [selectedList appendString:@","];
                [selectedList appendString:selectedTeamId3];
            }
            NSString *post = [[NSString alloc] initWithFormat:@"token=%@&team=%@",self.userToken,selectedList];
            
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/saveteam"];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setHTTPBody:postData];
            NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            
            if(theConnection ){ }
        }
    }
}

- (IBAction)favouriteTeamDeleteButtonClicked:(id)sender {
    deleteButtonSender = sender;
    NSString *message = @"Sure you want to remove";
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirmation" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"Cancel", nil) otherButtonTitles:NSLocalizedString(@"OK", nil), nil];
    alert.delegate = self;
    [alert show];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        if (deleteButtonSender == self.team1DeleteButton)
        {
            self.team1Logo.image = [UIImage imageNamed:@"lo-file_bg"];
            self.team1Name.text = @"Select your Favourite";
            selectedTeamId1 = nil;
            self.team1DeleteButton.hidden = YES;
        }
        else if (deleteButtonSender == self.team2DeleteButton)
        {
            self.team2Logo.image = [UIImage imageNamed:@"lo-file_bg"];
            self.team2Name.text = @"Select your Favourite";
            selectedTeamId2 = nil;
            self.team2DeleteButton.hidden = YES;
        }
        else if (deleteButtonSender == self.team3DeleteButton)
        {
            self.team3Logo.image = [UIImage imageNamed:@"lo-file_bg"];
            self.team3Name.text = @"Select your Favourite";
            selectedTeamId3 = nil;
            self.team3DeleteButton.hidden = YES;
        }
    }
}
@end
