//
//  Utils.m
//  WeGuess
//
//  Created by Maurice on 29/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "Utils.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>
#import <QuartzCore/QuartzCore.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define KAShrinkDimension 2
@implementation Utils



+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [Utils getIPAddresses];
    //NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) || (interface->ifa_flags & IFF_LOOPBACK)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                char addrBuf[INET6_ADDRSTRLEN];
                if(inet_ntop(addr->sin_family, &addr->sin_addr, addrBuf, sizeof(addrBuf))) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, addr->sin_family == AF_INET ? IP_ADDR_IPv4 : IP_ADDR_IPv6];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

+ (UIColor *) colorFromHexString:(NSString *)hexString {
    if(hexString == nil || [hexString isEqualToString:@"<null>"])
        return [UIColor colorWithRed:255 green:255 blue:255 alpha:0.7f];
    
    NSString *cleanString = [hexString stringByReplacingOccurrencesOfString:@"#" withString:@""];
    if([cleanString length] == 3) {
        cleanString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                       [cleanString substringWithRange:NSMakeRange(0, 1)],[cleanString substringWithRange:NSMakeRange(0, 1)],
                       [cleanString substringWithRange:NSMakeRange(1, 1)],[cleanString substringWithRange:NSMakeRange(1, 1)],
                       [cleanString substringWithRange:NSMakeRange(2, 1)],[cleanString substringWithRange:NSMakeRange(2, 1)]];
    }
    if([cleanString length] == 6) {
        cleanString = [cleanString stringByAppendingString:@"ff"];
    }
    
    unsigned int baseValue;
    [[NSScanner scannerWithString:cleanString] scanHexInt:&baseValue];
    
    float red = ((baseValue >> 24) & 0xFF)/255.0f;
    float green = ((baseValue >> 16) & 0xFF)/255.0f;
    float blue = ((baseValue >> 8) & 0xFF)/255.0f;
    float alpha = ((baseValue >> 0) & 0xFF)/255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (NSString *)getCountryID:(NSString*)name
{
    NSString *countryId = nil;
    NSMutableArray* countryAllNameList = [[NSMutableArray alloc] init];
    NSMutableArray* countryAllIdList = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"countries" ofType:@"json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    NSError *e = nil;
    
    NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &e];
    data = nil;
    e = nil;
    
    for (NSDictionary *values in JSON)
    {
        NSString *tempid = [NSString stringWithFormat:@"%@", [values objectForKey:@"CountryCode"]];
        [countryAllIdList addObject:tempid];
        NSString *tempName = [NSString stringWithFormat:@"%@", [values objectForKey:@"CountryName"]];
        [countryAllNameList addObject:tempName];
        if([tempName isEqualToString:name])
        {
            countryId = tempid;
            break;
        }
    }
    return countryId;
}



+ (UIImage*)correctCapturedImageOrientation:(UIImage*)viewImage
{
    Boolean isNinetyDegree = NO;
    float rotRad = 0.0;
    
    UIGraphicsBeginImageContext(CGSizeMake(viewImage.size.width, viewImage.size.height));
    CGContextRef graphicsContext = UIGraphicsGetCurrentContext();
    
    switch ([viewImage imageOrientation])
    {
        case UIImageOrientationLeft:
            rotRad = -M_PI_2;
            isNinetyDegree = YES;
            break;
            
        case UIImageOrientationRight:
            rotRad = M_PI_2;
            isNinetyDegree = YES;
            break;
            
        case UIImageOrientationDown:
            rotRad = M_PI;
            isNinetyDegree = NO;
            break;
            
        default:
            break;
    }
    
    
    CGContextTranslateCTM(graphicsContext, viewImage.size.width / KAShrinkDimension, viewImage.size.height / KAShrinkDimension);
    CGContextRotateCTM(graphicsContext, rotRad);
    CGContextScaleCTM(graphicsContext, 1.0, -1.0);
    float height = isNinetyDegree ? viewImage.size.width : viewImage.size.height;
    float width  = isNinetyDegree ? viewImage.size.height : viewImage.size.width;
    CGContextDrawImage(graphicsContext, CGRectMake(-width / KAShrinkDimension, -height / KAShrinkDimension, width, height), [viewImage CGImage]);
    
    if (isNinetyDegree)
        CGContextTranslateCTM(graphicsContext, -viewImage.size.height / KAShrinkDimension, -viewImage.size.width / KAShrinkDimension);
    
    UIImage* rotatedImage = UIGraphicsGetImageFromCurrentImageContext();
    viewImage = nil;
    UIGraphicsEndImageContext();
    return rotatedImage;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    UIGraphicsBeginImageContext( newSize );
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (void)setBackgroundImage:(UIView*)view
{
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"background"]];
    bgImageView.frame = view.bounds;
    [view addSubview:bgImageView];
    [view sendSubviewToBack:bgImageView];
}

+ (NSString*)getAppVersionNumber
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}
+ (NSString*)getAppVersionBuildNumber
{
    NSString * appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString * appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    return [NSString stringWithFormat:@"Version: %@ (%@)", appVersionString, appBuildString];
}

+ (UIColor*)weGuessyellowColor
{
    return [UIColor colorWithRed:247/255. green:194/255. blue:0/255. alpha:1.0];
}


+ (UIColor*)weGuessGreenColor
{
    return [UIColor colorWithRed:0/255. green:146/255. blue:63/255. alpha:1.0];
}

+ (void)setRoundedView:(UIImageView *)roundedView toDiameter:(float)newSize
{
    CGPoint saveCenter = roundedView.center;
    CGRect newFrame = CGRectMake(roundedView.frame.origin.x, roundedView.frame.origin.y, newSize, newSize);
    roundedView.frame = newFrame;
    roundedView.layer.cornerRadius = newSize / 2.0;
    roundedView.center = saveCenter;
    roundedView.clipsToBounds = YES;
    roundedView.layer.masksToBounds = YES;
}
@end
