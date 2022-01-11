//
//  SecondViewController.h
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AllMatchesTableViewController.h"

@interface PredictionsViewController : UIViewController <NSURLConnectionDelegate>
{
    @public
    NSInteger homePrediction;
    NSInteger awayPrediction;
}
@property(nonatomic, weak)NSString *userToken;
//@property(nonatomic, weak)NSString *matchId;
@property(nonatomic, weak)NSString *bettingStatus;
@property(nonatomic, weak)NSString *matchTime;
@property(nonatomic, weak)UIColor *awayColor;
@property(nonatomic, weak)NSString *awayGuide;
@property(nonatomic, weak)NSString *awayName;
@property(nonatomic, weak)NSString *awayImageLogo;
@property(nonatomic, weak)UIColor *homeColor;
@property(nonatomic, weak)NSString *homeGuide;
@property(nonatomic, weak)NSString *homeName;
@property(nonatomic, weak)NSString *homeImageLogo;
@property(nonatomic, strong)NSString *teamhome_predicition;
@property(nonatomic, strong)NSString *teamaway_predicition;
@property(nonatomic, strong)NSString *predictiondraw;
@property (weak, nonatomic) NSString *matchID;
//@property(nonatomic, strong)NSArray *goalNumber;
@property(nonatomic, weak)id<SavePrediction> delegate;
@property (weak, nonatomic) IBOutlet UIButton *predictNowButton;
@property (weak, nonatomic) IBOutlet UIView *homeTeamView;
@property (weak, nonatomic) IBOutlet UIView *awayTeamView;
@property (weak, nonatomic) IBOutlet UIImageView *homeTeamLogoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *awayTeamLogoImageView;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamScoreLabel;
@property (weak, nonatomic) IBOutlet UIStepper *homeTeamStepper;
@property (weak, nonatomic) IBOutlet UIStepper *awayTeamStepper;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *bettingName;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamBetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamBetNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamBetScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamBetScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *drawbetScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchPlace;
@property (weak, nonatomic) IBOutlet UILabel *matchVenue;
@property (weak, nonatomic) IBOutlet UILabel *homeTeamFormGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *awayTeamFormGuideLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastTimeLabel;
- (IBAction)predictButtonClicked:(id)sender;
- (IBAction)homeTeamStepperValueChanged:(UIStepper*)sender;
- (IBAction)awayTeamStepperValueChanged:(UIStepper*)sender;
@end
