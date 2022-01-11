//
//  AboutViewController.m
//  WeGuess
//
//  Created by Sudip on 19/05/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "AboutViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"pattern"]];
    self.navigationController.navigationBarHidden = YES;
    [self.aboutWebView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"about/about" ofType:@"html"] isDirectory:NO]]];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}


@end
