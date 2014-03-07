//
//  CommentDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-3-7.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "CommentDetailViewController.h"
#import "SPLoadingView.h"
#import "NetworkClient.h"
#import "CommentReviewView.h"

@interface CommentDetailViewController ()

@property (nonatomic, strong) UIScrollView *container;
@property (nonatomic, strong) SPLoadingView *loadingView;
@property (nonatomic, strong) CommentReviewView *crView;
@property (nonatomic, strong) UITableView *mainTable;

@property (nonatomic, assign) BOOL isReview;

@property (nonatomic, strong) NSDictionary *reviewDetail;

@property (nonatomic, strong) CommentReviewView *reviewDetailInfoView;

@end

@implementation CommentDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithIsReview:(BOOL)isReview
{
    self = [super init];
    if (self) {
        // Custom initialization
        self.isReview = isReview;
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
    
    self.container = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.container];
    
    self.crView = [[CommentReviewView alloc] initWithFrame:self.view.bounds];
    self.crView.showBookInfo = NO;
    self.crView.showMegaInfo = YES;
    self.crView.isDetailMode = YES;
    
    [self.container addSubview:self.crView];
    
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                   self.crView.frame.size.height,
                                                                   self.view.bounds.size.width,
                                                                   GENERAL_CELL_HEIGHT * 3)
                                                  style:UITableViewStylePlain];
    self.mainTable.delegate = self;
    self.mainTable.dataSource = self;
    self.mainTable.scrollEnabled = NO;
    [self.container addSubview:self.mainTable];
    
    [self updateContainerContentSize];

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

- (void)updateContainerContentSize
{
    self.container.contentSize = CGSizeMake(self.view.bounds.size.width, self.crView.calculatedHeight + self.mainTable.frame.size.height);
}

#pragma mark - Event handler
- (void)didGetDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_REVIEW_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_COMMENT_DETAIL object:nil];
    
    [self.loadingView hide];
    
    self.reviewDetail = [[notification userInfo] objectForKey:@"data"];
    self.crView.comment = self.reviewDetail;
    self.crView.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.crView.calculatedHeight);
    
    self.mainTable = [[UITableView alloc] initWithFrame:CGRectMake(0.0,
                                                                   self.crView.frame.size.height,
                                                                   self.view.bounds.size.width,
                                                                   GENERAL_CELL_HEIGHT * 3)
                                                  style:UITableViewStylePlain];
    [self.mainTable reloadData];
    
    [self updateContainerContentSize];
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
    if (section == 0) {
        return GENERAL_HEADER_HEIGHT;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return GENERAL_CELL_HEIGHT;
        case 1:
            return self.crView.calculatedHeight;
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
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
        case 1:
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

@end
