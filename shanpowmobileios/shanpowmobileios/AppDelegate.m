//
//  AppDelegate.m
//  shanpowmobileios
//
//  Created by 木一 on 13-11-29.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "AppDelegate.h"
#import "AFNetworking.h"

@interface AppDelegate ()

@property (nonatomic, strong) MainMenuViewController *menuController;
@property (nonatomic, strong) UserProfileViewController *userController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window makeKeyAndVisible];

	// Init user interface
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

	// Prepare view controllers
	self.menuController = [[MainMenuViewController alloc] init];

	self.mainMenuController = [[UINavigationController alloc] initWithRootViewController:self.menuController];

	self.userController = [[UserProfileViewController alloc] init];
	self.userController.isSelf = YES;

	self.userProfileController = [[UINavigationController alloc] initWithRootViewController:self.userController];

	// Prepare tab bar controller
	UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"Home"] tag:1];
	UITabBarItem *userItem = [[UITabBarItem alloc] initWithTitle:@"我的山坡" image:[UIImage imageNamed:@"User"] tag:2];

	self.mainMenuController.tabBarItem = homeItem;
	self.userProfileController.tabBarItem = userItem;

	self.mainTabBar = [[UITabBarController alloc] init];
	self.mainTabBar.delegate = self;
	[self.mainTabBar setViewControllers:@[self.mainMenuController, self.userProfileController]];

	// Add tab bar controller to window
	self.window.rootViewController = self.mainTabBar;

	// Customize the appearance of uinavigationbar and uitabbar
	if (IsSysVerGTE(7.0)) {
		[[UITabBar appearance] setTintColor:UIC_CYAN(1.0)];

		[self.mainMenuController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forBarMetrics:UIBarMetricsDefault];
		self.mainMenuController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		self.mainMenuController.navigationBar.tintColor = [UIColor whiteColor];

		[self.userProfileController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forBarMetrics:UIBarMetricsDefault];
		self.userProfileController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
		self.userProfileController.navigationBar.tintColor = [UIColor whiteColor];

		self.mainTabBar.tabBar.barTintColor = UIC_BRIGHT_GRAY(1.0);
		[self.mainTabBar.tabBar setTranslucent:NO];
	}
	else {
		self.mainMenuController.navigationBar.barStyle = UIBarStyleDefault;
		self.mainMenuController.navigationBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];

		self.userProfileController.navigationBar.barStyle = UIBarStyleDefault;
		self.userProfileController.navigationBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
	}

	// WeiboSDK
#ifdef DEBUG
	[WeiboSDK enableDebugMode:YES];
	//  [[NetworkClient sharedNetworkClient] logout];
#endif
	[WeiboSDK registerApp:weiboAppKey];

	return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotatio {
	if ([[url absoluteString] rangeOfString:@"tencent"].location == 0) {
		return [TencentOAuth HandleOpenURL:url];
	}

	if ([[url absoluteString] rangeOfString:@"wb"].location == 0) {
		return [WeiboSDK handleOpenURL:url delegate:[WeiboLogin sharedWeiboLogin]];
	}

	return YES;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	if ([[url absoluteString] rangeOfString:@"tencent"].location == 0) {
		return [TencentOAuth HandleOpenURL:url];
	}

	if ([[url absoluteString] rangeOfString:@"wb"].location == 0) {
		return [WeiboSDK handleOpenURL:url delegate:[WeiboLogin sharedWeiboLogin]];
	}

	return YES;
}

#pragma mark - UITabBarController delegate

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	if ([viewController isEqual:self.userProfileController]) {
		if (isLogin()) {
			self.menuController.shouldRemainBottomBarOnDisappear = YES;
			return YES;
		}
		else {
			self.loginController = [[LoginViewController alloc] init];
			[self.mainTabBar presentViewController:self.loginController animated:YES completion: ^{
			    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLogin:) name:MSG_DID_LOGIN object:nil];
			}];
			return NO;
		}
	}
	return YES;
}

#pragma mark - Event handler

- (void)didLogin:(NSNotification *)notification {
	[self.mainMenuController dismissViewControllerAnimated:YES completion: ^() {
	    self.userController.username = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER];
	    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_LOGIN object:nil];
	}];
}

@end
