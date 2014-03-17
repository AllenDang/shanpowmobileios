//
//  ReviewListViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "ReviewListViewController.h"
#import "NetworkClient.h"
#import "SPLoadingView.h"
#import "CommentReviewCell.h"
#import "CommentDetailViewController.h"
#import "UserProfileViewController.h"

@interface ReviewListViewController ()

@property (nonatomic, assign) NSInteger currentPageNum;
@property (nonatomic, assign) NSInteger currentNumPerPage;
@property (nonatomic, strong) NSString *currentCategory;
@property (nonatomic, assign) NSInteger currentScore;
@property (nonatomic, assign) FilterChannel currentChannel;

@property (nonatomic, strong) SPLoadingView *loadingView;

@property (nonatomic, strong) NSArray *reviews;

@end

@implementation ReviewListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.currentPageNum = 1;
        self.currentCategory = @"";
        // comment and review each 10
        self.currentNumPerPage = 10;
        self.currentScore = 0;
        self.currentChannel = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nicknameTapped:) name:MSG_TAPPED_NICKNAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetReviews:) name:MSG_DID_GET_REVIEWS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetReviews:) name:MSG_FAIL_GET_REVIEWS object:nil];
    
    [self getReviewsWithRange:NSMakeRange(1, self.currentNumPerPage)];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.currentPageNum = 1;
    self.reviews = nil;
    [self.tableView reloadData];
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)getReviewsWithRange:(NSRange)range
{
    self.loadingView = [[SPLoadingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.loadingView show];
    
    if (self.bookId) {
        if (self.isComment) {
            [[NetworkClient sharedNetworkClient] getMoreCommentsByBookId:self.bookId range:range];
        } else {
            [[NetworkClient sharedNetworkClient] getMoreReviewsByBookId:self.bookId range:range];
        }
    } else {
        [[NetworkClient sharedNetworkClient] getReviewsByCategory:self.currentCategory channel:self.currentChannel score:self.currentScore range:range];
    }
}

#pragma mark - Event handler
- (void)didGetReviews:(NSNotification *)notification
{
    [self.loadingView hide];
    
    self.reviews = self.reviews ? [self.reviews arrayByAddingObjectsFromArray:[[notification userInfo] objectForKey:@"data"]] : [[notification userInfo] objectForKey:@"data"];
    
    [self.tableView reloadData];
    
    self.currentPageNum++;
}

- (void)failGetReviews:(NSNotification *)notification
{
    [self.loadingView hide];
}

- (void)handleError:(NSNotification *)notification
{
    [self.loadingView hide];
}

- (void)nicknameTapped:(NSNotification *)notification
{
    UserProfileViewController *uesrProfileController = [[UserProfileViewController alloc] initWithUsername:[[notification userInfo] objectForKey:@"Nickname"]];
    
    [self pushViewController:uesrProfileController];
}

#pragma mark - Filter data source
- (void)filterDataWithReadStatus:(BOOL)showAll channel:(FilterChannel)channel categoryToShow:(NSString *)category scoreToShow:(NSInteger)score
{
    if ([category isEqualToString:@"全部"]) {
        self.currentCategory = @"";
    } else {
        self.currentCategory = category;
    }
    
    self.currentScore = score;
    self.currentChannel = channel;
    
    self.reviews = nil;
    [self getReviewsWithRange:NSMakeRange(1, self.currentNumPerPage)];
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.reviews count]) {
        return GENERAL_CELL_HEIGHT;
    } else {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        return cell.frame.size.height;
    }
                                                            
    return GENERAL_CELL_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == [self.reviews count]) {
        [self getReviewsWithRange:NSMakeRange(self.currentPageNum, self.currentNumPerPage)];
        return;
    }
    
    NSDictionary *review = [self.reviews objectAtIndex:indexPath.row];
    BOOL isReview = [[review objectForKey:@"Title"] length] > 0;
    CommentDetailViewController *commentReviewDetailController = [[CommentDetailViewController alloc] initWithIsReview:isReview];
    if (isReview) {
        commentReviewDetailController.reviewId = [review objectForKey:@"Id"];
    } else {
        commentReviewDetailController.bookId = [review objectForKey:@"BookId"] ? [review objectForKey:@"BookId"] : self.bookId;
        commentReviewDetailController.authorId = [[review objectForKey:@"Author"] objectForKey:@"Id"];
    }
    
    commentReviewDetailController.bookTitle = [review objectForKey:@"BookTitle"];
    commentReviewDetailController.bookCategory = [review objectForKey:@"BookCategory"];
    
    [self pushViewController:commentReviewDetailController hideBottomBar:YES];
    
    return;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    NSInteger num = 0;
    
    if (self.reviews) {
        num = [self.reviews count] + 1;
    } else {
        num = 1;
    }
    
    if ([self.reviews count] == self.itemSum) {
        num--;
    }
    
    return num;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == [self.reviews count]) {
        static NSString *CellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                            reuseIdentifier:CellIdentifier];
        }
        
        cell.textLabel.text = @"点击加载更多";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = MEDIUM_FONT;
        
        return cell;
    } else {
        static NSString *CellIdentifier1 = @"Cell1";
        CommentReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier1];
        
        if (cell == nil) {
            cell = [[CommentReviewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier1];
        }
        if (self.bookId) {
            cell.showBookInfo = NO;
        } else {
            cell.showBookInfo = YES;
        }
        cell.showMegaInfo = YES;
        cell.comment = [self.reviews objectAtIndex:indexPath.row];
        
        return cell;
    }
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
