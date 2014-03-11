//
//  BookDetailViewController.m
//  shanpowmobileios
//
//  Created by Marvin Gu on 14-2-20.
//  Copyright (c) 2014年 木一. All rights reserved.
//

#import "BookDetailViewController.h"
#import "AMRatingControl.h"
#import "SPLabel.h"
#import "BooklistListViewController.h"
#import "UserProfileViewController.h"
#import "RightSubtitleCell.h"
#import "CommentDetailViewController.h"

@interface BookDetailViewController ()

@property (nonatomic, strong) NSArray *relatedInfoSectionItems;
@property (nonatomic, strong) NSDictionary *bookInfo;

@property (nonatomic, strong) SPLoadingView *loadingView;

@property (nonatomic, assign) float generalMargin;
@property (nonatomic, assign) float generalCellHeight;
@property (nonatomic, assign) float generalHeaderHeight;
@property (nonatomic, assign) float commentCellHeight;
@property (nonatomic, assign) float reviewCellHeight;

#pragma mark - Section 0
@property (nonatomic, strong) UILabel *bookTitleLabel;
@property (nonatomic, strong) AMRatingControl *ratingStar;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *ratingSumLabel;
@property (nonatomic, strong) UILabel *authorTitleLabel;
@property (nonatomic, strong) UILabel *authorLabel;
@property (nonatomic, strong) UILabel *statusTitleLabel;
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *wordCountTitleLabel;
@property (nonatomic, strong) UILabel *wordCountLabel;
@property (nonatomic, strong) UILabel *categoryTitleLabel;
@property (nonatomic, strong) UILabel *categoryLabel;
@property (nonatomic, strong) UILabel *lastUpdateTitleLabel;
@property (nonatomic, strong) UILabel *lastUpdateLabel;
@property (nonatomic, strong) UIView *section0Divider;
@property (nonatomic, strong) UILabel *summaryLabel;

@property (nonatomic, strong) AwesomeMenu *actionMenu;
@property (nonatomic, strong) AwesomeMenuItem *mainItem;
@property (nonatomic, strong) AwesomeMenuItem *ratingItem;
@property (nonatomic, strong) AwesomeMenuItem *shareItem;
@property (nonatomic, strong) AwesomeMenuItem *addToBooklistItem;

@end

@implementation BookDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.relatedInfoSectionItems = @[@"本书作者还写过", @"喜欢这本书的人还喜欢", @"收录这本书的书单"];
        self.bookId = @"";
        self.generalMargin = 10.0;
        self.generalCellHeight = 50.0;
        self.generalHeaderHeight = 40.0;
        self.commentCellHeight = 140.0;
        self.reviewCellHeight = 155.0;
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
//    self.title = @"书籍详细信息";
    
    if (IsSysVerGTE(7.0)) {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    UIImage *starImage = [UIImage imageNamed:@"icon-star"];
    UIImage *shareImage = [UIImage imageNamed:@"icon-share"];
    UIImage *addImage = [UIImage imageNamed:@"icon-plus"];
    self.ratingItem = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:starImage
                                                    highlightedContentImage:nil];
    self.shareItem = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                           highlightedImage:storyMenuItemImagePressed
                                                               ContentImage:shareImage
                                                    highlightedContentImage:nil];
    self.addToBooklistItem = [[AwesomeMenuItem alloc] initWithImage:storyMenuItemImage
                                                   highlightedImage:storyMenuItemImagePressed
                                                       ContentImage:addImage
                                            highlightedContentImage:nil];
    // the start item, similar to "add" button of Path
    self.mainItem = [[AwesomeMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton"]
                                                       highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted"]
                                                           ContentImage:[UIImage imageNamed:@"icon-plus"]
                                                highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted"]];
    
    self.actionMenu = [[AwesomeMenu alloc] initWithFrame:[UIScreen mainScreen].bounds
                                                 startItem:self.mainItem
                                               optionMenus:@[self.ratingItem, self.addToBooklistItem]];
    self.actionMenu.delegate = self;
    self.actionMenu.menuWholeAngle = M_PI / 3;
    self.actionMenu.startPoint = CGPointMake(40.0, [UIScreen mainScreen].bounds.size.height);
    self.actionMenu.animationDuration = 0.4;
    self.actionMenu.endRadius = 100.0;
    self.actionMenu.farRadius = 110.0;
    self.actionMenu.nearRadius = 95.0;
    self.actionMenu.rotateAngle = M_PI / 12;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cmtUserTapped:) name:MSG_TAPPED_NICKNAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleError:) name:MSG_ERROR object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isLogin()) {
        [self.view.window addSubview:self.actionMenu];
        
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.actionMenu.frame = CGRectMake(0.0,
                                                                [UIScreen mainScreen].bounds.origin.y - 50.0,
                                                                [UIScreen mainScreen].bounds.size.width,
                                                                [UIScreen mainScreen].bounds.size.height);
                         }];
    }
    
    if (self.bookId.length > 0) {
        [self getBookDetail];
    }
    
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (isLogin()) {
        [UIView animateWithDuration:0.2
                         animations:^{
                             self.actionMenu.frame = [UIScreen mainScreen].bounds;
                         }
                         completion:^(BOOL finished) {
                             [self.actionMenu removeFromSuperview];
                         }];
    }
    
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setBookInfo:(NSDictionary *)bookInfo
{
    if (![_bookInfo isEqualToDictionary:bookInfo]) {
        _bookInfo = bookInfo;
        
        [self updateBookInfo];
        
        [self.tableView reloadData];
    }
}

