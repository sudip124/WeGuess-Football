//
//  WeGuessRootViewController.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "WeGuessRootViewController.h"
#import "LoginViewController.h"
#import "FavouriteTeamsViewController.h"
#import "LeaguesModel.h"
#import "Utils.h"

@interface WeGuessRootViewController ()
@property(nonatomic, strong)NSString *userId;
@property(nonatomic, strong)NSString *userToken;
@end

@implementation WeGuessRootViewController
{
    BOOL facebookLogin;
}

- (void) viewDidLoad
{
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{
                    UITextAttributeFont :               [UIFont fontWithName:@"ContinuumMedium" size:20.0f],
                    UITextAttributeTextColor :          [UIColor whiteColor],
                    UITextAttributeTextShadowColor :    [Utils weGuessyellowColor],
                    UITextAttributeTextShadowOffset :   [NSValue valueWithUIOffset:UIOffsetMake(0.0f, 1.0f)]}];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{UITextAttributeFont:[UIFont fontWithName:@"Continuum Medium" size:16.0]} forState:UIControlStateNormal];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[self performSegueWithIdentifier:@"leagueList" sender:self];
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        self.userToken = [standardUserDefaults objectForKey:@"token"];
        //self.userToken = @"Hello";
    }
    
    if (self.userToken != nil && self.userToken.length > 0)
    {
        [self performSegueWithIdentifier:@"first" sender:self];
        facebookLogin = [standardUserDefaults boolForKey:@"facebookLogin"];
    }
    else
    {
        [self performSegueWithIdentifier:@"login" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"login"])
    {
        [segue.destinationViewController setDelegate:self];
    }
    if ([[segue identifier] isEqualToString:@"leagueList"])
    {
        FavouriteTeamsViewController *dest = (FavouriteTeamsViewController*)[segue destinationViewController];
        LeaguesModel *test1 = [[LeaguesModel alloc] init];
        test1.leagueName = @"Barclays Premier League";
        test1.leagueId = @"1";
        test1.leagueLogo = nil;
        
        LeaguesModel *test2 = [[LeaguesModel alloc] init];
        test2.leagueName = @"Serie A";
        test2.leagueId = @"2";
        test2.leagueLogo = nil;
        
        LeaguesModel *test3 = [[LeaguesModel alloc] init];
        test3.leagueName = @"Scottish Premier League";
        test3.leagueId = @"3";
        test3.leagueLogo = nil;
        
        NSMutableArray *testArray = [[NSMutableArray alloc] initWithObjects:test1, test2, test3,nil];
        dest.leagueArray = testArray;
        dest.userToken = @"356a192b7913b04c54574d18c28d46e6395428ab";
    }
}

- (void) saveProfile:(NSString*)user isFacebookLogin:(BOOL)flag
{
    self.userId = user;
    facebookLogin = flag;
    NSLog(@"Facebook login: %@",self.userId);
    NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    
    if (standardUserDefaults) {
        [standardUserDefaults setObject:self.userId forKey:@"userId"];
        [standardUserDefaults setBool:facebookLogin forKey:@"facebookLogin"];
        [standardUserDefaults synchronize];
    }
}
@end
