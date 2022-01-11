//
//  HelpViewController.m
//  WeGuess
//
//  Created by Sudip on 20/05/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "HelpViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.navigationController.navigationBarHidden = YES;
    [self.helpWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"help/index" ofType:@"html"] isDirectory:NO]]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}
@end
