//
//  CommentReviewDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-6.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CommentReviewDetailViewController.h"
#import "SPLoadingView.h"
#import "NetworkClient.h"
#import "CommentReviewView.h"

@interface CommentReviewDetailViewController ()

@property (nonatomic, strong) SPLoadingView *loadingView;
@property (nonatomic, strong) CommentReviewView *crView;
@property (nonatomic, assign) BOOL isReview;

@property (nonatomic, strong) NSDictionary *reviewDetail;

@property (nonatomic, strong) CommentReviewView *reviewDetailInfoView;

@end

@implementation CommentReviewDetailViewController

- (id)initWithStyle:(UITableViewStyle)style isReview:(BOOL)isReview
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.isReview = isReview;
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
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self getCommentReviewDetail];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 
- (void)getCommentReviewDetail
{
    self.loadingView = [[SPLoadingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.loadingView show];
    
    if (self.isReview) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDetail:) name:MSG_DID_GET_REVIEW_DETAIL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetDetail:) name:MSG_FAIL_GET_REVIEW_DETAIL object:nil];
        
        [[NetworkClient sharedNetworkClient] getReviewDetailById:self.reviewId];
    } else {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetDetail:) name:MSG_DID_GET_COMMENT_DETAIL object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetDetail:) name:MSG_FAIL_GET_COMMENT_DETAIL object:nil];
        
        [[NetworkClient sharedNetworkClient] getCommentDetailByBookId:self.bookId authorId:self.authorId];
    }
}

#pragma mark - Event handler
- (void)didGetDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_REVIEW_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_COMMENT_DETAIL object:nil];
    
    [self.loadingView hide];
    
    self.reviewDetail = [[notification userInfo] objectForKey:@"data"];
    self.crView.comment = self.reviewDetail;
    self.crView.frame = CGRectMake(self.crView.frame.origin.x,
                                   self.crView.frame.origin.y,
                                   self.crView.frame.size.width,
                                   self.crView.calculatedHeight);
    
    [self.tableView reloadData];
}

- (void)failGetDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_REVIEW_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_COMMENT_DETAIL object:nil];
    
    [self.loadingView hide];
    
    NSLog(@"%@", [notification userInfo]);
}

- (void)handleError:(NSNotification *)notification
{
    [self.loadingView hide];
    
    NSLog(@"%@", [notification userInfo]);
}

#pragma mark - Table view delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return GENERAL_HEADER_HEIGHT;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return self.crView.calculatedHeight;
        case 1:
            return GENERAL_CELL_HEIGHT;
        default:
            return GENERAL_CELL_HEIGHT;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
        case 2:
            return 1;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                if (self.crView == nil) {
                    self.crView = [[CommentReviewView alloc] initWithFrame:cell.bounds];
                    [cell addSubview:self.crView];
                }
            }
            
            self.crView.comment = self.reviewDetail;
            self.crView.showBookInfo = YES;
            self.crView.showMegaInfo = YES;
            self.crView.isDetailMode = YES;
            cell.frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.crView.calculatedHeight);
            
            return cell;
        }
        case 1:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 8.0, cell.bounds.size.width - 50, 20)];
                titleLabel.text = self.bookTitle;
                titleLabel.font = MEDIUM_FONT;
                [cell addSubview:titleLabel];
                
                UILabel *categoryLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0,
                                                                                   cell.bounds.size.height - TextHeightWithFont(SMALL_FONT) + 5,
                                                                                   cell.bounds.size.width - 50,
                                                                                   TextHeightWithFont(SMALL_FONT))];
                categoryLabel.text = self.bookCategory;
                categoryLabel.font = SMALL_FONT;
                categoryLabel.textColor = UIC_BRIGHT_GRAY(0.5);
                [cell addSubview:categoryLabel];
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            return cell;
        }
        case 2:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            return cell;
        }
        default:
            return nil;
            break;
    }
    return nil;
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
