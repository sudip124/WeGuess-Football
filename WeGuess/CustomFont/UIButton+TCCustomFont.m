//
//  UIButton+TCCustomFont.m
//  WeGuess
//
//  Created by Team Codez on 20/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "UIButton+TCCustomFont.h"

@implementation UIButton (TCCustomFont)

- (NSString *)fontName {
    return self.titleLabel.font.fontName;
}

- (void)setFontName:(NSString *)fontName {
    self.titleLabel.font = [UIFont fontWithName:fontName size:self.titleLabel.font.pointSize];
}
@end
