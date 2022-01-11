//
//  AllMatchesTableViewController.h
//  WeGuess
//
//  Created by Maurice on 29/05/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SavePrediction <NSObject>

- (void) saveMatchPrediction:(NSInteger)home away:(NSInteger)away;

@end

@interface AllMatchesTableViewController : UITableViewController

@end
