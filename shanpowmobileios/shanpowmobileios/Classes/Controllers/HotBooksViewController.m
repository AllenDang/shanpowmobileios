//
//  HotBooksViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-5.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "HotBooksViewController.h"

@interface HotBooksViewController ()

@property (nonatomic, strong) BookGridViewController *bookGridController;

- (void)loadHotBooks;
- (void)refreshData:(UIRefreshControl *)refresh;

@end

@implementation HotBooksViewController

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
    
    self.title = @"热门书籍";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.bookGridController = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
    self.bookGridController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.bookGridController.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
    
    self.bookGridController.refreshControl = [[UIRefreshControl alloc] init];
    [self.bookGridController.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.bookGridController.refreshControl.layer.zPosition = self.bookGridController.view.layer.zPosition + 1;
    
    [self.view addSubview:self.bookGridController.view];
    
    [self loadHotBooks];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)refreshData:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        [self loadHotBooks];
    }
}

- (void)loadHotBooks
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetHotBooks:) name:MSG_DID_GET_HOTBOOKS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetHotBooks:) name:MSG_FAIL_GET_HOTBOOKS object:nil];
    [[NetworkClient sharedNetworkClient] getHotBooks];
}

#pragma mark - Event handler

- (void)didGetHotBooks:(NSNotification *)notification
{
    self.bookGridController.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    NSDictionary *userInfo = [notification userInfo];
    NSArray *data = [[userInfo objectForKey:@"data"] class] == [NSNull class] ? nil : [userInfo objectForKey:@"data"];
    self.bookGridController.books = data;
    
    [self.bookGridController.tableView reloadData];
    [self.bookGridController.refreshControl endRefreshing];
}

- (void)failGetHotBooks:(NSNotification *)notification
{
    [self.bookGridController.refreshControl endRefreshing];
    
    NSString *errorMsg = [[notification userInfo] objectForKey:@"ErrorMsg"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络问题" message:errorMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

- (void)handleError:(NSNotification *)notification
{
    [self.bookGridController.refreshControl endRefreshing];
    
    NSString *errorMsg = [[notification userInfo] objectForKey:@"ErrorMsg"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络问题" message:errorMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    [alert show];
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