- (void)getBookDetail
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didGetBookDetail:) name:MSG_DID_GET_BOOK_DETAIL object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failGetBookDetail:) name:MSG_FAIL_GET_BOOK_DETAIL object:nil];
    
    self.loadingView = [[SPLoadingView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.loadingView show];
    
    [[NetworkClient sharedNetworkClient] getBookDetail:self.bookId];
}

#pragma mark - UI related

-(void)updateBookInfo
{
    [self updateBookBasicInfoLayout];
    [self updateBookBasicInfoData];
}

- (void)initBookBasicInfoLabels
{
    if (!self.bookTitleLabel)
    {
        self.bookTitleLabel = [[UILabel alloc] init];
        self.bookTitleLabel.font = LARGE_BOLD_FONT;
    }
    
    if (!self.ratingStar)
    {
        self.ratingStar = [[AMRatingControl alloc] initWithLocation:CGPointZero
                                                         emptyImage:[UIImage imageNamed:@"Star_Gray_Small"]
                                                         solidImage:[UIImage imageNamed:@"Star_Red_Small"]
                                                       andMaxRating:5];
        self.ratingStar.starWidthAndHeight = StarSize(@"Star_Red_Small");
        self.ratingStar.starSpacing = 1.0;
    }
    
    if (!self.scoreLabel)
    {
        self.scoreLabel = [[UILabel alloc] init];
        self.scoreLabel.font = MEDIUM_FONT;
    }
    
    if (!self.ratingSumLabel)
    {
        self.ratingSumLabel = [[UILabel alloc] init];
        self.ratingSumLabel.font = MEDIUM_FONT;
    }
    
    if (!self.authorTitleLabel)
    {
        self.authorTitleLabel = [[UILabel alloc] init];
        self.authorTitleLabel.font = MEDIUM_FONT;
    }
    
    if (!self.authorLabel)
    {
        self.authorLabel = [[UILabel alloc] init];
        self.authorLabel.font = MEDIUM_FONT;
        self.authorLabel.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnLabel:)];
        [self.authorLabel addGestureRecognizer:longPressRecognizer];
    }
    
    if (!self.statusTitleLabel)
    {
        self.statusTitleLabel = [[UILabel alloc] init];
        self.statusTitleLabel.font = MEDIUM_FONT;
    }
    
    if (!self.statusLabel)
    {
        self.statusLabel = [[UILabel alloc] init];
        self.statusLabel.font = MEDIUM_FONT;
    }
    
    if (!self.wordCountTitleLabel)
    {
        self.wordCountTitleLabel = [[UILabel alloc] init];
        self.wordCountTitleLabel.font = MEDIUM_FONT;
    }
    
    if (!self.wordCountLabel)
    {
        self.wordCountLabel = [[UILabel alloc] init];
        self.wordCountLabel.font = MEDIUM_FONT;
    }
    
    if (!self.categoryTitleLabel)
    {
        self.categoryTitleLabel = [[UILabel alloc] init];
        self.categoryTitleLabel.font = MEDIUM_FONT;
    }
    
    if (!self.categoryLabel)
    {
        self.categoryLabel = [[UILabel alloc] init];
        self.categoryLabel.font = MEDIUM_FONT;
        self.categoryLabel.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOnLabel:)];
        [self.categoryLabel addGestureRecognizer:longPressRecognizer];
    }
    
    if (!self.lastUpdateTitleLabel)
    {
        self.lastUpdateTitleLabel = [[UILabel alloc] init];
        self.lastUpdateTitleLabel.font = MEDIUM_FONT;
    }
    
    if (!self.lastUpdateLabel)
    {
        self.lastUpdateLabel = [[UILabel alloc] init];
        self.lastUpdateLabel.font = MEDIUM_FONT;
    }
    
    if (!self.section0Divider)
    {
        self.section0Divider = [[UIView alloc] init];
    }
    
    if (!self.summaryLabel)
    {
        self.summaryLabel = [[UILabel alloc] init];
        self.summaryLabel.font = MEDIUM_FONT;
    }
}

