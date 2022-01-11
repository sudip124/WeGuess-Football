//
//  ModalPickerViewController.h
//  WeGuess
//
//  Created by Team Codez on 12/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TeamDetailsModel.h"
#import "FavouriteTeamsViewController.h"

@interface ModalPickerViewController : UITableViewController
@property(nonatomic, weak)NSMutableArray *teamList;
@property(nonatomic, weak)NSString *selectedLeagueId;
@property(nonatomic, weak)id<SaveTeamProtocol> delegate;
- (IBAction)cancelButtonClicked:(id)sender;
@end
