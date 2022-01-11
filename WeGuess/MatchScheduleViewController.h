//
//  MatchScheduleViewController.h
//  WeGuess
//
//  Created by Maurice on 30/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>

/*@protocol SavePrediction <NSObject>

- (void) saveMatchPrediction:(NSInteger)home away:(NSInteger)away;

@end*/

//@interface MatchScheduleViewController : UIViewController <NSURLConnectionDelegate, SavePrediction>
@interface MatchScheduleViewController : UIViewController <NSURLConnectionDelegate>

-(void) downloadMatchSchedule;
@property (weak, nonatomic) NSString *matchID;
@property (weak, nonatomic) IBOutlet UIImageView *leagueLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *homeTeamLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *awayTeamLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *stadiumLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamFormGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamFormguideLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;
- (IBAction)predictButtonClicked:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *predictButton;

@end
