//
//  ModalPickerViewController.m
//  WeGuess
//
//  Created by Team Codez on 12/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "ModalPickerViewController.h"
#import "NSData+Base64.h"
#import "Utils.h"
@interface ModalPickerViewController ()

@end

@implementation ModalPickerViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.title = @"Select One";
    //self.navigationController.navigationBar.backgroundColor = [Utils weGuessRedColor];
    //[Utils setBackgroundImage:self.view];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.teamList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    TeamDetailsModel *currentTeam = (TeamDetailsModel*)[self.teamList objectAtIndex:indexPath.row];
    UILabel *titleLabel = (UILabel*)[cell viewWithTag:101];
    titleLabel.text = currentTeam.teamName;
    //titleLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView addSubview:titleLabel];
    
    UIImageView *teamLogo = (UIImageView*)[cell viewWithTag:100];
    NSData *data = [[NSData alloc] initWithData:[NSData dataFromBase64String:currentTeam.teamLogo]];
    if(currentTeam.teamLogo != nil && currentTeam.teamLogo.length > 10)
        teamLogo.image = [Utils imageWithImage:[UIImage imageWithData:data] scaledToSize:CGSizeMake(40, 40)];
    
    [cell.contentView addSubview:teamLogo];
    if(indexPath.row%2 == 1)
        cell.backgroundColor = [UIColor colorWithRed:255/255. green:255/255. blue:255/255. alpha:0.1];
    else
        cell.backgroundColor = [UIColor clearColor];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(saveTeam:)]) {
        [self.delegate saveTeam:(TeamDetailsModel*)[self.teamList objectAtIndex:indexPath.row]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)cancelButtonClicked:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self.delegate saveTeam:nil];
}
@end
