//
//  RootViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-3.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIButton *hotCategoriesButton;
@property (nonatomic, strong) UIButton *wizardButton;
@property (nonatomic, strong) UIButton *reviewsButton;
@property (nonatomic, strong) UIButton *asksButton;
@property (nonatomic, strong) UIButton *booklistsButton;

- (void)showLoginView;

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
  [self setBackgroundImage:[UIImage imageNamed:@"Main_Background"]];
  self.title = @"山坡网";
  
  self.navigationController.navigationBar.backgroundColor = self.view.backgroundColor;
  
  UIImageView *header = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Main_HeaderText"]];
  header.frame = CGRectMake(35.0, 120.0, 247.0, 81.0);
  [self.view addSubview:header];
  
  float screenRatio = self.view.bounds.size.height / 568.0;
  
  self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height)];
  self.scrollView.backgroundColor = [UIColor clearColor];
  self.scrollView.scrollsToTop = NO;
  self.scrollView.scrollEnabled = YES;
  self.scrollView.userInteractionEnabled = YES;
  self.scrollView.showsHorizontalScrollIndicator = NO;
  self.scrollView.showsVerticalScrollIndicator = NO;
  self.scrollView.canCancelContentTouches = NO;
  self.scrollView.bounces = YES;
  [self.view addSubview:self.scrollView];
  
  self.menuView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 260.0 * screenRatio, self.view.bounds.size.width, self.view.bounds.size.height)];
  self.menuView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Main_MenuBkg"]];
  [self.scrollView addSubview:self.menuView];
  
  // Modify content size to limit scroll area
  self.scrollView.contentSize = CGSizeMake(self.menuView.bounds.size.width, self.menuView.bounds.size.height + self.menuView.frame.origin.y);
  
  UIImage *bkgImage = [[UIImage imageNamed:@"Main_MenuButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(3.0, 3.0, 3.0, 3.0)];
  CGFloat buttonHeight = (self.view.bounds.size.height - self.menuView.frame.origin.y) / 3;
  
  // Hot Categories Button
  self.hotCategoriesButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.hotCategoriesButton.frame = CGRectMake(-1.0, 
                                              18.0 * screenRatio, 
                                              320.0 + 2, 
                                              buttonHeight);
  [self.hotCategoriesButton setBackgroundImage:bkgImage forState:UIControlStateNormal];
  [self.hotCategoriesButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
  [self.hotCategoriesButton setTitle:@"注册" forState:UIControlStateNormal];
  [self.hotCategoriesButton addTarget:self action:@selector(showHotCategoriesView) forControlEvents:UIControlEventTouchUpInside];
  [self.menuView addSubview:self.hotCategoriesButton];
  
  // Wizard Button
  self.wizardButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.wizardButton.frame = CGRectMake(-1.0, 
                                       18.0 * screenRatio + buttonHeight - 1, 
                                       320.0 / 2 + 1, 
                                       buttonHeight);
  [self.wizardButton setBackgroundImage:bkgImage forState:UIControlStateNormal];
  [self.wizardButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
  [self.wizardButton setTitle:@"注册" forState:UIControlStateNormal];
  [self.menuView addSubview:self.wizardButton];
  
  // Reviews Button
  self.reviewsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.reviewsButton.frame = CGRectMake(320.0 / 2 - 1, 
                                        18.0 * screenRatio + buttonHeight - 1, 
                                        320.0 / 2 + 2, 
                                        buttonHeight);
  [self.reviewsButton setBackgroundImage:bkgImage forState:UIControlStateNormal];
  [self.reviewsButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
  [self.reviewsButton setTitle:@"注册" forState:UIControlStateNormal];
  [self.menuView addSubview:self.reviewsButton];
  
  // Asks Button
  self.asksButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.asksButton.frame = CGRectMake(-1.0, 
                                     18.0 * screenRatio + buttonHeight * 2 - 2, 
                                     320.0 / 2 + 1, 
                                     buttonHeight);
  [self.asksButton setBackgroundImage:bkgImage forState:UIControlStateNormal];
  [self.asksButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
  [self.asksButton setTitle:@"注册" forState:UIControlStateNormal];
  [self.menuView addSubview:self.asksButton];
  
  // Booklists Button
  self.booklistsButton = [UIButton buttonWithType:UIButtonTypeCustom];
  self.booklistsButton.frame = CGRectMake(320.0 / 2 - 1, 
                                          18.0 * screenRatio + buttonHeight * 2 - 2, 
                                          320.0 / 2 + 2, 
                                          buttonHeight);
  [self.booklistsButton setBackgroundImage:bkgImage forState:UIControlStateNormal];
  [self.booklistsButton setBackgroundImage:[UIImage imageNamed:@"Login_LoginButton_Highlight"] forState:UIControlStateHighlighted];
  [self.booklistsButton setTitle:@"注册" forState:UIControlStateNormal];
  [self.menuView addSubview:self.booklistsButton];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Main_Background"] forBarMetrics:UIBarMetricsDefault];
  self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
//  self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  
  if (!isLogin()) {
    [self showLoginView];
  }
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

- (void)showLoginView
{
  if (!self.loginViewController) {
    self.loginViewController = [[LoginViewController alloc] init];
  }
  
  __block RootViewController *me = self;
  
  [self presentViewController:self.loginViewController animated:YES completion:^(){
    [[NSNotificationCenter defaultCenter] addObserver:me selector:@selector(didLogin:) name:MSG_DID_LOGIN object:nil];
  }];
}

- (void)showHotCategoriesView
{
  self.hotBooksViewController = [[HotBooksViewController alloc] initWithStyle:UITableViewStylePlain];
  [self.navigationController pushViewController:self.hotBooksViewController animated:YES];
}

#pragma mark - Notification handlers
- (void)didLogin:(NSNotification *)notification
{
  [self dismissViewControllerAnimated:YES completion:^(){
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_LOGIN object:nil];
  }];
}

@end
