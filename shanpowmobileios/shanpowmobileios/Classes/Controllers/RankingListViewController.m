//
//  RankingListViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-11.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "RankingListViewController.h"
#import "CachedDownloadManager.h"
#import "NetworkClient.h"
#import "AccessoryTypeDotTableViewCell.h"
#import "RankingViewController.h"

@interface RankingListViewController ()

@property (nonatomic, strong) NSArray *rankingLists;

@property (nonatomic, strong) UISegmentedControl *channelSwitch;


@end

@implementation RankingListViewController

- (id)initWithStyle:(UITableViewStyle)style {
	self = [super initWithStyle:style];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];

	// Uncomment the following line to preserve selection between presentations.
	// self.clearsSelectionOnViewWillAppear = NO;

	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
	self.title = @"榜单";
	if (IsSysVerGTE(7.0)) {
		self.tableView.separatorInset = UIEdgeInsetsZero;
	}

	self.channelSwitch = [[UISegmentedControl alloc] initWithItems:@[@"男生频道", @"女生频道"]];
	self.channelSwitch.frame = CGRectMake((self.view.bounds.size.width - 140) / 2,
	                                      5.0,
	                                      140.0,
	                                      30.0);
	self.channelSwitch.tintColor = UIC_CYAN(1.0);
	[self.channelSwitch addTarget:self action:@selector(getTitlesOfAllRankingList) forControlEvents:UIControlEventValueChanged];

	self.channelSwitch.selectedSegmentIndex = 0;

	self.refreshControl = [[UIRefreshControl alloc] init];
	[self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	[MobClick beginLogPageView:NSStringFromClass([self class])];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetTitles:) name:MSG_DID_GET_RANKINGLIST_TITLES object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetTitles:) name:MSG_FAIL_GET_RANKINGLIST_TITLES object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];

	[self getTitlesOfAllRankingList];
}

- (void)viewWillDisappear:(BOOL)animated {
	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[MobClick endLogPageView:NSStringFromClass([self class])];

	[super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)getTitlesOfAllRankingList {
	id data = [[CachedDownloadManager sharedCachedDownloadManager] loadCacheForKey:(self.channelSwitch.selectedSegmentIndex == 0 ? CACHE_RANK_MAN : CACHE_RANK_WOMAN)];
	if (data) {
		[self didGetTitles:[NSNotification notificationWithName:MSG_DID_GET_RANKINGLIST_TITLES object:self userInfo:@{ @"data": data }]];
	}
	else {
		[[NetworkClient sharedNetworkClient] getTitlesOfAllRankingListForMan:(self.channelSwitch.selectedSegmentIndex == 0 ? YES : NO)];
	}
}

- (void)didGetTitles:(NSNotification *)notification {
	[self.refreshControl endRefreshing];

	self.rankingLists = [[notification userInfo] objectForKey:@"data"];

	if (self.rankingLists == (id)[NSNull null]) {
		self.rankingLists = nil;
	}

	[self.tableView reloadData];

	[[CachedDownloadManager sharedCachedDownloadManager] saveCache:self.rankingLists forKey:(self.channelSwitch.selectedSegmentIndex == 0 ? CACHE_RANK_MAN : CACHE_RANK_WOMAN)];
}

- (void)failGetTitles:(NSNotification *)notification {
	[self.refreshControl endRefreshing];
}

- (void)handleError:(NSNotification *)notification {
	[self.refreshControl endRefreshing];
}

- (void)refreshData:(UIRefreshControl *)refresh {
	if (refresh.refreshing) {
		[[CachedDownloadManager sharedCachedDownloadManager] clearCacheForKey:CACHE_RANK_MAN];
		[[CachedDownloadManager sharedCachedDownloadManager] clearCacheForKey:CACHE_RANK_WOMAN];

		[self getTitlesOfAllRankingList];
	}
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return GENERAL_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return GENERAL_CELL_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UIView *bkgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, GENERAL_HEADER_HEIGHT)];
	bkgView.backgroundColor = UIC_ALMOSTWHITE(1.0);
	[bkgView addSubview:self.channelSwitch];

	CGFloat height = IsSysVerGTE(7.0) ? 0.5 : 1;
	UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0.0, GENERAL_HEADER_HEIGHT - height, self.view.bounds.size.width, height)];
	divider.backgroundColor = [self.tableView separatorColor];
	[bkgView addSubview:divider];

	return bkgView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:YES];

	RankingViewController *rankingDetailController = [[RankingViewController alloc] init];
	rankingDetailController.currentRankingTitle = [[self.rankingLists objectAtIndex:indexPath.row] objectForKey:@"Title"];
	rankingDetailController.currentRankingVersion = [[self.rankingLists objectAtIndex:indexPath.row] objectForKey:@"Version"];
	rankingDetailController.title = [[self.rankingLists objectAtIndex:indexPath.row] objectForKey:@"Title"];

	[self pushViewController:rankingDetailController];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// Return the number of sections.
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// Return the number of rows in the section.
	return self.rankingLists ? [self.rankingLists count] : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *cellIdentifier = @"Cell";

	AccessoryTypeDotTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

	if (cell == nil) {
		cell = [[AccessoryTypeDotTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
	}

	cell.textLabel.text = [[self.rankingLists objectAtIndex:indexPath.row] objectForKey:@"Title"];
	cell.textLabel.font = MEDIUM_BOLD_FONT;
	cell.showDot = NO;

	return cell;
}

/*
   // Override to support conditional editing of the table view.
   - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
   {
    // Return NO if you do not want the specified item to be editable.
    return YES;
   }
 */

/*
   // Override to support editing the table view.
   - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
   {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
   }
 */

/*
   // Override to support rearranging the table view.
   - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
   {
   }
 */

/*
   // Override to support conditional rearranging of the table view.
   - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
   {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
   }
 */

/*
   #pragma mark - Navigation

   // In a storyboard-based application, you will often want to do a little preparation before navigation
   - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
   {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
   }
 */

@end