- (void)updateBookBasicInfoLayout
{
    float segmentMargin = self.generalMargin * 1.5;
    
    // First Segment
    self.bookTitleLabel.frame = CGRectMake(self.generalMargin, segmentMargin, self.view.frame.size.width - 20.0, 20.0);
    
    // Second Segment
    self.ratingStar.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                       self.bookTitleLabel.frame.origin.y + self.bookTitleLabel.frame.size.height + segmentMargin,
                                       5 * StarSize(@"Star_Red_Small") + 4,
                                       StarSize(@"Star_Red_Small"));
    
    self.scoreLabel.frame = CGRectMake(self.ratingStar.frame.origin.x + self.ratingStar.frame.size.width + self.generalMargin,
                                       self.ratingStar.frame.origin.y - ABS(StarSize(@"Star_Red_Small") - TextHeightWithFont(MEDIUM_FONT)) / 2,
                                       50.0,
                                       TextHeightWithFont(self.scoreLabel.font));
    
    self.ratingSumLabel.frame = CGRectMake(self.scoreLabel.frame.origin.x + self.scoreLabel.frame.size.width + self.generalMargin,
                                           self.scoreLabel.frame.origin.y,
                                           self.view.frame.size.width - self.ratingStar.frame.size.width - self.scoreLabel.frame.size.width - self.generalMargin * 3,
                                           TextHeightWithFont(self.ratingSumLabel.font));
    
    // Third Segment
    self.authorTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                             self.ratingStar.frame.origin.y + self.ratingStar.frame.size.height + segmentMargin,
                                             50.0,
                                             TextHeightWithFont(self.authorTitleLabel.font));
    
    self.authorLabel.frame = CGRectMake(self.authorTitleLabel.frame.size.width + self.authorTitleLabel.frame.origin.x,
                                        self.authorTitleLabel.frame.origin.y,
                                        [self.authorLabel.text sizeWithFont:MEDIUM_FONT].width,
                                        TextHeightWithFont(self.authorLabel.font));
    self.authorLabel.textColor = UIC_CERULEAN(1.0);
    self.authorLabel.highlightedTextColor = UIC_CYAN(1.0);
    
    self.statusTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                             self.authorTitleLabel.frame.origin.y + self.authorTitleLabel.frame.size.height + self.generalMargin,
                                             50.0,
                                             TextHeightWithFont(self.statusTitleLabel.font));
    
    self.statusLabel.frame = CGRectMake(self.statusTitleLabel.frame.origin.x + self.statusTitleLabel.frame.size.width,
                                        self.statusTitleLabel.frame.origin.y,
                                        self.view.frame.size.width - self.statusTitleLabel.frame.size.width - self.generalMargin * 2,
                                        TextHeightWithFont(self.statusLabel.font));
    
    self.wordCountTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                                self.statusTitleLabel.frame.origin.y + self.statusTitleLabel.frame.size.height + self.generalMargin,
                                                50.0,
                                                TextHeightWithFont(self.wordCountTitleLabel.font));
    
    self.wordCountLabel.frame = CGRectMake(self.wordCountTitleLabel.frame.origin.x + self.wordCountTitleLabel.frame.size.width,
                                           self.wordCountTitleLabel.frame.origin.y,
                                           self.view.frame.size.width - self.wordCountTitleLabel.frame.size.width - self.generalMargin * 2,
                                           TextHeightWithFont(self.wordCountLabel.font));
    
    self.categoryTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                               self.wordCountTitleLabel.frame.origin.y + self.wordCountTitleLabel.frame.size.height + self.generalMargin,
                                               50.0,
                                               TextHeightWithFont(self.categoryTitleLabel.font));
    
    self.categoryLabel.frame = CGRectMake(self.categoryTitleLabel.frame.origin.x + self.categoryTitleLabel.frame.size.width,
                                          self.categoryTitleLabel.frame.origin.y,
                                          [self.categoryLabel.text sizeWithFont:MEDIUM_FONT].width,
                                          TextHeightWithFont(self.categoryLabel.font));
    self.categoryLabel.textColor = UIC_CERULEAN(1.0);
    self.categoryLabel.highlightedTextColor = UIC_CYAN(1.0);
    
    self.lastUpdateTitleLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                                 self.categoryTitleLabel.frame.origin.y + self.categoryTitleLabel.frame.size.height + self.generalMargin,
                                                 115.0,
                                                 TextHeightWithFont(self.lastUpdateTitleLabel.font));
    
    self.lastUpdateLabel.frame = CGRectMake(self.lastUpdateTitleLabel.frame.origin.x + self.lastUpdateTitleLabel.frame.size.width,
                                            self.lastUpdateTitleLabel.frame.origin.y,
                                            self.view.frame.size.width - self.lastUpdateTitleLabel.frame.size.width - self.generalMargin * 2,
                                            TextHeightWithFont(self.lastUpdateLabel.font));
    
    // Fourth Segment
    self.section0Divider.frame = CGRectMake(0.0,
                                            self.lastUpdateTitleLabel.frame.origin.y + self.lastUpdateTitleLabel.frame.size.height + segmentMargin,
                                            self.view.frame.size.width,
                                            IsSysVerGTE(7.0) ? 0.5 : 1.0);
    self.section0Divider.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Dot"]];
    self.section0Divider.alpha = 0.5;
    
    // Fifth Segment
    self.summaryLabel.frame = CGRectMake(self.bookTitleLabel.frame.origin.x,
                                         self.section0Divider.frame.origin.y + self.section0Divider.frame.size.height + segmentMargin,
                                         self.view.frame.size.width - self.bookTitleLabel.frame.origin.x * 2,
                                         TextHeightWithFont(self.summaryLabel.font) * 7);
    self.summaryLabel.numberOfLines = 7;
}

