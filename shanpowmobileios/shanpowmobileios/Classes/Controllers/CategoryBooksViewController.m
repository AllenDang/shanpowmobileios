//
//  CategoryBooksViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-5.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CategoryBooksViewController.h"
#import "BookGridViewController.h"
#import "NetworkClient.h"

@interface CategoryBooksViewController ()

@property (nonatomic, strong) BookGridViewController *booksController;
@property (nonatomic, assign) NSInteger currentPageNum;

@end

@implementation CategoryBooksViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCategory:(NSString *)category
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.category = category;
        
        self.booksController = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
        self.booksController.isPlain = YES;
        self.booksController.needLoadMore = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = self.category;
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBooks:) name:MSG_DID_GET_BOOKS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBooks:) name:MSG_FAIL_GET_BOOKS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMoreBooks:) name:MSG_BOOKGRID_LOADMORE_TAPPED object:nil];
    
    if (self.booksController) {
        self.booksController.view.frame = self.view.bounds;
        [self.view addSubview:self.booksController.view];
    }
    
    self.booksController.refreshControl = [[UIRefreshControl alloc] init];
    [self.booksController.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
    self.booksController.refreshControl.layer.zPosition = self.booksController.view.layer.zPosition + 1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)setCategory:(NSString *)category
{
    if (![category isEqualToString:_category]) {
        _category = category;
        
        self.title = category;
        
        [self getBooksWithRange:NSMakeRange(1, 20)];
        self.currentPageNum = 1;
    }
}

- (void)getBooksWithRange:(NSRange)range
{
    [[NetworkClient sharedNetworkClient] getBooksByCategory:self.category range:range];
}

- (void)refreshData:(UIRefreshControl *)sender
{
    [self getBooksWithRange:NSMakeRange(self.currentPageNum, 20)];
}

#pragma mark - Event handler
- (void)didGetBooks:(NSNotification *)notification
{
    [self.booksController.refreshControl endRefreshing];
    
    NSArray *books = [[notification userInfo] objectForKey:@"data"];
    self.booksController.books = self.booksController.books ? [self.booksController.books arrayByAddingObjectsFromArray:books] : books;
    [self.booksController.tableView reloadData];
    self.currentPageNum++;
}

- (void)failGetBooks:(NSNotification *)notification
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"出错啦" message:@"网络出现问题，请重试" delegate:self cancelButtonTitle:@"好的" otherButtonTitles: nil];
    [alert show];
}

- (void)loadMoreBooks:(NSNotification *)notification
{
    [self getBooksWithRange:NSMakeRange(self.currentPageNum + 1, 20)];
}

@end
