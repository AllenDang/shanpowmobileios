//
//  WizardResultViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-11.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "WizardResultViewController.h"
#import "NetworkClient.h"
#import "BookGridViewController.h"
#import "BookDetailViewController.h"
#import "CachedDownloadManager.h"

@interface WizardResultViewController ()

@property (nonatomic, strong) NSArray *results;


@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) BookGridViewController *bookGridController;

@end

@implementation WizardResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.results = @[];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"一键治书荒";
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 60.0)];
    self.tipLabel.backgroundColor = UIC_BRIGHT_GRAY(1.0);
    self.tipLabel.font = MEDIUM_BOLD_FONT;
    self.tipLabel.textAlignment = NSTextAlignmentCenter;
    self.tipLabel.textColor = UIC_ALMOSTWHITE(1.0);
    self.tipLabel.text = @"以下为系统根据您的口味向您推荐的书籍\n如需更精准结果，请标记更多书籍。";
    self.tipLabel.numberOfLines = 2;
    [self.view addSubview:self.tipLabel];
    
    self.bookGridController = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
    self.bookGridController.view.frame = CGRectMake(0.0,
                                                    self.tipLabel.frame.size.height,
                                                    self.view.frame.size.width,
                                                    self.view.bounds.size.height - self.tipLabel.frame.size.height);
    self.bookGridController.isPlain = YES;
    [self.view addSubview:self.bookGridController.view];
    
    self.bookGridController.refreshControl = [[UIRefreshControl alloc] init];
    [self.bookGridController.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.bookGridController.refreshControl.layer.zPosition = self.bookGridController.view.layer.zPosition + 1;
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetWizardResult:) name:MSG_DID_GET_WIZARD_RESULT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetWizardResult:) name:MSG_FAIL_GET_WIZARD_RESULT object:nil];
    
    id data = [[CachedDownloadManager sharedCachedDownloadManager] loadCacheForKey:CACHE_WIZARD];
    if (data) {
        [self didGetWizardResult:[NSNotification notificationWithName:MSG_DID_GET_WIZARD_RESULT object:self userInfo:@{@"data": data}]];
    } else {
        [self getResults];
    }
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[CachedDownloadManager sharedCachedDownloadManager] saveCache:self.bookGridController.books forKey:CACHE_WIZARD];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)refreshData:(UIRefreshControl *)refresh
{
    if (refresh.refreshing) {
        [self getResults];
    }
}

- (void)getResults
{
    [[NetworkClient sharedNetworkClient] getWizardResult];
}

#pragma mark - Event handler

- (void)didGetWizardResult:(NSNotification *)notification
{
    self.bookGridController.books = [[notification userInfo] objectForKey:@"data"];
    
    [self.bookGridController.tableView reloadData];
    [self.bookGridController.refreshControl endRefreshing];
}

- (void)failGetWizardResult:(NSNotification *)notification
{
    [self.bookGridController.refreshControl endRefreshing];
}

- (void)handleError:(NSNotification *)notification
{
    [self.bookGridController.refreshControl endRefreshing];
}

- (void)didSelectBook:(NSNotification *)notification
{
    BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    bookDetailController.bookId = [[notification userInfo] objectForKey:@"BookId"];
    [self pushViewController:bookDetailController];
}

@end
