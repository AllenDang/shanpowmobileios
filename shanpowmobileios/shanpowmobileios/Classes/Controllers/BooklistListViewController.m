//
//  BooklistListViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-26.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BooklistListViewController.h"
#import "Common.h"
#import "BooklistGridViewController.h"
#import "NetworkClient.h"
#import "BooklistDetailViewController.h"
#import "BooklistDetailInfoViewController.h"
#import "FilterViewController.h"

@interface BooklistListViewController ()

@property (nonatomic, strong) BooklistGridViewController *booklistsController;
@property (nonatomic, strong) BooklistDetailViewController *booklistDetailController;

@end

@implementation BooklistListViewController

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
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.booklistsController = [[BooklistGridViewController alloc] initWithStyle:UITableViewStylePlain];
    self.booklistsController.view.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.booklistsController.showDescription = YES;
    [self.view addSubview:self.booklistsController.view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBooklist:) name:MSG_DID_SELECT_BOOKLIST object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getBooklists];
    
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)getBooklists
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBooklists:) name:MSG_DID_GET_BOOKLISTS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBooklists:) name:MSG_FAIL_GET_BOOKLISTS object:nil];
    
    switch (self.dataSource) {
        case BLDS_CreateAuthor:
        {
            if (!self.userId) {
                return;
            } else {
                [[NetworkClient sharedNetworkClient] getBooklistsByAuthorId:self.userId];
            }
        }
            break;
        case BLDS_FavedBy:
        {
            if (!self.userId) {
                return;
            } else {
                [[NetworkClient sharedNetworkClient] getBooklistsBySubscriberId:self.userId];
            }
        }
            break;
        case BLDS_ContainBook:
        {
            if (!self.bookId) {
                return;
            } else {
                [[NetworkClient sharedNetworkClient] getBooklistsByBookId:self.bookId];
            }
        }
            break;
        default:
            break;
    }
}

#pragma mark - Event handler
- (void)didGetBooklists:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_BOOKLISTS object:nil];
    
    NSArray *booklists = [[notification userInfo] objectForKey:@"data"];
    self.booklistsController.booklists = booklists;
}

- (void)failGetBooklists:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_BOOKLISTS object:nil];
}

- (void)didSelectBooklist:(NSNotification *)notification
{
    NSString *booklistId = [[notification userInfo] objectForKey:@"booklistId"];

    self.booklistDetailController = [[BooklistDetailViewController alloc] initWithBooklistId:booklistId];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:self.booklistDetailController animated:YES];
    self.hidesBottomBarWhenPushed = NO;
}

@end
