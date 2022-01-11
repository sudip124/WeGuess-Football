//
//  AllMatchesTableViewController.m
//  WeGuess
//
//  Created by Maurice on 29/05/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "AllMatchesTableViewController.h"
#import "Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"
#import "PredictionsViewController.h"

@interface AllMatches: NSObject
@property (nonatomic, strong)NSString *matchDate;
@property (nonatomic, strong)NSString *matchId;
@property (nonatomic, strong)NSString *teamhome_name;
@property (nonatomic, strong)NSString *teamaway_name;
@property (nonatomic, strong)NSString *userPredictionHomeTeam;
@property (nonatomic, strong)NSString *userPredictionAwayTeam;
@property (nonatomic, strong)NSString *homeimage;
@property (nonatomic, strong)NSString *awayimage;
@property (nonatomic, strong)NSString *userpredict;

@end

@implementation AllMatches

@end

@interface AllMatchesTableViewController ()
{
    NSMutableData *_responseData;
    BOOL isFetchedFromServer;
}
@property(nonatomic, strong)NSString *userToken;
@property (nonatomic, strong)NSMutableArray *matchArray;
@end

@implementation AllMatchesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];    
    if (self.matchArray == nil)
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
            if (!isFetchedFromServer)
                [self fetchFromServer];
        }
    }
}
- (void)fetchFromServer
{
    isFetchedFromServer = YES;
    NSString *post = [[NSString alloc] initWithFormat:@"token=%@",self.userToken];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/allmatch"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:postData];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(theConnection){ }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults)
        self.userToken = [standardUserDefaults objectForKey:@"token"];
    
    self.navigationController.navigationBarHidden = YES;
    [[UITabBar appearance] setTintColor:[Utils weGuessyellowColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor colorWithRed:26/255. green:57/255. blue:91/255. alpha:0.9]];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                UITextAttributeFont :               [UIFont fontWithName:@"ContinuumMedium" size:12.0f],
                UITextAttributeTextColor :          [UIColor whiteColor],
                //UITextAttributeTextShadowColor :    [UIColor grayColor],
                UITextAttributeTextShadowOffset:[NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]}forState:UIControlStateNormal];
    
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                UITextAttributeFont :               [UIFont fontWithName:@"ContinuumMedium" size:12.0f],
                UITextAttributeTextColor :          [UIColor whiteColor],
                UITextAttributeTextShadowColor :    [Utils weGuessyellowColor],
                UITextAttributeTextShadowOffset :   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]} forState:UIControlStateSelected];
    isFetchedFromServer = NO;

}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
     return self.matchArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    AllMatches *currentProfile = [self.matchArray objectAtIndex:indexPath.row];
    UILabel *notesLabel = (UILabel*)[cell viewWithTag:100];
    notesLabel.text = currentProfile.matchDate;
    notesLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:notesLabel];
    
    UILabel *pointsLabel = (UILabel*)[cell viewWithTag:101];
    pointsLabel.text = currentProfile.teamhome_name;
    //pointsLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:pointsLabel];
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:102];
    dateLabel.text = currentProfile.teamaway_name;
    //dateLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:dateLabel];
    
    UIImageView *homeImageView = (UIImageView*)[cell viewWithTag:103];
    NSString *homePImage = [currentProfile.homeimage stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
    NSData *hdata = [[NSData alloc] initWithData:[NSData dataFromBase64String:homePImage]];
    if(currentProfile.homeimage != nil && currentProfile.homeimage.length > 10)
        homeImageView.image = [UIImage imageWithData:hdata];
    homeImageView.layer.cornerRadius = 5;
    [cell.contentView addSubview:homeImageView];
    
    UIImageView *awayImageView = (UIImageView*)[cell viewWithTag:104];
    NSString *awayPImage = [currentProfile.awayimage stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
    NSData *adata = [[NSData alloc] initWithData:[NSData dataFromBase64String:awayPImage]];
    if(currentProfile.awayimage != nil && currentProfile.awayimage.length > 10)
        awayImageView.image = [UIImage imageWithData:adata];
    awayImageView.layer.cornerRadius = 5;
    [cell.contentView addSubview:awayImageView];
    NSString *yesText= @"1";
    if ([currentProfile.userpredict isEqualToString:yesText])
    {
        UIImageView *predictImageView = (UIImageView*)[cell viewWithTag:105];
        predictImageView.image = [UIImage imageNamed:@"right"];
        predictImageView.layer.cornerRadius = 5;
        [cell.contentView addSubview:predictImageView];
        
        UILabel *homePredictionLabel = (UILabel*)[cell viewWithTag:110];
        homePredictionLabel.text = currentProfile.userPredictionHomeTeam;
        [cell.contentView addSubview:homePredictionLabel];
        
        UILabel *awayPredictionLabel = (UILabel*)[cell viewWithTag:111];
        awayPredictionLabel.text = currentProfile.userPredictionAwayTeam;
        [cell.contentView addSubview:awayPredictionLabel];
        
    }
    
    if(indexPath.row%2 == 1)
        cell.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:0.1];
    else
        cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,50)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, tableView.frame.size.width,30)];
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [[NSString alloc] initWithFormat:@"Upcoming Matches"];
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.font = [UIFont fontWithName:@"Continuum Medium" size:18];
    headerView.backgroundColor = [UIColor colorWithRed:(250/255.0) green:(203/255.0) blue:(0/255.0) alpha:1];
    [headerView addSubview:headerLabel];
    return headerView;
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,50)];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, tableView.frame.size.width,30)];
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = @"Standings";
    headerLabel.textColor = [UIColor clearColor];
    headerLabel.font = [UIFont fontWithName:@"Continuum Medium" size:20];
    [headerView addSubview:headerLabel];
    return headerView;
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
    if(![jsonData isKindOfClass:[NSArray class]])
    {
        NSDictionary *retVal = (NSDictionary*)[jsonData objectAtIndex:0];
        NSString *retToken = [retVal objectForKey:@"error"];
        if(retToken != nil)
        {
            NSString *message = @"Please update app before proceeding";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        NSArray *matchList = jsonData;
        //totalPoints = 0;
        if(matchList.count > 0)
            self.matchArray = nil;
        self.matchArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < matchList.count; i++) {
            AllMatches *matchObject = [[AllMatches alloc] init];
            NSDictionary *list = [matchList objectAtIndex:i];
            matchObject.matchId=[[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"matchId"]];
            matchObject.matchDate = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"match_time"]];
            matchObject.teamhome_name = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"teamhome_name"]];
            matchObject.teamaway_name = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"teamaway_name"]];
            matchObject.homeimage=[[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"teamhome_logo"]];
            matchObject.awayimage=[[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"teamaway_logo"]];
            matchObject.userpredict=[[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"userpredictionstatus"]];
            matchObject.userPredictionHomeTeam = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"userpredictionhome"]];
            matchObject.userPredictionAwayTeam = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"userpredictionaway"]];
            
            //totalPoints += [invoiceObject.points doubleValue];
            [self.matchArray addObject:matchObject];
        }
        isFetchedFromServer = NO;
        [self.tableView reloadData];
    }
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"detailsegus"])
    {
        NSIndexPath *indexpath=nil;
        indexpath= [self.tableView indexPathForSelectedRow];
        AllMatches *currentProfile = [self.matchArray objectAtIndex:indexpath.row];
        [[segue destinationViewController] setMatchID:currentProfile.matchId];
        [[segue destinationViewController] setDelegate:self];
    }
}

- (void) saveMatchPrediction:(NSInteger)home away:(NSInteger)away
{
    NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
    AllMatches *currentProfile = [self.matchArray objectAtIndex:indexpath.row];
    currentProfile.userPredictionHomeTeam = [[NSString alloc] initWithFormat:@"%d",home];
    currentProfile.userPredictionAwayTeam = [[NSString alloc] initWithFormat:@"%d",away];
    currentProfile.userpredict = @"1";
    [self.tableView reloadData];
}

@end
