//
//  UITextField+TCCustomFont.m
//  WeGuess
//
//  Created by Team Codez on 20/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "UITextField+TCCustomFont.h"

@implementation UITextField (TCCustomFont)

- (NSString *)fontName {
    return self.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.font = [UIFont fontWithName:fontName size:self.font.pointSize];
}

@end
