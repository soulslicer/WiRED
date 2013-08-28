//
//  AppDelegate.m
//  WiRED
//
//  Created by Yaadhav Raaj on 3/7/13.
//  Copyright (c) 2013 Yaadhav Raaj. All rights reserved.
//

#import "AppDelegate.h"
#import "SVProgressHUD.h"
#import "UserDefaults.h"

@implementation AppDelegate
@synthesize networkLayer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"Starting Network Layer..");
    self.networkLayer=[[NetworkLayer alloc]init];
    [self.networkLayer setHostPortName:[UserDefaults getServerIP] port:PORT];
    self.modIRCode=[[ModifyIRCode alloc]init];
    self.irDeviceView=[[AddIRDeviceView alloc]init];
    self.irCodeView=[[AddIRCodeView alloc]init];
    self.remoteView=[[RemoteControlView alloc]init];
    
    UIColor* background=[[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] colorWithAlphaComponent:1.0];
    [[SVProgressHUD appearance] setHudBackgroundColor:background];
    [[SVProgressHUD appearance] setHudForegroundColor:[UIColor darkGrayColor]];
    [[SVProgressHUD appearance] setHudFont:[UIFont fontWithName:@"Helvetica-Light" size:16]];
    [[SVProgressHUD appearance] setHudStatusShadowColor:background];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"returned");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
