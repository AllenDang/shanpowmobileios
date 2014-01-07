//
//  HotBooksViewController.m
//  shanpowmobileios
//
//  Created by 木一 on 13-12-5.
//  Copyright (c) 2013年 木一. All rights reserved.
//

#import "HotBooksViewController.h"

@interface HotBooksViewController ()

@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, assign) float headerHeight;

- (void)loadHotBooks;
- (void)refreshData:(UIRefreshControl *)refresh;

@end

@implementation HotBooksViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.title = @"热门书籍";
  [self.view setBackgroundColor:[UIColor colorWithRed:0.937 green:0.933 blue:0.890 alpha:1.0]];
  self.tableView.backgroundColor = self.view.backgroundColor;
  
  self.headerHeight = 40.0;
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    self.tableView.separatorInset = UIEdgeInsetsZero;
  }
  
  self.tableView.separatorColor = [UIColor clearColor];
  self.tableView.opaque = NO;
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:0.302 green:0.329 blue:0.298 alpha:1.0]] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
  } else {
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithWhite:0.3 alpha:1.0];
  }
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSelectTableCell:) name:MSG_HC_BOOK_SELECTED object:nil];
  
  self.refreshControl = [[UIRefreshControl alloc] init];
  [self.refreshControl addTarget:self action:@selector(refreshData:) forControlEvents:UIControlEventValueChanged];
  self.refreshControl.layer.zPosition = self.tableView.backgroundView.layer.zPosition + 1;
  
  [self loadHotBooks];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  
  self.navigationController.navigationBar.hidden = NO;
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
  self.tableView.separatorColor = [UIColor colorWithRed:0.843 green:0.835 blue:0.722 alpha:1.0];
  
  NSDictionary *userInfo = [notification userInfo];
  NSArray *data = [userInfo objectForKey:@"data"];
  self.categories = data;
  
  [self.tableView reloadData];
  [self.refreshControl endRefreshing];
}

- (void)failGetHotBooks:(NSNotification *)notification
{
  [self.refreshControl endRefreshing];
  
  NSString *errorMsg = [[notification userInfo] objectForKey:@"ErrorMsg"];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络问题" message:errorMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
  [alert show];
}

- (void)handleError:(NSNotification *)notification
{
  [self.refreshControl endRefreshing];
  
  NSString *errorMsg = [[notification userInfo] objectForKey:@"ErrorMsg"];
  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"网络问题" message:errorMsg delegate:self cancelButtonTitle:@"好的" otherButtonTitles:nil];
  [alert show];
}

- (void)didSelectTableCell:(NSNotification *)notification
{
  NSString *bookId = [[notification userInfo] objectForKey:@"BookId"];
  
  for (BookInfoCell *cell in self.tableView.visibleCells) {
    if ([cell.bookInfoView.book.Id isEqualToString:bookId]) {
      [self.tableView selectRowAtIndexPath:cell.indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
      [self.tableView deselectRowAtIndexPath:cell.indexPath animated:YES];
    }
  }
}

#pragma mark -

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  return 70.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
  return self.headerHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSLog(@"TableCell %d.%d Tapped!", indexPath.section, indexPath.row);
  
  return;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
  UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.frame.size.width - 20, self.headerHeight)];
  headerLabel.text = [[self.categories objectAtIndex:section] objectForKey:@"Category"];
  headerLabel.textColor = [UIColor colorWithRed:0.129 green:0.180 blue:0.196 alpha:1.0];
  headerLabel.backgroundColor= [UIColor clearColor];
  
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectZero];
  [headerView addSubview:headerLabel];
  headerView.backgroundColor = [UIColor colorWithRed:0.843 green:0.835 blue:0.722 alpha:1.0];
  
  return headerView;
}

#pragma mark - Table view data source

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
  NSMutableArray *titles = [NSMutableArray arrayWithCapacity:10];
  for (NSDictionary *category in self.categories) {
    [titles addObject:[[category objectForKey:@"Category"] substringToIndex:1]];
  }
  if (titles.count >= 20) {
    return titles;
  }
  return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  if (self.categories == nil) {
    return 0;
  }
  return [self.categories count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  if (self.categories == nil) {
    return 0;
  }
  return [[[self.categories objectAtIndex:section] objectForKey:@"Books"] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
  return [[self.categories objectAtIndex:section] objectForKey:@"Category"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  BookInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  
  NSDictionary *bookInfo = [[[self.categories objectAtIndex:indexPath.section] objectForKey:@"Books"] objectAtIndex:indexPath.row];
  
  if (cell == nil) {
    cell = [[BookInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.bookInfoView.style = BookInfoViewStyleMedium;
    cell.bookInfoView.colorStyle = BookInfoViewColorStyleDefault;
  }
  
  Book *book = [Book bookFromDictionary:bookInfo];
  [cell.bookInfoView setBook:book];
  
  if (book.summary) {
    cell.bookInfoView.hasBookDescription = YES;
  }
  if (book.simpleComment) {
    cell.bookInfoView.hasBookComment = YES;
  }
  
  UIView *cellBackground = [[UIView alloc] initWithFrame:cell.bounds];
  cellBackground.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
  cell.selectedBackgroundView = cellBackground;
  
  cell.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
  
  if ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0) {
    cell.contentView.backgroundColor = cell.backgroundColor;
  }
  
  cell.indexPath = indexPath;
  
  [cell addSubview:cell.bookInfoView];
  
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
 }   
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
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
 
 // In a story board-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 
 */

@end
