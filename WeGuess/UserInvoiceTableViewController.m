//
//  UserInvoiceTableViewController.m
//  WeGuess
//
//  Created by Team Codez on 20/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "UserInvoiceTableViewController.h"
#import "Reachability.h"
#import "Utils.h"
#import "MBProgressHUD.h"
#import "NSData+Base64.h"

@interface InvoiceDetails : NSObject
@property (nonatomic, strong)NSString *notes;
@property (nonatomic, strong)NSString *date;
@property (nonatomic, strong)NSString *points;
@end

@implementation InvoiceDetails

@end

@interface UserInvoiceTableViewController ()
{
    NSMutableData *_responseData;
    double totalPoints;
    BOOL isFetchedFromServer;
}

@property(nonatomic, strong)NSString *userToken;
@property (nonatomic, strong)NSMutableArray *invoiceArray;
@end

@implementation UserInvoiceTableViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.invoiceArray == nil)
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
    
    NSURL *url = [NSURL URLWithString:@"http://www.weguesstheapp.com/weguesswebservice/invoice"];
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
    totalPoints = 0;
    isFetchedFromServer = NO;
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.invoiceArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    InvoiceDetails *currentProfile = [self.invoiceArray objectAtIndex:indexPath.row];
    UILabel *notesLabel = (UILabel*)[cell viewWithTag:100];
    notesLabel.text = currentProfile.notes;
    //notesLabel.text = [[NSString alloc] initWithFormat:@"Row: %d  Value%d",indexPath.row,indexPath.row%2];
    notesLabel.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:notesLabel];
    
    UILabel *pointsLabel = (UILabel*)[cell viewWithTag:101];
    pointsLabel.text = currentProfile.points;
    pointsLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:pointsLabel];
    
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:102];
    dateLabel.text = currentProfile.date;
    dateLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:dateLabel];
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
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 19, tableView.frame.size.width,30)];
    
    headerLabel.textAlignment = NSTextAlignmentCenter;
    headerLabel.text = [[NSString alloc] initWithFormat:@"Total Points: %.0f",totalPoints];
    headerLabel.textColor = [UIColor colorWithRed:26/255. green:57/255. blue:91/255. alpha:1.0];
    headerLabel.font = [UIFont fontWithName:@"Continuum Medium" size:16];
    headerView.backgroundColor = [Utils weGuessyellowColor];
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
        NSArray *invoiceList = jsonData;
        totalPoints = 0;
        if(invoiceList.count > 0)
            self.invoiceArray = nil;
        self.invoiceArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < invoiceList.count; i++) {
            InvoiceDetails *invoiceObject = [[InvoiceDetails alloc] init];
            NSDictionary *list = [invoiceList objectAtIndex:i];
            invoiceObject.points = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"point"]];
            invoiceObject.date = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"date_time"]];
            invoiceObject.notes = [[NSString alloc] initWithFormat:@"%@",[list objectForKey:@"note"]];
            totalPoints += [invoiceObject.points doubleValue];
            [self.invoiceArray addObject:invoiceObject];
        }
        isFetchedFromServer = NO;
        [self.tableView reloadData];
    }
}
@end
