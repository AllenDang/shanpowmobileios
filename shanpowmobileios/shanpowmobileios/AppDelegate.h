//
//  AppDelegate.h
//  shanpowmobileios
//
//  Created by 木一 on 13-11-29.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "Common.h"
#import "NetworkClient.h"
#import "NSData+Base64.h"
#import "WeiboSDK.h"
#import "WeiboLogin.h"
#import "MainMenuViewController.h"
#import "UserProfileViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UITabBarController *mainTabBar;
@property (strong, nonatomic) UINavigationController *mainMenuController;
@property (strong, nonatomic) UINavigationController *userProfileController;

@end
