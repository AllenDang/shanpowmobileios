//
//  SearchResultViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-18.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "SearchResultViewController.h"
#import "BookDetailViewController.h"
#import "BooklistDetailViewController.h"
#import "UserProfileViewController.h"

@interface SearchResultViewController ()

@property (nonatomic, strong) UISegmentedControl *categoryFilterSegment;
@property (nonatomic, strong) BookGridViewController *bookGrid;
@property (nonatomic, strong) BooklistGridViewController *booklistGrid;
@property (nonatomic, strong) UserListViewController *userlistController;
@property (nonatomic, strong) NSMutableArray *segmentedItems;

@end

@implementation SearchResultViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithSearchResult:(NSDictionary *)searchResult
{
    self = [super init];
    if (self) {
        self.bookGrid = [[BookGridViewController alloc] initWithStyle:UITableViewStylePlain];
        self.booklistGrid = [[BooklistGridViewController alloc] initWithStyle:UITableViewStylePlain];
        self.userlistController = [[UserListViewController alloc] initWithStyle:UITableViewStylePlain];
        
        self.searchResult = searchResult;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.title = @"搜索结果";
    self.view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    if (!self.segmentedItems) {
        self.segmentedItems = [NSMutableArray arrayWithArray:@[@"书籍", @"书单", @"用户"]];
    }
    
    if (!self.categoryFilterSegment) {
        [self initSegmentedControl];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBooklist:) name:MSG_DID_SELECT_BOOKLIST object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectUser:) name:MSG_DID_SELECT_USER object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initSegmentedControl
{
    self.categoryFilterSegment = [[UISegmentedControl alloc] initWithItems:self.segmentedItems];
    self.categoryFilterSegment.tintColor = UIC_CYAN(1.0);
    self.categoryFilterSegment.selectedSegmentIndex = 0;
    [self.categoryFilterSegment addTarget:self action:@selector(didChangeCategoryFilter:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.categoryFilterSegment];
}

- (void)updateUILayout
{
    self.categoryFilterSegment.frame = CGRectMake(10.0, 10.0, self.view.bounds.size.width - 20, 30.0);
    
    CGRect resultListRect = CGRectMake(0.0,
                                       self.categoryFilterSegment.frame.size.height + self.categoryFilterSegment.frame.origin.y * 2,
                                       self.view.bounds.size.width,
                                       self.view.bounds.size.height - self.tabBarController.tabBar.frame.size.height - self.categoryFilterSegment.frame.size.height - self.categoryFilterSegment.frame.origin.y * 2);
    if (self.bookGrid) {
        self.bookGrid.view.frame = resultListRect;
        [self.view bringSubviewToFront:self.bookGrid.view];
    }
    
    if (self.booklistGrid) {
        self.booklistGrid.view.frame = resultListRect;
    }
    
    if (self.userlistController) {
        self.userlistController.view.frame = resultListRect;
    }
}

- (void)setSearchResult:(NSDictionary *)searchResult
{
    if (![searchResult isEqual:_searchResult]) {
        _searchResult = searchResult;
        
        if (!self.segmentedItems) {
            self.segmentedItems = [NSMutableArray arrayWithCapacity:40];
        }
        
        if ([searchResult objectForKey:@"Books"] != [NSNull null]) {
            self.bookGrid.books = [searchResult objectForKey:@"Books"];
            self.bookGrid.isPlain = YES;
            
            [self.segmentedItems addObject:@"书籍"];
        }
        
        if ([searchResult objectForKey:@"Booklists"] != [NSNull null]) {
            self.booklistGrid.booklists = [searchResult objectForKey:@"Booklists"];
            
            [self.segmentedItems addObject:@"书单"];
        }
        
        if ([searchResult objectForKey:@"Users"] != [NSNull null]) {
            self.userlistController.users = [searchResult objectForKey:@"Users"];
            
            [self.segmentedItems addObject:@"用户"];
        }
        
        [self.view addSubview:self.bookGrid.view];
        [self.view addSubview:self.booklistGrid.view];
        [self.view addSubview:self.userlistController.view];
        
        [self updateUILayout];
    }
}

#pragma mark - Event handler
- (void)didChangeCategoryFilter:(UISegmentedControl *)sender
{
    NSInteger value = sender.selectedSegmentIndex;
    
    if ([[sender titleForSegmentAtIndex:value] isEqualToString:@"书籍"]) {
        [self.view bringSubviewToFront:self.bookGrid.view];
    } else if ([[sender titleForSegmentAtIndex:value] isEqualToString:@"书单"]) {
        [self.view bringSubviewToFront:self.booklistGrid.view];
    } else if ([[sender titleForSegmentAtIndex:value] isEqualToString:@"用户"]) {
        [self.view bringSubviewToFront:self.userlistController.view];
    }
}

- (void)didSelectBook:(NSNotification *)notification
{
    BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    bookDetailController.bookId = [[notification userInfo] objectForKey:@"BookId"];
    
    [self pushViewController:bookDetailController];
}

- (void)didSelectBooklist:(NSNotification *)notification
{
    NSString *booklistId = [[notification userInfo] objectForKey:@"BooklistId"];
    
    BooklistDetailViewController *booklistDetailController = [[BooklistDetailViewController alloc] initWithBooklistId:booklistId];
    
    [self pushViewController:booklistDetailController];
}

- (void)didSelectUser:(NSNotification *)notification
{
    NSString *nickname = [[notification userInfo] objectForKey:@"Nickname"];
    
    UserProfileViewController *userProfileController = [[UserProfileViewController alloc] initWithUsername:nickname];
    
    [self pushViewController:userProfileController];
}

@end
