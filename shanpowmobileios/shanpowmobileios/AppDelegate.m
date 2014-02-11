//
//  AppDelegate.m
//  shanpowmobileios
//
//  Created by 木一 on 13-11-29.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

@implementation AppDelegate

@synthesize rootController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    // Init user interface
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.rootController = [[UINavigationController alloc] initWithRootViewController:[[RootViewController alloc] init]];
    self.window.rootViewController = self.rootController;
    
    if (isSysVerGTE(7.0)) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
        [[UITabBar appearance] setTintColor:UIC_CYAN(1.0)];
    }
    
    // WeiboSDK
#ifdef DEBUG
    [WeiboSDK enableDebugMode:YES];
    //  [[NetworkClient sharedNetworkClient] logout];
#endif
    [WeiboSDK registerApp:weiboAppKey];
    
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

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatio
{
    if ([[url absoluteString] rangeOfString:@"tencent"].location == 0) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    if ([[url absoluteString] rangeOfString:@"wb"].location == 0) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboLogin sharedWeiboLogin]];
    }
    
    return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if ([[url absoluteString] rangeOfString:@"tencent"].location == 0) {
        return [TencentOAuth HandleOpenURL:url];
    }
    
    if ([[url absoluteString] rangeOfString:@"wb"].location == 0) {
        return [WeiboSDK handleOpenURL:url delegate:[WeiboLogin sharedWeiboLogin]];
    }
    
    return YES;
}

@end
