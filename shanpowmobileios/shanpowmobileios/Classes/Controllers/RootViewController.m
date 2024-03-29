//
//  RootViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-3.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) UITabBarController *mainTabBar;
@property (nonatomic, strong) MainMenuViewController *mainMenuController;
@property (nonatomic, strong) LoginViewController *loginController;

@end

@implementation RootViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"专治书荒";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.mainMenuController = [[MainMenuViewController alloc] init];
    self.loginController = [[LoginViewController alloc] init];
    
    self.mainTabBar = [[UITabBarController alloc] init];
    [self.mainTabBar.tabBar setBackgroundImage:[UIImage imageWithColor:UIC_BRIGHT_GRAY(1.0)]];
    [self.mainTabBar setViewControllers:@[self.mainMenuController, self.loginController]];
    [self.view addSubview:self.mainTabBar.view];
    
    if (isSysVerGTE(7.0)) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -


@end
