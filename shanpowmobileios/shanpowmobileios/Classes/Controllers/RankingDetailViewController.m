//
//  RankingDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-12.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "RankingDetailViewController.h"
#import "NetworkClient.h"
#import "SPLoadingView.h"
#import "RankingDetailCell.h"
#import "BookDetailViewController.h"
#import "zoomPopup.h"

@interface RankingDetailViewController ()

@property (nonatomic, strong) SPLoadingView *loadingView;
@property (nonatomic, strong) UITableView *currentRankingTabel;
@property (nonatomic, strong) UITableView *bookGrid;

@property (nonatomic, strong) NSDictionary *rankingDetail;

@property (nonatomic, readwrite) BOOL isActive;

@end

@implementation RankingDetailViewController

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
    self.loadingView = [[SPLoadingView alloc] initWithFrame:CGRectZero];
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.bookGrid = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.bookGrid.dataSource = self;
    self.bookGrid.delegate = self;
    if (IsSysVerGTE(7.0)) {
        self.bookGrid.separatorInset = UIEdgeInsetsZero;
    }
    [self.view addSubview:self.bookGrid];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetRankingDetail:) name:MSG_DID_GET_RANKINGLIST_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetRankingDetail:) name:MSG_FAIL_GET_RANKINGLIST_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectBook:) name:MSG_DID_SELECT_BOOK object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reasonTapped:) name:MSG_TAPPED_REASON object:nil];
    
    [self getRankingDetail];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark -
- (void)getRankingDetail
{
    [self.loadingView show];
    
    [[NetworkClient sharedNetworkClient] getRankingDetailByTitle:self.rankingTitle version:self.version];
}

#pragma mark - Event handler
- (void)didGetRankingDetail:(NSNotification *)notification
{
    [self.loadingView hide];
    
    self.rankingDetail = [[notification userInfo] objectForKey:@"data"];
    self.isActive = [[self.rankingDetail objectForKey:@"IsActive"] boolValue];
    
    [self.bookGrid reloadData];
}

- (void)failGetRankingDetail:(NSNotification *)notification
{
    [self.loadingView hide];
}

- (void)handleError:(NSNotification *)notification
{
    [self.loadingView hide];
}

- (void)didSelectBook:(NSNotification *)notification
{
    NSString *bookId = [[notification userInfo] objectForKey:@"BookId"];
    
    BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    bookDetailController.bookId = bookId;
    
    [self pushViewController:bookDetailController];
}

- (void)reasonTapped:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_TAPPED_REASON object:nil];
    
    NSString *bookId = [[notification userInfo] objectForKey:@"Id"];
    
    NSString *comment = @"";
    
    for (NSDictionary *book in [self.rankingDetail objectForKey:@"Books"]) {
        if ([[book objectForKey:@"Id"] isEqualToString:bookId]) {
            comment = [book objectForKey:@"Comment"];
        }
    }
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 100.0)];
    view.backgroundColor = UIC_ALMOSTWHITE(1.0);
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height)];
    label.text = comment;
    label.numberOfLines = INFINITY;
    label.font = MEDIUM_FONT;
    label.textColor = UIC_BRIGHT_GRAY(1.0);
    [view addSubview:label];
    
    zoomPopup *popup = [[zoomPopup alloc] initWithMainview:self.view andStartRect:CGRectMake(self.view.bounds.size.width / 2,
                                                                                             self.view.bounds.size.height / 2,
                                                                                             1.0,
                                                                                             1.0)];
    [popup setBlurRadius:10];
    [popup showPopup:view];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zoomPopupClosed:) name:@"ZoomPopUpClosed" object:nil];
}

- (void)zoomPopupClosed:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ZoomPopUpClosed" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reasonTapped:) name:MSG_TAPPED_REASON object:nil];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return GENERAL_CELL_HEIGHT * 1.5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *bookId = [[[self.rankingDetail objectForKey:@"Books"] objectAtIndex:indexPath.row] objectForKey:@"Id"];
    BookDetailViewController *bookDetailController = [[BookDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    bookDetailController.bookId = bookId;
    
    [self pushViewController:bookDetailController];
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[self.rankingDetail objectForKey:@"Books"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    RankingDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[RankingDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.book = [[self.rankingDetail objectForKey:@"Books"] objectAtIndex:indexPath.row];
    
    return cell;
}

@end
