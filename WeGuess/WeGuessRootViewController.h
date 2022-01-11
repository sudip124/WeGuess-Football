//
//  WeGuessRootViewController.h
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserProfile

- (void) saveProfile:(NSString*)user isFacebookLogin:(BOOL)flag;

@end;

@interface WeGuessRootViewController : UIViewController <UserProfile>
@end
