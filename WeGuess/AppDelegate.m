//
//  AppDelegate.m
//  WeGuess
//
//  Created by Maurice on 26/03/14.
//  Copyright (c) 2014 Codez. All rights reserved.
//

#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "HorizontalPickerView.h"
#import "Reachability.h"
#import <AudioToolbox/AudioToolbox.h>
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [FBLoginView class];
    [HorizontalPickerView class];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
     (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    application.applicationIconBadgeNumber = 0;
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [FBSession.activeSession close];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    

    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    return wasHandled;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
    [standardUserDefaults setObject:deviceToken forKey:@"deviceToken"];
    [standardUserDefaults synchronize];
}

- (void)sendTokentoServer:(NSData*)token userToken:(NSString*)userToken
{
#if !TARGET_IPHONE_SIMULATOR
    
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
	NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
	NSUInteger rntypes = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
	NSString *pushBadge = @"disabled";
	NSString *pushAlert = @"disabled";
	NSString *pushSound = @"disabled";

	if(rntypes == UIRemoteNotificationTypeBadge)
		pushBadge = @"enabled";
	else if(rntypes == UIRemoteNotificationTypeAlert)
		pushAlert = @"enabled";
	else if(rntypes == UIRemoteNotificationTypeSound)
		pushSound = @"enabled";
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	else if(rntypes == ( UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)){
		pushBadge = @"enabled";
		pushAlert = @"enabled";
		pushSound = @"enabled";
	}
	
	UIDevice *dev = [UIDevice currentDevice];
	NSString *deviceUuid = [[dev identifierForVendor] UUIDString];
    NSString *deviceName = dev.name;
	NSString *deviceModel = dev.model;
	NSString *deviceSystemVersion = dev.systemVersion;
	
	NSString *deviceToken = [[[[token description] stringByReplacingOccurrencesOfString:@"<"withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString: @" " withString: @""];
	
	/*
     http://www.weguesstheapp.com/weguesswebservice/forms/registerpushnotification.php?token=356a192b7913b04c54574d18c28d46e6395428ab&appname=weguess&appversion=1.0&devicename=ios&deviceuid=8C515A14-BA6C-4E71-A6AE-2BDE2B6CCE6C&devicetoken=366363434105366a0fbdd4829e30591c1edf851a099a2496e2614ddf701344c8&devicemodel=iPhone&deviceversion=7.0.4&pushbadge=%20enabled&pushalert=%20enabled&pushsound=enabled*/
    NSString *host = @"weguesstheapp.com/weguesswebservice/forms";
	NSString *urlString = [NSString stringWithFormat:@"/registerpushnotification.php?token=%@&appname=%@&appversion=%@&deviceuid=%@&devicetoken=%@&devicename=%@&devicemodel=%@&deviceversion=%@&pushbadge=%@&pushalert=%@&pushsound=%@", userToken, appName,appVersion, deviceUuid, deviceToken, deviceName, deviceModel, deviceSystemVersion, pushBadge, pushAlert, pushSound];
	
	NSURL *url = [[NSURL alloc] initWithScheme:@"http" host:host path:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSURLResponse *response = nil;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if (returnData != nil)
        NSLog(@"returnData: %@ response%@",returnData, [response description]);
#endif
    
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
#if !TARGET_IPHONE_SIMULATOR
    
	NSLog(@"remote notification: %@",[userInfo description]);
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
	
	NSString *alert = [NSString stringWithFormat:@"%@ ",[apsInfo objectForKey:@"alert"]];
    if(alert != nil && alert.length > 3)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"WeGuess" message:alert delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
	
	NSString *sound = [apsInfo objectForKey:@"sound"];
	NSLog(@"Received Push Sound: %@", sound);
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	NSString *badge = [apsInfo objectForKey:@"badge"];
	NSLog(@"Received Push Badge: %@", badge);
	application.applicationIconBadgeNumber = [[apsInfo objectForKey:@"badge"] integerValue];
	
#endif
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (response) {
        NSHTTPURLResponse* newResp = (NSHTTPURLResponse*)response;
        NSLog(@"AppDelegate Status code: %ld", (long)newResp.statusCode);
    }
}

@end
