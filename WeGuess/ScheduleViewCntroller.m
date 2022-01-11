//
//  FirstViewController.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "ScheduleViewCntroller.h"
#import "Reachibility/Reachability.h"

@interface ScheduleViewCntroller ()

@property (strong, nonatomic) UIActivityIndicatorView *progressIndicator;
@property (strong, nonatomic) NSMutableArray *scheduleItemList;
@property (strong, nonatomic) NSMutableDictionary *scheduleItem;
@property (strong, nonatomic) NSMutableString *matchDate;
@property (strong, nonatomic) NSMutableString *country1;
@property (strong, nonatomic) NSMutableString *country2;
@property (strong, nonatomic) NSMutableString *scorePrediction;
@end

@implementation ScheduleViewCntroller

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
	
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.scheduleItemList = [[NSMutableArray alloc] init];
    //[self startScheduleDownload]; ///////////TEST************
    Reachability* internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    switch (netStatus)
    {
        case NotReachable:
        {
            NSLog(@"Access Not Available");
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
            [self.progressIndicator stopAnimating];
            break;
        }
            
        case ReachableViaWWAN:
        {
            NSLog(@"Reachable WWAN");
            [self startScheduleDownload];
            break;
        }
        case ReachableViaWiFi:
        {
            NSLog(@"Reachable WiFi");
            [self startScheduleDownload];
            break;
        }
        default:
        {
            NSLog(@"Internet Reachable");
            [self startScheduleDownload];
        }
    }
}

- (void)startScheduleDownload
{
    ////////********************TEST*********************!!!!
    self.scheduleItem    = [[NSMutableDictionary alloc] init];
    self.matchDate = [[NSMutableString alloc] initWithString:@"Friday, 13 August 2014 1:30 pm"];
    self.country1 = [[NSMutableString alloc] initWithString:@"Brazil"];
    self.country2 = [[NSMutableString alloc] initWithString:@"Argentina"];
    self.scorePrediction = [[NSMutableString alloc] initWithString:@"n.p."];
    [self.scheduleItem setObject:self.matchDate forKey:@"date"];
    [self.scheduleItem setObject:self.country1 forKey:@"country1Name"];
    [self.scheduleItem setObject:self.country2 forKey:@"country2Name"];
    [self.scheduleItem setObject:self.scorePrediction forKey:@"scorePrediction"];
    [self.scheduleItemList addObject:[self.scheduleItem copy]];
    
    self.scheduleItem    = [[NSMutableDictionary alloc] init];
    self.matchDate = [[NSMutableString alloc] initWithString:@"Monday, 19 August 2014 11:30 am"];
    self.country1 = [[NSMutableString alloc] initWithString:@"Germany"];
    self.country2 = [[NSMutableString alloc] initWithString:@"Spain"];
    self.scorePrediction = [[NSMutableString alloc] initWithString:@"(1 - 0)"];
    [self.scheduleItem setObject:self.matchDate forKey:@"date"];
    [self.scheduleItem setObject:self.country1 forKey:@"country1Name"];
    [self.scheduleItem setObject:self.country2 forKey:@"country2Name"];
    [self.scheduleItem setObject:self.scorePrediction forKey:@"scorePrediction"];
    [self.scheduleItemList addObject:[self.scheduleItem copy]];
    [self.tableView reloadData];
    ////////********************TEST*********************!!!!
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSLog(@"*********Number of rows: %lu",(unsigned long)self.scheduleItemList.count);
    long rowCount = self.scheduleItemList.count;
    
    if(rowCount == 0)
        return 1;
    else
        return rowCount;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if(self.scheduleItemList.count == 0)
    {
        self.progressIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        UIView *viewProgress = [[UIView alloc] initWithFrame:CGRectMake(150, 20, 320, 50)];
        [viewProgress addSubview:self.progressIndicator]; // <-- Your UIActivityIndicatorView
        [cell addSubview:viewProgress];
        [self.progressIndicator startAnimating];
        return cell;
    }
    UILabel *dateLabel = (UILabel*)[cell viewWithTag:100];
    dateLabel.text = [[self.scheduleItemList objectAtIndex:indexPath.row] objectForKey: @"date"];
    [cell addSubview:dateLabel];
    
    UILabel *country1Name = (UILabel*)[cell viewWithTag:101];
    country1Name.textAlignment = NSTextAlignmentLeft;
    country1Name.text = [[self.scheduleItemList objectAtIndex:indexPath.row] objectForKey: @"country1Name"];
    [cell addSubview:country1Name];
    
    UILabel *country2Name = (UILabel*)[cell viewWithTag:102];
    country2Name.textAlignment = NSTextAlignmentRight;
    country2Name.text = [[self.scheduleItemList objectAtIndex:indexPath.row] objectForKey: @"country2Name"];
    [cell addSubview:country2Name];
    
    UIImageView *flag1= (UIImageView*)[cell viewWithTag:103];
    flag1.image = [UIImage imageNamed:@"first"];
    flag1.layer.cornerRadius = 5;
    flag1.layer.masksToBounds = YES;
    flag1.clipsToBounds =YES;
    [cell addSubview:flag1];
    
    UIImageView *flag2= (UIImageView*)[cell viewWithTag:104];
    flag2.image = [UIImage imageNamed:@"first"];
    flag2.layer.cornerRadius = 5;
    flag2.layer.masksToBounds = YES;
    flag2.clipsToBounds =YES;
    [cell addSubview:flag2];
    
    UILabel *scorePredict = (UILabel*)[cell viewWithTag:105];
    scorePredict.text = [[self.scheduleItemList objectAtIndex:indexPath.row] objectForKey: @"scorePrediction"];
    [cell addSubview:scorePredict];
    
    return cell;
}

@end
