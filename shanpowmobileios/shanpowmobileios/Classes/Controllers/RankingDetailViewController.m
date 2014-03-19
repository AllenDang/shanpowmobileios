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

@interface RankingDetailViewController ()

@property (nonatomic, strong) SPLoadingView *loadingView;
@property (nonatomic, strong) UITableView *currentRankingTabel;
@property (nonatomic, strong) UITableView *bookGrid;

@property (nonatomic, strong) NSDictionary *rankingDetail;

@property (nonatomic, readwrite) BOOL isActive;

@property (nonatomic, strong) NSMutableArray *heightCheck;

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
    if (IsSysVerGTE(7.0)) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.heightCheck = [NSMutableArray arrayWithCapacity:40];
    
    self.bookGrid = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.bookGrid.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.view.bounds.size.height - UINAVIGATIONBAR_HEIGHT - UISTATUSBAR_HEIGHT);
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
- (void)markShowReasonForIndex:(NSUInteger)index
{
    [self.heightCheck removeAllObjects];
    
    for (NSUInteger i = 0; i < [[self.rankingDetail objectForKey:@"Books"] count]; i++) {
        [self.heightCheck insertObject:[NSNumber numberWithBool:NO] atIndex:i];
    }
    
    [self.heightCheck insertObject:[NSNumber numberWithBool:YES] atIndex:index];
    [self.heightCheck removeLastObject];
}

- (void)getRankingDetail
{
    [[NetworkClient sharedNetworkClient] getRankingDetailByTitle:self.rankingTitle version:self.version];
}

#pragma mark - Event handler
- (void)didGetRankingDetail:(NSNotification *)notification
{
    self.rankingDetail = [[notification userInfo] objectForKey:@"data"];
    self.isActive = [[self.rankingDetail objectForKey:@"IsActive"] boolValue];
    
    for (NSUInteger i = 0; i < [[self.rankingDetail objectForKey:@"Books"] count]; i++) {
        [self.heightCheck insertObject:[NSNumber numberWithBool:NO] atIndex:i];
    }
    
    [self.bookGrid reloadData];
}

- (void)failGetRankingDetail:(NSNotification *)notification
{

}

- (void)handleError:(NSNotification *)notification
{

}

- (void)reasonTapped:(NSNotification *)notification
{
    NSString *bookId = [[notification userInfo] objectForKey:@"BookId"];
    
    NSUInteger index = 0;
    
    for (NSUInteger i = 0; i < [[self.rankingDetail objectForKey:@"Books"] count]; i++) {
        NSDictionary *book = [[self.rankingDetail objectForKey:@"Books"] objectAtIndex:i];
        if ([[book objectForKey:@"Id"] isEqualToString:bookId]) {
            index = i;
        }
    }
    
    [self markShowReasonForIndex:index];
    
    [self.bookGrid reloadData];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if ([[self.heightCheck objectAtIndex:indexPath.row] boolValue]) {
    NSString *content = [[[self.rankingDetail objectForKey:@"Books"] objectAtIndex:indexPath.row] objectForKey:@"Comment"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width - 40, GENERAL_CELL_HEIGHT * 1.5)];
    label.font = MEDIUM_FONT;
    label.text = content;
    label.numberOfLines = 0;
    [label sizeToFit];
    return GENERAL_CELL_HEIGHT * 1.5 + label.frame.size.height + 20;
//    }else{
//
//        return GENERAL_CELL_HEIGHT * 1.5;
//    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *bookId = [[[self.rankingDetail objectForKey:@"Books"] objectAtIndex:indexPath.row] objectForKey:@"Id"];
    [[NSNotificationCenter defaultCenter] postNotificationName:MSG_DID_SELECT_BOOK object:self userInfo:@{@"BookId": bookId}];
    
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
