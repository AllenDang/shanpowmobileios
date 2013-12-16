//
//  RootViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-3.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "RootViewController.h"

@interface RootViewController ()

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
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"山坡网";
    
    self.tableData = [NSArray arrayWithObjects:@"热门书籍", @"一键治书荒", @"看书评", @"求推书", @"看书单", nil];
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

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        self.hotBooksViewController = [[HotBooksViewController alloc] initWithStyle:UITableViewStylePlain];
        [self.navigationController pushViewController:self.hotBooksViewController animated:YES];
    }
    return;
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    
    cell.textLabel.text = [self.tableData objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tableData count];
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

#pragma mark - Notification handlers
- (void)didLogin:(NSNotification *)notification
{
    [self dismissViewControllerAnimated:YES completion:^(){
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_LOGIN object:nil];
    }];
}

@end
