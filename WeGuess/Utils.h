//
//  Utils.h
//  WeGuess
//
//  Created by Maurice on 29/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject
+ (NSString *)getIPAddress:(BOOL)preferIPv4;
+ (UIColor *) colorFromHexString:(NSString *)hexString;
+ (NSString *)getCountryID:(NSString*)name;
+ (UIImage*)correctCapturedImageOrientation:(UIImage*)viewImage;
+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize;
+ (void)setBackgroundImage:(UIView*)view;
+ (NSString*)getAppVersionNumber;
+ (NSString*)getAppVersionBuildNumber;
+ (UIColor*)weGuessyellowColor;
+ (UIColor*)weGuessGreenColor;
+ (void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize;
@end
