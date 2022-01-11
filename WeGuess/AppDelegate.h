//
//  AppDelegate.h
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
- (void)sendTokentoServer:(NSData*)token userToken:(NSString*)userToken;
@end
