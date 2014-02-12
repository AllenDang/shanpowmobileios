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
@property (nonatomic, strong) UIBarButtonItem *searchButton;

@property (nonatomic, strong) MainMenuViewController *mainMenuController;
@property (nonatomic, strong) LoginViewController *loginController;
@property (nonatomic, strong) SearchViewController *searchController;

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
    
    if (isSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.mainMenuController = [[MainMenuViewController alloc] init];
    self.loginController = [[LoginViewController alloc] init];
    
    UITabBarItem *homeItem = [[UITabBarItem alloc] initWithTitle:@"首页" image:[UIImage imageNamed:@"Home"] tag:1];
    UITabBarItem *userItem = [[UITabBarItem alloc] initWithTitle:@"用户" image:[UIImage imageNamed:@"User"] tag:2];
    
    self.mainMenuController.tabBarItem = homeItem;
    self.loginController.tabBarItem = userItem;
    
    self.mainTabBar = [[UITabBarController alloc] init];
    [self.mainTabBar setViewControllers:@[self.mainMenuController, self.loginController]];
    [self.view addSubview:self.mainTabBar.view];
    
    if (isSysVerGTE(7.0)) {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:UIC_CERULEAN(1.0)] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        self.mainTabBar.tabBar.barTintColor = UIC_BRIGHT_GRAY(1.0);
        [self.mainTabBar.tabBar setTranslucent:NO];
    } else {
        self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
        self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
    }
    
    self.searchButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(showSearchView:)];
    [self.navigationItem setRightBarButtonItem:self.searchButton];
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

- (void)showSearchView:(id)sender
{
    self.searchController = [[SearchViewController alloc] init];
    [MAIN_NAVIGATION_CONTROLLER pushViewController:self.searchController animated:YES];
}

@end