- (void)pushWriteReviewView
{
    WriteCommentReviewViewController *wcrController = [[WriteCommentReviewViewController alloc] init];
    wcrController.bookId = self.bookId;
    wcrController.bookTitle = self.bookTitleLabel.text;
    wcrController.bookImageUrl = [self.bookInfo objectForKey:@"ImageUrl"];
    wcrController.bookCategory = self.categoryLabel.text;
    
    [self pushViewController:wcrController];
}

- (void)pushAddToBooklistView
{
    AddToBooklistViewController *atbController = [[AddToBooklistViewController alloc] init];
    atbController.bookIdToAdd = self.bookId;
    
    [self pushViewController:atbController];
}

#pragma mark - Data related

- (void)updateBookBasicInfoData
{
    self.bookTitleLabel.text = [self.bookInfo objectForKey:@"Title"];
    [self.ratingStar setRating:[[self.bookInfo objectForKey:@"Score"] integerValue] / 2];
    self.scoreLabel.text = [NSString stringWithFormat:@"%@ 分", [self.bookInfo objectForKey:@"Score"]];
    self.ratingSumLabel.text = [NSString stringWithFormat:@"（%@ 人评分）", [self.bookInfo objectForKey:@"ScoreSum"]];
    self.authorTitleLabel.text = @"作者：";
    self.authorLabel.text = [self.bookInfo objectForKey:@"Author"];
    self.statusTitleLabel.text = @"状态：";
    self.statusLabel.text = [self.bookInfo objectForKey:@"Status"];
    self.wordCountTitleLabel.text = @"字数：";
    self.wordCountLabel.text = [self.bookInfo objectForKey:@"WordCount"];
    self.categoryTitleLabel.text = @"类型：";
    self.categoryLabel.text = [self.bookInfo objectForKey:@"Category"];
    self.lastUpdateTitleLabel.text = @"最近更新时间：";
    self.lastUpdateLabel.text = [self.bookInfo objectForKey:@"LastUpdateDate"];
    self.summaryLabel.text = [NSString stringWithFormat:@"%@\n\n\n\n\n\n\n", [self.bookInfo objectForKey:@"Summary"]];
    
    self.title = [self.bookInfo objectForKey:@"Title"];
}

