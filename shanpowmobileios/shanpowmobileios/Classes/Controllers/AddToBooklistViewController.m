//
//  AddToBooklistViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-3.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "AddToBooklistViewController.h"
#import "BooklistGridViewController.h"
#import "NetworkClient.h"
#import "CreateBookListViewController.h"

@interface AddToBooklistViewController ()

@property (nonatomic, strong) BooklistGridViewController *booklistsController;
@property (nonatomic, strong) CreateBookListViewController *createBooklistController;

@end

@implementation AddToBooklistViewController

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
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.booklistsController = [[BooklistGridViewController alloc] initWithStyle:UITableViewStylePlain];
    self.booklistsController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.booklistsController.mode = BGM_SelectionMode;
    [self.view addSubview:self.booklistsController.view];
    
    UIBarButtonItem *createBooklistItem = [[UIBarButtonItem alloc] initWithTitle:@"创建" style:UIBarButtonItemStylePlain target:self action:@selector(pushCreateBooklistView:)];
    self.navigationItem.rightBarButtonItem = createBooklistItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBooklist:) name:MSG_DID_SELECT_BOOKLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddBookToBooklist:) name:MSG_DID_ADD_BOOK_TO_BOOKLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failAddBookToBooklist:) name:MSG_FAIL_ADD_BOOK_TO_BOOKLIST object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getBooklists];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.booklistsController.tableView reloadData];
    
    [super viewDidAppear:animated];
}

#pragma mark -

- (void)getBooklists
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBooklists:) name:MSG_DID_GET_BOOKLISTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBooklists:) name:MSG_FAIL_GET_BOOKLISTS object:nil];
    
    NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_CURRENT_USER_ID];
    [[NetworkClient sharedNetworkClient] getBooklistsByAuthorId:currentUserId];
}

#pragma mark - Event handler
- (void)didGetBooklists:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_BOOKLISTS object:nil];
    
    NSArray *booklists = [[notification userInfo] objectForKey:@"data"];
    self.booklistsController.booklists = booklists;
    [self.booklistsController.tableView reloadData];
}

- (void)failGetBooklists:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_BOOKLISTS object:nil];
    
    NSString *err = [[notification userInfo] objectForKey:@"ErrorMsg"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:err delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    alert.tag = 1002;
    [alert show];
}

- (void)pushCreateBooklistView:(UIBarButtonItem *)sender
{
    self.createBooklistController = [[CreateBookListViewController alloc] init];
    
    self.hidesBottomBarWhenPushed = YES;
    [self pushViewController:self.createBooklistController];
}

- (void)didSelectBooklist:(NSNotification *)notification
{
    NSString *booklistId = [[notification userInfo] objectForKey:@"BooklistId"];
    
    [[NetworkClient sharedNetworkClient] addBook:self.bookIdToAdd toBooklist:booklistId];
}

- (void)didAddBookToBooklist:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"成功" message:@"已经成功将书籍添加到书单" delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    alert.tag = 1000;
    [alert show];
}

- (void)failAddBookToBooklist:(NSNotification *)notification
{
    NSString *err = [[notification userInfo] objectForKey:@"ErrorMsg"];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:err delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
    alert.tag = 1001;
    [alert show];
}

#pragma mark - UIAlertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
