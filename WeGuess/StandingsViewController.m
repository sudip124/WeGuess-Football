//
//  StandingsViewController.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "StandingsViewController.h"
#import "Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "UserRankModel.h"
#import "NSData+Base64.h"

@interface StandingsViewController()
{
    NSMutableData *_responseData;
    BOOL isFetchedFromServer;
}
@property(nonatomic, strong)NSMutableArray *rankListAll;
@property(nonatomic, strong)NSMutableArray *rankListFacebook;
@property(nonatomic, strong)UISegmentedControl *segmentedControl;
@end

@implementation StandingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.userToken = [[NSUserDefaults standardUserDefaults] objectForKey:@"token"];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    isFetchedFromServer = NO;
    //[self setupNavigationController];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = YES;
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //[self setupNavigationController];
    if (self.rankListAll == nil && self.rankListFacebook == nil)
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

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)fetchFromServer
{
    isFetchedFromServer = YES;
    NSString *post = [[NSString alloc] initWithFormat:@"token=%@",self.userToken];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
    
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/rank"];
    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:url];
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [theRequest setHTTPBody:postData];
    NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    
    if(theConnection){ }
}
#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger retCount = 1;
    if(self.segmentedControl.selectedSegmentIndex == 0)
        retCount = self.rankListAll.count;
    else
        retCount = self.rankListFacebook.count;
    
    if (retCount == 0)
        return 1;
    else
        return retCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];

    UserRankModel *currentProfile = nil;
    if (self.segmentedControl.selectedSegmentIndex == 0)
        currentProfile = [self.rankListAll objectAtIndex:indexPath.row];
    else
        currentProfile = [self.rankListFacebook objectAtIndex:indexPath.row];
    
    UILabel *currentRank = (UILabel*)[cell viewWithTag:100];
    UIImageView *profileImageView = (UIImageView*)[cell viewWithTag:101];
    UILabel *currentUserName = (UILabel*)[cell viewWithTag:102];
    UILabel *currentUserPoint = (UILabel*)[cell viewWithTag:104];
    if(currentProfile != nil)
    {
        currentRank.text = currentProfile.Rank;
        currentRank.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:currentRank];
        
        currentUserName.text = currentProfile.userName;
        currentUserName.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:currentUserName];
        
        currentUserPoint.text = currentProfile.Point;
        currentUserPoint.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:currentUserPoint];
        
        NSString *profileImage = [currentProfile.profileImage stringByReplacingOccurrencesOfString:@"%2B" withString:@"+"];
        
        NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:profileImage]];
        if(currentProfile.profileImage != nil && currentProfile.profileImage.length > 10)
            profileImageView.image = [UIImage imageWithData:data];
        
        profileImageView.layer.cornerRadius = 5;
        [cell.contentView addSubview:profileImageView];
    }
    else
    {
        currentRank.text = @"";
        currentRank.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:currentRank];
        
        currentUserName.text = @"No profiles found";
        currentUserName.textAlignment = NSTextAlignmentCenter;
        [cell.contentView addSubview:currentUserName];
        
        currentUserPoint.text = @"";
        currentUserPoint.textAlignment = NSTextAlignmentLeft;
        [cell.contentView addSubview:currentUserPoint];
        UILabel *holder = (UILabel*)[cell viewWithTag:103];
        holder.text = @"";
        profileImageView.image = [UIImage imageNamed:@"profile"];
    }
    
    if(indexPath.row%2 == 1)
        cell.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:0.1];
    else
        cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Table view delegate
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 50.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,80)];
    if ( self.segmentedControl == nil)
    {
        self.segmentedControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"All", @"Facebook", nil]];
        self.segmentedControl.frame = CGRectMake(0, 50, 200, 30);
        self.segmentedControl.center = headerView.center;
        self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
        self.segmentedControl.selectedSegmentIndex = 0;
        self.segmentedControl.tintColor = [Utils weGuessyellowColor];
        [self.segmentedControl setTitleTextAttributes:@{
                    UITextAttributeFont :               [UIFont fontWithName:@"ContinuumMedium" size:14.0f],
                    UITextAttributeTextColor :          [UIColor whiteColor],
                    UITextAttributeTextShadowColor :    [Utils weGuessyellowColor],
                    UITextAttributeTextShadowOffset :   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]} forState:UIControlStateNormal];
        [self.segmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents: UIControlEventValueChanged];
    }
    [headerView addSubview:self.segmentedControl];
    CGRect sepFrame = CGRectMake(0, headerView.frame.size.height-1, 320, 0.5);
    UIView *seperatorView = [[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = [Utils weGuessGreenColor];// [UIColor whiteColor];
    [headerView addSubview:seperatorView];
    return headerView;
}

- (void)valueChanged:(UISegmentedControl *)segment {
    [self.tableView reloadData];
    
    /*if(segment.selectedSegmentIndex == 0) {
        //action for the first button (All)
    }else if(segment.selectedSegmentIndex == 1){
        //action for the second button (Present)
    }*/
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0,0,tableView.frame.size.width,50)];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, tableView.frame.size.width,30)];
    
    footerLabel.textAlignment = NSTextAlignmentCenter;
    footerLabel.text = @"Standings";
    footerLabel.textColor = [UIColor clearColor];
    footerLabel.font = [UIFont fontWithName:@"Continuum Medium" size:20];
    [footerView addSubview:footerLabel];
    
    CGRect sepFrame = CGRectMake(0, 0, 320, 0.5);
    UIView *seperatorView = [[UIView alloc] initWithFrame:sepFrame];
    seperatorView.backgroundColor = [Utils weGuessGreenColor];// [UIColor whiteColor];
    [footerView addSubview:seperatorView];
    return footerView;
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
    if([jsonData isKindOfClass:[NSArray class]])
    {
        NSDictionary *retVal = (NSDictionary*)[jsonData objectAtIndex:0];
        NSString *retToken = [retVal objectForKey:@"error"];
        if(retToken != nil)
        {
            NSString *message = @"Unable to fetch Rank!!";
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
            [alert show];
        }
    }
    else
    {
        NSArray *allUsers = (NSArray*)[jsonData objectForKey:@"all"];
        if(allUsers != nil && allUsers.count > 0)
        {
            if(self.rankListAll != nil)
                self.rankListAll = nil;
            self.rankListAll = [[NSMutableArray alloc] init];
            for (int i = 0; i < allUsers.count; i++) {
                UserRankModel *userRank = [[UserRankModel alloc] init];
                NSDictionary *list = [allUsers objectAtIndex:i];
                userRank.userName = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"username"]];
                userRank.profileImage = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"profilepicurl"]];
                userRank.Point = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"point"]];
                userRank.Rank = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"Rank"]];
                userRank->isFacebookList = NO;
                [self.rankListAll addObject:userRank];
            }
        }
        
        NSArray *faceboookUsers = (NSArray*)[jsonData objectForKey:@"facebook"];
        if (faceboookUsers != nil && faceboookUsers.count > 0)
        {
            if(self.rankListFacebook != nil)
                self.rankListFacebook = nil;
            self.rankListFacebook = [[NSMutableArray alloc] init];
            for (int i = 0; i < faceboookUsers.count; i++) {
                UserRankModel *userRank = [[UserRankModel alloc] init];
                NSDictionary *list = [faceboookUsers objectAtIndex:i];
                userRank.userName = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"username"]];
                userRank.profileImage = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"profilepicurl"]];
                userRank.Point = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"point"]];
                userRank.Rank = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"Rank"]];
                userRank->isFacebookList = YES;
                [self.rankListFacebook addObject:userRank];
            }
        }
        isFetchedFromServer = NO;
        [self.tableView reloadData];
    }
}

- (void) setupNavigationController
{
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.barTintColor = [Utils weGuessyellowColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationItem.hidesBackButton = YES;
    self.navigationController.navigationBar.tintColor = [Utils weGuessyellowColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    //self.title = nil;
}
@end