#pragma mark - Event handler

- (void)didGetBookDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_DID_GET_BOOK_DETAIL object:nil];
    
    [self.loadingView hide];
    
    self.bookInfo = [[notification userInfo] objectForKey:@"data"];
}

- (void)failGetBookDetail:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MSG_FAIL_GET_BOOK_DETAIL object:nil];
}

- (void)handleError:(NSNotification *)notification
{
    [self.loadingView hide];
}

- (void)longPressOnLabel:(UIGestureRecognizer *)sender
{
    [sender.view becomeFirstResponder];

    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (![menu isMenuVisible]) {
        [menu setTargetRect:sender.view.frame inView:sender.view.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (void)cmtUserTapped:(NSNotification *)notification
{
    NSString *nickname = [[notification userInfo] objectForKey:@"nickname"];
    NSString *userId = [[notification userInfo] objectForKey:@"Id"];
    
    UserProfileViewController *userProfileController = [[UserProfileViewController alloc] initWithUsername:nickname];
    userProfileController.isSelf = NO;
    userProfileController.userId = userId;
    
    self.hidesBottomBarWhenPushed = YES;
    [self pushViewController:userProfileController];
    self.hidesBottomBarWhenPushed = NO;
}

#pragma mark - Awesome Menu delegate
- (void)awesomeMenu:(AwesomeMenu *)menu didSelectIndex:(NSInteger)idx;
{
    switch (idx) {
        case 0:
        {
            [self pushWriteReviewView];
            break;
        }
        case 1:
        {
            [self pushAddToBooklistView];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 410.0;
            break;
        case 3:
            if ([self.bookInfo objectForKey:@"Comments"] != [NSNull null]) {
                if (indexPath.row < 5) {
                    return self.commentCellHeight;
                } else {
                    return self.generalCellHeight + 10;
                }
            }
            break;
        case 4:
            if ([self.bookInfo objectForKey:@"Reviews"] != [NSNull null]) {
                if (indexPath.row < 5) {
                    return self.reviewCellHeight;
                } else {
                    return self.generalCellHeight + 10;
                }
            }
            break;
        default:
            return GENERAL_CELL_HEIGHT;
            break;
    }
    return self.generalCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 3 || section == 4) {
        return self.generalHeaderHeight;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header = [[UIView alloc] init];
    header.backgroundColor = UIC_WHISPER(1.0);
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.bounds.size.width - 20, self.generalHeaderHeight)];
    title.backgroundColor = [UIColor clearColor];
    title.font = MEDIUM_FONT;
    
    UILabel *sum = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - 10.0 - [[[self.bookInfo objectForKey:@"CommentSum"] stringValue] sizeWithFont:MEDIUM_FONT].width, 0.0, [[[self.bookInfo objectForKey:@"CommentSum"] stringValue] sizeWithFont:MEDIUM_FONT].width, self.generalHeaderHeight)];
    sum.backgroundColor = [UIColor clearColor];
    sum.font = MEDIUM_FONT;
    sum.textColor = UIC_BRIGHT_GRAY(0.5);
    
    switch (section) {
        case 3:
            title.text = @"一句话评论";
            sum.text = [[self.bookInfo objectForKey:@"CommentSum"] stringValue];
            break;
        case 4:
            title.text = @"书评";
            sum.text = [[self.bookInfo objectForKey:@"ReviewSum"] stringValue];
            break;
        default:
            break;
    }
    
    [header addSubview:sum];
    [header addSubview:title];
    
    return header;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 2:
        {
            switch (indexPath.row) {
                case 2:
                {
                    BooklistListViewController *booklistsController = [[BooklistListViewController alloc] init];
                    booklistsController.title = @"包含本书的书单";
                    booklistsController.dataSource = BLDS_ContainBook;
                    booklistsController.bookId = self.bookId;
                    
                    self.hidesBottomBarWhenPushed = YES;
                    [self pushViewController:booklistsController];
                    self.hidesBottomBarWhenPushed = NO;
                    
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 3:
        {
            if (indexPath.row == 0 && [self.bookInfo objectForKey:@"Comments"] == [NSNull null]) {
                [self pushWriteReviewView];
            } else {
                if (indexPath.row < 5) {
                    CommentDetailViewController *commentDetailController = [[CommentDetailViewController alloc] initWithIsReview:NO];
                    commentDetailController.bookId = self.bookId;
                    commentDetailController.authorId = [[[[self.bookInfo objectForKey:@"Comments"] objectAtIndex:indexPath.row] objectForKey:@"Author"] objectForKey:@"Id"];
                    
                    [self pushViewController:commentDetailController];
                }
            }
            break;
        }
        case 4:
        {
            if (indexPath.row == 0 && [self.bookInfo objectForKey:@"Reviews"] == [NSNull null]) {
                [self pushWriteReviewView];
            } else {
                if (indexPath.row < 5) {
                    CommentDetailViewController *commentDetailController = [[CommentDetailViewController alloc] initWithIsReview:YES];
                    commentDetailController.reviewId = [[[self.bookInfo objectForKey:@"Reviews"] objectAtIndex:indexPath.row] objectForKey:@"Id"];
                    commentDetailController.bookTitle = self.bookTitleLabel.text;
                    commentDetailController.bookCategory = [self.bookInfo objectForKey:@"Category"];
                    
                    [self pushViewController:commentDetailController];
                }
            }
            
            break;
        }
        default:
            break;
    }
    
    return;
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 3:
            return @"一句话评论";
            break;
        case 4:
            return @"书评";
            break;
        default:
            break;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if (!self.bookInfo) {
        return 0;
    }
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 1:
            return 0;
            break;
        case 2:
            return 3;
            break;
        case 3:
        {
            NSArray *comments = [self.bookInfo objectForKey:@"Comments"];
            if ([self.bookInfo objectForKey:@"Comments"] != [NSNull null]) {
                if ([[self.bookInfo objectForKey:@"CommentSum"] integerValue] > 5) {
                    return 6;
                } else {
                    return [comments count];
                }
            } else {
                return 1;
            }
        }
            break;
        case 4:
        {
            NSArray *reviews = [self.bookInfo objectForKey:@"Reviews"];
            if ([self.bookInfo objectForKey:@"Reviews"] != [NSNull null]) {
                return [[self.bookInfo objectForKey:@"ReviewSum"] integerValue] > 5 ? 6 : [reviews count];
            } else {
                return 1;
            }
        }
            break;
        default:
            return 1;
            break;
    }
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"Section0Cell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                [self initBookBasicInfoLabels];
                [self updateBookBasicInfoLayout];
                [self updateBookBasicInfoData];
                
                // Add label to cell
                [cell addSubview:self.bookTitleLabel];
                [cell addSubview:self.ratingStar];
                [cell addSubview:self.scoreLabel];
                [cell addSubview:self.ratingSumLabel];
                [cell addSubview:self.authorTitleLabel];
                [cell addSubview:self.authorLabel];
                [cell addSubview:self.statusTitleLabel];
                [cell addSubview:self.statusLabel];
                [cell addSubview:self.wordCountTitleLabel];
                [cell addSubview:self.wordCountLabel];
                [cell addSubview:self.categoryTitleLabel];
                [cell addSubview:self.categoryLabel];
                [cell addSubview:self.lastUpdateTitleLabel];
                [cell addSubview:self.lastUpdateLabel];
                [cell addSubview:self.section0Divider];
                [cell addSubview:self.summaryLabel];
            }
            
            return  cell;
        }
            break;
        case 2:
        {
            static NSString *CellIdentifier = @"Section1Cell";
            
            RightSubtitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[RightSubtitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            }
            
            NSArray *numKeys = @[@"AuthorBookSum", @"SimilarBookSum", @"BooklistContainThisBookSum"];
            NSString *text = [NSString stringWithFormat:@"%d", [[self.bookInfo objectForKey:[numKeys objectAtIndex:indexPath.row]] integerValue]];
            
            cell.title = [self.relatedInfoSectionItems objectAtIndex:indexPath.row];
            cell.rightTitle = [text isEqualToString:@"0"] ? @"" : text;
            
            return cell;
        }
            break;
        case 3:
        {
            if ([self.bookInfo objectForKey:@"Comments"] != [NSNull null]) {
                if (indexPath.row <= 4) {
                    static NSString *CellIdentifier = @"Section31Cell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        
                        CommentReviewView *crView = [[CommentReviewView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.commentCellHeight)];
                        crView.comment = [[self.bookInfo objectForKey:@"Comments"] objectAtIndex:indexPath.row];
                        [cell addSubview:crView];
                    }
                    
                    return cell;
                } else {
                    static NSString *CellIdentifier = @"Section32Cell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        
                        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.bounds.size.width, 50.0)];
                        titleLabel.font = MEDIUM_FONT;
                        titleLabel.backgroundColor = [UIColor clearColor];
                        titleLabel.text = @"查看更多一句话评论";
                        titleLabel.textAlignment = NSTextAlignmentCenter;
                        [cell addSubview:titleLabel];
                    }
                    
                    return cell;
                }
            } else {
                static NSString *CellIdentifier = @"Section30Cell";
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    
                    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"暂时还没有评论\n（第一个来写评论）"]
                                                                                                    attributes:@{}];
                    [titleString addAttributes:@{
                                                 NSFontAttributeName: SMALL_FONT
                                                 }
                                         range:[titleString.string rangeOfString:@"（第一个来写评论）"]];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.bounds.size.width, 50.0)];
                    titleLabel.font = MEDIUM_FONT;
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.attributedText = titleString;
                    titleLabel.numberOfLines = 2;
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = UIC_BRIGHT_GRAY(0.5);
                    [cell addSubview:titleLabel];
                }
                
                return cell;
            }
        }
            break;
        case 4:
        {
            if ([self.bookInfo objectForKey:@"Reviews"] != [NSNull null]) {
                if (indexPath.row <= 4) {
                    static NSString *CellIdentifier = @"Section41Cell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        
                        CommentReviewView *crView = [[CommentReviewView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, self.reviewCellHeight)];
                        crView.comment = [[self.bookInfo objectForKey:@"Reviews"] objectAtIndex:indexPath.row];
                        [cell addSubview:crView];
                    }
                    
                    return cell;
                } else {
                    static NSString *CellIdentifier = @"Section42Cell";
                    
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                    
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                        
                        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.bounds.size.width, 50.0)];
                        titleLabel.font = MEDIUM_FONT;
                        titleLabel.backgroundColor = [UIColor clearColor];
                        titleLabel.text = @"查看更多书评";
                        [cell addSubview:titleLabel];
                    }
                    
                    return cell;
                }
            } else {
                static NSString *CellIdentifier = @"Section40Cell";
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                    
                    NSMutableAttributedString *titleString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"暂时还没有书评\n（第一个来写书评）"]
                                                                                                    attributes:@{}];
                    [titleString addAttributes:@{
                                                 NSFontAttributeName: SMALL_FONT
                                                 }
                                         range:[titleString.string rangeOfString:@"（第一个来写书评）"]];
                    
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, self.view.bounds.size.width, 50.0)];
                    titleLabel.font = MEDIUM_FONT;
                    titleLabel.backgroundColor = [UIColor clearColor];
                    titleLabel.attributedText = titleString;
                    titleLabel.numberOfLines = 2;
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    titleLabel.textColor = UIC_BRIGHT_GRAY(0.5);
                    [cell addSubview:titleLabel];
                }
                
                return cell;
            }
        }
            break;
        default:
        {
            static NSString *CellIdentifier = @"SectionCell";
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
            
            return cell;
        }
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
