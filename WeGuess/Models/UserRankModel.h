//
//  UserRankModel.h
//  WeGuess
//
//  Created by Team Codez on 15/04/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserRankModel : NSObject
{
    @public
    BOOL isFacebookList;
}
@property(nonatomic,strong) NSString *userName;
@property(nonatomic,strong) NSString *profileImage;
@property(nonatomic,strong) NSString *Point;
@property(nonatomic,strong) NSString *Rank;
@end
