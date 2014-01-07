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
@property (nonatomic, strong) NSArray *tableColor;

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
  
  self.edgesForExtendedLayout = UIRectEdgeNone;
  
  UIColor *headColor = [UIColor colorWithRed:0.129 green:0.180 blue:0.196 alpha:1.0];
  
  UIView *placeHolderView = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] statusBarFrame]];
  placeHolderView.backgroundColor = headColor;
  [self.view addSubview:placeHolderView];
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.129 green:0.180 blue:0.196 alpha:1.0]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  } else {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
  }
  
  CGRect tableFrame = CGRectMake(0.0, placeHolderView.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height);
  self.mainTable = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStylePlain];
  self.mainTable.delegate = self;
  self.mainTable.dataSource = self;
  self.mainTable.scrollEnabled = NO;
  self.mainTable.separatorStyle = UITableViewCellSeparatorStyleNone;
  [self.view addSubview:self.mainTable];
  
  self.tableData = @[@"继续阅读", @"书库", @"热门书籍", @"一键治书荒", @"看书评", @"看书单", @"分类", @"用户"];
  self.tableColor = @[headColor,
                      [UIColor colorWithRed:0.522 green:0.576 blue:0.478 alpha:1.0],
                      [UIColor colorWithRed:0.349 green:0.428 blue:0.368 alpha:1.0],
                      [UIColor colorWithRed:0.663 green:0.686 blue:0.565 alpha:1.0],
                      [UIColor colorWithRed:0.302 green:0.329 blue:0.298 alpha:1.0],
                      [UIColor colorWithRed:0.745 green:0.739 blue:0.641 alpha:1.0],
                      [UIColor colorWithRed:0.595 green:0.667 blue:0.549 alpha:1.0],
                      [UIColor colorWithRed:0.323 green:0.333 blue:0.287 alpha:1.0]];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBar.hidden = YES;
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

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
  
  return (tableView.bounds.size.height - statusBarHeight) / [self.tableData count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSLog(@"TableCell %d.%d Tapped!", indexPath.section, indexPath.row);
  
  switch (indexPath.row) {
    case 0:
      [self showHotCategoriesView];
      break;
      
    default:
      break;
  }
  
  return;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return [self.tableData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
  cell.textLabel.textColor = [UIColor whiteColor];
  cell.backgroundColor = [self.tableColor objectAtIndex:indexPath.row];
  
  return cell;
}


@end
