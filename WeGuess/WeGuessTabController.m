//
//  WeGuessTabController.m
//  WeGuess
//
//  Created by Sudip on 20/05/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "WeGuessTabController.h"
#import "Utils.h"

@interface WeGuessTabController ()

@end

@implementation WeGuessTabController



-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.moreNavigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.moreNavigationController.navigationBar.shadowImage = [UIImage new];
    self.moreNavigationController.navigationBar.translucent = YES;
    self.moreNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.moreNavigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.moreNavigationController.navigationBar setTitleTextAttributes:@{
                    UITextAttributeFont :               [UIFont fontWithName:@"ContinuumMedium" size:20.0f],
                    UITextAttributeTextColor :          [UIColor whiteColor],
                    UITextAttributeTextShadowColor :    [Utils weGuessyellowColor],
                    UITextAttributeTextShadowOffset :   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]}];

    self.moreNavigationController.navigationBarHidden = YES;
    self.customizableViewControllers = nil;
    
    NSArray *tabBarItems = [self.tabBar items];
    UITabBarItem *item = [tabBarItems objectAtIndex:0];
    [item setFinishedSelectedImage:[UIImage imageNamed:@"prediction_red"] withFinishedUnselectedImage:[UIImage imageNamed:@"prediction_blue"]];
    
    item = [tabBarItems objectAtIndex:1];
    [item setFinishedSelectedImage:[UIImage imageNamed:@"favorites_red"] withFinishedUnselectedImage:[UIImage imageNamed:@"favorites_blue"]];
    
    item = [tabBarItems objectAtIndex:2];
    [item setFinishedSelectedImage:[UIImage imageNamed:@"standings_red"] withFinishedUnselectedImage:[UIImage imageNamed:@"standings_blue"]];
    
    item = [tabBarItems objectAtIndex:3];
    [item setFinishedSelectedImage:[UIImage imageNamed:@"invoice_red"] withFinishedUnselectedImage:[UIImage imageNamed:@"invoice_blue"]];
    
    UITableView *moreTableView = (UITableView *)self.moreNavigationController.topViewController.view;
    [moreTableView setBackgroundColor:[UIColor colorWithRed:26/255. green:57/255. blue:91/255. alpha:1.0]];
    [self.moreNavigationController setDelegate:self];
    originalDataSource = [(UITableView *)self.moreNavigationController.topViewController.view dataSource];
    [(UITableView *)self.moreNavigationController.topViewController.view  setDataSource:self];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [originalDataSource tableView:tableView numberOfRowsInSection:section];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [originalDataSource tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
    [cell.textLabel setFont:[UIFont fontWithName:@"ContinuumMedium" size:20.0f]];
    [cell.textLabel setTextColor:[UIColor whiteColor]];
    [cell.imageView setAlpha:0.5f];
    if(indexPath.row == 0)
    {
        cell.imageView.image = [UIImage imageNamed:@"accout_blue"];
    }
    cell.backgroundColor = [UIColor clearColor];
    cell.backgroundView = [UIView new] ;
    cell.selectedBackgroundView = [UIView new];
    return cell;
}


- (void) tabBarController:(UITabBarController *)controller willBeginCustomizingViewControllers:(NSArray *)viewControllers {
    
    // Set the color of the navigationbar if edit was selected
    UIView *editView = [controller.view.subviews objectAtIndex:1];
    UINavigationBar *modalNavBar = [editView.subviews objectAtIndex:0];
    modalNavBar.tintColor = [UIColor colorWithRed:27 green:57 blue:91 alpha:0.8f];
}

@end
