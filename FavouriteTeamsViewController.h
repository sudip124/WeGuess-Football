//
//  FavouriteTeamsViewController.h
//  WeGuess
//
//  Created by Maurice on 07/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HorizontalPickerView.h"
#import "TeamDetailsModel.h"
#import "LoginViewController.h"
@protocol SaveTeamProtocol <NSObject>
- (void)saveTeam:(TeamDetailsModel*)team;
@end

@interface FavouriteTeamsViewController : UIViewController<HPickerViewDataSource, HPickerViewDelegate, NSURLConnectionDelegate, SaveTeamProtocol, UIAlertViewDelegate>
@property (nonatomic, strong)NSMutableArray *leagueArray;
@property (weak, nonatomic) IBOutlet UIImageView *leagueLogo;
@property (weak, nonatomic) IBOutlet HorizontalPickerView *leagueNamePicker;
@property (weak, nonatomic) IBOutlet UIImageView *team1Logo;
@property (weak, nonatomic) IBOutlet UILabel *team1Name;
@property (weak, nonatomic) IBOutlet UIImageView *team2Logo;
@property (weak, nonatomic) IBOutlet UILabel *team2Name;
@property (weak, nonatomic) IBOutlet UIImageView *team3Logo;
@property (weak, nonatomic) IBOutlet UILabel *team3Name;
@property(nonatomic, strong)NSString *userToken;
- (IBAction)saveButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property(weak, nonatomic) id<MovetoTabView> delegate;
@property (weak, nonatomic) IBOutlet UIView *holderView;
@property (weak, nonatomic) IBOutlet UIButton *team1DeleteButton;

- (IBAction)favouriteTeamDeleteButtonClicked:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *team2DeleteButton;
@property (weak, nonatomic) IBOutlet UIButton *team3DeleteButton;

@end
